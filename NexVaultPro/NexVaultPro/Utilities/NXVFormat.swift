//
//  NXVFormat.swift
//  NexVaultPro
//
//  Shared formatting helpers.
//

import Foundation
import SwiftUI

extension Color {
    /// iOS 15-compatible stand-in for the iOS 16 `Color.gradient`.
    /// A subtle top-to-bottom shade of the base color.
    var nxvGradient: LinearGradient {
        LinearGradient(
            colors: [self, self.opacity(0.75)],
            startPoint: .top,
            endPoint: .bottom)
    }
}

enum NXVFormat {
    static func currency(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.maximumFractionDigits = value.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        return f.string(from: NSNumber(value: value)) ?? "$\(value)"
    }

    static func date(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }

    static func relative(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .full
        return f.localizedString(for: date, relativeTo: Date())
    }
}
