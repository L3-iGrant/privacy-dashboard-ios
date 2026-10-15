//
//  BBConsentTokenStoreTests.swift
//  PrivacyDashboardiOSTests
//

import XCTest
@testable import PrivacyDashboardiOS

final class BBConsentTokenStoreTests: SDKTestCase {
    private func token(from store: BBConsentTokenStore) -> Result<String, Error> {
        let done = expectation(description: "token")
        var result: Result<String, Error> = .failure(PrivacyDashboardError.notConfigured)
        store.token { value in
            result = value
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
        return result
    }

    func testExpiryIsReadFromTheJWTPayload() {
        let exp = Date(timeIntervalSince1970: 1_900_000_000)
        XCTAssertEqual(BBConsentTokenStore.expiry(ofJWT: TestJWT.make(exp: exp)), exp)
        XCTAssertNil(BBConsentTokenStore.expiry(ofJWT: TestJWT.make(exp: nil)))
        XCTAssertNil(BBConsentTokenStore.expiry(ofJWT: "not-a-jwt"))
    }

    func testProviderIsAskedOnFirstUseAndTheTokenIsKeptInMemory() {
        let store = BBConsentTokenStore()
        let jwt = TestJWT.make(exp: Date().addingTimeInterval(600))
        let spy = TokenProviderSpy(tokens: [jwt])
        store.configure(provider: spy.provider)
        XCTAssertEqual(spy.calls, 0)

        XCTAssertEqual(try token(from: store).get(), jwt)
        XCTAssertEqual(try token(from: store).get(), jwt)
        XCTAssertEqual(spy.calls, 1)
    }

    func testProviderIsAskedAgainWhenTheTokenIsLessThan60SecondsFromExpiry() {
        let store = BBConsentTokenStore()
        let start = Date()
        var now = start
        store.now = { now }
        let first = TestJWT.make(exp: start.addingTimeInterval(120))
        let second = TestJWT.make(exp: start.addingTimeInterval(720))
        let spy = TokenProviderSpy(tokens: [first, second])
        store.configure(provider: spy.provider)

        XCTAssertEqual(try token(from: store).get(), first)
        now = start.addingTimeInterval(59) // 61 s left
        XCTAssertEqual(try token(from: store).get(), first)
        XCTAssertEqual(spy.calls, 1)

        now = start.addingTimeInterval(61) // 59 s left
        XCTAssertEqual(try token(from: store).get(), second)
        XCTAssertEqual(spy.calls, 2)
    }

    func testInvalidateMakesTheStoreAskAgain() {
        let store = BBConsentTokenStore()
        let first = TestJWT.make(exp: nil, subject: "a")
        let second = TestJWT.make(exp: nil, subject: "b")
        let spy = TokenProviderSpy(tokens: [first, second])
        store.configure(provider: spy.provider)

        XCTAssertEqual(try token(from: store).get(), first)
        store.invalidate("other-token")
        XCTAssertEqual(try token(from: store).get(), first)
        store.invalidate(first)
        XCTAssertEqual(try token(from: store).get(), second)
        XCTAssertEqual(spy.calls, 2)
    }

    func testParallelRequestsShareOneProviderCall() {
        let store = BBConsentTokenStore()
        var completions: [(Result<String, Error>) -> Void] = []
        store.configure { completion in completions.append(completion) }
        let done = expectation(description: "both")
        done.expectedFulfillmentCount = 2
        store.token { _ in done.fulfill() }
        store.token { _ in done.fulfill() }
        let asked = expectation(description: "asked")
        DispatchQueue.main.async { asked.fulfill() }
        wait(for: [asked], timeout: 5)
        XCTAssertEqual(completions.count, 1)
        completions.first?(.success(TestJWT.make(exp: nil)))
        wait(for: [done], timeout: 5)
    }

    func testEmptyTokenIsAnError() {
        let store = BBConsentTokenStore()
        store.configure { completion in completion(.success("")) }
        XCTAssertThrowsError(try token(from: store).get())
    }

    func testResetDeletesTheTokenAndTheProvider() {
        let store = BBConsentTokenStore()
        let spy = TokenProviderSpy(tokens: [TestJWT.make(exp: nil)])
        store.configure(provider: spy.provider)
        XCTAssertNoThrow(try token(from: store).get())

        store.reset()
        XCTAssertFalse(store.hasProvider)
        XCTAssertThrowsError(try token(from: store).get()) { error in
            XCTAssertEqual(error as? PrivacyDashboardError, .notConfigured)
        }
    }

    func testAsyncProviderIsSupported() {
        let jwt = TestJWT.make(exp: nil)
        PrivacyDashboard.configure(baseUrl: baseUrl, organisationId: organisationId) { () async throws -> String in
            jwt
        }
        XCTAssertEqual(try token(from: .shared).get(), jwt)
    }
}
