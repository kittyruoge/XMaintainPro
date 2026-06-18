//
//  NXVLifecycleEngine.swift
//  NexVaultPro
//
//  Derives lifecycle status from an asset's raw facts.
//  Pure functions — no state, no storage.
//

import Foundation

enum NXVLifecycleEngine {

    /// Days-before-expiry threshold that flips an asset to `.expiring`.
    static let expiringThresholdDays = 30
    /// Idle-days threshold that flips an unexpiring asset to `.idle`.
    static let idleThresholdDays = 90

    /// The headline status shown on the card.
    static func nxvGetStatus(for asset: NXVAssetModel, reference: Date = Date()) -> NXVStatus {
        if let days = asset.nxvDaysUntilExpiry(reference: reference) {
            if days < 0 { return .expired }
            if days <= expiringThresholdDays { return .expiring }
        }
        if asset.nxvDaysIdle(reference: reference) >= idleThresholdDays {
            return .idle
        }
        return .active
    }

    /// Human-readable one-liner describing why the asset is in its state.
    static func nxvStatusReason(for asset: NXVAssetModel, reference: Date = Date()) -> String {
        switch nxvGetStatus(for: asset, reference: reference) {
        case .expired:
            if let d = asset.nxvDaysUntilExpiry(reference: reference) {
                return "Expired \(abs(d)) day\(abs(d) == 1 ? "" : "s") ago"
            }
            return "Expired"
        case .expiring:
            let d = asset.nxvDaysUntilExpiry(reference: reference) ?? 0
            return "Expires in \(d) day\(d == 1 ? "" : "s")"
        case .idle:
            return "Idle for \(asset.nxvDaysIdle(reference: reference)) days"
        case .active:
            return "In good standing"
        }
    }
}
