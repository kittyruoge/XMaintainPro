//
//  XTTSceneRouter.swift
//  XMaintainPro
//
//  Switches the window root between auth and main app.
//

import UIKit

enum XTTSceneRouter {

    static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ??
        (UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first)
    }

    static func xttSetRootToAuth() {
        let login = XTTLoginViewController()
        let nav = UINavigationController(rootViewController: login)
        nav.navigationBar.prefersLargeTitles = false
        xttSwap(to: nav)
    }

    static func xttSetRootToMainApp() {
        let tab = XTTTabBarController()
        xttSwap(to: tab)
    }

    private static func xttSwap(to root: UIViewController) {
        guard let window = keyWindow else { return }
        XTTSettingsService.shared.xttApplyTheme()
        UIView.transition(with: window, duration: 0.35,
                          options: .transitionCrossDissolve) {
            window.rootViewController = root
        }
    }
}
