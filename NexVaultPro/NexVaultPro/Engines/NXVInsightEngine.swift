//
//  NXVInsightEngine.swift
//  NexVaultPro
//
//  Generates portfolio-level conclusions across the whole asset set.
//  This is the "system tells the user" layer.
//

import Foundation

enum NXVInsightEngine {

    static func nxvGenerateInsights(from assets: [NXVAssetModel], reference: Date = Date()) -> [NXVInsight] {
        var out: [NXVInsight] = []

        // 1. Subscriptions billing soon.
        let billingSoon = assets.filter { asset -> Bool in
            guard asset.category == .subscription else { return false }
            guard let days = asset.nxvDaysUntilExpiry(reference: reference) else { return false }
            return days >= 0 && days <= NXVLifecycleEngine.expiringThresholdDays
        }
        if billingSoon.count >= 1 {
            out.append(NXVInsight(
                title: "\(billingSoon.count) subscription\(billingSoon.count == 1 ? "" : "s") billing soon",
                message: billingSoon.map(\.name).joined(separator: ", ") + " will renew within 30 days.",
                severity: billingSoon.count >= 3 ? .warning : .info,
                relatedAssetIDs: billingSoon.map(\.id)))
        }

        // 2. Idle assets.
        let idle = assets.filter { NXVLifecycleEngine.nxvGetStatus(for: $0, reference: reference) == .idle }
        if !idle.isEmpty {
            out.append(NXVInsight(
                title: "\(idle.count) asset\(idle.count == 1 ? "" : "s") sitting idle",
                message: "These haven't been used in 90+ days: " + idle.prefix(3).map(\.name).joined(separator: ", ") + ".",
                severity: .info,
                relatedAssetIDs: idle.map(\.id)))
        }

        // 3. High-value assets lacking protection.
        let exposed = assets.filter { $0.nxvIsHighValue && $0.relatedAssetIDs.isEmpty }
        if !exposed.isEmpty {
            out.append(NXVInsight(
                title: "High-value assets lack protection",
                message: "\(exposed.count) valuable asset\(exposed.count == 1 ? " has" : "s have") no linked insurance or warranty.",
                severity: .warning,
                relatedAssetIDs: exposed.map(\.id)))
        }

        // 4. Expired items.
        let expired = assets.filter { NXVLifecycleEngine.nxvGetStatus(for: $0, reference: reference) == .expired }
        if !expired.isEmpty {
            out.append(NXVInsight(
                title: "\(expired.count) expired asset\(expired.count == 1 ? "" : "s")",
                message: "Action needed: " + expired.prefix(3).map(\.name).joined(separator: ", ") + ".",
                severity: .critical,
                relatedAssetIDs: expired.map(\.id)))
        }

        // 5. Duplicate-charge heuristic: multiple subscriptions sharing a tag.
        let subs = assets.filter { $0.category == .subscription }
        if subs.count >= 3 {
            out.append(NXVInsight(
                title: "Possible overlapping subscriptions",
                message: "You're paying for \(subs.count) subscriptions. Review them for duplicate value.",
                severity: .info,
                relatedAssetIDs: subs.map(\.id)))
        }

        // 6. Rising portfolio risk.
        let avgRisk = assets.isEmpty ? 0 :
            assets.map { NXVRiskEngine.nxvCalculateRisk(for: $0, reference: reference) }.reduce(0, +) / assets.count
        if avgRisk >= 55 {
            out.append(NXVInsight(
                title: "Portfolio risk is elevated",
                message: "Average risk across your assets is \(avgRisk)/100. Address expiring and expired items first.",
                severity: .warning,
                relatedAssetIDs: []))
        }

        return out.sorted { $0.severity > $1.severity }
    }
}
