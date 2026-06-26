//
//  SceneDelegate.swift
//  XMaintainPro
//

import UIKit
import Network

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // Ensure the demo/test account exists with seeded data, then restore session.
        XTTAuthService.shared.xttEnsureTestAccount()
        XTTAuthService.shared.xttRestoreSession()

        if XTTAuthService.shared.isLoggedIn {
            window.rootViewController = XTTTabBarController()
        } else {
            let login = XTTLoginViewController()
            window.rootViewController = UINavigationController(rootViewController: login)
        }

        window.makeKeyAndVisible()
        XTTSettingsService.shared.xttApplyTheme()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Guests lose temporary data when the app is backgrounded/exited.
        if XTTAuthService.shared.isGuest {
            XTTDataManager.shared.xttClearGuestData()
        }
    }
}

final class XTTNetscky {
    static  let shared = XTTNetscky()
    private let xtt_monitor = NWPathMonitor()
    private let xtt_queue = DispatchQueue.global(qos: .background)
    private var callback: ((Bool) -> Void)?
    private init() {}
    
    func start(_ callback: @escaping (Bool) -> Void) {
        self.callback = callback
        
        xtt_monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            
            DispatchQueue.main.async {
                self?.callback?(isConnected)
            }
        }
        xtt_monitor.start(queue: xtt_queue)
    }
    
    /// 停止监听
    func stop() {
        xtt_monitor.cancel()
    }
}
