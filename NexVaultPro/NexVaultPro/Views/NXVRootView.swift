//
//  NXVRootView.swift
//  NexVaultPro
//
//  Tab container. iOS 15 uses NavigationView per tab.
//

import SwiftUI

struct NXVRootView: View {
    var body: some View {
        TabView {
            NavigationView { NXVDashboardView() }
                .navigationViewStyle(.stack)
                .tabItem { Label("Home", systemImage: "square.grid.2x2.fill") }

            NavigationView { NXVAssetListView() }
                .navigationViewStyle(.stack)
                .tabItem { Label("Assets", systemImage: "tray.full.fill") }

            NavigationView { NXVInsightView() }
                .navigationViewStyle(.stack)
                .tabItem { Label("Insights", systemImage: "lightbulb.fill") }

            NavigationView { NXVMoreView() }
                .navigationViewStyle(.stack)
                .tabItem { Label("More", systemImage: "ellipsis.circle.fill") }
        }
        .tint(.accentColor)
    }
}

/// "More" hub linking the secondary screens, keeping the tab bar to 4.
struct NXVMoreView: View {
    var body: some View {
        List {
            Section("Explore") {
                NavigationLink { NXVTimelineView() } label: {
                    Label("Timeline", systemImage: "clock.arrow.circlepath")
                }
                NavigationLink { NXVGraphView() } label: {
                    Label("Relationship Graph", systemImage: "point.3.connected.trianglepath.dotted")
                }
                NavigationLink { NXVAnalyticsView() } label: {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
            }
            Section("Manage") {
                NavigationLink { NXVSubscriptionManagerView() } label: {
                    Label("Subscriptions", systemImage: "arrow.triangle.2.circlepath")
                }
                NavigationLink { NXVDocumentVaultView() } label: {
                    Label("Document Vault", systemImage: "doc.text.fill")
                }
                NavigationLink { NXVSettingsView() } label: {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            }
        }
        .navigationTitle("More")
    }
}
