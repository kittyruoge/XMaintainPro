//
//  NXVAnalyticsView.swift
//  NexVaultPro
//
//  Portfolio statistics with lightweight Canvas-drawn charts (iOS 15,
//  no Charts framework dependency).
//

import SwiftUI

struct NXVAnalyticsView: View {
    @EnvironmentObject private var store: NXVAssetStore

    private var byCategory: [(category: NXVCategory, count: Int, value: Double)] {
        NXVCategory.allCases.map { cat in
            let items = store.assets.filter { $0.category == cat }
            return (cat, items.count, items.reduce(0) { $0 + ($1.value ?? 0) })
        }.filter { $0.count > 0 }
    }

    private var riskBuckets: [(band: NXVRiskBand, count: Int)] {
        let scores = store.assets.map { store.risk(for: $0) }
        let bands: [NXVRiskBand] = [.low, .moderate, .high, .critical]
        return bands.map { band in
            (band, scores.filter { NXVRiskBand(score: $0) == band }.count)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                NXVCardSection(title: "Value by Category") {
                    if byCategory.isEmpty {
                        Text("No data yet.").font(.subheadline).foregroundColor(.secondary)
                    } else {
                        let maxValue = byCategory.map(\.value).max() ?? 1
                        ForEach(byCategory, id: \.category) { row in
                            NXVBar(label: row.category.label,
                                   value: row.value,
                                   fraction: maxValue > 0 ? row.value / maxValue : 0,
                                   tint: row.category.tint,
                                   trailing: NXVFormat.currency(row.value))
                        }
                    }
                }

                NXVCardSection(title: "Risk Distribution") {
                    let maxCount = riskBuckets.map(\.count).max() ?? 1
                    ForEach(riskBuckets, id: \.band) { row in
                        NXVBar(label: row.band.rawValue,
                               value: Double(row.count),
                               fraction: maxCount > 0 ? Double(row.count) / Double(maxCount) : 0,
                               tint: row.band.tint,
                               trailing: "\(row.count)")
                    }
                }

                NXVCardSection(title: "Portfolio") {
                    NXVKeyValueRow(key: "Total assets", value: "\(store.assets.count)")
                    NXVKeyValueRow(key: "Total value", value: NXVFormat.currency(store.totalValue))
                    NXVKeyValueRow(key: "Average risk", value: "\(store.averageRisk)/100")
                    NXVKeyValueRow(key: "Categories used", value: "\(byCategory.count)")
                }
            }
            .padding()
        }
        .navigationTitle("Analytics")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct NXVBar: View {
    let label: String
    let value: Double
    let fraction: Double
    let tint: Color
    let trailing: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label).font(.caption.weight(.medium))
                Spacer()
                Text(trailing).font(.caption).foregroundColor(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.15))
                    Capsule()
                        .fill(tint.nxvGradient)
                        .frame(width: max(6, geo.size.width * CGFloat(fraction)))
                }
            }
            .frame(height: 10)
        }
    }
}
