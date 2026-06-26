//
//  XTTFormKit.swift
//  XMaintainPro
//
//  Lightweight form field builders shared by all edit screens.
//

import UIKit

// MARK: - Labeled text field row
final class XTTFormField: UIView {
    let textField = UITextField()
    private let titleLabel = UILabel()

    init(title: String, placeholder: String, value: String = "", keyboard: UIKeyboardType = .default) {
        super.init(frame: .zero)
        titleLabel.text = title.uppercased()
        titleLabel.font = XTTTheme.Font.caption()
        titleLabel.textColor = XTTTheme.Color.secondaryText

        textField.placeholder = placeholder
        textField.text = value
        textField.font = XTTTheme.Font.body()
        textField.textColor = XTTTheme.Color.primaryText
        textField.keyboardType = keyboard
        textField.backgroundColor = XTTTheme.Color.fieldBackground
        textField.xttRoundCorners(XTTTheme.Metric.fieldRadius)
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        let pad = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 50))
        textField.leftView = pad
        textField.leftViewMode = .always
        let padR = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 50))
        textField.rightView = padR
        textField.rightViewMode = .always

        let stack = UIStackView(arrangedSubviews: [titleLabel, textField])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        stack.xttPinEdges(to: self)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    var value: String { textField.text ?? "" }
}

// MARK: - Multiline notes field
final class XTTFormTextView: UIView {
    let textView = UITextView()
    private let titleLabel = UILabel()
    private let placeholderLabel = UILabel()

    init(title: String, placeholder: String, value: String = "") {
        super.init(frame: .zero)
        titleLabel.text = title.uppercased()
        titleLabel.font = XTTTheme.Font.caption()
        titleLabel.textColor = XTTTheme.Color.secondaryText

        textView.text = value
        textView.font = XTTTheme.Font.body()
        textView.textColor = XTTTheme.Color.primaryText
        textView.backgroundColor = XTTTheme.Color.fieldBackground
        textView.xttRoundCorners(XTTTheme.Metric.fieldRadius)
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        textView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        textView.delegate = self

        placeholderLabel.text = placeholder
        placeholderLabel.font = XTTTheme.Font.body()
        placeholderLabel.textColor = XTTTheme.Color.secondaryText
        placeholderLabel.isHidden = !value.isEmpty
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [titleLabel, textView])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        stack.xttPinEdges(to: self)
        textView.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 14)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    var value: String { textView.text ?? "" }
}

extension XTTFormTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

// MARK: - Segmented selector row (for enums)
final class XTTFormSegment: UIView {
    let segmented: UISegmentedControl
    private let titleLabel = UILabel()

    init(title: String, options: [String], selectedIndex: Int = 0) {
        segmented = UISegmentedControl(items: options)
        super.init(frame: .zero)
        titleLabel.text = title.uppercased()
        titleLabel.font = XTTTheme.Font.caption()
        titleLabel.textColor = XTTTheme.Color.secondaryText

        segmented.selectedSegmentIndex = selectedIndex
        segmented.selectedSegmentTintColor = XTTTheme.Color.accent
        segmented.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)

        let stack = UIStackView(arrangedSubviews: [titleLabel, segmented])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        stack.xttPinEdges(to: self)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    var selectedIndex: Int { segmented.selectedSegmentIndex }
}

// MARK: - Tappable picker row (date / selection)
final class XTTFormPicker: UIControl {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    init(title: String, value: String) {
        super.init(frame: .zero)
        titleLabel.text = title.uppercased()
        titleLabel.font = XTTTheme.Font.caption()
        titleLabel.textColor = XTTTheme.Color.secondaryText

        valueLabel.text = value
        valueLabel.font = XTTTheme.Font.body()
        valueLabel.textColor = XTTTheme.Color.primaryText

        let chevron = UIImageView(image: UIImage(systemName: "chevron.up.chevron.down"))
        chevron.tintColor = XTTTheme.Color.secondaryText
        chevron.contentMode = .scaleAspectFit
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        let box = UIView()
        box.backgroundColor = XTTTheme.Color.fieldBackground
        box.xttRoundCorners(XTTTheme.Metric.fieldRadius)
        box.isUserInteractionEnabled = false
        box.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let inner = UIStackView(arrangedSubviews: [valueLabel, chevron])
        inner.axis = .horizontal
        inner.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(inner)
        inner.xttPinEdges(to: box, insets: UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14))

        let stack = UIStackView(arrangedSubviews: [titleLabel, box])
        stack.axis = .vertical
        stack.spacing = 6
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        stack.xttPinEdges(to: self)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func xttSetValue(_ text: String) { valueLabel.text = text }
}
