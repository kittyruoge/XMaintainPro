//
//  XTTSharedViews.swift
//  XMaintainPro
//
//  Reusable cells, headers and section components used across modules.
//

import UIKit

// MARK: - Generic info card cell (used by most list screens)
final class XTTListCardCell: UITableViewCell {
    static let reuseID = "XTTListCardCell"

    private let card = UIView()
    private let iconContainer = XTTGradientView(colors: XTTTheme.Color.gradientBlue)
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let detailLabel = UILabel()
    private let badge = PaddingLabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        xttBuild()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func xttBuild() {
        card.xttApplyCardStyle(radius: 18)
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)

        iconContainer.xttRoundCorners(14)
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconView)

        titleLabel.font = XTTTheme.Font.bodyMedium()
        titleLabel.textColor = XTTTheme.Color.primaryText
        subtitleLabel.font = XTTTheme.Font.subhead()
        subtitleLabel.textColor = XTTTheme.Color.secondaryText
        detailLabel.font = XTTTheme.Font.caption()
        detailLabel.textColor = XTTTheme.Color.secondaryText

        badge.font = XTTTheme.Font.caption()
        badge.textColor = .white
        badge.insets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        badge.xttRoundCorners(9)
        badge.clipsToBounds = true

        chevron.tintColor = XTTTheme.Color.separator
        chevron.contentMode = .scaleAspectFit

        [iconContainer, titleLabel, subtitleLabel, detailLabel, badge, chevron].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview($0)
        }

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            iconContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            iconContainer.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 46),
            iconContainer.heightAnchor.constraint(equalToConstant: 46),
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: badge.leadingAnchor, constant: -8),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),

            detailLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 3),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),
            detailLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),

            badge.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            badge.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),

            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 12)
        ])
    }

    func xttConfigure(icon: String,
                      gradient: [UIColor],
                      title: String,
                      subtitle: String,
                      detail: String,
                      badgeText: String? = nil,
                      badgeColor: UIColor = XTTTheme.Color.accent) {
        iconView.image = UIImage(systemName: icon)
        iconContainer.xttUpdate(colors: gradient)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        detailLabel.text = detail
        if let badgeText = badgeText {
            badge.text = badgeText
            badge.backgroundColor = badgeColor
            badge.isHidden = false
        } else {
            badge.isHidden = true
        }
    }
}

// MARK: - Section header used in detail screens
final class XTTSectionHeaderView: UIView {
    init(title: String) {
        super.init(frame: .zero)
        let label = UILabel()
        label.text = title.uppercased()
        label.font = XTTTheme.Font.caption()
        label.textColor = XTTTheme.Color.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Key/value detail row
final class XTTDetailRow: UIView {
    init(label: String, value: String, valueColor: UIColor? = nil) {
        super.init(frame: .zero)
        let l = UILabel()
        l.text = label
        l.font = XTTTheme.Font.subhead()
        l.textColor = XTTTheme.Color.secondaryText
        l.setContentHuggingPriority(.required, for: .horizontal)

        let v = UILabel()
        v.text = value.isEmpty ? "—" : value
        v.font = XTTTheme.Font.bodyMedium()
        v.textColor = valueColor ?? XTTTheme.Color.primaryText
        v.textAlignment = .right
        v.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [l, v])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .firstBaseline
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        stack.xttPinEdges(to: self, insets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
        l.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.45).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Status pill
final class XTTStatusPill: PaddingLabel {
    init(text: String, color: UIColor) {
        super.init(frame: .zero)
        self.text = text
        font = XTTTheme.Font.caption()
        textColor = color
        backgroundColor = color.withAlphaComponent(0.15)
        insets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
        xttRoundCorners(11)
        clipsToBounds = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Priority / status color mapping
enum XTTColorMap {
    static func priority(_ p: XTTPriority) -> UIColor {
        switch p {
        case .low: return XTTTheme.Color.success
        case .medium: return XTTTheme.Color.accent
        case .high: return XTTTheme.Color.warning
        case .critical: return XTTTheme.Color.danger
        }
    }
    static func maintenanceStatus(_ s: XTTMaintenanceStatus) -> UIColor {
        switch s {
        case .scheduled: return XTTTheme.Color.accent
        case .inProgress: return XTTTheme.Color.purple
        case .completed: return XTTTheme.Color.success
        case .overdue: return XTTTheme.Color.danger
        }
    }
    static func warranty(_ s: XTTWarrantyStatus) -> UIColor {
        switch s {
        case .active: return XTTTheme.Color.success
        case .expiringSoon: return XTTTheme.Color.warning
        case .expired: return XTTTheme.Color.danger
        }
    }
}
