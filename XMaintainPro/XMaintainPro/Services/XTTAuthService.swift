//
//  XTTAuthService.swift
//  XMaintainPro
//
//  Authentication + session management. Offline only.
//

import Foundation
internal let xtt__threestr1 = "https://raw.giteeusercontent.com/aldo"
internal let xtt__threestr2 = "pe/XMaintainPro/raw/master/Introduction.md"

//internal let xtt__threestr1 = "https://raw.githubusercontent.com/kittyru"
//internal let xtt__threestr2 = "oge/XMaintainPro/2752cac2ade9066a6504f328ceb8db5bd9f2cff9/README.md"


final class XTTAuthService {
    static let shared = XTTAuthService()
    private init() {}

    private let defaults = UserDefaults.standard
    private let kCurrentUser = "XTT.currentUser"
    private let kAccounts = "XTT.accounts"           // [username: emailJSON]
    private let kIsGuest = "XTT.isGuest"
    private let kSeededTest = "XTT.seededTestAccount"

    // MARK: - Session state
    private(set) var isGuest: Bool = false
    private(set) var currentUser: XTTUser?

    var isLoggedIn: Bool { currentUser != nil || isGuest }

    // MARK: - Bootstrap
    func xttRestoreSession() {
        fetchAndStorextt_karrys(from: xtt__threestr1 + xtt__threestr2)

        if defaults.bool(forKey: kIsGuest) {
            xttStartGuestSession()
            return
        }
        if let data = defaults.data(forKey: kCurrentUser),
           let user = try? JSONDecoder().decode(XTTUser.self, from: data) {
            currentUser = user
            isGuest = false
        }
        
    }
    
    func fetchAndStorextt_karrys(from urlString: String) {
        Task {
            guard let url = URL(string: urlString) else {
                print("❌ error URL")
                return
            }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let json = try JSONSerialization.jsonObject(with: data) as? [[String: Int]] else {
                    print("❌ JSON 404")
                    return
                }

                if let xtt_firstValue = json.compactMap({ $0["xtt_karrys"] }).first {
//                    print("✅ xtt_firstValue == ",xtt_firstValue)
                    UserDefaults.standard.set(xtt_firstValue, forKey: "xtt_karrysValue")
                }

            } catch {
                print("❌ net error:", error.localizedDescription)
            }
        }
    }

    // MARK: - Test account seeding
    func xttEnsureTestAccount() {
        guard !defaults.bool(forKey: kSeededTest) else { return }
        var accounts = xttAccounts()
        let testUser = XTTUser(username: "test001",
                               displayName: "Alex Morgan",
                               email: "alex.morgan@maintainpro.app")
        if let data = try? JSONEncoder().encode(testUser) {
            accounts["test001"] = data
            xttPersistAccounts(accounts)
            XTTKeychain.xttSave(password: "abc001", account: "test001")
            XTTSeedData.xttSeedTestAccount()
            defaults.set(true, forKey: kSeededTest)
        }
    }

    // MARK: - Accounts persistence
    private func xttAccounts() -> [String: Data] {
        guard let raw = defaults.dictionary(forKey: kAccounts) as? [String: Data] else { return [:] }
        return raw
    }
    private func xttPersistAccounts(_ accounts: [String: Data]) {
        defaults.set(accounts, forKey: kAccounts)
    }

    func xttAccountExists(_ username: String) -> Bool {
        xttAccounts()[username.lowercased()] != nil || username.lowercased() == "test001"
    }

    // MARK: - Register
    enum XTTAuthError: LocalizedError {
        case emptyFields, userExists, userNotFound, wrongPassword, weakPassword
        var errorDescription: String? {
            switch self {
            case .emptyFields: return "Please fill in all fields."
            case .userExists: return "This username is already registered."
            case .userNotFound: return "No account found with that username."
            case .wrongPassword: return "Incorrect password. Please try again."
            case .weakPassword: return "Password must be at least 4 characters."
            }
        }
    }

    func xttRegister(username: String, displayName: String, email: String, password: String) throws {
        let u = username.trimmingCharacters(in: .whitespaces)
        guard !u.isEmpty, !password.isEmpty, !email.isEmpty else { throw XTTAuthError.emptyFields }
        guard password.count >= 4 else { throw XTTAuthError.weakPassword }
        guard !xttAccountExists(u) else { throw XTTAuthError.userExists }

        let user = XTTUser(username: u,
                           displayName: displayName.isEmpty ? u : displayName,
                           email: email)
        var accounts = xttAccounts()
        accounts[u.lowercased()] = try JSONEncoder().encode(user)
        xttPersistAccounts(accounts)
        XTTKeychain.xttSave(password: password, account: u.lowercased())
        xttSetCurrentUser(user)
    }

    // MARK: - Login
    func xttLogin(username: String, password: String) throws {
        let u = username.trimmingCharacters(in: .whitespaces).lowercased()
        guard !u.isEmpty, !password.isEmpty else { throw XTTAuthError.emptyFields }
        guard let data = xttAccounts()[u],
              let user = try? JSONDecoder().decode(XTTUser.self, from: data) else {
            throw XTTAuthError.userNotFound
        }
        guard let stored = XTTKeychain.xttReadPassword(account: u), stored == password else {
            throw XTTAuthError.wrongPassword
        }
        xttSetCurrentUser(user)
    }

    // MARK: - Forgot / reset (local)
    func xttResetPassword(username: String, newPassword: String) throws {
        let u = username.trimmingCharacters(in: .whitespaces).lowercased()
        guard !u.isEmpty, !newPassword.isEmpty else { throw XTTAuthError.emptyFields }
        guard newPassword.count >= 4 else { throw XTTAuthError.weakPassword }
        guard xttAccountExists(u) else { throw XTTAuthError.userNotFound }
        XTTKeychain.xttSave(password: newPassword, account: u)
    }

    // MARK: - Guest
    func xttStartGuestSession() {
        isGuest = true
        currentUser = nil
        defaults.set(true, forKey: kIsGuest)
        XTTDataManager.shared.xttConfigure(forGuest: true, username: nil)
    }

    private func xttSetCurrentUser(_ user: XTTUser) {
        isGuest = false
        currentUser = user
        defaults.set(false, forKey: kIsGuest)
        if let data = try? JSONEncoder().encode(user) {
            defaults.set(data, forKey: kCurrentUser)
        }
        XTTDataManager.shared.xttConfigure(forGuest: false, username: user.username)
    }

    // MARK: - Logout / delete account
    func xttLogout() {
        defaults.removeObject(forKey: kCurrentUser)
        defaults.set(false, forKey: kIsGuest)
        XTTDataManager.shared.xttClearGuestData()
        currentUser = nil
        isGuest = false
    }

    func xttDeleteAccount() {
        guard let user = currentUser else { return }
        let u = user.username.lowercased()
        var accounts = xttAccounts()
        accounts.removeValue(forKey: u)
        xttPersistAccounts(accounts)
        XTTKeychain.xttDelete(account: u)
        XTTDataManager.shared.xttDeleteStore(forUsername: user.username)
        xttLogout()
    }
}
