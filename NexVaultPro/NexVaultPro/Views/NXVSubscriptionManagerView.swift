//
//  NXVSubscriptionManagerView.swift
//  NexVaultPro
//
//  Subscriptions with renewal dates and monthly spend.
//

import SwiftUI

struct NXVSubscriptionManagerView: View {
    @EnvironmentObject private var store: NXVAssetStore
    @State private var showAdd = false

    private var subscriptions: [NXVAssetModel] {
        store.assets
            .filter { $0.category == .subscription }
            .sorted { ($0.nxvDaysUntilExpiry() ?? .max) < ($1.nxvDaysUntilExpiry() ?? .max) }
    }

    private var monthlySpend: Double {
        subscriptions.filter { $0.renewsMonthly }.reduce(0) { $0 + ($1.value ?? 0) }
    }

    var body: some View {
        Group {
            if subscriptions.isEmpty {
                NXVEmptyState(systemImage: "arrow.triangle.2.circlepath",
                              title: "No subscriptions",
                              message: "Add a subscription asset to track renewals here.")
            } else {
                List {
                    Section {
                        HStack {
                            Text("Monthly spend").font(.subheadline)
                            Spacer()
                            Text(NXVFormat.currency(monthlySpend))
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                    }
                    Section("Subscriptions") {
                        ForEach(subscriptions) { sub in
                            NavigationLink {
                                NXVAssetDetailView(assetID: sub.id)
                            } label: {
                                NXVSubscriptionRow(sub: sub, status: store.status(for: sub))
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Subscriptions")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showAdd) { NXVAddAssetFlow() }
    }
}

struct NXVSubscriptionRow: View {
    let sub: NXVAssetModel
    let status: NXVStatus

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(sub.name).font(.headline)
                if let days = sub.nxvDaysUntilExpiry() {
                    Text(days < 0 ? "Renewal overdue" : "Renews in \(days) day\(days == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(status == .expiring || status == .expired ? .orange : .secondary)
                }
            }
            Spacer()
            if let value = sub.value {
                Text(NXVFormat.currency(value))
                    .font(.subheadline.weight(.semibold))
            }
        }
    }
}
