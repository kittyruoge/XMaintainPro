//
//  NXVStorage.swift
//  NexVaultPro
//
//  Codable JSON persistence in the app's Documents directory.
//  The bottom of the stack: View → ViewModel → Engine → Service → Storage.
//

import Foundation

final class NXVStorage {
    static let shared = NXVStorage()

    private let assetsFile = "nxv_assets.json"
    private let eventsFile = "nxv_events.json"
    private let fileManager = FileManager.default

    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func url(for name: String) -> URL {
        documentsURL.appendingPathComponent(name)
    }

    // MARK: - Assets

    func nxvLoadAssets() -> [NXVAssetModel] {
        load([NXVAssetModel].self, from: assetsFile) ?? []
    }

    func nxvSaveAssets(_ assets: [NXVAssetModel]) {
        save(assets, to: assetsFile)
    }

    // MARK: - Timeline events

    func nxvLoadEvents() -> [NXVTimelineEvent] {
        load([NXVTimelineEvent].self, from: eventsFile) ?? []
    }

    func nxvSaveEvents(_ events: [NXVTimelineEvent]) {
        save(events, to: eventsFile)
    }

    // MARK: - Generic codec

    private func load<T: Decodable>(_ type: T.Type, from name: String) -> T? {
        let target = url(for: name)
        guard let data = try? Data(contentsOf: target) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(T.self, from: data)
    }

    private func save<T: Encodable>(_ value: T, to name: String) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted]
        guard let data = try? encoder.encode(value) else { return }
        try? data.write(to: url(for: name), options: [.atomic])
    }
}
