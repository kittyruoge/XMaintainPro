//
//  NXVTimelineEvent.swift
//  NexVaultPro
//
//  An event in an asset's life — the unit of the Timeline feed.
//

import Foundation

struct NXVTimelineEvent: Identifiable, Codable, Equatable {
    enum Kind: String, Codable {
        case added            = "Added"
        case valueChanged     = "Value changed"
        case renewed          = "Renewed"
        case expiringSoon     = "Expiring soon"
        case expired          = "Expired"
        case usedRecently     = "Marked as used"
        case edited           = "Edited"
        case relationshipAdded = "Linked"

        var systemIcon: String {
            switch self {
            case .added:             return "plus.circle.fill"
            case .valueChanged:      return "dollarsign.arrow.circlepath"
            case .renewed:           return "arrow.triangle.2.circlepath"
            case .expiringSoon:      return "exclamationmark.triangle.fill"
            case .expired:           return "xmark.octagon.fill"
            case .usedRecently:      return "hand.tap.fill"
            case .edited:            return "pencil"
            case .relationshipAdded: return "link"
            }
        }
    }

    let id: UUID
    let assetID: UUID
    let assetName: String
    let kind: Kind
    let detail: String
    let date: Date

    init(id: UUID = UUID(),
         assetID: UUID,
         assetName: String,
         kind: Kind,
         detail: String = "",
         date: Date = Date()) {
        self.id = id
        self.assetID = assetID
        self.assetName = assetName
        self.kind = kind
        self.detail = detail
        self.date = date
    }
}
