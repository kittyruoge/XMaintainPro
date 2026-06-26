//
//  XTTSettingsService.swift
//  XMaintainPro
//
//  App preferences stored in UserDefaults.
//

import UIKit

enum XTTThemeMode: Int, CaseIterable {
    case system = 0
    case light = 1
    case dark = 2

    var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }
}

final class XTTSettingsService {
    static let shared = XTTSettingsService()
    private init() {}

    private let defaults = UserDefaults.standard
    private let kBiometric = "XTT.biometricEnabled"
    private let kAutoLock = "XTT.autoLockEnabled"
    private let kTheme = "XTT.themeMode"

    var biometricEnabled: Bool {
        get { defaults.bool(forKey: kBiometric) }
        set { defaults.set(newValue, forKey: kBiometric) }
    }
    var autoLockEnabled: Bool {
        get { defaults.bool(forKey: kAutoLock) }
        set { defaults.set(newValue, forKey: kAutoLock) }
    }
    var themeMode: XTTThemeMode {
        get { XTTThemeMode(rawValue: defaults.integer(forKey: kTheme)) ?? .system }
        set {
            defaults.set(newValue.rawValue, forKey: kTheme)
            xttApplyTheme()
        }
    }

    func xttApplyTheme() {
        let style = themeMode.interfaceStyle
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            windowScene.windows.forEach { $0.overrideUserInterfaceStyle = style }
        }
    }
}
