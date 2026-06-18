//
//  NXVRiskEngine.swift
//  NexVaultPro
//
//  Computes a 0–100 risk score per asset from weighted signals.
//

import Foundation

enum NXVRiskEngine {

    /// A single weighted contribution to the score, surfaced in the UI
    /// so the user understands *why* the number is what it is.
    struct Factor: Identifiable {
        let id = UUID()
        let label: String
        let points: Int
    }

    /// Returns the contributing factors (before clamping) for an asset.
    static func nxvRiskFactors(for asset: NXVAssetModel, reference: Date = Date()) -> [Factor] {
        var factors: [Factor] = []

        let status = NXVLifecycleEngine.nxvGetStatus(for: asset, reference: reference)

        if asset.expiryDate != nil {
            factors.append(Factor(label: "Has an expiry date", points: 30))
        }
        if asset.nxvIsHighValue {
            factors.append(Factor(label: "High value (≥ $1,000)", points: 20))
        }
        switch status {
        case .expiring:
            factors.append(Factor(label: "Expiring within 30 days", points: 40))
        case .expired:
            factors.append(Factor(label: "Already expired", points: 100))
        case .idle:
            factors.append(Factor(label: "Idle 90+ days", points: 15))
        case .active:
            break
        }
        if asset.category == .subscription && asset.renewsMonthly {
            factors.append(Factor(label: "Recurring monthly charge", points: 10))
        }
        // High-value items with no protective relationships are exposed.
        if asset.nxvIsHighValue && asset.relatedAssetIDs.isEmpty {
            factors.append(Factor(label: "High value with no linked protection", points: 15))
        }
        return factors
    }

    /// The clamped 0–100 risk score.
    static func nxvCalculateRisk(for asset: NXVAssetModel, reference: Date = Date()) -> Int {
        let total = nxvRiskFactors(for: asset, reference: reference)
            .reduce(0) { $0 + $1.points }
        return min(100, max(0, total))
    }
}
