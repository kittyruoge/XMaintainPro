//
//  NXVInsight.swift
//  NexVaultPro
//
//  A system-generated conclusion produced by NXVInsightEngine.
//

import SwiftUI

struct NXVInsight: Identifiable, Equatable {
    enum Severity: Int, Comparable {
        case info = 0
        case warning = 1
        case critical = 2

        static func < (lhs: Severity, rhs: Severity) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        var tint: Color {
            switch self {
            case .info:     return .blue
            case .warning:  return .orange
            case .critical: return .red
            }
        }

        var systemIcon: String {
            switch self {
            case .info:     return "lightbulb.fill"
            case .warning:  return "exclamationmark.triangle.fill"
            case .critical: return "exclamationmark.octagon.fill"
            }
        }
    }

    let id = UUID()
    let title: String
    let message: String
    let severity: Severity
    /// Assets this insight references, for tap-through.
    let relatedAssetIDs: [UUID]

    static func == (lhs: NXVInsight, rhs: NXVInsight) -> Bool {
        lhs.title == rhs.title && lhs.message == rhs.message
    }
}
