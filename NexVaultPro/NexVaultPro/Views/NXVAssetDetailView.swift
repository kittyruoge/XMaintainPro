//
//  NXVAssetDetailView.swift
//  NexVaultPro
//
//  Lifecycle, risk breakdown, related assets, per-asset timeline.
//

import SwiftUI

struct NXVAssetDetailView: View {
    @EnvironmentObject private var store: NXVAssetStore
    let assetID: UUID
    @State private var showEdit = false
    @State private var showLink = false

    var body: some View {
        Group {
            if let asset = store.asset(with: assetID) {
                content(for: asset)
            } else {
                NXVEmptyState(systemImage: "questionmark.folder",
                              title: "Asset removed",
                              message: "This asset no longer exists.")
            }
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if store.asset(with: assetID) != nil {
                    Button("Edit") { showEdit = true }
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            if let asset = store.asset(with: assetID) {
                NXVAddAssetFlow(editing: asset)
            }
        }
        .sheet(isPresented: $showLink) {
            if let asset = store.asset(with: assetID) {
                NXVLinkAssetSheet(source: asset)
            }
        }
    }

    @ViewBuilder
    private func content(for asset: NXVAssetModel) -> some View {
        let status = store.status(for: asset)
        let risk = store.risk(for: asset)

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack(spacing: 14) {
                    NXVCategoryBadge(category: asset.category)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(asset.name).font(.title2.weight(.bold))
                        Text(asset.category.label).font(.subheadline).foregroundColor(.secondary)
                    }
                    Spacer()
                    NXVRiskDial(score: risk, size: 64)
                }

                // Lifecycle
                NXVCardSection(title: "Lifecycle") {
                    HStack {
                        NXVStatusPill(status: status)
                        Spacer()
                        Text(NXVLifecycleEngine.nxvStatusReason(for: asset))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    if let value = asset.value {
                        NXVKeyValueRow(key: "Value", value: NXVFormat.currency(value))
                    }
                    if let expiry = asset.expiryDate {
                        NXVKeyValueRow(key: "Expiry", value: NXVFormat.date(expiry))
                    }
                    NXVKeyValueRow(key: "Added", value: NXVFormat.date(asset.createdAt))
                    NXVKeyValueRow(key: "Last used", value: NXVFormat.relative(asset.lastUsedAt))
                }

                // Risk breakdown
                NXVCardSection(title: "Risk Breakdown") {
                    let factors = NXVRiskEngine.nxvRiskFactors(for: asset)
                    if factors.isEmpty {
                        Text("No risk factors. This asset is in good standing.")
                            .font(.subheadline).foregroundColor(.secondary)
                    } else {
                        ForEach(factors) { factor in
                            HStack {
                                Text(factor.label).font(.subheadline)
                                Spacer()
                                Text("+\(factor.points)")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }

                // Tags
                if !asset.tags.isEmpty {
                    NXVCardSection(title: "Tags") {
                        NXVWrapTags(tags: asset.tags)
                    }
                }

                // Related assets
                NXVCardSection(title: "Related Assets") {
                    let related = store.relatedAssets(of: asset)
                    if related.isEmpty {
                        Text("No linked assets. Link protection like warranties or insurance.")
                            .font(.subheadline).foregroundColor(.secondary)
                    } else {
                        ForEach(related) { rel in
                            NavigationLink {
                                NXVAssetDetailView(assetID: rel.id)
                            } label: {
                                HStack {
                                    Image(systemName: rel.category.systemIcon)
                                        .foregroundColor(rel.category.tint)
                                    Text(rel.name).foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption).foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    Button { showLink = true } label: {
                        Label("Link an asset", systemImage: "link.badge.plus")
                    }
                    .font(.subheadline)
                    .padding(.top, 4)
                }

                // Per-asset timeline
                NXVCardSection(title: "Timeline") {
                    let events = store.events(for: asset.id)
                    if events.isEmpty {
                        Text("No events recorded yet.")
                            .font(.subheadline).foregroundColor(.secondary)
                    } else {
                        ForEach(events) { event in
                            NXVTimelineRow(event: event, compact: true)
                        }
                    }
                }

                // Actions
                VStack(spacing: 10) {
                    Button {
                        store.nxvMarkUsed(asset)
                    } label: {
                        Label("Mark as used today", systemImage: "hand.tap.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    if asset.category == .subscription || asset.expiryDate != nil {
                        Button {
                            store.nxvRenew(asset, months: 1)
                        } label: {
                            Label("Renew 1 month", systemImage: "arrow.triangle.2.circlepath")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }

                    Button(role: .destructive) {
                        store.nxvDeleteAsset(asset)
                    } label: {
                        Label("Delete asset", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Detail helpers

struct NXVCardSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct NXVKeyValueRow: View {
    let key: String
    let value: String
    var body: some View {
        HStack {
            Text(key).font(.subheadline).foregroundColor(.secondary)
            Spacer()
            Text(value).font(.subheadline.weight(.medium))
        }
    }
}

struct NXVWrapTags: View {
    let tags: [String]
    var body: some View {
        // Simple flowing layout using an adaptive grid.
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.accentColor.opacity(0.15))
                    .foregroundColor(.accentColor)
                    .clipShape(Capsule())
            }
        }
    }
}
