//
//  NXVAssetModel.swift
//  NexVaultPro
//
//  The core asset entity. Stores raw facts only — status and risk
//  are computed on demand by the engines.
//

import Foundation

struct NXVAssetModel: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var category: NXVCategory
    var value: Double?          // optional monetary value
    var expiryDate: Date?       // optional expiry
    var tags: [String]
    var note: String

    var createdAt: Date
    var lastUsedAt: Date        // drives idle detection
    var renewsMonthly: Bool     // subscription billing flag

    /// IDs of assets this one relates to (e.g. iPhone → AppleCare).
    var relatedAssetIDs: [UUID]

    init(id: UUID = UUID(),
         name: String,
         category: NXVCategory,
         value: Double? = nil,
         expiryDate: Date? = nil,
         tags: [String] = [],
         note: String = "",
         createdAt: Date = Date(),
         lastUsedAt: Date = Date(),
         renewsMonthly: Bool = false,
         relatedAssetIDs: [UUID] = []) {
        self.id = id
        self.name = name
        self.category = category
        self.value = value
        self.expiryDate = expiryDate
        self.tags = tags
        self.note = note
        self.createdAt = createdAt
        self.lastUsedAt = lastUsedAt
        self.renewsMonthly = renewsMonthly
        self.relatedAssetIDs = relatedAssetIDs
    }
}

extension NXVAssetModel {
    /// Days since the asset was last used. Negative values clamped to 0.
    func nxvDaysIdle(reference: Date = Date()) -> Int {
        max(0, Calendar.current.dateComponents([.day], from: lastUsedAt, to: reference).day ?? 0)
    }

    /// Days until expiry. nil if no expiry set. Negative means already expired.
    func nxvDaysUntilExpiry(reference: Date = Date()) -> Int? {
        guard let expiryDate else { return nil }
        return Calendar.current.dateComponents([.day], from: reference, to: expiryDate).day
    }

    var nxvIsHighValue: Bool { (value ?? 0) >= 1000 }
}
