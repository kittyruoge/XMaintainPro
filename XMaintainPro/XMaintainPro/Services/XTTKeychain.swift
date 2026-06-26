//
//  XTTKeychain.swift
//  XMaintainPro
//
//  Minimal Keychain wrapper for password storage.
//

import Foundation
import Security

enum XTTKeychain {
    private static let service = "com.XMaintainPro.credentials"

    @discardableResult
    static func xttSave(password: String, account: String) -> Bool {
        guard let data = password.data(using: .utf8) else { return false }
        // Remove any existing item first.
        xttDelete(account: account)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    static func xttReadPassword(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let pw = String(data: data, encoding: .utf8) else { return nil }
        return pw
    }

    @discardableResult
    static func xttDelete(account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
}
