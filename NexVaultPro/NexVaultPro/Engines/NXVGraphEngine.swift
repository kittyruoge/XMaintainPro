//
//  NXVGraphEngine.swift
//  NexVaultPro
//
//  Builds the node/edge model for the relationship Graph View
//  and lays nodes out on a circle for rendering.
//

import CoreGraphics
import Foundation

enum NXVGraphEngine {

    struct Node: Identifiable {
        let id: UUID
        let name: String
        let category: NXVCategory
        let risk: Int
        var position: CGPoint = .zero
    }

    struct Edge: Identifiable {
        let id = UUID()
        let from: UUID
        let to: UUID
    }

    struct Graph {
        var nodes: [Node]
        var edges: [Edge]
    }

    /// Build nodes + de-duplicated edges from the asset set.
    static func nxvBuildGraph(from assets: [NXVAssetModel], reference: Date = Date()) -> Graph {
        let nodes = assets.map {
            Node(id: $0.id,
                 name: $0.name,
                 category: $0.category,
                 risk: NXVRiskEngine.nxvCalculateRisk(for: $0, reference: reference))
        }
        let valid = Set(assets.map(\.id))
        var seen = Set<String>()
        var edges: [Edge] = []
        for asset in assets {
            for related in asset.relatedAssetIDs where valid.contains(related) {
                // Undirected: canonicalize the pair so A→B and B→A collapse.
                let key = [asset.id.uuidString, related.uuidString].sorted().joined()
                if seen.insert(key).inserted {
                    edges.append(Edge(from: asset.id, to: related))
                }
            }
        }
        return Graph(nodes: nodes, edges: edges)
    }

    /// Lay nodes out evenly on a circle inside `size`. Deterministic — no RNG.
    static func nxvLayout(_ graph: Graph, in size: CGSize) -> Graph {
        var g = graph
        let count = g.nodes.count
        guard count > 0 else { return g }

        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2 * 0.72

        if count == 1 {
            g.nodes[0].position = center
            return g
        }
        for i in g.nodes.indices {
            let angle = (2 * Double.pi / Double(count)) * Double(i) - Double.pi / 2
            g.nodes[i].position = CGPoint(
                x: center.x + radius * CGFloat(cos(angle)),
                y: center.y + radius * CGFloat(sin(angle)))
        }
        return g
    }
}
