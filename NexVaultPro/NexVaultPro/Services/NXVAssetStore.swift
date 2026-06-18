//
//  NXVAssetStore.swift
//  NexVaultPro
//
//  The single source of truth shared across the app. Owns the asset
//  set + timeline, persists through NXVStorage, and exposes derived
//  views computed via the engines.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class NXVAssetStore: ObservableObject {
    @Published private(set) var assets: [NXVAssetModel] = []
    @Published private(set) var events: [NXVTimelineEvent] = []

    private let storage = NXVStorage.shared

    init(seedIfEmpty: Bool = true) {
        assets = storage.nxvLoadAssets()
        events = storage.nxvLoadEvents()
        if assets.isEmpty && seedIfEmpty {
            nxvSeedSampleData()
        }
    }

    // MARK: - Derived / computed views

    var totalValue: Double {
        assets.reduce(0) { $0 + ($1.value ?? 0) }
    }

    var insights: [NXVInsight] {
        NXVInsightEngine.nxvGenerateInsights(from: assets)
    }

    var averageRisk: Int {
        guard !assets.isEmpty else { return 0 }
        let sum = assets.map { NXVRiskEngine.nxvCalculateRisk(for: $0) }.reduce(0, +)
        return sum / assets.count
    }

    func status(for asset: NXVAssetModel) -> NXVStatus {
        NXVLifecycleEngine.nxvGetStatus(for: asset)
    }

    func risk(for asset: NXVAssetModel) -> Int {
        NXVRiskEngine.nxvCalculateRisk(for: asset)
    }

    func expiringSoon() -> [NXVAssetModel] {
        assets.filter { status(for: $0) == .expiring }
            .sorted { ($0.nxvDaysUntilExpiry() ?? 0) < ($1.nxvDaysUntilExpiry() ?? 0) }
    }

    func events(for assetID: UUID) -> [NXVTimelineEvent] {
        events.filter { $0.assetID == assetID }.sorted { $0.date > $1.date }
    }

    func asset(with id: UUID) -> NXVAssetModel? {
        assets.first { $0.id == id }
    }

    func relatedAssets(of asset: NXVAssetModel) -> [NXVAssetModel] {
        asset.relatedAssetIDs.compactMap { id in assets.first { $0.id == id } }
    }

    // MARK: - Mutations

    func nxvAddAsset(_ asset: NXVAssetModel) {
        assets.append(asset)
        nxvRecord(.added, on: asset, detail: asset.category.label)
        persist()
    }

    func nxvUpdateAsset(_ asset: NXVAssetModel) {
        guard let idx = assets.firstIndex(where: { $0.id == asset.id }) else { return }
        let old = assets[idx]
        assets[idx] = asset
        if old.value != asset.value {
            nxvRecord(.valueChanged, on: asset,
                      detail: "\(nxvFormatCurrency(old.value)) → \(nxvFormatCurrency(asset.value))")
        } else {
            nxvRecord(.edited, on: asset)
        }
        persist()
    }

    func nxvDeleteAsset(_ asset: NXVAssetModel) {
        assets.removeAll { $0.id == asset.id }
        // Drop dangling relationships.
        for i in assets.indices {
            assets[i].relatedAssetIDs.removeAll { $0 == asset.id }
        }
        events.removeAll { $0.assetID == asset.id }
        persist()
    }

    func nxvMarkUsed(_ asset: NXVAssetModel) {
        guard let idx = assets.firstIndex(where: { $0.id == asset.id }) else { return }
        assets[idx].lastUsedAt = Date()
        nxvRecord(.usedRecently, on: assets[idx])
        persist()
    }

    func nxvRenew(_ asset: NXVAssetModel, months: Int = 1) {
        guard let idx = assets.firstIndex(where: { $0.id == asset.id }) else { return }
        let base = assets[idx].expiryDate ?? Date()
        assets[idx].expiryDate = Calendar.current.date(byAdding: .month, value: months, to: base)
        nxvRecord(.renewed, on: assets[idx], detail: "+\(months) month\(months == 1 ? "" : "s")")
        persist()
    }

    func nxvLink(_ a: NXVAssetModel, to b: NXVAssetModel) {
        guard a.id != b.id,
              let ia = assets.firstIndex(where: { $0.id == a.id }),
              let ib = assets.firstIndex(where: { $0.id == b.id }) else { return }
        if !assets[ia].relatedAssetIDs.contains(b.id) { assets[ia].relatedAssetIDs.append(b.id) }
        if !assets[ib].relatedAssetIDs.contains(a.id) { assets[ib].relatedAssetIDs.append(a.id) }
        nxvRecord(.relationshipAdded, on: assets[ia], detail: "Linked to \(b.name)")
        persist()
    }

    // MARK: - Internals

    private func nxvRecord(_ kind: NXVTimelineEvent.Kind, on asset: NXVAssetModel, detail: String = "") {
        events.append(NXVTimelineEvent(assetID: asset.id, assetName: asset.name, kind: kind, detail: detail))
    }

    private func persist() {
        storage.nxvSaveAssets(assets)
        storage.nxvSaveEvents(events)
    }

    private func nxvFormatCurrency(_ value: Double?) -> String {
        guard let value else { return "—" }
        return NXVFormat.currency(value)
    }

    // MARK: - Seed data

    private func nxvSeedSampleData() {
        let now = Date()
        func daysFromNow(_ d: Int) -> Date { Calendar.current.date(byAdding: .day, value: d, to: now)! }

        let iphone = NXVAssetModel(
            name: "iPhone 15 Pro", category: .physical, value: 1199,
            tags: ["Apple", "Device"], lastUsedAt: now)
        let appleCare = NXVAssetModel(
            name: "AppleCare+", category: .finance, value: 199,
            expiryDate: daysFromNow(220), tags: ["Insurance"])
        let netflix = NXVAssetModel(
            name: "Netflix", category: .subscription, value: 15.49,
            expiryDate: daysFromNow(12), tags: ["Streaming"], renewsMonthly: true)
        let spotify = NXVAssetModel(
            name: "Spotify", category: .subscription, value: 11.99,
            expiryDate: daysFromNow(25), tags: ["Music"], renewsMonthly: true)
        let icloud = NXVAssetModel(
            name: "iCloud+ 2TB", category: .subscription, value: 9.99,
            expiryDate: daysFromNow(8), tags: ["Storage"], renewsMonthly: true)
        let passport = NXVAssetModel(
            name: "Passport", category: .document, value: nil,
            expiryDate: daysFromNow(40), tags: ["Travel", "ID"])
        let insurance = NXVAssetModel(
            name: "Health Insurance Card", category: .document, value: nil,
            expiryDate: daysFromNow(-5), tags: ["Health"],
            lastUsedAt: Calendar.current.date(byAdding: .day, value: -120, to: now)!)
        let oldLaptop = NXVAssetModel(
            name: "MacBook Air 2017", category: .physical, value: 1300,
            tags: ["Apple", "Laptop"],
            lastUsedAt: Calendar.current.date(byAdding: .day, value: -150, to: now)!)

        var seeded = [iphone, appleCare, netflix, spotify, icloud, passport, insurance, oldLaptop]

        // iPhone → AppleCare relationship.
        if let i = seeded.firstIndex(where: { $0.id == iphone.id }),
           let j = seeded.firstIndex(where: { $0.id == appleCare.id }) {
            seeded[i].relatedAssetIDs.append(appleCare.id)
            seeded[j].relatedAssetIDs.append(iphone.id)
        }

        assets = seeded
        for a in seeded {
            events.append(NXVTimelineEvent(assetID: a.id, assetName: a.name, kind: .added,
                                           detail: a.category.label,
                                           date: Calendar.current.date(byAdding: .hour, value: -seeded.firstIndex(of: a)!, to: now)!))
        }
        persist()
    }
}
