//
//  XTTProfileViewController.swift
//  XMaintainPro
//
//  User profile summary with account stats.
//

import UIKit

final class XTTProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        xttApplyBaseBackground()
        xttBuild()
    }

    private func xttBuild() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.xttPinEdges(to: view)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24)
        ])

        let auth = XTTAuthService.shared
        let name = auth.isGuest ? "Guest User" : (auth.currentUser?.displayName ?? "User")

        // Avatar header
        let avatarBg = XTTGradientView(colors: XTTTheme.Color.gradientPurple)
        avatarBg.xttRoundCorners(44)
        avatarBg.translatesAutoresizingMaskIntoConstraints = false
        avatarBg.widthAnchor.constraint(equalToConstant: 88).isActive = true
        avatarBg.heightAnchor.constraint(equalToConstant: 88).isActive = true
        let initials = UILabel()
        initials.text = String(name.prefix(1)).uppercased()
        initials.font = .systemFont(ofSize: 36, weight: .bold)
        initials.textColor = .white
        initials.translatesAutoresizingMaskIntoConstraints = false
        avatarBg.addSubview(initials)
        NSLayoutConstraint.activate([
            initials.centerXAnchor.constraint(equalTo: avatarBg.centerXAnchor),
            initials.centerYAnchor.constraint(equalTo: avatarBg.centerYAnchor)
        ])

        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = XTTTheme.Font.title()
        nameLabel.textColor = XTTTheme.Color.primaryText
        nameLabel.textAlignment = .center

        let header = UIStackView(arrangedSubviews: [avatarBg, nameLabel])
        header.axis = .vertical
        header.spacing = 12
        header.alignment = .center
        stack.addArrangedSubview(header)

        // Account info card
        let infoRows = UIStackView()
        infoRows.axis = .vertical
        if auth.isGuest {
            infoRows.addArrangedSubview(XTTDetailRow(label: "Mode", value: "Guest"))
            infoRows.addArrangedSubview(xttSep())
            infoRows.addArrangedSubview(XTTDetailRow(label: "Data", value: "Temporary"))
        } else if let user = auth.currentUser {
            infoRows.addArrangedSubview(XTTDetailRow(label: "Username", value: user.username))
            infoRows.addArrangedSubview(xttSep())
            infoRows.addArrangedSubview(XTTDetailRow(label: "Email", value: user.email))
            infoRows.addArrangedSubview(xttSep())
            infoRows.addArrangedSubview(XTTDetailRow(label: "Member Since", value: user.createdAt.xttFormatted()))
        }
        stack.addArrangedSubview(xttTitledCard("Account", content: infoRows))

        // Activity stats
        let dm = XTTDataManager.shared
        let statsRows = UIStackView()
        statsRows.axis = .vertical
        statsRows.addArrangedSubview(XTTDetailRow(label: "Equipment", value: "\(dm.store.equipment.count)"))
        statsRows.addArrangedSubview(xttSep())
        statsRows.addArrangedSubview(XTTDetailRow(label: "Maintenance Plans", value: "\(dm.store.plans.count)"))
        statsRows.addArrangedSubview(xttSep())
        statsRows.addArrangedSubview(XTTDetailRow(label: "Repairs Logged", value: "\(dm.store.repairs.count)"))
        statsRows.addArrangedSubview(xttSep())
        statsRows.addArrangedSubview(XTTDetailRow(label: "Spare Parts", value: "\(dm.store.spareParts.count)"))
        statsRows.addArrangedSubview(xttSep())
        statsRows.addArrangedSubview(XTTDetailRow(label: "Documents", value: "\(dm.store.documents.count)"))
        stack.addArrangedSubview(xttTitledCard("Activity", content: statsRows))
    }

    private func xttTitledCard(_ title: String, content: UIView) -> UIView {
        let header = UILabel()
        header.text = title
        header.font = XTTTheme.Font.headline()
        header.textColor = XTTTheme.Color.primaryText
        let card = UIView()
        card.xttApplyCardStyle()
        card.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)
        content.xttPinEdges(to: card, insets: UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16))
        let wrap = UIStackView(arrangedSubviews: [header, card])
        wrap.axis = .vertical
        wrap.spacing = 8
        return wrap
    }

    private func xttSep() -> UIView {
        let v = UIView()
        v.backgroundColor = XTTTheme.Color.separator
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return v
    }
}
