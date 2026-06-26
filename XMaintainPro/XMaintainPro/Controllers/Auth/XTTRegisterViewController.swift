//
//  XTTRegisterViewController.swift
//  XMaintainPro
//

import UIKit

final class XTTRegisterViewController: UIViewController {

    private let nameField = XTTTextField(placeholder: "Display Name", icon: "person.text.rectangle.fill")
    private let usernameField = XTTTextField(placeholder: "Username", icon: "at")
    private let emailField = XTTTextField(placeholder: "Email", icon: "envelope.fill")
    private let passwordField = XTTTextField(placeholder: "Password", icon: "lock.fill", secure: true)
    private let confirmField = XTTTextField(placeholder: "Confirm Password", icon: "lock.rotation", secure: true)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        xttApplyBaseBackground()
        emailField.keyboardType = .emailAddress
        xttBuildUI()
        xttEnableTapToDismissKeyboard()
    }

    private func xttBuildUI() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.keyboardDismissMode = .interactive
        view.addSubview(scroll)
        scroll.xttPinEdges(to: view)

        let header = UILabel()
        header.text = "Join X Maintain Pro"
        header.font = XTTTheme.Font.title()
        header.textColor = XTTTheme.Color.primaryText

        let sub = UILabel()
        sub.text = "Create a local account to save and manage your maintenance data."
        sub.numberOfLines = 0
        sub.font = XTTTheme.Font.subhead()
        sub.textColor = XTTTheme.Color.secondaryText

        let createButton = XTTPrimaryButton(title: "Create Account")
        createButton.addTarget(self, action: #selector(xttCreateTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            header, sub, nameField, usernameField, emailField, passwordField, confirmField, createButton
        ])
        stack.axis = .vertical
        stack.spacing = 14
        stack.setCustomSpacing(20, after: sub)
        stack.setCustomSpacing(24, after: confirmField)
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -30)
        ])
    }

    @objc private func xttCreateTapped() {
        view.endEditing(true)
        guard (passwordField.text ?? "") == (confirmField.text ?? "") else {
            xttShowAlert(title: "Mismatch", message: "Passwords do not match.")
            return
        }
        do {
            try XTTAuthService.shared.xttRegister(username: usernameField.text ?? "",
                                                  displayName: nameField.text ?? "",
                                                  email: emailField.text ?? "",
                                                  password: passwordField.text ?? "")
            XTTSceneRouter.xttSetRootToMainApp()
        } catch {
            xttShowAlert(title: "Registration Failed", message: error.localizedDescription)
        }
    }
}
