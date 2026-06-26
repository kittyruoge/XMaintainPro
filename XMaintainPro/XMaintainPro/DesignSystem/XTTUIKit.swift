//
//  XTTUIKit.swift
//  XMaintainPro
//
//  Reusable UI helpers and view extensions.
//

import UIKit

// MARK: - UIView convenience
extension UIView {
    func xttAddSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }

    func xttApplyCardStyle(radius: CGFloat = XTTTheme.Metric.cardRadius) {
        backgroundColor = XTTTheme.Color.card
        layer.cornerRadius = radius
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 14
        layer.shadowOffset = CGSize(width: 0, height: 6)
    }

    func xttRoundCorners(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.cornerCurve = .continuous
        clipsToBounds = true
    }

    func xttPinEdges(to view: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        ])
    }
}

// MARK: - Gradient view
final class XTTGradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    init(colors: [UIColor],
         start: CGPoint = CGPoint(x: 0, y: 0),
         end: CGPoint = CGPoint(x: 1, y: 1)) {
        super.init(frame: .zero)
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = start
        gradientLayer.endPoint = end
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func xttUpdate(colors: [UIColor]) {
        gradientLayer.colors = colors.map { $0.cgColor }
    }
}

// MARK: - Primary gradient button
final class XTTPrimaryButton: UIButton {
    private let gradient = CAGradientLayer()
    private var colors: [UIColor]

    init(title: String, colors: [UIColor] = XTTTheme.Color.gradientBlue) {
        self.colors = colors
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = XTTTheme.Font.headline()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = XTTTheme.Metric.buttonRadius
        layer.insertSublayer(gradient, at: 0)
        layer.cornerRadius = XTTTheme.Metric.buttonRadius
        layer.cornerCurve = .continuous
        layer.shadowColor = colors.first?.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 6)
        heightAnchor.constraint(equalToConstant: 54).isActive = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
                self.alpha = self.isHighlighted ? 0.92 : 1.0
            }
        }
    }
}

// MARK: - Soft secondary button
final class XTTSoftButton: UIButton {
    init(title: String, tint: UIColor = XTTTheme.Color.accent) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(tint, for: .normal)
        titleLabel?.font = XTTTheme.Font.bodyMedium()
        backgroundColor = tint.withAlphaComponent(0.12)
        layer.cornerRadius = XTTTheme.Metric.buttonRadius
        layer.cornerCurve = .continuous
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Padded text field
final class XTTTextField: UITextField {
    private let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    private let iconName: String?

    init(placeholder: String, icon: String? = nil, secure: Bool = false) {
        self.iconName = icon
        super.init(frame: .zero)
        self.placeholder = placeholder
        isSecureTextEntry = secure
        font = XTTTheme.Font.body()
        textColor = XTTTheme.Color.primaryText
        backgroundColor = XTTTheme.Color.fieldBackground
        layer.cornerRadius = XTTTheme.Metric.fieldRadius
        layer.cornerCurve = .continuous
        autocorrectionType = .no
        autocapitalizationType = .none
        heightAnchor.constraint(equalToConstant: 52).isActive = true

        if let icon = icon {
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 52))
            let iv = UIImageView(image: UIImage(systemName: icon))
            iv.tintColor = XTTTheme.Color.secondaryText
            iv.contentMode = .scaleAspectFit
            iv.frame = CGRect(x: 14, y: 16, width: 20, height: 20)
            container.addSubview(iv)
            leftView = container
            leftViewMode = .always
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private var effectiveLeftInset: CGFloat { iconName == nil ? padding.left : 44 }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: UIEdgeInsets(top: 0, left: effectiveLeftInset, bottom: 0, right: padding.right))
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        textRect(forBounds: bounds)
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        textRect(forBounds: bounds)
    }
}

// MARK: - Chip (filter / tag)
final class XTTChip: UIControl {
    private let label = UILabel()
    var text: String { didSet { label.text = text } }
    var isSelectedChip: Bool = false { didSet { xttUpdateAppearance() } }
    private let tintColorValue: UIColor

    init(text: String, tint: UIColor = XTTTheme.Color.accent) {
        self.text = text
        self.tintColorValue = tint
        super.init(frame: .zero)
        label.text = text
        label.font = XTTTheme.Font.caption()
        label.textAlignment = .center
        addSubview(label)
        label.xttPinEdges(to: self, insets: UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 14))
        layer.cornerRadius = 15
        layer.cornerCurve = .continuous
        xttUpdateAppearance()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func xttUpdateAppearance() {
        if isSelectedChip {
            backgroundColor = tintColorValue
            label.textColor = .white
        } else {
            backgroundColor = tintColorValue.withAlphaComponent(0.12)
            label.textColor = tintColorValue
        }
    }
}

// MARK: - Empty state view
final class XTTEmptyStateView: UIView {
    init(icon: String, title: String, message: String) {
        super.init(frame: .zero)
        let iconBg = XTTGradientView(colors: [XTTTheme.Color.accent.withAlphaComponent(0.15),
                                              XTTTheme.Color.accentSecondary.withAlphaComponent(0.15)])
        iconBg.xttRoundCorners(28)
        iconBg.translatesAutoresizingMaskIntoConstraints = false

        let iv = UIImageView(image: UIImage(systemName: icon))
        iv.tintColor = XTTTheme.Color.accent
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = XTTTheme.Font.headline()
        titleLabel.textColor = XTTTheme.Color.primaryText
        titleLabel.textAlignment = .center

        let msgLabel = UILabel()
        msgLabel.text = message
        msgLabel.font = XTTTheme.Font.subhead()
        msgLabel.textColor = XTTTheme.Color.secondaryText
        msgLabel.textAlignment = .center
        msgLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [iconBg, titleLabel, msgLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.setCustomSpacing(20, after: iconBg)
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        iconBg.addSubview(iv)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -30),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -40),
            iconBg.widthAnchor.constraint(equalToConstant: 96),
            iconBg.heightAnchor.constraint(equalToConstant: 96),
            iv.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iv.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iv.widthAnchor.constraint(equalToConstant: 42),
            iv.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - UIViewController helpers
extension UIViewController {
    func xttShowToast(_ message: String) {
        let toast = PaddingLabel()
        toast.text = message
        toast.font = XTTTheme.Font.subhead()
        toast.textColor = .white
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.82)
        toast.numberOfLines = 0
        toast.textAlignment = .center
        toast.xttRoundCorners(14)
        toast.alpha = 0
        toast.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toast)
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            toast.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40)
        ])
        UIView.animate(withDuration: 0.25, animations: { toast.alpha = 1 }) { _ in
            UIView.animate(withDuration: 0.25, delay: 1.6, options: []) {
                toast.alpha = 0
            } completion: { _ in toast.removeFromSuperview() }
        }
    }

    func xttConfirmDelete(title: String = "Delete",
                          message: String,
                          confirmTitle: String = "Delete",
                          onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: confirmTitle, style: .destructive) { _ in onConfirm() })
        present(alert, animated: true)
    }

    func xttShowAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func xttApplyBaseBackground() {
        view.backgroundColor = XTTTheme.Color.background
    }

    /// Adds a tap recognizer that dismisses the keyboard when tapping outside a field.
    /// `cancelsTouchesInView = false` so taps still reach buttons, cells, and switches.
    func xttEnableTapToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}

// MARK: - Label with padding
class PaddingLabel: UILabel {
    var insets = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + insets.left + insets.right,
                      height: s.height + insets.top + insets.bottom)
    }
}

// MARK: - Date helpers
extension Date {
    func xttFormatted(_ style: DateFormatter.Style = .medium) -> String {
        let df = DateFormatter()
        df.dateStyle = style
        df.timeStyle = .none
        df.locale = Locale(identifier: "en_US")
        return df.string(from: self)
    }

    func xttDaysUntil(_ other: Date) -> Int {
        let cal = Calendar.current
        let a = cal.startOfDay(for: self)
        let b = cal.startOfDay(for: other)
        return cal.dateComponents([.day], from: a, to: b).day ?? 0
    }

    static func xttFrom(daysFromNow days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
    }
}
