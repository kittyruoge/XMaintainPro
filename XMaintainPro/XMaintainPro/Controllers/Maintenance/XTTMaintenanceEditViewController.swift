//
//  XTTMaintenanceEditViewController.swift
//  XMaintainPro
//

import UIKit

final class XTTMaintenanceEditViewController: UIViewController {

    private var plan: XTTMaintenancePlan
    private let isNew: Bool

    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    private let nameField: XTTFormField
    private let equipmentPicker: XTTFormPicker
    private let cyclePicker: XTTFormPicker
    private let datePicker: XTTFormPicker
    private let priorityField: XTTFormSegment
    private let statusField: XTTFormSegment
    private let notesField: XTTFormTextView

    private var selectedEquipmentId: String
    private var selectedCycle: XTTMaintenanceCycle
    private var selectedDate: Date

    init(plan: XTTMaintenancePlan?, presetEquipmentId: String? = nil) {
        let firstEquipment = XTTDataManager.shared.store.equipment.first?.id ?? ""
        let model = plan ?? XTTMaintenancePlan(planName: "",
                                               equipmentId: presetEquipmentId ?? firstEquipment,
                                               nextDate: Date.xttFrom(daysFromNow: 7))
        self.plan = model
        self.isNew = (plan == nil)
        self.selectedEquipmentId = model.equipmentId
        self.selectedCycle = model.cycle
        self.selectedDate = model.nextDate
        nameField = XTTFormField(title: "Plan Name", placeholder: "e.g. Spindle Lubrication", value: model.planName)
        equipmentPicker = XTTFormPicker(title: "Equipment",
                                        value: XTTDataManager.shared.xttEquipmentName(model.equipmentId))
        cyclePicker = XTTFormPicker(title: "Cycle", value: model.cycle.rawValue)
        datePicker = XTTFormPicker(title: "Next Date", value: model.nextDate.xttFormatted())
        priorityField = XTTFormSegment(title: "Priority",
                                       options: XTTPriority.allCases.map { $0.rawValue },
                                       selectedIndex: XTTPriority.allCases.firstIndex(of: model.priority) ?? 1)
        let statusOptions: [XTTMaintenanceStatus] = [.scheduled, .inProgress, .completed]
        statusField = XTTFormSegment(title: "Status",
                                     options: statusOptions.map { $0.rawValue },
                                     selectedIndex: statusOptions.firstIndex(of: model.status == .overdue ? .scheduled : model.status) ?? 0)
        notesField = XTTFormTextView(title: "Notes", placeholder: "Additional details…", value: model.notes)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = isNew ? "New Plan" : "Edit Plan"
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
        stack.addArrangedSubview(equipmentPicker)
        stack.addArrangedSubview(cyclePicker)
        stack.addArrangedSubview(datePicker)
        stack.addArrangedSubview(priorityField)
        stack.addArrangedSubview(statusField)
        stack.addArrangedSubview(notesField)

        equipmentPicker.addTarget(self, action: #selector(xttPickEquipment), for: .touchUpInside)
        cyclePicker.addTarget(self, action: #selector(xttPickCycle), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(xttPickDate), for: .touchUpInside)
    }

    @objc private func xttPickEquipment() {
        xttPresentEquipmentPicker(allowUnassigned: false, from: equipmentPicker) { [weak self] e in
            guard let e = e else { return }
            self?.selectedEquipmentId = e.id
            self?.equipmentPicker.xttSetValue(e.name)
        }
    }
    @objc private func xttPickCycle() {
        xttPresentOptions(title: "Cycle", options: XTTMaintenanceCycle.allCases.map { $0.rawValue }, from: cyclePicker) { [weak self] i in
            let c = XTTMaintenanceCycle.allCases[i]
            self?.selectedCycle = c
            self?.cyclePicker.xttSetValue(c.rawValue)
        }
    }
    @objc private func xttPickDate() {
        xttPresentDatePicker(title: "Next Date", initial: selectedDate) { [weak self] d in
            self?.selectedDate = d
            self?.datePicker.xttSetValue(d.xttFormatted())
        }
    }

    @objc private func xttCancel() { dismiss(animated: true) }
    @objc private func xttSave() {
        view.endEditing(true)
        guard !nameField.value.trimmingCharacters(in: .whitespaces).isEmpty else {
            xttShowAlert(title: "Name Required", message: "Please enter a plan name."); return
        }
        guard !selectedEquipmentId.isEmpty else {
            xttShowAlert(title: "Equipment Required", message: "Please add equipment first, then assign this plan."); return
        }
        plan.planName = nameField.value
        plan.equipmentId = selectedEquipmentId
        plan.cycle = selectedCycle
        plan.nextDate = selectedDate
        plan.priority = XTTPriority.allCases[priorityField.selectedIndex]
        let statusOptions: [XTTMaintenanceStatus] = [.scheduled, .inProgress, .completed]
        plan.status = statusOptions[statusField.selectedIndex]
        plan.notes = notesField.value
        XTTDataManager.shared.xttUpsert(plan: plan)
        dismiss(animated: true)
    }
}
