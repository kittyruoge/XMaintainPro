//
//  NXVDocumentVaultView.swift
//  NexVaultPro
//
//  Document assets + OCR scanning to pre-fill a new document.
//

import SwiftUI

struct NXVDocumentVaultView: View {
    @EnvironmentObject private var store: NXVAssetStore
    @State private var showPicker = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var scannedText: String?
    @State private var scanning = false
    @State private var scanError: String?

    private var documents: [NXVAssetModel] {
        store.assets.filter { $0.category == .document }
    }

    private var cameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        List {
            Section("Scan a document") {
                if cameraAvailable {
                    Button {
                        pickerSource = .camera
                        showPicker = true
                    } label: {
                        Label("Scan with camera", systemImage: "camera.fill")
                    }
                }
                Button {
                    pickerSource = .photoLibrary
                    showPicker = true
                } label: {
                    Label("Import from photos", systemImage: "photo.on.rectangle")
                }
                if scanning {
                    HStack { ProgressView(); Text("Recognizing text…").foregroundColor(.secondary) }
                }
                if let scanError {
                    Text(scanError).font(.caption).foregroundColor(.red)
                }
            }

            if let scannedText {
                Section("Recognized text") {
                    Text(scannedText).font(.callout)
                    NavigationLink {
                        NXVAddAssetFlowPrefilled(text: scannedText)
                    } label: {
                        Label("Create document from text", systemImage: "doc.badge.plus")
                    }
                }
            }

            Section("Your documents") {
                if documents.isEmpty {
                    Text("No documents yet.").foregroundColor(.secondary)
                } else {
                    ForEach(documents) { doc in
                        NavigationLink {
                            NXVAssetDetailView(assetID: doc.id)
                        } label: {
                            HStack {
                                Image(systemName: "doc.text.fill").foregroundColor(.purple)
                                VStack(alignment: .leading) {
                                    Text(doc.name)
                                    if let e = doc.expiryDate {
                                        Text("Expires \(NXVFormat.date(e))")
                                            .font(.caption).foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Document Vault")
        .sheet(isPresented: $showPicker) {
            NXVImagePicker(sourceType: pickerSource) { image in
                runOCR(on: image)
            }
        }
    }

    private func runOCR(on image: UIImage) {
        scanning = true
        scanError = nil
        scannedText = nil
        NXVOCRService.shared.nxvRecognizeText(in: image) { result in
            scanning = false
            switch result {
            case .success(let text): scannedText = text
            case .failure: scanError = "Couldn't read any text from that image."
            }
        }
    }
}

/// Thin wrapper that opens the add flow with the document category and a
/// name guessed from the OCR text's first line.
struct NXVAddAssetFlowPrefilled: View {
    let text: String
    var body: some View {
        let firstLine = text.split(separator: "\n").first.map(String.init) ?? "Scanned Document"
        NXVAddAssetFlow(
            seedName: String(firstLine.prefix(40)),
            seedCategory: .document,
            seedNote: text)
    }
}
