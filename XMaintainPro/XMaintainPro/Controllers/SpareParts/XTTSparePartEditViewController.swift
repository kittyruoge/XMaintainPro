//
//  XTTSparePartEditViewController.swift
//  XMaintainPro
//

import UIKit

final class XTTSparePartEditViewController: UIViewController {

    private var part: XTTSparePart
    private let isNew: Bool

    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    private let nameField: XTTFormField
    private let numberField: XTTFormField
    private let equipmentPicker: XTTFormPicker
    private let quantityField: XTTFormField
    private let supplierField: XTTFormField
    private let priceField: XTTFormField
    private let notesField: XTTFormTextView

    private var selectedEquipmentId: String

    init(part: XTTSparePart?, presetEquipmentId: String? = nil) {
        let model = part ?? XTTSparePart(partName: "", equipmentId: presetEquipmentId ?? "")
        self.part = model
        self.isNew = (part == nil)
        self.selectedEquipmentId = model.equipmentId
        nameField = XTTFormField(title: "Part Name", placeholder: "e.g. Spindle Bearing", value: model.partName)
        numberField = XTTFormField(title: "Part Number", placeholder: "e.g. SB-7204-CTP", value: model.partNumber)
        equipmentPicker = XTTFormPicker(title: "Equipment",
                                        value: model.equipmentId.isEmpty ? "Unassigned" : XTTDataManager.shared.xttEquipmentName(model.equipmentId))
        quantityField = XTTFormField(title: "Quantity", placeholder: "0", value: "\(model.quantity)", keyboard: .numberPad)
        supplierField = XTTFormField(title: "Supplier", placeholder: "e.g. Precision Bearings Co.", value: model.supplier)
        priceField = XTTFormField(title: "Price", placeholder: "0.00", value: model.price > 0 ? String(format: "%.2f", model.price) : "", keyboard: .decimalPad)
        notesField = XTTFormTextView(title: "Notes", placeholder: "Additional details…", value: model.notes)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = isNew ? "New Part" : "Edit Part"
        xttApplyBaseBackground()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(xttCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(xttSave))
        xttBuild()
        xttEnableTapToDismissKeyboard()
    }

    private func xttBuild() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        scrollView.xttPinEdges(to: view)
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -40)
        ])
        stack.addArrangedSubview(nameField)
        stack.addArrangedSubview(numberField)
        stack.addArrangedSubview(equipmentPicker)
        stack.addArrangedSubview(quantityField)
        stack.addArrangedSubview(supplierField)
        stack.addArrangedSubview(priceField)
        stack.addArrangedSubview(notesField)
        equipmentPicker.addTarget(self, action: #selector(xttPickEquipment), for: .touchUpInside)
    }

    @objc private func xttPickEquipment() {
        xttPresentEquipmentPicker(allowUnassigned: true, from: equipmentPicker) { [weak self] e in
            self?.selectedEquipmentId = e?.id ?? ""
            self?.equipmentPicker.xttSetValue(e?.name ?? "Unassigned")
        }
    }

    @objc private func xttCancel() { dismiss(animated: true) }
    @objc private func xttSave() {
        view.endEditing(true)
        guard !nameField.value.trimmingCharacters(in: .whitespaces).isEmpty else {
            xttShowAlert(title: "Name Required", message: "Please enter a part name."); return
        }
        part.partName = nameField.value
        part.partNumber = numberField.value
        part.equipmentId = selectedEquipmentId
        part.quantity = Int(quantityField.value) ?? 0
        part.supplier = supplierField.value
        part.price = Double(priceField.value.replacingOccurrences(of: ",", with: ".")) ?? 0
        part.notes = notesField.value
        XTTDataManager.shared.xttUpsert(part: part)
        dismiss(animated: true)
    }
}
