//
//  BBConsentAuthInterceptor.swift
//  PrivacyDashboardiOS
//

import Foundation
import Alamofire

// Sets the authorisation headers of the SDK API requests.
//
// With a token provider: `Authorization: Bearer <token>` and no
// `X-ConsentBB-IndividualId`. After a 401 the interceptor asks the provider
// for a new token and sends the request again, one time only.
//
// Without a token provider (deprecated API key path): the headers of the
// earlier SDK versions, in the order of `LegacyOrder`.
final class BBConsentAuthInterceptor: RequestInterceptor {
    static let individualIdHeader = "X-ConsentBB-IndividualId"

    enum LegacyOrder {
        // API key and individual id when both are set, else the access token.
        case apiKeyFirst
        // Access token when it is set, else the API key.
        case accessTokenFirst
    }

    private let legacyOrder: LegacyOrder
    private let tokenStore: BBConsentTokenStore

    init(legacyOrder: LegacyOrder, tokenStore: BBConsentTokenStore = .shared) {
        self.legacyOrder = legacyOrder
        self.tokenStore = tokenStore
    }

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        guard tokenStore.hasProvider else {
            BBConsentAuthInterceptor.legacyHeaders(order: legacyOrder).forEach { name, value in
                request.setValue(value, forHTTPHeaderField: name)
            }
            completion(.success(request))
            return
        }
        tokenStore.token { result in
            completion(result.map { token in
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.setValue(nil, forHTTPHeaderField: BBConsentAuthInterceptor.individualIdHeader)
                return request
            })
        }
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard tokenStore.hasProvider,
              request.response?.statusCode == 401,
              request.retryCount == 0,
              let authorization = request.request?.value(forHTTPHeaderField: "Authorization"),
              authorization.hasPrefix("Bearer ") else {
            completion(.doNotRetry)
            return
        }
        tokenStore.invalidate(String(authorization.dropFirst("Bearer ".count)))
        completion(.retry)
    }

    static func legacyHeaders(order: LegacyOrder) -> [String: String] {
        let dashboard = BBConsentPrivacyDashboardiOS.shared
        let apiKey = BBConsentKeyChainUtils.load(key: BBConsentKeyChainUtils.apiKeyAccount).map { String(data: $0, encoding: .utf8) ?? "" }
        switch order {
        case .apiKeyFirst:
            if dashboard.userId != "", let apiKey = apiKey {
                return ["Authorization": "ApiKey \(apiKey)", individualIdHeader: dashboard.userId ?? ""]
            }
            return ["Authorization": "Bearer \(dashboard.accessToken ?? "")"]
        case .accessTokenFirst:
            if let accessToken = dashboard.accessToken, !accessToken.isEmpty {
                return ["Authorization": "Bearer \(accessToken)"]
            }
            if let apiKey = apiKey, !apiKey.isEmpty {
                var headers = ["Authorization": "ApiKey \(apiKey)"]
                if let userId = dashboard.userId, !userId.isEmpty {
                    headers[individualIdHeader] = userId
                }
                return headers
            }
            BBConsentLog.debug("No API key available")
            return [:]
        }
    }

    // Makes a 401 a request error when the request used a provider token, so
    // that `retry` runs. Other status codes are not changed.
    static let validateUnauthorised: DataRequest.Validation = { request, response, _ in
        guard response.statusCode == 401,
              BBConsentTokenStore.shared.hasProvider,
              request?.value(forHTTPHeaderField: "Authorization")?.hasPrefix("Bearer ") == true else {
            return .success(())
        }
        return .failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 401)))
    }
}

// The Alamofire session of the SDK API requests.
enum BBConsentNetwork {
    static var session = Session()
}
