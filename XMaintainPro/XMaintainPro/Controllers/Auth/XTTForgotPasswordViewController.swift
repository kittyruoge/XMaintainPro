//
//  XTTForgotPasswordViewController.swift
//  XMaintainPro
//

import UIKit

final class XTTForgotPasswordViewController: UIViewController {

    private let usernameField = XTTTextField(placeholder: "Username", icon: "person.fill")
    private let newPasswordField = XTTTextField(placeholder: "New Password", icon: "lock.fill", secure: true)
    private let confirmField = XTTTextField(placeholder: "Confirm New Password", icon: "lock.rotation", secure: true)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reset Password"
        xttApplyBaseBackground()
        xttBuildUI()
        xttEnableTapToDismissKeyboard()
    }

    private func xttBuildUI() {
        let icon = UIImageView(image: UIImage(systemName: "key.horizontal.fill"))
        icon.tintColor = XTTTheme.Color.accent
        icon.contentMode = .scaleAspectFit
        icon.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let header = UILabel()
        header.text = "Local Password Reset"
        header.font = XTTTheme.Font.title()
        header.textColor = XTTTheme.Color.primaryText

        let sub = UILabel()
        sub.text = "Reset is performed entirely on this device. Enter your username and a new password."
        sub.numberOfLines = 0
        sub.font = XTTTheme.Font.subhead()
        sub.textColor = XTTTheme.Color.secondaryText

        let resetButton = XTTPrimaryButton(title: "Reset Password")
        resetButton.addTarget(self, action: #selector(xttResetTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            icon, header, sub, usernameField, newPasswordField, confirmField, resetButton
        ])
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        stack.setCustomSpacing(20, after: sub)
        stack.setCustomSpacing(24, after: confirmField)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        icon.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    @objc private func xttResetTapped() {
        view.endEditing(true)
        guard (newPasswordField.text ?? "") == (confirmField.text ?? "") else {
            xttShowAlert(title: "Mismatch", message: "Passwords do not match.")
            return
        }
        do {
            try XTTAuthService.shared.xttResetPassword(username: usernameField.text ?? "",
                                                       newPassword: newPasswordField.text ?? "")
            let alert = UIAlertController(title: "Password Reset",
                                          message: "Your password has been updated. Please log in.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
        } catch {
            xttShowAlert(title: "Reset Failed", message: error.localizedDescription)
        }
    }
}
