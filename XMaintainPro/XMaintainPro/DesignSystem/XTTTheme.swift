//
//  XTTTheme.swift
//  XMaintainPro
//
//  Central design system: colors, fonts, metrics.
//

import UIKit

enum XTTTheme {

    // MARK: - Palette (light, modern Apple style)
    enum Color {
        static var accent: UIColor { UIColor(hex: 0x2D6CDF) }          // deep blue
        static var accentSecondary: UIColor { UIColor(hex: 0x4FA3FF) } // light blue
        static var success: UIColor { UIColor(hex: 0x2BB673) }
        static var warning: UIColor { UIColor(hex: 0xF5A623) }
        static var danger: UIColor { UIColor(hex: 0xE65A5A) }
        static var purple: UIColor { UIColor(hex: 0x7A5CF0) }
        static var teal: UIColor { UIColor(hex: 0x14B8C4) }

        static var background: UIColor {
            UIColor { tc in
                tc.userInterfaceStyle == .dark ? UIColor(hex: 0x0E1116) : UIColor(hex: 0xF2F4F8)
            }
        }
        static var card: UIColor {
            UIColor { tc in
                tc.userInterfaceStyle == .dark ? UIColor(hex: 0x1B2129) : UIColor.white
            }
        }
        static var groupedCard: UIColor {
            UIColor { tc in
                tc.userInterfaceStyle == .dark ? UIColor(hex: 0x232B35) : UIColor(hex: 0xF7F9FC)
            }
        }
        static var primaryText: UIColor {
            UIColor { tc in
                tc.userInterfaceStyle == .dark ? UIColor(hex: 0xF5F7FA) : UIColor(hex: 0x1A2233)
            }
        }
        static var secondaryText: UIColor {
            UIColor { tc in
                tc.userInterfaceStyle == .dark ? UIColor(hex: 0x9AA6B6) : UIColor(hex: 0x6B778C)
            }
        }
        static var separator: UIColor {
            UIColor { tc in
                tc.userInterfaceStyle == .dark ? UIColor(hex: 0x2C3540) : UIColor(hex: 0xE2E7EF)
            }
        }
        static var fieldBackground: UIColor {
            UIColor { tc in
                tc.userInterfaceStyle == .dark ? UIColor(hex: 0x232B35) : UIColor(hex: 0xEFF2F7)
            }
        }

        static let gradientBlue: [UIColor] = [UIColor(hex: 0x2D6CDF), UIColor(hex: 0x4FA3FF)]
        static let gradientPurple: [UIColor] = [UIColor(hex: 0x7A5CF0), UIColor(hex: 0x4FA3FF)]
        static let gradientGreen: [UIColor] = [UIColor(hex: 0x2BB673), UIColor(hex: 0x14B8C4)]
        static let gradientOrange: [UIColor] = [UIColor(hex: 0xF5A623), UIColor(hex: 0xE65A5A)]
        static let gradientTeal: [UIColor] = [UIColor(hex: 0x14B8C4), UIColor(hex: 0x2D6CDF)]
    }

    // MARK: - Fonts
    enum Font {
        static func largeTitle() -> UIFont { .systemFont(ofSize: 32, weight: .bold) }
        static func title() -> UIFont { .systemFont(ofSize: 24, weight: .bold) }
        static func headline() -> UIFont { .systemFont(ofSize: 18, weight: .semibold) }
        static func body() -> UIFont { .systemFont(ofSize: 16, weight: .regular) }
        static func bodyMedium() -> UIFont { .systemFont(ofSize: 16, weight: .medium) }
        static func subhead() -> UIFont { .systemFont(ofSize: 14, weight: .regular) }
        static func caption() -> UIFont { .systemFont(ofSize: 12, weight: .medium) }
        static func mono() -> UIFont { .monospacedSystemFont(ofSize: 14, weight: .medium) }
    }

    // MARK: - Metrics
    enum Metric {
        static let cardRadius: CGFloat = 20
        static let buttonRadius: CGFloat = 16
        static let fieldRadius: CGFloat = 14
        static let spacing: CGFloat = 16
        static let smallSpacing: CGFloat = 8
        static let cardPadding: CGFloat = 16
    }
}

// MARK: - UIColor hex helper
extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
