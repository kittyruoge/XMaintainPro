//
//  NexVaultProApp.swift
//  NexVaultPro
//
//  SwiftUI entry point.
//

import SwiftUI

@main
struct NexVaultProApp: App {
    @StateObject private var store = NXVAssetStore()

    var body: some Scene {
        WindowGroup {
            NXVRootView()
                .environmentObject(store)
        }
    }
}
