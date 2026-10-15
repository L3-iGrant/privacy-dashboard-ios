//
//  BBConsentStorageAndLoggingTests.swift
//  PrivacyDashboardiOSTests
//

import XCTest
import Kingfisher
@testable import PrivacyDashboardiOS

final class BBConsentKeychainTests: SDKTestCase {
    func testItemsUseTheSDKServiceAndThisDeviceOnlyAccessibility() throws {
        XCTAssertEqual(BBConsentKeyChainUtils.save(key: BBConsentKeyChainUtils.apiKeyAccount, data: Data("test-api-key".utf8)), errSecSuccess)

        XCTAssertEqual(keychain.items.count, 1)
        let item = try XCTUnwrap(keychain.items.first)
        XCTAssertEqual(item[kSecAttrService as String] as? String, "PrivacyDashboardiOS")
        XCTAssertEqual(item[kSecAttrAccount as String] as? String, BBConsentKeyChainUtils.apiKeyAccount)
        XCTAssertEqual(item[kSecAttrAccessible as String] as? String, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String)
        XCTAssertEqual(BBConsentKeyChainUtils.load(key: BBConsentKeyChainUtils.apiKeyAccount), Data("test-api-key".utf8))
    }

    func testSystemKeychainStoresTheAttributes() throws {
        BBConsentKeyChainUtils.backend = .system
        let account = "PrivacyDashboardiOSTestsProbe"
        let status = BBConsentKeyChainUtils.save(key: account, data: Data("x".utf8))
        defer { BBConsentKeyChainUtils.delete(key: account) }
        if status == errSecMissingEntitlement {
            throw XCTSkip("The system Keychain is not available in this test host (errSecMissingEntitlement)")
        }
        XCTAssertEqual(status, errSecSuccess)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne]
        var item: AnyObject?
        XCTAssertEqual(SecItemCopyMatching(query as CFDictionary, &item), errSecSuccess)
        let attributes = try XCTUnwrap(item as? [String: Any])
        XCTAssertEqual(attributes[kSecAttrService as String] as? String, "PrivacyDashboardiOS")
        XCTAssertEqual(attributes[kSecAttrAccessible as String] as? String, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String)
    }

    func testResetDeletesKeychainItemsAndTheToken() throws {
        _ = BBConsentKeyChainUtils.save(key: BBConsentKeyChainUtils.apiKeyAccount, data: Data("test-api-key".utf8))
        // Item as older SDK versions stored it: no service.
        keychain.insert([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: BBConsentKeyChainUtils.apiKeyAccount,
            kSecValueData as String: Data("old-api-key".utf8)])
        let jwt = TestJWT.make(exp: nil)
        PrivacyDashboard.configure(baseUrl: baseUrl, organisationId: organisationId, tokenProvider: TokenProviderSpy(tokens: [jwt]).provider)
        // configure with a token provider deletes the API key items.
        XCTAssertTrue(keychain.items.isEmpty)
        _ = BBConsentKeyChainUtils.save(key: BBConsentKeyChainUtils.apiKeyAccount, data: Data("test-api-key".utf8))
        BBConsentPrivacyDashboardiOS.shared.userId = "user-1"

        PrivacyDashboard.reset()

        XCTAssertTrue(keychain.items.isEmpty)
        XCTAssertNil(BBConsentKeyChainUtils.load(key: BBConsentKeyChainUtils.apiKeyAccount))
        XCTAssertFalse(BBConsentTokenStore.shared.hasProvider)
        XCTAssertNil(BBConsentPrivacyDashboardiOS.shared.userId)
    }

    func testLegacyUserSessionIsDeletedButAHostValueIsKept() throws {
        let suite = "PrivacyDashboardiOSTests.legacy"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let key = Constant.AppSetupConstant.KSavingUSerInfoUserDefaultKey

        defaults.set("host value", forKey: key)
        PrivacyDashboard.removeLegacyUserSession(from: defaults)
        XCTAssertEqual(defaults.string(forKey: key), "host value")

        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        archiver.setClassName("PrivacyDashboardiOS.UserInfo", for: FakeUserInfo.self)
        archiver.encode(FakeUserInfo(), forKey: NSKeyedArchiveRootObjectKey)
        archiver.finishEncoding()
        defaults.set(archiver.encodedData, forKey: key)
        PrivacyDashboard.removeLegacyUserSession(from: defaults)
        XCTAssertNil(defaults.object(forKey: key))
    }
}

// Stands for the `UserInfo` class of older SDK versions.
@objc(PrivacyDashboardiOSTestsFakeUserInfo)
final class FakeUserInfo: NSObject, NSCoding {
    override init() {}
    init?(coder: NSCoder) {}
    func encode(with coder: NSCoder) { coder.encode("refresh", forKey: "refreshToken") }
}

final class BBConsentImageRequestTests: SDKTestCase {
    private var originalConfiguration: URLSessionConfiguration!

    override func setUp() {
        super.setUp()
        originalConfiguration = KingfisherManager.shared.downloader.sessionConfiguration
        KingfisherManager.shared.downloader.sessionConfiguration = StubURLProtocol.configuration
    }

    override func tearDown() {
        KingfisherManager.shared.downloader.sessionConfiguration = originalConfiguration
        super.tearDown()
    }

    @MainActor
    private func loadImage() throws -> URLRequest {
        let url = URL(string: "https://images.example.test/\(UUID().uuidString).png")!
        let requested = expectation(description: "image request")
        StubURLProtocol.respond { _ in
            requested.fulfill()
            return (404, Data())
        }
        BBConsentImageLoader.setImage(UIImageView(), url: url, placeholder: nil)
        wait(for: [requested], timeout: 5)
        return try XCTUnwrap(StubURLProtocol.requests.first { $0.url == url })
    }

    @MainActor
    func testImageRequestHasNoAuthHeadersInTokenMode() throws {
        PrivacyDashboard.configure(baseUrl: baseUrl, organisationId: organisationId, tokenProvider: TokenProviderSpy(tokens: [TestJWT.make(exp: nil)]).provider)
        let request = try loadImage()
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
        XCTAssertNil(request.value(forHTTPHeaderField: "X-ConsentBB-IndividualId"))
    }

    @MainActor
    func testImageRequestHasNoAuthHeadersInApiKeyMode() throws {
        _ = BBConsentKeyChainUtils.save(key: BBConsentKeyChainUtils.apiKeyAccount, data: Data("test-api-key".utf8))
        BBConsentPrivacyDashboardiOS.shared.userId = "user-1"
        BBConsentPrivacyDashboardiOS.shared.accessToken = "legacy-token"
        let request = try loadImage()
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
        XCTAssertNil(request.value(forHTTPHeaderField: "X-ConsentBB-IndividualId"))
    }
}

final class BBConsentLoggingTests: XCTestCase {
    func testDebugLoggingIsOffByDefaultAndDoesNotBuildTheMessage() {
        XCTAssertFalse(PrivacyDashboard.isLoggingEnabled)
        var built = false
        BBConsentLog.debug({ built = true; return "body" }())
        XCTAssertFalse(built)
    }

    func testSourcesHaveNoPrintCalls() throws {
        let sources = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Sources")
        let enumerator = try XCTUnwrap(FileManager.default.enumerator(at: sources, includingPropertiesForKeys: nil))
        let pattern = try NSRegularExpression(pattern: #"(^|[^A-Za-z_.])(debugPrint|print|NSLog|dump)\("#, options: [.anchorsMatchLines])
        var findings: [String] = []
        var files = 0
        for case let url as URL in enumerator where url.pathExtension == "swift" {
            files += 1
            let text = try String(contentsOf: url, encoding: .utf8)
            for (index, line) in text.components(separatedBy: "\n").enumerated() {
                let code = line.components(separatedBy: "//").first ?? ""
                if pattern.firstMatch(in: code, range: NSRange(code.startIndex..., in: code)) != nil {
                    findings.append("\(url.lastPathComponent):\(index + 1)")
                }
            }
        }
        XCTAssertGreaterThan(files, 10)
        XCTAssertEqual(findings, [])
    }
}
