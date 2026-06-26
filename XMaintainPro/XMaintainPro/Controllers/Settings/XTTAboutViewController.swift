//
//  XTTAboutViewController.swift
//  XMaintainPro
//

import UIKit

final class XTTAboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About"
        xttApplyBaseBackground()
        xttBuild()
    }

    private func xttBuild() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.xttPinEdges(to: view)

        let logoBg = XTTGradientView(colors: XTTTheme.Color.gradientBlue)
        logoBg.xttRoundCorners(24)
        logoBg.translatesAutoresizingMaskIntoConstraints = false
        logoBg.widthAnchor.constraint(equalToConstant: 90).isActive = true
        logoBg.heightAnchor.constraint(equalToConstant: 90).isActive = true
        let logo = UIImageView(image: UIImage(systemName: "wrench.and.screwdriver.fill"))
        logo.tintColor = .white
        logo.contentMode = .scaleAspectFit
        logo.translatesAutoresizingMaskIntoConstraints = false
        logoBg.addSubview(logo)
        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: logoBg.centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: logoBg.centerYAnchor),
            logo.widthAnchor.constraint(equalToConstant: 44),
            logo.heightAnchor.constraint(equalToConstant: 44)
        ])

        let name = UILabel()
        name.text = "X Maintain Pro"
        name.font = XTTTheme.Font.title()
        name.textColor = XTTTheme.Color.primaryText

        let version = UILabel()
        version.text = "Version 1.0"
        version.font = XTTTheme.Font.subhead()
        version.textColor = XTTTheme.Color.secondaryText

        let descCard = UIView()
        descCard.xttApplyCardStyle()
        descCard.translatesAutoresizingMaskIntoConstraints = false
        let desc = UILabel()
        desc.numberOfLines = 0
        desc.font = XTTTheme.Font.body()
        desc.textColor = XTTTheme.Color.secondaryText
        desc.text = "X Maintain Pro is a fully offline equipment maintenance management tool. Track equipment, schedule recurring maintenance, log repairs, manage spare parts and warranties, and keep all your documents in one place.\n\nAll data is stored privately on your device. No accounts, no servers, no tracking."
        desc.translatesAutoresizingMaskIntoConstraints = false
        descCard.addSubview(desc)
        desc.xttPinEdges(to: descCard, insets: UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18))

        let featuresCard = UIView()
        featuresCard.xttApplyCardStyle()
        featuresCard.translatesAutoresizingMaskIntoConstraints = false
        let featureStack = UIStackView()
        featureStack.axis = .vertical
        featureStack.spacing = 14
        featureStack.translatesAutoresizingMaskIntoConstraints = false
        let features: [(String, String)] = [
            ("gearshape.2.fill", "Equipment lifecycle tracking"),
            ("calendar.badge.clock", "Recurring maintenance plans"),
            ("wrench.fill", "Full repair history"),
            ("shippingbox.fill", "Spare parts inventory"),
            ("checkmark.shield.fill", "Warranty reminders"),
            ("lock.fill", "100% offline & private")
        ]
        for (icon, text) in features {
            let iv = UIImageView(image: UIImage(systemName: icon))
            iv.tintColor = XTTTheme.Color.accent
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: 22).isActive = true
            let label = UILabel()
            label.text = text
            label.font = XTTTheme.Font.body()
            label.textColor = XTTTheme.Color.primaryText
            let row = UIStackView(arrangedSubviews: [iv, label])
            row.axis = .horizontal
            row.spacing = 14
            row.alignment = .center
            featureStack.addArrangedSubview(row)
        }
        featuresCard.addSubview(featureStack)
        featureStack.xttPinEdges(to: featuresCard, insets: UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18))

        let container = UIStackView(arrangedSubviews: [logoBg, name, version, descCard, featuresCard])
        container.axis = .vertical
        container.spacing = 14
        container.alignment = .center
        container.setCustomSpacing(20, after: version)
        container.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 24),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            container.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -30),
            descCard.widthAnchor.constraint(equalTo: container.widthAnchor),
            featuresCard.widthAnchor.constraint(equalTo: container.widthAnchor)
        ])
    }
}
