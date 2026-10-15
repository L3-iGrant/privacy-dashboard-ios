//
//  BBConsentTokenStore.swift
//  PrivacyDashboardiOS
//

import Foundation

// Keeps the individual access token in memory only. The token comes from the
// token provider of the host app. The store asks the provider again when the
// token is less than `refreshMargin` seconds from expiry, or after the
// server refused the token (`invalidate`).
final class BBConsentTokenStore: @unchecked Sendable {
    typealias Provider = (@escaping (Result<String, Error>) -> Void) -> Void

    static let shared = BBConsentTokenStore()
    static let refreshMargin: TimeInterval = 60

    // Clock, replaceable in tests.
    var now: () -> Date = Date.init

    private let lock = NSLock()
    private var provider: Provider?
    private var token: String?
    private var expiry: Date?
    private var pending: [(Result<String, Error>) -> Void] = []
    // Changes on each configure and reset, so that the result of an older
    // provider call is not kept.
    private var generation = 0

    var hasProvider: Bool {
        lock.lock(); defer { lock.unlock() }
        return provider != nil
    }

    func configure(provider: @escaping Provider) {
        lock.lock()
        self.provider = provider
        clearLocked()
        lock.unlock()
    }

    func reset() {
        lock.lock()
        provider = nil
        clearLocked()
        lock.unlock()
    }

    // Removes the token if it is still the current token. The next call to
    // `token(completion:)` asks the provider again.
    func invalidate(_ rejected: String) {
        lock.lock()
        if token == rejected {
            token = nil
            expiry = nil
        }
        lock.unlock()
    }

    func token(completion: @escaping (Result<String, Error>) -> Void) {
        lock.lock()
        guard let provider = provider else {
            lock.unlock()
            completion(.failure(PrivacyDashboardError.notConfigured))
            return
        }
        if let token = token, isFreshLocked() {
            lock.unlock()
            completion(.success(token))
            return
        }
        pending.append(completion)
        // A provider call is already in progress: wait for its result.
        if pending.count > 1 {
            lock.unlock()
            return
        }
        let callGeneration = generation
        lock.unlock()

        DispatchQueue.main.async {
            provider { result in
                self.finish(result, generation: callGeneration)
            }
        }
    }

    private func finish(_ result: Result<String, Error>, generation callGeneration: Int) {
        lock.lock()
        guard callGeneration == generation else {
            lock.unlock()
            return
        }
        let checked: Result<String, Error> = result.flatMap { value in
            value.isEmpty ? .failure(PrivacyDashboardError.invalidToken) : .success(value)
        }
        if case .success(let value) = checked {
            token = value
            expiry = BBConsentTokenStore.expiry(ofJWT: value)
        }
        let waiting = pending
        pending = []
        lock.unlock()
        waiting.forEach { $0(checked) }
    }

    private func isFreshLocked() -> Bool {
        // A token without a readable `exp` is used until the server refuses it.
        guard let expiry = expiry else { return true }
        return expiry.timeIntervalSince(now()) > BBConsentTokenStore.refreshMargin
    }

    private func clearLocked() {
        generation += 1
        token = nil
        expiry = nil
        let waiting = pending
        pending = []
        if !waiting.isEmpty {
            DispatchQueue.main.async {
                waiting.forEach { $0(.failure(PrivacyDashboardError.notConfigured)) }
            }
        }
    }

    // Reads `exp` from the JWT payload. The signature is not verified: the
    // value is used only to know when to ask for a new token.
    static func expiry(ofJWT jwt: String) -> Date? {
        let parts = jwt.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 3 else { return nil }
        var base64 = parts[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }
        guard let data = Data(base64Encoded: base64),
              let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = payload["exp"] as? NSNumber else {
            return nil
        }
        return Date(timeIntervalSince1970: exp.doubleValue)
    }
}
