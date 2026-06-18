//
//  NXVAddAssetFlow.swift
//  NexVaultPro
//
//  Stepped asset creation wizard. Doubles as the editor.
//

import SwiftUI

struct NXVAddAssetFlow: View {
    @EnvironmentObject private var store: NXVAssetStore
    @Environment(\.presentationMode) private var presentationMode

    /// When non-nil, the flow edits an existing asset instead of creating one.
    var editing: NXVAssetModel? = nil

    /// Seed values for a *new* asset (e.g. from OCR). Ignored when editing.
    var seedName: String? = nil
    var seedCategory: NXVCategory? = nil
    var seedNote: String? = nil

    @State private var step = 0
    @State private var name = ""
    @State private var category: NXVCategory = .physical
    @State private var hasValue = false
    @State private var valueText = ""
    @State private var hasExpiry = false
    @State private var expiry = Date().addingTimeInterval(60 * 60 * 24 * 30)
    @State private var renewsMonthly = false
    @State private var tagsText = ""
    @State private var note = ""

    private let totalSteps = 5

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ProgressView(value: Double(step + 1), total: Double(totalSteps))
                    .padding()

                Form {
                    switch step {
                    case 0: stepName
                    case 1: stepCategory
                    case 2: stepValue
                    case 3: stepExpiry
                    default: stepTags
                    }
                }

                HStack {
                    if step > 0 {
                        Button("Back") { withAnimation { step -= 1 } }
                            .buttonStyle(.bordered)
                    }
                    Spacer()
                    if step < totalSteps - 1 {
                        Button("Next") { withAnimation { step += 1 } }
                            .buttonStyle(.borderedProminent)
                            .disabled(step == 0 && name.trimmingCharacters(in: .whitespaces).isEmpty)
                    } else {
                        Button(editing == nil ? "Add Asset" : "Save") { save() }
                            .buttonStyle(.borderedProminent)
                            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                .padding()
            }
            .navigationTitle(editing == nil ? "Add Asset" : "Edit Asset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
            }
            .onAppear(perform: prefill)
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Steps

    private var stepName: some View {
        Section(header: Text("What is it?")) {
            TextField("e.g. iPhone 15 Pro", text: $name)
        }
    }

    private var stepCategory: some View {
        Section(header: Text("Category")) {
            ForEach(NXVCategory.allCases) { cat in
                Button {
                    category = cat
                } label: {
                    HStack {
                        Image(systemName: cat.systemIcon).foregroundColor(cat.tint)
                        Text(cat.label).foregroundColor(.primary)
                        Spacer()
                        if category == cat {
                            Image(systemName: "checkmark").foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
    }

    private var stepValue: some View {
        Section(header: Text("Value (optional)")) {
            Toggle("Track a value", isOn: $hasValue)
            if hasValue {
                TextField("Amount in USD", text: $valueText)
                    .keyboardType(.decimalPad)
            }
        }
    }

    private var stepExpiry: some View {
        Section(header: Text("Expiry (optional)")) {
            Toggle("Has an expiry date", isOn: $hasExpiry)
            if hasExpiry {
                DatePicker("Expires", selection: $expiry, displayedComponents: .date)
            }
            if category == .subscription {
                Toggle("Renews monthly", isOn: $renewsMonthly)
            }
        }
    }

    private var stepTags: some View {
        Group {
            Section(header: Text("Tags (optional)")) {
                TextField("Comma separated, e.g. Apple, Device", text: $tagsText)
            }
            Section(header: Text("Note (optional)")) {
                TextEditor(text: $note)
                    .frame(minHeight: 80)
            }
        }
    }

    // MARK: - Logic

    private func prefill() {
        guard name.isEmpty else { return }
        if let asset = editing {
            name = asset.name
            category = asset.category
            if let v = asset.value { hasValue = true; valueText = String(v) }
            if let e = asset.expiryDate { hasExpiry = true; expiry = e }
            renewsMonthly = asset.renewsMonthly
            tagsText = asset.tags.joined(separator: ", ")
            note = asset.note
        } else {
            // Seed a brand-new asset (e.g. from OCR) without entering edit mode.
            if let seedName { name = seedName }
            if let seedCategory { category = seedCategory }
            if let seedNote { note = seedNote }
        }
    }

    private func save() {
        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let value = hasValue ? Double(valueText.replacingOccurrences(of: ",", with: ".")) : nil

        if let existing = editing {
            var updated = existing
            updated.name = name.trimmingCharacters(in: .whitespaces)
            updated.category = category
            updated.value = value
            updated.expiryDate = hasExpiry ? expiry : nil
            updated.renewsMonthly = renewsMonthly
            updated.tags = tags
            updated.note = note
            store.nxvUpdateAsset(updated)
        } else {
            let asset = NXVAssetModel(
                name: name.trimmingCharacters(in: .whitespaces),
                category: category,
                value: value,
                expiryDate: hasExpiry ? expiry : nil,
                tags: tags,
                note: note,
                renewsMonthly: renewsMonthly)
            store.nxvAddAsset(asset)
        }
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Link sheet

struct NXVLinkAssetSheet: View {
    @EnvironmentObject private var store: NXVAssetStore
    @Environment(\.presentationMode) private var presentationMode
    let source: NXVAssetModel

    var body: some View {
        NavigationView {
            List {
                ForEach(store.assets.filter { $0.id != source.id }) { candidate in
                    Button {
                        store.nxvLink(source, to: candidate)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Image(systemName: candidate.category.systemIcon)
                                .foregroundColor(candidate.category.tint)
                            Text(candidate.name).foregroundColor(.primary)
                            Spacer()
                            if source.relatedAssetIDs.contains(candidate.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Link to \(source.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
