//
//  TestSupport.swift
//  PrivacyDashboardiOSTests
//

import Foundation
import XCTest
import Alamofire
@testable import PrivacyDashboardiOS

// Answers all requests of a URLSession that has this class in `protocolClasses`.
final class StubURLProtocol: URLProtocol {
    private static let lock = NSLock()
    private static var _requests: [URLRequest] = []
    private static var _handler: ((URLRequest) -> (Int, Data))?

    static var requests: [URLRequest] {
        lock.lock(); defer { lock.unlock() }
        return _requests
    }

    static func respond(with handler: @escaping (URLRequest) -> (Int, Data)) {
        lock.lock(); _handler = handler; _requests = []; lock.unlock()
    }

    static func reset() {
        lock.lock(); _handler = nil; _requests = []; lock.unlock()
    }

    static var configuration: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return configuration
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        StubURLProtocol.lock.lock()
        StubURLProtocol._requests.append(request)
        let handler = StubURLProtocol._handler
        StubURLProtocol.lock.unlock()
        let (status, body) = handler?(request) ?? (200, Data("{}".utf8))
        let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

// Counts the calls of a token provider and gives the tokens in order.
final class TokenProviderSpy {
    private let lock = NSLock()
    private var tokens: [String]
    private(set) var calls = 0

    init(tokens: [String]) {
        self.tokens = tokens
    }

    var provider: PrivacyDashboardTokenProvider {
        return { completion in
            self.lock.lock()
            self.calls += 1
            let token = self.tokens.isEmpty ? "" : self.tokens.removeFirst()
            self.lock.unlock()
            completion(.success(token))
        }
    }
}

// In-memory Keychain. Matches items on class, service and account, as the
// Keychain does for generic passwords.
final class FakeKeychain {
    private(set) var items: [[String: Any]] = []
    private let matchKeys = [kSecClass as String, kSecAttrService as String, kSecAttrAccount as String]

    var backend: BBConsentKeychainBackend {
        return BBConsentKeychainBackend(
            add: { query in
                if self.matching(query).isEmpty == false { return errSecDuplicateItem }
                self.items.append(query)
                return errSecSuccess
            },
            copyData: { query in
                guard let item = self.matching(query).first else { return (errSecItemNotFound, nil) }
                return (errSecSuccess, item[kSecValueData as String] as? Data)
            },
            delete: { query in
                let before = self.items.count
                self.items.removeAll { self.matches($0, query) }
                return self.items.count < before ? errSecSuccess : errSecItemNotFound
            })
    }

    func insert(_ item: [String: Any]) {
        items.append(item)
    }

    private func matching(_ query: [String: Any]) -> [[String: Any]] {
        return items.filter { matches($0, query) }
    }

    private func matches(_ item: [String: Any], _ query: [String: Any]) -> Bool {
        for key in matchKeys {
            guard let wanted = query[key] else { continue }
            guard let actual = item[key], "\(actual)" == "\(wanted)" else { return false }
        }
        return true
    }
}

enum TestJWT {
    // An unsigned JWT with the given `exp`. The SDK reads `exp` only for timing.
    static func make(exp: Date?, subject: String = "individual-1") -> String {
        var payload: [String: Any] = ["sub": subject]
        if let exp = exp {
            payload["exp"] = Int(exp.timeIntervalSince1970)
        }
        let header = base64url(try! JSONSerialization.data(withJSONObject: ["alg": "ES256", "typ": "individual+jwt"]))
        let body = base64url(try! JSONSerialization.data(withJSONObject: payload))
        return "\(header).\(body).c2lnbmF0dXJl"
    }

    private static func base64url(_ data: Data) -> String {
        return data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

class SDKTestCase: XCTestCase {
    let baseUrl = "https://consent.example.test/v2"
    let organisationId = "org-1"
    var keychain = FakeKeychain()

    override func setUp() {
        super.setUp()
        keychain = FakeKeychain()
        BBConsentKeyChainUtils.backend = keychain.backend
        _ = BBConsentPrivacyDashboardiOS.shared
        PrivacyDashboard.reset()
        BBConsentTokenStore.shared.now = Date.init
        BBConsentNetwork.session = Session(configuration: StubURLProtocol.configuration)
        StubURLProtocol.reset()
    }

    override func tearDown() {
        PrivacyDashboard.reset()
        BBConsentTokenStore.shared.now = Date.init
        BBConsentNetwork.session = Session()
        StubURLProtocol.reset()
        BBConsentKeyChainUtils.backend = .system
        super.tearDown()
    }

    func makeAPICall(_ method: BBConsentBaseWebService.ApiType = .get) -> (success: Bool, result: [String: Any]) {
        let done = expectation(description: "makeAPICall")
        var outcome: (Bool, [String: Any]) = (false, [:])
        BBConsentBaseWebService.shared.makeAPICall(urlString: Constant.URLStrings.fetchDataAgreement + "da-1", method: method) { success, result in
            outcome = (success, result)
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
        return outcome
    }
}
