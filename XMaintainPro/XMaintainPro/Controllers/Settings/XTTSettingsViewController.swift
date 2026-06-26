//
//  XTTSettingsViewController.swift
//  XMaintainPro
//
//  App settings: profile, security, appearance, data, about.
//

import UIKit
import LocalAuthentication

final class XTTSettingsViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        navigationItem.largeTitleDisplayMode = .always
        xttApplyBaseBackground()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.xttPinEdges(to: view)
        stack.axis = .vertical
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        xttRender()
    }

    private func xttRender() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        xttProfileHeader()

        xttSection("Security", rows: [
            xttToggleRow(icon: "faceid", tint: XTTTheme.Color.accent, title: "Face ID / Touch ID",
                         isOn: XTTSettingsService.shared.biometricEnabled) { [weak self] on in
                self?.xttToggleBiometric(on)
            },
            xttToggleRow(icon: "lock.fill", tint: XTTTheme.Color.purple, title: "Auto Lock",
                         isOn: XTTSettingsService.shared.autoLockEnabled) { on in
                XTTSettingsService.shared.autoLockEnabled = on
            }
        ])

        xttSection("Appearance", rows: [
            xttNavRow(icon: "paintbrush.fill", tint: XTTTheme.Color.teal, title: "Theme",
                      value: XTTSettingsService.shared.themeMode.title, action: #selector(xttPickTheme)),
            xttNavRow(icon: "globe", tint: XTTTheme.Color.accent, title: "Language",
                      value: "English", action: #selector(xttLanguageInfo))
        ])

        xttSection("Data", rows: [
            xttNavRow(icon: "square.and.arrow.up.fill", tint: XTTTheme.Color.success, title: "Export Data",
                      value: "", action: #selector(xttExport))
        ])

        xttSection("About", rows: [
            xttNavRow(icon: "info.circle.fill", tint: XTTTheme.Color.accent, title: "About",
                      value: "", action: #selector(xttAbout)),
            xttNavRow(icon: "hand.raised.fill", tint: XTTTheme.Color.purple, title: "Privacy Policy",
                      value: "", action: #selector(xttPrivacy)),
            xttNavRow(icon: "doc.text.fill", tint: XTTTheme.Color.teal, title: "Terms of Use",
                      value: "", action: #selector(xttTerms))
        ])

        // Account actions
        let auth = XTTAuthService.shared
        let logoutButton = XTTSoftButton(title: auth.isGuest ? "Exit Guest Mode" : "Log Out")
        logoutButton.addTarget(self, action: #selector(xttLogout), for: .touchUpInside)
        stack.addArrangedSubview(logoutButton)

        if !auth.isGuest {
            let deleteButton = XTTSoftButton(title: "Delete Account", tint: XTTTheme.Color.danger)
            deleteButton.addTarget(self, action: #selector(xttDeleteAccount), for: .touchUpInside)
            stack.addArrangedSubview(deleteButton)
        }

        let version = UILabel()
        version.text = "X Maintain Pro · Version 1.0"
        version.font = XTTTheme.Font.caption()
        version.textColor = XTTTheme.Color.secondaryText
        version.textAlignment = .center
        stack.addArrangedSubview(version)
    }

    // MARK: - Profile header
    private func xttProfileHeader() {
        let card = XTTGradientView(colors: XTTTheme.Color.gradientBlue)
        card.xttRoundCorners(20)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 110).isActive = true

        let auth = XTTAuthService.shared
        let name = auth.isGuest ? "Guest User" : (auth.currentUser?.displayName ?? "User")
        let email = auth.isGuest ? "Data is temporary in guest mode" : (auth.currentUser?.email ?? "")

        let avatar = UIView()
        avatar.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        avatar.xttRoundCorners(30)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        let initials = UILabel()
        initials.text = String(name.prefix(1)).uppercased()
        initials.font = .systemFont(ofSize: 26, weight: .bold)
        initials.textColor = .white
        initials.translatesAutoresizingMaskIntoConstraints = false
        avatar.addSubview(initials)

        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 20, weight: .bold)
        nameLabel.textColor = .white

        let emailLabel = UILabel()
        emailLabel.text = email
        emailLabel.font = XTTTheme.Font.subhead()
        emailLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        emailLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [nameLabel, emailLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(avatar)
        card.addSubview(textStack)
        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            avatar.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 60),
            avatar.heightAnchor.constraint(equalToConstant: 60),
            initials.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            initials.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            textStack.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(xttOpenProfile))
        card.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true
        stack.addArrangedSubview(card)
    }

    // MARK: - Section + rows
    private func xttSection(_ title: String, rows: [UIView]) {
        let header = UILabel()
        header.text = title.uppercased()
        header.font = XTTTheme.Font.caption()
        header.textColor = XTTTheme.Color.secondaryText

        let card = UIView()
        card.xttApplyCardStyle(radius: 18)
        card.translatesAutoresizingMaskIntoConstraints = false
        let rowStack = UIStackView()
        rowStack.axis = .vertical
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        for (i, row) in rows.enumerated() {
            rowStack.addArrangedSubview(row)
            if i < rows.count - 1 {
                let sep = UIView()
                sep.backgroundColor = XTTTheme.Color.separator
                sep.translatesAutoresizingMaskIntoConstraints = false
                sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
                rowStack.addArrangedSubview(sep)
            }
        }
        card.addSubview(rowStack)
        rowStack.xttPinEdges(to: card, insets: UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))

        let wrap = UIStackView(arrangedSubviews: [header, card])
        wrap.axis = .vertical
        wrap.spacing = 8
        stack.addArrangedSubview(wrap)
    }

    private func xttRowBase(icon: String, tint: UIColor, title: String) -> (UIStackView, UIView) {
        let iconBg = UIView()
        iconBg.backgroundColor = tint.withAlphaComponent(0.15)
        iconBg.xttRoundCorners(8)
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        let iv = UIImageView(image: UIImage(systemName: icon))
        iv.tintColor = tint
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iv)
        NSLayoutConstraint.activate([
            iconBg.widthAnchor.constraint(equalToConstant: 32),
            iconBg.heightAnchor.constraint(equalToConstant: 32),
            iv.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iv.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iv.widthAnchor.constraint(equalToConstant: 17),
            iv.heightAnchor.constraint(equalToConstant: 17)
        ])

        let label = UILabel()
        label.text = title
        label.font = XTTTheme.Font.bodyMedium()
        label.textColor = XTTTheme.Color.primaryText

        let row = UIStackView(arrangedSubviews: [iconBg, label])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        return (row, label)
    }

    private func xttToggleRow(icon: String, tint: UIColor, title: String, isOn: Bool,
                              onChange: @escaping (Bool) -> Void) -> UIView {
        let (row, _) = xttRowBase(icon: icon, tint: tint, title: title)
        let toggle = UISwitch()
        toggle.isOn = isOn
        toggle.onTintColor = XTTTheme.Color.accent
        toggle.addAction(UIAction { _ in onChange(toggle.isOn) }, for: .valueChanged)
        row.addArrangedSubview(UIView())
        row.addArrangedSubview(toggle)
        return row
    }

    private func xttNavRow(icon: String, tint: UIColor, title: String, value: String, action: Selector) -> UIView {
        let (row, _) = xttRowBase(icon: icon, tint: tint, title: title)
        row.addArrangedSubview(UIView())
        if !value.isEmpty {
            let valueLabel = UILabel()
            valueLabel.text = value
            valueLabel.font = XTTTheme.Font.subhead()
            valueLabel.textColor = XTTTheme.Color.secondaryText
            row.addArrangedSubview(valueLabel)
        }
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = XTTTheme.Color.separator
        row.addArrangedSubview(chevron)
        row.isUserInteractionEnabled = true
        row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
        return row
    }

    // MARK: - Actions
    private func xttToggleBiometric(_ on: Bool) {
        guard on else { XTTSettingsService.shared.biometricEnabled = false; return }
        let context = LAContext()
        var err: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &err) {
            XTTSettingsService.shared.biometricEnabled = true
            xttShowToast("Biometric lock enabled")
        } else {
            XTTSettingsService.shared.biometricEnabled = false
            xttShowAlert(title: "Unavailable", message: "Biometric authentication is not available on this device.")
            xttRender()
        }
    }

    @objc private func xttPickTheme() {
        xttPresentOptions(title: "Theme", options: XTTThemeMode.allCases.map { $0.title }, from: view) { [weak self] i in
            XTTSettingsService.shared.themeMode = XTTThemeMode.allCases[i]
            self?.xttRender()
        }
    }
    @objc private func xttLanguageInfo() {
        xttShowAlert(title: "Language", message: "English is currently the only available language. More languages are planned for future updates.")
    }
    @objc private func xttExport() {
        if XTTDataManager.shared.xttIsReadOnlyPersistence {
            xttShowAlert(title: "Guest Mode", message: "Export is only available for registered accounts. Please create an account to save and export your data.")
            return
        }
        guard let url = XTTDataManager.shared.xttWriteExportFile() else {
            xttShowAlert(title: "Export Failed", message: "Could not generate the export file.")
            return
        }
        let share = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        share.popoverPresentationController?.sourceView = view
        share.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
        present(share, animated: true)
    }
    @objc private func xttAbout() {
        navigationController?.pushViewController(XTTAboutViewController(), animated: true)
    }
    @objc private func xttPrivacy() {
        navigationController?.pushViewController(XTTLegalViewController(kind: .privacy), animated: true)
    }
    @objc private func xttTerms() {
        navigationController?.pushViewController(XTTLegalViewController(kind: .terms), animated: true)
    }
    @objc private func xttOpenProfile() {
        navigationController?.pushViewController(XTTProfileViewController(), animated: true)
    }
    @objc private func xttLogout() {
        let auth = XTTAuthService.shared
        let title = auth.isGuest ? "Exit Guest Mode" : "Log Out"
        let msg = auth.isGuest ? "Your temporary data will be cleared. Continue?" : "Are you sure you want to log out?"
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: title, style: .destructive) { _ in
            XTTAuthService.shared.xttLogout()
            XTTSceneRouter.xttSetRootToAuth()
        })
        present(alert, animated: true)
    }
    @objc private func xttDeleteAccount() {
        let alert = UIAlertController(title: "Delete Account",
                                      message: "This permanently deletes your account and all local data. This cannot be undone.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            XTTAuthService.shared.xttDeleteAccount()
            XTTSceneRouter.xttSetRootToAuth()
        })
        present(alert, animated: true)
    }
}
