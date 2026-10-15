//
//  BBConsentKeychainUtils.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 31/08/23.
//

import Foundation
import Security

// The Keychain calls of the SDK. Tests replace it with an in-memory store,
// because a test bundle without a host app has no Keychain access.
struct BBConsentKeychainBackend {
    var add: ([String: Any]) -> OSStatus
    var copyData: ([String: Any]) -> (OSStatus, Data?)
    var delete: ([String: Any]) -> OSStatus

    static let system = BBConsentKeychainBackend(
        add: { query in SecItemAdd(query as CFDictionary, nil) },
        copyData: { query in
            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)
            return (status, result as? Data)
        },
        delete: { query in SecItemDelete(query as CFDictionary) })
}

class BBConsentKeyChainUtils {
    // All items of the SDK use this service, so that they do not mix with the items of the host app.
    static let service = "PrivacyDashboardiOS"
    static let apiKeyAccount = "BBConsentApiKey"
    static var backend = BBConsentKeychainBackend.system

    static func query(key: String) -> [String: Any] {
        return [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : key ]
    }

    static func save(key: String, data: Data) -> OSStatus {
        delete(key: key)
        var query = query(key: key)
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        query[kSecValueData as String] = data
        return backend.add(query)
    }

    class func load(key: String) -> Data? {
        var query = query(key: key)
        query[kSecReturnData as String] = kCFBooleanTrue!
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        let (status, data) = backend.copyData(query)
        return status == noErr ? data : nil
    }

    // Deletes the item of the SDK and also the item that older SDK versions stored without a service.
    @discardableResult
    static func delete(key: String) -> OSStatus {
        let legacyQuery = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key ] as [String : Any]
        _ = backend.delete(legacyQuery)
        return backend.delete(query(key: key))
    }

    static func deleteAll() {
        delete(key: apiKeyAccount)
        let serviceQuery = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service ] as [String : Any]
        _ = backend.delete(serviceQuery)
    }

    class func createUniqueID() -> String {
        let uuid: CFUUID = CFUUIDCreate(nil)
        let cfStr: CFString = CFUUIDCreateString(nil, uuid)
        let swiftString: String = cfStr as String
        return swiftString
    }
}
