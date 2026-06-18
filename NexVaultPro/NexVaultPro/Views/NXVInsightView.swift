//
//  NXVInsightView.swift
//  NexVaultPro
//
//  System-generated conclusions across the whole portfolio.
//

import SwiftUI

struct NXVInsightView: View {
    @EnvironmentObject private var store: NXVAssetStore

    var body: some View {
        let insights = store.insights
        Group {
            if insights.isEmpty {
                NXVEmptyState(systemImage: "checkmark.seal.fill",
                              title: "All clear",
                              message: "NexVault found nothing that needs your attention right now.")
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(insights) { insight in
                            NXVInsightDetailCard(insight: insight)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Insights")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct NXVInsightDetailCard: View {
    @EnvironmentObject private var store: NXVAssetStore
    let insight: NXVInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: insight.severity.systemIcon)
                    .foregroundColor(insight.severity.tint)
                    .font(.title3)
                Text(insight.title).font(.headline)
                Spacer()
            }
            Text(insight.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            let related = insight.relatedAssetIDs.compactMap { store.asset(with: $0) }
            if !related.isEmpty {
                Divider()
                ForEach(related.prefix(5)) { asset in
                    NavigationLink {
                        NXVAssetDetailView(assetID: asset.id)
                    } label: {
                        HStack {
                            Image(systemName: asset.category.systemIcon)
                                .foregroundColor(asset.category.tint)
                            Text(asset.name).foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption).foregroundColor(.secondary)
                        }
                        .font(.subheadline)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(insight.severity.tint.opacity(0.3), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
