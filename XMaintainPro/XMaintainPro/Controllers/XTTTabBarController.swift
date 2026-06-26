//
//  XTTTabBarController.swift
//  XMaintainPro
//
//  Root tab bar: Dashboard · Equipment · Calendar · Statistics · Settings.
//

import UIKit

final class XTTTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        xttSetupTabs()
        xttStyleTabBar()
    }

    private func xttSetupTabs() {
        viewControllers = [
            xttNav(XTTDashboardViewController(), title: "Home", icon: "house.fill"),
            xttNav(XTTEquipmentListViewController(), title: "Equipment", icon: "gearshape.2.fill"),
            xttNav(XTTCalendarViewController(), title: "Calendar", icon: "calendar"),
            xttNav(XTTStatisticsViewController(), title: "Stats", icon: "chart.bar.fill"),
            xttNav(XTTSettingsViewController(), title: "Settings", icon: "gearshape.fill")
        ]
    }

    private func xttNav(_ root: UIViewController, title: String, icon: String) -> UINavigationController {
        root.title = title
        let nav = UINavigationController(rootViewController: root)
        nav.navigationBar.prefersLargeTitles = true
        nav.tabBarItem = UITabBarItem(title: title,
                                      image: UIImage(systemName: icon),
                                      selectedImage: UIImage(systemName: icon))
        return nav
    }

    private func xttStyleTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = XTTTheme.Color.card
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.tintColor = XTTTheme.Color.accent
        tabBar.unselectedItemTintColor = XTTTheme.Color.secondaryText
    }
}
