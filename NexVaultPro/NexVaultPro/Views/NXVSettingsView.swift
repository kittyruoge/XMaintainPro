//
//  NXVSettingsView.swift
//  NexVaultPro
//
//  Basic settings + data management.
//

import SwiftUI

struct NXVSettingsView: View {
    @EnvironmentObject private var store: NXVAssetStore
    @State private var confirmReset = false

    var body: some View {
        List {
            Section("About") {
                NXVKeyValueRow(key: "App", value: "NexVault Pro")
                NXVKeyValueRow(key: "Version", value: appVersion)
                NXVKeyValueRow(key: "Assets stored", value: "\(store.assets.count)")
            }

            Section {
                Button(role: .destructive) {
                    confirmReset = true
                } label: {
                    Label("Delete all assets", systemImage: "trash")
                }
            } footer: {
                Text("This permanently removes every asset and its history from this device.")
            }
        }
        .navigationTitle("Settings")
        .alert("Delete everything?", isPresented: $confirmReset) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                store.assets.forEach { store.nxvDeleteAsset($0) }
            }
        } message: {
            Text("All assets and timeline events will be erased. This cannot be undone.")
        }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}
