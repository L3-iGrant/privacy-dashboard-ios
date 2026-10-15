//
//  BBConsentAuthHeaderTests.swift
//  PrivacyDashboardiOSTests
//

import XCTest
@testable import PrivacyDashboardiOS

final class BBConsentAuthHeaderTests: SDKTestCase {
    private let individualIdHeader = "X-ConsentBB-IndividualId"

    func testTokenModeSendsBearerTokenAndNoIndividualId() {
        let jwt = TestJWT.make(exp: Date().addingTimeInterval(600))
        let spy = TokenProviderSpy(tokens: [jwt])
        PrivacyDashboard.configure(baseUrl: baseUrl, organisationId: organisationId, tokenProvider: spy.provider)
        StubURLProtocol.respond { _ in (200, Data(#"{"dataAgreement":{}}"#.utf8)) }

        let outcome = makeAPICall()

        XCTAssertTrue(outcome.success)
        XCTAssertEqual(StubURLProtocol.requests.count, 1)
        let request = StubURLProtocol.requests[0]
        XCTAssertEqual(request.url?.absoluteString, baseUrl + "/service/data-agreement/da-1")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(jwt)")
        XCTAssertNil(request.value(forHTTPHeaderField: individualIdHeader))
        XCTAssertEqual(spy.calls, 1)
    }

    @available(*, deprecated)
    func testTokenModeIgnoresAnIndividualIdOfAnEarlierApiKeyCall() throws {
        PrivacyDashboard.configure(withApiKey: "test-api-key", withUserId: "user-1", withOrgId: organisationId, withBaseUrl: baseUrl, withLocale: "en")
        let jwt = TestJWT.make(exp: nil)
        PrivacyDashboard.configure(baseUrl: baseUrl, organisationId: organisationId, tokenProvider: TokenProviderSpy(tokens: [jwt]).provider)
        XCTAssertNil(BBConsentKeyChainUtils.load(key: BBConsentKeyChainUtils.apiKeyAccount))

        let service = OrganisationWebService()
        service.baseUrl = baseUrl
        let done = expectation(description: "service call")
        let delegate = ServiceDelegate { done.fulfill() }
        service.delegate = delegate
        service.organization()
        wait(for: [done], timeout: 5)

        let request = try XCTUnwrap(StubURLProtocol.requests.first)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(jwt)")
        XCTAssertNil(request.value(forHTTPHeaderField: individualIdHeader))
    }

    func testUnauthorisedResponseGetsANewTokenAndOneRetry() {
        let first = TestJWT.make(exp: nil, subject: "first")
        let second = TestJWT.make(exp: nil, subject: "second")
        let spy = TokenProviderSpy(tokens: [first, second])
        PrivacyDashboard.configure(baseUrl: baseUrl, organisationId: organisationId, tokenProvider: spy.provider)
        StubURLProtocol.respond { request in
            request.value(forHTTPHeaderField: "Authorization") == "Bearer \(second)"
                ? (200, Data(#"{"ok":true}"#.utf8))
                : (401, Data(#"{"errorCode":401}"#.utf8))
        }

        let outcome = makeAPICall()

        XCTAssertTrue(outcome.success)
        XCTAssertEqual(outcome.result["ok"] as? Bool, true)
        XCTAssertEqual(StubURLProtocol.requests.map { $0.value(forHTTPHeaderField: "Authorization") }, ["Bearer \(first)", "Bearer \(second)"])
        XCTAssertEqual(spy.calls, 2)
    }

    func testSecondUnauthorisedResponseIsNotRetried() {
        let spy = TokenProviderSpy(tokens: [TestJWT.make(exp: nil, subject: "a"), TestJWT.make(exp: nil, subject: "b"), TestJWT.make(exp: nil, subject: "c")])
        PrivacyDashboard.configure(baseUrl: baseUrl, organisationId: organisationId, tokenProvider: spy.provider)
        StubURLProtocol.respond { _ in (401, Data(#"{"errorCode":401}"#.utf8)) }

        let outcome = makeAPICall()

        XCTAssertFalse(outcome.success)
        XCTAssertEqual(StubURLProtocol.requests.count, 2)
        XCTAssertEqual(spy.calls, 2)
    }

    func testUnauthorisedResponseOfAServiceCallIsRetriedOnce() {
        let spy = TokenProviderSpy(tokens: [TestJWT.make(exp: nil, subject: "a"), TestJWT.make(exp: nil, subject: "b"), TestJWT.make(exp: nil, subject: "c")])
        PrivacyDashboard.configure(baseUrl: baseUrl, organisationId: organisationId, tokenProvider: spy.provider)
        StubURLProtocol.respond { _ in (401, Data(#"{"errorCode":401}"#.utf8)) }

        let service = OrganisationWebService()
        service.baseUrl = baseUrl
        let done = expectation(description: "service call")
        let delegate = ServiceDelegate { done.fulfill() }
        service.delegate = delegate
        service.organization()
        wait(for: [done], timeout: 5)

        XCTAssertTrue(delegate.failed)
        XCTAssertEqual(StubURLProtocol.requests.count, 2)
        XCTAssertEqual(spy.calls, 2)
    }

    func testProviderErrorFailsTheRequestWithoutNetworkCall() {
        struct HostError: Error {}
        PrivacyDashboard.configure(baseUrl: baseUrl, organisationId: organisationId) { completion in
            completion(.failure(HostError()))
        }
        let outcome = makeAPICall()
        XCTAssertFalse(outcome.success)
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    @available(*, deprecated)
    func testApiKeyModeSendsApiKeyAndIndividualId() throws {
        PrivacyDashboard.configure(withApiKey: "test-api-key", withUserId: "user-1", withOrgId: organisationId, withBaseUrl: baseUrl, withLocale: "en")
        BBConsentPrivacyDashboardiOS.shared.orgId = organisationId
        StubURLProtocol.respond { _ in (401, Data(#"{"errorCode":401}"#.utf8)) }

        let outcome = makeAPICall()

        // As in earlier SDK versions: the error body comes back, no retry.
        XCTAssertTrue(outcome.success)
        XCTAssertEqual(outcome.result["errorCode"] as? Int, 401)
        XCTAssertEqual(StubURLProtocol.requests.count, 1)
        let request = StubURLProtocol.requests[0]
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "ApiKey test-api-key")
        XCTAssertEqual(request.value(forHTTPHeaderField: individualIdHeader), "user-1")
        XCTAssertEqual(request.value(forHTTPHeaderField: "organizationId"), organisationId)
    }

    @available(*, deprecated)
    func testApiKeyEntryPointReplacesTheTokenProvider() throws {
        let spy = TokenProviderSpy(tokens: [TestJWT.make(exp: nil)])
        PrivacyDashboard.configure(baseUrl: baseUrl, organisationId: organisationId, tokenProvider: spy.provider)
        PrivacyDashboard.configure(withApiKey: "test-api-key", withUserId: "user-1", withOrgId: organisationId, withBaseUrl: baseUrl, withLocale: "en")

        _ = makeAPICall()

        XCTAssertEqual(spy.calls, 0)
        XCTAssertEqual(StubURLProtocol.requests.first?.value(forHTTPHeaderField: "Authorization"), "ApiKey test-api-key")
    }

    func testLegacyServiceCallHeaders() throws {
        _ = BBConsentKeyChainUtils.save(key: BBConsentKeyChainUtils.apiKeyAccount, data: Data("test-api-key".utf8))
        BBConsentPrivacyDashboardiOS.shared.userId = "user-1"
        BBConsentPrivacyDashboardiOS.shared.accessToken = "legacy-token"
        XCTAssertEqual(BBConsentAuthInterceptor.legacyHeaders(order: .apiKeyFirst), ["Authorization": "ApiKey test-api-key", individualIdHeader: "user-1"])
        XCTAssertEqual(BBConsentAuthInterceptor.legacyHeaders(order: .accessTokenFirst), ["Authorization": "Bearer legacy-token"])

        BBConsentPrivacyDashboardiOS.shared.userId = ""
        XCTAssertEqual(BBConsentAuthInterceptor.legacyHeaders(order: .apiKeyFirst), ["Authorization": "Bearer legacy-token"])
    }
}

final class ServiceDelegate: NSObject, BaseServiceDelegates {
    private let onFinish: () -> Void
    private(set) var failed = false

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    func didSuccessfullyReceiveData(response: RestResponse?) {
        onFinish()
    }

    func didFailedToReceiveData(response: RestResponse?) {
        failed = true
        onFinish()
    }
}
