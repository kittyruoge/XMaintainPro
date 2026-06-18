//
//  NXVGraphView.swift
//  NexVaultPro
//
//  Relationship graph rendered with Canvas. Circular layout from
//  NXVGraphEngine, tap a node to open its detail.
//

import SwiftUI

struct NXVGraphView: View {
    @EnvironmentObject private var store: NXVAssetStore
    @State private var selectedID: UUID?

    var body: some View {
        GeometryReader { geo in
            let graph = NXVGraphEngine.nxvLayout(
                NXVGraphEngine.nxvBuildGraph(from: store.assets),
                in: geo.size)

            ZStack {
                // Edges
                Canvas { context, _ in
                    let positions = Dictionary(uniqueKeysWithValues: graph.nodes.map { ($0.id, $0.position) })
                    for edge in graph.edges {
                        guard let a = positions[edge.from], let b = positions[edge.to] else { continue }
                        var path = Path()
                        path.move(to: a)
                        path.addLine(to: b)
                        context.stroke(path, with: .color(.secondary.opacity(0.35)), lineWidth: 1.5)
                    }
                }

                // Nodes
                ForEach(graph.nodes) { node in
                    NXVGraphNodeView(node: node)
                        .position(node.position)
                        .onTapGesture { selectedID = node.id }
                }

                if graph.nodes.isEmpty {
                    NXVEmptyState(systemImage: "point.3.connected.trianglepath.dotted",
                                  title: "No assets to map",
                                  message: "Add assets and link them to see the relationship graph.")
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .navigationTitle("Graph")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .background(
            NavigationLink(
                destination: selectedID.map { NXVAssetDetailView(assetID: $0) },
                isActive: Binding(
                    get: { selectedID != nil },
                    set: { if !$0 { selectedID = nil } })
            ) { EmptyView() }.hidden()
        )
    }
}

struct NXVGraphNodeView: View {
    let node: NXVGraphEngine.Node

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(node.category.tint.nxvGradient)
                    .frame(width: 46, height: 46)
                Image(systemName: node.category.systemIcon)
                    .foregroundColor(.white)
                Circle()
                    .stroke(NXVRiskBand(score: node.risk).tint, lineWidth: 3)
                    .frame(width: 52, height: 52)
            }
            Text(node.name)
                .font(.caption2.weight(.medium))
                .lineLimit(1)
                .frame(maxWidth: 80)
        }
    }
}
