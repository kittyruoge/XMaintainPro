//
//  NXVAssetListView.swift
//  NexVaultPro
//
//  All assets with category filter and sort.
//

import SwiftUI

struct NXVAssetListView: View {
    @EnvironmentObject private var store: NXVAssetStore
    @State private var filter: NXVCategory? = nil
    @State private var sort: SortMode = .risk
    @State private var showAdd = false

    enum SortMode: String, CaseIterable, Identifiable {
        case risk = "Risk"
        case value = "Value"
        case name = "Name"
        var id: String { rawValue }
    }

    private var filtered: [NXVAssetModel] {
        var list = store.assets
        if let filter { list = list.filter { $0.category == filter } }
        switch sort {
        case .risk:  list.sort { store.risk(for: $0) > store.risk(for: $1) }
        case .value: list.sort { ($0.value ?? 0) > ($1.value ?? 0) }
        case .name:  list.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
        return list
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    NXVFilterChip(title: "All", selected: filter == nil) { filter = nil }
                    ForEach(NXVCategory.allCases) { cat in
                        NXVFilterChip(title: cat.label, selected: filter == cat) {
                            filter = (filter == cat) ? nil : cat
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            List {
                ForEach(filtered) { asset in
                    ZStack {
                        NXVAssetCard(asset: asset,
                                     status: store.status(for: asset),
                                     risk: store.risk(for: asset))
                        NavigationLink {
                            NXVAssetDetailView(assetID: asset.id)
                        } label: { EmptyView() }.opacity(0)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(Color.clear)
                }
                .onDelete(perform: delete)

                if filtered.isEmpty {
                    NXVEmptyState(systemImage: "tray",
                                  title: "Nothing here",
                                  message: "No assets match this filter.")
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Assets")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Picker("Sort", selection: $sort) {
                        ForEach(SortMode.allCases) { Text($0.rawValue).tag($0) }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showAdd) { NXVAddAssetFlow() }
    }

    private func delete(_ offsets: IndexSet) {
        let targets = offsets.map { filtered[$0] }
        targets.forEach { store.nxvDeleteAsset($0) }
    }
}

struct NXVFilterChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(selected ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                .foregroundColor(selected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
