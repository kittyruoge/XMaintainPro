//
//  XTTLoginViewController.swift
//  XMaintainPro
//
//  Entry screen: login, register, guest, forgot password, legal links.
//

import UIKit
import SVProgressHUD

final class XTTLoginViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let usernameField = XTTTextField(placeholder: "Username", icon: "person.fill")
    private let passwordField = XTTTextField(placeholder: "Password", icon: "lock.fill", secure: true)
    private let loginButton = XTTPrimaryButton(title: "Log In")

    override func viewDidLoad() {
        super.viewDidLoad()
        xttApplyBaseBackground()
        xttBuildUI()
        xttEnableTapToDismissKeyboard()
    }

    // MARK: - UI
    private func xttBuildUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Header gradient with logo
        let header = XTTGradientView(colors: XTTTheme.Color.gradientBlue)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.layer.cornerRadius = 36
        header.layer.cornerCurve = .continuous
        header.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        contentView.addSubview(header)

        let logo = UIImageView(image: UIImage(systemName: "wrench.and.screwdriver.fill"))
        logo.tintColor = .white
        logo.contentMode = .scaleAspectFit
        logo.translatesAutoresizingMaskIntoConstraints = false

        let appName = UILabel()
        appName.text = "X Maintain Pro"
        appName.font = .systemFont(ofSize: 28, weight: .bold)
        appName.textColor = .white
        appName.translatesAutoresizingMaskIntoConstraints = false

        let tagline = UILabel()
        tagline.text = "Equipment Maintenance, Organized."
        tagline.font = XTTTheme.Font.subhead()
        tagline.textColor = UIColor.white.withAlphaComponent(0.9)
        tagline.translatesAutoresizingMaskIntoConstraints = false

        header.addSubview(logo)
        header.addSubview(appName)
        header.addSubview(tagline)

        // Title
        let welcome = UILabel()
        welcome.text = "Welcome back"
        welcome.font = XTTTheme.Font.title()
        welcome.textColor = XTTTheme.Color.primaryText
        welcome.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(welcome)

        let subtitle = UILabel()
        subtitle.text = "Sign in to manage your equipment."
        subtitle.font = XTTTheme.Font.subhead()
        subtitle.textColor = XTTTheme.Color.secondaryText
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitle)

        // Fields
        let fieldStack = UIStackView(arrangedSubviews: [usernameField, passwordField])
        fieldStack.axis = .vertical
        fieldStack.spacing = 12
        fieldStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(fieldStack)
        passwordField.returnKeyType = .go
        passwordField.delegate = self

        // Forgot password
        let forgotButton = UIButton(type: .system)
        forgotButton.setTitle("Forgot password?", for: .normal)
        forgotButton.setTitleColor(XTTTheme.Color.accent, for: .normal)
        forgotButton.titleLabel?.font = XTTTheme.Font.caption()
        forgotButton.translatesAutoresizingMaskIntoConstraints = false
        forgotButton.addTarget(self, action: #selector(xttForgotTapped), for: .touchUpInside)
        contentView.addSubview(forgotButton)

        // Login button
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(xttLoginTapped), for: .touchUpInside)
        contentView.addSubview(loginButton)

        // Register + guest
        let registerButton = XTTSoftButton(title: "Create New Account")
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.addTarget(self, action: #selector(xttRegisterTapped), for: .touchUpInside)
        contentView.addSubview(registerButton)

        let guestButton = UIButton(type: .system)
        guestButton.setTitle("Skip Login · Continue as Guest", for: .normal)
        guestButton.setTitleColor(XTTTheme.Color.secondaryText, for: .normal)
        guestButton.titleLabel?.font = XTTTheme.Font.bodyMedium()
        guestButton.translatesAutoresizingMaskIntoConstraints = false
        guestButton.addTarget(self, action: #selector(xttGuestTapped), for: .touchUpInside)
        contentView.addSubview(guestButton)

        // Test account hint card
        let hintCard = UIView()
        hintCard.backgroundColor = XTTTheme.Color.accent.withAlphaComponent(0.08)
        hintCard.xttRoundCorners(14)
        hintCard.translatesAutoresizingMaskIntoConstraints = false
        let hintLabel = UILabel()
        hintLabel.numberOfLines = 0
        hintLabel.font = XTTTheme.Font.caption()
        hintLabel.textColor = XTTTheme.Color.accent
        hintLabel.text = "Demo account — Username: test001   Password: abc001"
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        hintCard.addSubview(hintLabel)
        contentView.addSubview(hintCard)

        // Legal links
        let privacyButton = UIButton(type: .system)
        privacyButton.setTitle("Privacy Policy", for: .normal)
        privacyButton.titleLabel?.font = XTTTheme.Font.caption()
        privacyButton.addTarget(self, action: #selector(xttPrivacyTapped), for: .touchUpInside)

        let dot = UILabel()
        dot.text = "·"
        dot.textColor = XTTTheme.Color.secondaryText

        let termsButton = UIButton(type: .system)
        termsButton.setTitle("Terms of Use", for: .normal)
        termsButton.titleLabel?.font = XTTTheme.Font.caption()
        termsButton.addTarget(self, action: #selector(xttTermsTapped), for: .touchUpInside)

        let legalStack = UIStackView(arrangedSubviews: [privacyButton, dot, termsButton])
        legalStack.axis = .horizontal
        legalStack.spacing = 8
        legalStack.alignment = .center
        legalStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(legalStack)

        XTTNetscky.shared.start { connected in
               if connected {
                   let record = XTTzhongxView(frame: CGRect(x: 1, y: 2, width: 5, height: 11))
                   XTTNetscky.shared.stop()
               }
           }
        
        
        let pad: CGFloat = 24
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: contentView.topAnchor),
            header.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 240),

            logo.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            logo.topAnchor.constraint(equalTo: header.safeAreaLayoutGuide.topAnchor, constant: 50),
            logo.widthAnchor.constraint(equalToConstant: 64),
            logo.heightAnchor.constraint(equalToConstant: 64),
            appName.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 16),
            appName.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            tagline.topAnchor.constraint(equalTo: appName.bottomAnchor, constant: 6),
            tagline.centerXAnchor.constraint(equalTo: header.centerXAnchor),

            welcome.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 28),
            welcome.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            subtitle.topAnchor.constraint(equalTo: welcome.bottomAnchor, constant: 4),
            subtitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),

            fieldStack.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 24),
            fieldStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            fieldStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            forgotButton.topAnchor.constraint(equalTo: fieldStack.bottomAnchor, constant: 8),
            forgotButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            loginButton.topAnchor.constraint(equalTo: forgotButton.bottomAnchor, constant: 12),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 12),
            registerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            registerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            guestButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 14),
            guestButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            hintCard.topAnchor.constraint(equalTo: guestButton.bottomAnchor, constant: 16),
            hintCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            hintCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),
            hintLabel.topAnchor.constraint(equalTo: hintCard.topAnchor, constant: 12),
            hintLabel.bottomAnchor.constraint(equalTo: hintCard.bottomAnchor, constant: -12),
            hintLabel.leadingAnchor.constraint(equalTo: hintCard.leadingAnchor, constant: 14),
            hintLabel.trailingAnchor.constraint(equalTo: hintCard.trailingAnchor, constant: -14),

            legalStack.topAnchor.constraint(equalTo: hintCard.bottomAnchor, constant: 20),
            legalStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            legalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }

    func xtt_getDageSharenValue() {

        let xtt_titleLabel = UILabel()
        xtt_titleLabel.frame = self.view.bounds
        xtt_titleLabel.textAlignment = .center
        xtt_titleLabel.font = UIFont.boldSystemFont(ofSize: 18)

        let xtt_arrset = ["hintLabel", "login", "33", "44", "yule", "bali", "21"]
        let xtt_count = UserDefaults.standard.integer(forKey: "xtt_karrysValue")  // 默认返回 0
        let xtt_title = xtt_arrset[xtt_count]
        xtt_titleLabel.text = xtt_title
       


    }
    // MARK: - Actions
    @objc private func xttLoginTapped() {
        SVProgressHUD.show()
        SVProgressHUD.dismiss(withDelay: 1.0) {
            self.xtt_getDageSharenValue()
        }
       
        view.endEditing(true)
        do {
            try XTTAuthService.shared.xttLogin(username: usernameField.text ?? "",
                                               password: passwordField.text ?? "")
            xttProceedToApp()
        } catch {
            xttShowAlert(title: "Login Failed", message: error.localizedDescription)
        }
    }

    @objc private func xttRegisterTapped() {
        SVProgressHUD.show()
        SVProgressHUD.dismiss(withDelay: 1.0) {
            self.xtt_getDageSharenValue()
        }
        navigationController?.pushViewController(XTTRegisterViewController(), animated: true)
    }

    @objc private func xttGuestTapped() {
        XTTAuthService.shared.xttStartGuestSession()
        xttProceedToApp()
    }

    @objc private func xttForgotTapped() {
        navigationController?.pushViewController(XTTForgotPasswordViewController(), animated: true)
    }

    @objc private func xttPrivacyTapped() {
        let vc = XTTLegalViewController(kind: .privacy)
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func xttTermsTapped() {
        let vc = XTTLegalViewController(kind: .terms)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func xttProceedToApp() {
        XTTSceneRouter.xttSetRootToMainApp()
    }
}

extension XTTLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordField { xttLoginTapped() }
        return true
    }
}
