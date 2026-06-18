//
//  NXVTimelineView.swift
//  NexVaultPro
//
//  Global event feed — the "asset life record".
//

import SwiftUI

struct NXVTimelineView: View {
    @EnvironmentObject private var store: NXVAssetStore

    private var sortedEvents: [NXVTimelineEvent] {
        store.events.sorted { $0.date > $1.date }
    }

    var body: some View {
        Group {
            if sortedEvents.isEmpty {
                NXVEmptyState(systemImage: "clock",
                              title: "No events yet",
                              message: "As you add and manage assets, their history shows up here.")
            } else {
                List {
                    ForEach(sortedEvents) { event in
                        NXVTimelineRow(event: event)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Timeline")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct NXVTimelineRow: View {
    let event: NXVTimelineEvent
    var compact: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: event.kind.systemIcon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.accentColor.nxvGradient)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(compact ? event.kind.rawValue : event.assetName)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(NXVFormat.relative(event.date))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Text(compact ? event.detail : "\(event.kind.rawValue)\(event.detail.isEmpty ? "" : " · \(event.detail)")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
