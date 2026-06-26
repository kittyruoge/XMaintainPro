//
//  XTTWarrantyEditViewController.swift
//  XMaintainPro
//

import UIKit

final class XTTWarrantyEditViewController: UIViewController {

    private var warranty: XTTWarranty
    private let isNew: Bool

    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    private let equipmentPicker: XTTFormPicker
    private let startPicker: XTTFormPicker
    private let endPicker: XTTFormPicker
    private let supplierField: XTTFormField
    private let notesField: XTTFormTextView

    private var selectedEquipmentId: String
    private var startDate: Date
    private var endDate: Date

    init(warranty: XTTWarranty?, presetEquipmentId: String? = nil) {
        let firstEquipment = XTTDataManager.shared.store.equipment.first?.id ?? ""
        let model = warranty ?? XTTWarranty(equipmentId: presetEquipmentId ?? firstEquipment)
        self.warranty = model
        self.isNew = (warranty == nil)
        self.selectedEquipmentId = model.equipmentId
        self.startDate = model.warrantyStart
        self.endDate = model.warrantyEnd
        equipmentPicker = XTTFormPicker(title: "Equipment", value: XTTDataManager.shared.xttEquipmentName(model.equipmentId))
        startPicker = XTTFormPicker(title: "Warranty Start", value: model.warrantyStart.xttFormatted())
        endPicker = XTTFormPicker(title: "Warranty End", value: model.warrantyEnd.xttFormatted())
        supplierField = XTTFormField(title: "Supplier", placeholder: "e.g. Dell ProSupport", value: model.supplier)
        notesField = XTTFormTextView(title: "Notes", placeholder: "Coverage details…", value: model.notes)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = isNew ? "New Warranty" : "Edit Warranty"
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
        stack.addArrangedSubview(equipmentPicker)
        stack.addArrangedSubview(startPicker)
        stack.addArrangedSubview(endPicker)
        stack.addArrangedSubview(supplierField)
        stack.addArrangedSubview(notesField)
        equipmentPicker.addTarget(self, action: #selector(xttPickEquipment), for: .touchUpInside)
        startPicker.addTarget(self, action: #selector(xttPickStart), for: .touchUpInside)
        endPicker.addTarget(self, action: #selector(xttPickEnd), for: .touchUpInside)
    }

    @objc private func xttPickEquipment() {
        xttPresentEquipmentPicker(allowUnassigned: false, from: equipmentPicker) { [weak self] e in
            guard let e = e else { return }
            self?.selectedEquipmentId = e.id
            self?.equipmentPicker.xttSetValue(e.name)
        }
    }
    @objc private func xttPickStart() {
        xttPresentDatePicker(title: "Warranty Start", initial: startDate) { [weak self] d in
            self?.startDate = d
            self?.startPicker.xttSetValue(d.xttFormatted())
        }
    }
    @objc private func xttPickEnd() {
        xttPresentDatePicker(title: "Warranty End", initial: endDate) { [weak self] d in
            self?.endDate = d
            self?.endPicker.xttSetValue(d.xttFormatted())
        }
    }

    @objc private func xttCancel() { dismiss(animated: true) }
    @objc private func xttSave() {
        view.endEditing(true)
        guard !selectedEquipmentId.isEmpty else {
            xttShowAlert(title: "Equipment Required", message: "Please add equipment first, then assign this warranty."); return
        }
        guard endDate >= startDate else {
            xttShowAlert(title: "Invalid Dates", message: "Warranty end date must be after the start date."); return
        }
        warranty.equipmentId = selectedEquipmentId
        warranty.warrantyStart = startDate
        warranty.warrantyEnd = endDate
        warranty.supplier = supplierField.value
        warranty.notes = notesField.value
        XTTDataManager.shared.xttUpsert(warranty: warranty)
        dismiss(animated: true)
    }
}
