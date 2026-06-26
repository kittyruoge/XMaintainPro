//
//  XTTRepairEditViewController.swift
//  XMaintainPro
//

import UIKit

final class XTTRepairEditViewController: UIViewController {

    private var repair: XTTRepair
    private let isNew: Bool

    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    private let equipmentPicker: XTTFormPicker
    private let datePicker: XTTFormPicker
    private let problemField: XTTFormTextView
    private let solutionField: XTTFormTextView
    private let costField: XTTFormField
    private let technicianField: XTTFormField
    private let notesField: XTTFormTextView

    private var selectedEquipmentId: String
    private var selectedDate: Date
    private var photos: [UIImage] = []
    private let photoStack = UIStackView()

    init(repair: XTTRepair?, presetEquipmentId: String? = nil) {
        let firstEquipment = XTTDataManager.shared.store.equipment.first?.id ?? ""
        let model = repair ?? XTTRepair(equipmentId: presetEquipmentId ?? firstEquipment)
        self.repair = model
        self.isNew = (repair == nil)
        self.selectedEquipmentId = model.equipmentId
        self.selectedDate = model.repairDate
        equipmentPicker = XTTFormPicker(title: "Equipment", value: XTTDataManager.shared.xttEquipmentName(model.equipmentId))
        datePicker = XTTFormPicker(title: "Repair Date", value: model.repairDate.xttFormatted())
        problemField = XTTFormTextView(title: "Problem", placeholder: "Describe the issue…", value: model.problem)
        solutionField = XTTFormTextView(title: "Solution", placeholder: "What was done…", value: model.solution)
        costField = XTTFormField(title: "Cost", placeholder: "0.00", value: model.cost > 0 ? String(format: "%.2f", model.cost) : "", keyboard: .decimalPad)
        technicianField = XTTFormField(title: "Technician", placeholder: "e.g. M. Reyes", value: model.technician)
        notesField = XTTFormTextView(title: "Notes", placeholder: "Additional details…", value: model.notes)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = isNew ? "Log Repair" : "Edit Repair"
        xttApplyBaseBackground()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(xttCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(xttSave))
        xttLoadExistingPhotos()
        xttBuild()
        xttEnableTapToDismissKeyboard()
    }

    private func xttLoadExistingPhotos() {
        photos = repair.photoFileNames.compactMap { XTTDataManager.shared.xttImage(named: $0) }
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
        stack.addArrangedSubview(datePicker)
        stack.addArrangedSubview(problemField)
        stack.addArrangedSubview(solutionField)
        stack.addArrangedSubview(costField)
        stack.addArrangedSubview(technicianField)
        stack.addArrangedSubview(notesField)
        xttBuildPhotoSection()

        equipmentPicker.addTarget(self, action: #selector(xttPickEquipment), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(xttPickDate), for: .touchUpInside)
    }

    private func xttBuildPhotoSection() {
        let title = UILabel()
        title.text = "PHOTOS"
        title.font = XTTTheme.Font.caption()
        title.textColor = XTTTheme.Color.secondaryText

        photoStack.axis = .horizontal
        photoStack.spacing = 10
        photoStack.alignment = .center

        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(photoStack)
        photoStack.xttPinEdges(to: scroll)
        scroll.heightAnchor.constraint(equalToConstant: 84).isActive = true
        photoStack.heightAnchor.constraint(equalTo: scroll.heightAnchor).isActive = true

        let section = UIStackView(arrangedSubviews: [title, scroll])
        section.axis = .vertical
        section.spacing = 6
        stack.addArrangedSubview(section)
        xttRefreshPhotos()
    }

    private func xttRefreshPhotos() {
        photoStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, img) in photos.enumerated() {
            let iv = UIImageView(image: img)
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.xttRoundCorners(12)
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: 76).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 76).isActive = true
            iv.isUserInteractionEnabled = true
            iv.tag = i
            let tap = UITapGestureRecognizer(target: self, action: #selector(xttRemovePhoto(_:)))
            iv.addGestureRecognizer(tap)
            photoStack.addArrangedSubview(iv)
        }
        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = XTTTheme.Color.accent
        addButton.backgroundColor = XTTTheme.Color.fieldBackground
        addButton.xttRoundCorners(12)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.widthAnchor.constraint(equalToConstant: 76).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 76).isActive = true
        addButton.addTarget(self, action: #selector(xttAddPhoto), for: .touchUpInside)
        photoStack.addArrangedSubview(addButton)
    }

    @objc private func xttRemovePhoto(_ g: UITapGestureRecognizer) {
        guard let idx = g.view?.tag, idx < photos.count else { return }
        xttConfirmDelete(title: "Remove Photo", message: "Remove this photo?", confirmTitle: "Remove") { [weak self] in
            self?.photos.remove(at: idx)
            self?.xttRefreshPhotos()
        }
    }

    @objc private func xttAddPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    @objc private func xttPickEquipment() {
        xttPresentEquipmentPicker(allowUnassigned: true, from: equipmentPicker) { [weak self] e in
            self?.selectedEquipmentId = e?.id ?? ""
            self?.equipmentPicker.xttSetValue(e?.name ?? "Unassigned")
        }
    }
    @objc private func xttPickDate() {
        xttPresentDatePicker(title: "Repair Date", initial: selectedDate, maxDate: Date()) { [weak self] d in
            self?.selectedDate = d
            self?.datePicker.xttSetValue(d.xttFormatted())
        }
    }

    @objc private func xttCancel() { dismiss(animated: true) }
    @objc private func xttSave() {
        view.endEditing(true)
        guard !problemField.value.trimmingCharacters(in: .whitespaces).isEmpty else {
            xttShowAlert(title: "Problem Required", message: "Please describe the problem."); return
        }
        // persist new photos
        var fileNames: [String] = []
        for img in photos {
            if let name = XTTDataManager.shared.xttSaveImage(img) { fileNames.append(name) }
        }
        repair.equipmentId = selectedEquipmentId
        repair.repairDate = selectedDate
        repair.problem = problemField.value
        repair.solution = solutionField.value
        repair.cost = Double(costField.value.replacingOccurrences(of: ",", with: ".")) ?? 0
        repair.technician = technicianField.value
        repair.notes = notesField.value
        repair.photoFileNames = fileNames
        XTTDataManager.shared.xttUpsert(repair: repair)
        dismiss(animated: true)
    }
}

extension XTTRepairEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            photos.append(image)
            xttRefreshPhotos()
        }
        picker.dismiss(animated: true)
    }
}
