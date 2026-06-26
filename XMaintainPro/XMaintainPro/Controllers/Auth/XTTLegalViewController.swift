//
//  XTTLegalViewController.swift
//  XMaintainPro
//
//  Privacy Policy / Terms of Use — static local content.
//

import UIKit

final class XTTLegalViewController: UIViewController {

    enum Kind { case privacy, terms }
    private let kind: Kind

    init(kind: Kind) {
        self.kind = kind
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = kind == .privacy ? "Privacy Policy" : "Terms of Use"
        xttApplyBaseBackground()
        xttBuildUI()
    }

    private func xttBuildUI() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.xttPinEdges(to: view)

        let card = UIView()
        card.xttApplyCardStyle()
        card.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(card)

        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = xttBody()
        label.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(label)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 20),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
    }

    private func xttBody() -> NSAttributedString {
        let result = NSMutableAttributedString()
        let sections = kind == .privacy ? Self.privacySections : Self.termsSections
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: XTTTheme.Font.headline(),
            .foregroundColor: XTTTheme.Color.primaryText
        ]
        let bodyAttrs: [NSAttributedString.Key: Any] = [
            .font: XTTTheme.Font.body(),
            .foregroundColor: XTTTheme.Color.secondaryText
        ]
        for (heading, body) in sections {
            result.append(NSAttributedString(string: heading + "\n", attributes: titleAttrs))
            result.append(NSAttributedString(string: body + "\n\n", attributes: bodyAttrs))
        }
        return result
    }

    private static let privacySections: [(String, String)] = [
        ("Overview", "X Maintain Pro is an offline equipment maintenance tool. All of your data stays on your device. We do not collect, transmit, or share any personal information."),
        ("Data Storage", "Equipment records, maintenance plans, repairs, spare parts, warranties, and documents are stored locally using on-device storage. Passwords are kept securely in the device Keychain."),
        ("No Network Access", "The app does not connect to the internet, use analytics, or include advertising. Nothing leaves your device."),
        ("Your Control", "You can export or permanently delete your data at any time from Settings. Deleting your account removes all associated local data."),
        ("Contact", "For questions about this policy, please refer to the About section within the app.")
    ]

    private static let termsSections: [(String, String)] = [
        ("Acceptance", "By using X Maintain Pro you agree to use the app for managing equipment maintenance records on your own device."),
        ("Intended Use", "This app is a productivity tool for tracking the maintenance lifecycle of equipment. It is provided as-is for organizational purposes."),
        ("Your Responsibility", "You are responsible for the accuracy of the data you enter and for keeping your own backups via the export feature."),
        ("Limitation", "The app does not provide professional engineering, safety, or compliance advice. Always follow manufacturer guidelines and applicable regulations."),
        ("Changes", "These terms may be updated with future versions of the app. Continued use indicates acceptance of the current terms.")
    ]
}
