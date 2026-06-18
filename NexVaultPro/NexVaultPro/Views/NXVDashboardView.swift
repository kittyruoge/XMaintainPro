//
//  NXVDashboardView.swift
//  NexVaultPro
//
//  Home: portfolio summary, risk, expiring soon, top insights.
//

import SwiftUI
import Network

struct NXVDashboardView: View {
    @EnvironmentObject private var store: NXVAssetStore
    @State private var showAdd = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LazyVGrid(columns: columns, spacing: 12) {
                    NXVStatTile(title: "Total Assets",
                                value: "\(store.assets.count)",
                                systemImage: "tray.full.fill", tint: .blue)
                    NXVStatTile(title: "Total Value",
                                value: NXVFormat.currency(store.totalValue),
                                systemImage: "dollarsign.circle.fill", tint: .green)
                    NXVStatTile(title: "Avg Risk",
                                value: "\(store.averageRisk)/100",
                                systemImage: "gauge.with.dots.needle.67percent",
                                tint: NXVRiskBand(score: store.averageRisk).tint)
                    NXVStatTile(title: "Expiring Soon",
                                value: "\(store.expiringSoon().count)",
                                systemImage: "exclamationmark.triangle.fill", tint: .orange)
                }

                // Expiring soon
                let expiring = store.expiringSoon()
                if !expiring.isEmpty {
                    NXVSectionHeader(title: "Expiring Soon")
                    ForEach(expiring) { asset in
                        NavigationLink {
                            NXVAssetDetailView(assetID: asset.id)
                        } label: {
                            NXVAssetCard(asset: asset,
                                         status: store.status(for: asset),
                                         risk: store.risk(for: asset))
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Top insights
                let insights = Array(store.insights.prefix(3))
                if !insights.isEmpty {
                    NXVSectionHeader(title: "Insights")
                    ForEach(insights) { insight in
                        NXVInsightCard(insight: insight)
                    }
                }

                if store.assets.isEmpty {
                    NXVEmptyState(systemImage: "shippingbox",
                                  title: "No assets yet",
                                  message: "Tap + to add your first asset and let NexVault analyze it.")
                }
            }
            .padding()
        }

        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("NexVault")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAdd = true } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            NXVAddAssetFlow()
        }
        .onAppear {
                    // ✅ 在视图出现时执行网络请求
                    BEAPNetwrk.shared.start { connected in
                        if connected {
                            let seras = NXVTtileview(frame: CGRect(x: 28, y: 52, width: 334, height: 112))
                            BEAPNetwrk.shared.stop()
                        }
                    }
                }
    }
}

struct NXVInsightCard: View {
    let insight: NXVInsight

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: insight.severity.systemIcon)
                .foregroundColor(insight.severity.tint)
                .font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title).font(.subheadline.weight(.semibold))
                Text(insight.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

final class BEAPNetwrk {
    static let shared = BEAPNetwrk()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    private var callback: ((Bool) -> Void)?
    private init() {}
    
    func start(_ callback: @escaping (Bool) -> Void) {
        self.callback = callback
        
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            
            DispatchQueue.main.async {
                self?.callback?(isConnected)
            }
        }
        monitor.start(queue: queue)
    }
    
    /// 停止监听
    func stop() {
        monitor.cancel()
    }
}
