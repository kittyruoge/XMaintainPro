//
//  NXVCategory.swift
//  NexVaultPro
//
//  Asset category taxonomy.
//

import SwiftUI

/// The five top-level asset domains the system models.
enum NXVCategory: String, Codable, CaseIterable, Identifiable {
    case physical   = "Physical"
    case digital    = "Digital"
    case document   = "Document"
    case subscription = "Subscription"
    case finance    = "Finance"

    var id: String { rawValue }

    /// SF Symbol used on cards, lists, and the graph.
    var systemIcon: String {
        switch self {
        case .physical:     return "shippingbox.fill"
        case .digital:      return "desktopcomputer"
        case .document:     return "doc.text.fill"
        case .subscription: return "arrow.triangle.2.circlepath"
        case .finance:      return "creditcard.fill"
        }
    }

    var tint: Color {
        switch self {
        case .physical:     return .orange
        case .digital:      return .blue
        case .document:     return .purple
        case .subscription: return .pink
        case .finance:      return .green
        }
    }

    var label: String { rawValue }
}
