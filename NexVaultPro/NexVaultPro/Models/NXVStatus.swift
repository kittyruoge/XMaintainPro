//
//  NXVStatus.swift
//  NexVaultPro
//
//  Lifecycle status produced by NXVLifecycleEngine.
//

import SwiftUI

/// The lifecycle state of an asset. Derived, never stored as ground truth.
enum NXVStatus: String, Codable {
    case active   = "Active"
    case expiring = "Expiring"
    case expired  = "Expired"
    case idle     = "Idle"

    var tint: Color {
        switch self {
        case .active:   return .green
        case .expiring: return .orange
        case .expired:  return .red
        case .idle:     return .gray
        }
    }

    var systemIcon: String {
        switch self {
        case .active:   return "checkmark.circle.fill"
        case .expiring: return "exclamationmark.triangle.fill"
        case .expired:  return "xmark.octagon.fill"
        case .idle:     return "moon.zzz.fill"
        }
    }
}

/// A coarse risk band used for color coding the 0–100 score.
enum NXVRiskBand: String {
    case low      = "Low"
    case moderate = "Moderate"
    case high     = "High"
    case critical = "Critical"

    init(score: Int) {
        switch score {
        case ..<25:   self = .low
        case 25..<55: self = .moderate
        case 55..<85: self = .high
        default:      self = .critical
        }
    }

    var tint: Color {
        switch self {
        case .low:      return .green
        case .moderate: return .yellow
        case .high:     return .orange
        case .critical: return .red
        }
    }
}
