//
//  XTTEquipmentEditViewController.swift
//  XMaintainPro
//
//  Create / edit equipment, with image picker and category selection.
//

import UIKit

final class XTTEquipmentEditViewController: UIViewController {

    private var equipment: XTTEquipment
    private let isNew: Bool

    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    private let nameField: XTTFormField
    private let brandField: XTTFormField
    private let modelField: XTTFormField
    private let serialField: XTTFormField
    private let locationField: XTTFormField
    private let notesField: XTTFormTextView
    private let categoryPicker: XTTFormPicker
    private let datePicker: XTTFormPicker
    private let favoriteSwitch = UISwitch()

    private var selectedCategory: XTTEquipmentCategory
    private var selectedDate: Date
    private var pickedImage: UIImage?
    private let imageButton = UIButton(type: .system)

    init(equipment: XTTEquipment?) {
        let model = equipment ?? XTTEquipment(name: "")
        self.equipment = model
        self.isNew = (equipment == nil)
        self.selectedCategory = model.category
        self.selectedDate = model.purchaseDate
        nameField = XTTFormField(title: "Name", placeholder: "e.g. CNC Milling Machine", value: model.name)
        brandField = XTTFormField(title: "Brand", placeholder: "e.g. Haas", value: model.brand)
        modelField = XTTFormField(title: "Model", placeholder: "e.g. VF-2SS", value: model.model)
        serialField = XTTFormField(title: "Serial Number", placeholder: "e.g. HA-2019-44821", value: model.serialNumber)
        locationField = XTTFormField(title: "Location", placeholder: "e.g. Workshop A", value: model.location)
        notesField = XTTFormTextView(title: "Notes", placeholder: "Additional details…", value: model.notes)
        categoryPicker = XTTFormPicker(title: "Category", value: model.category.rawValue)
        datePicker = XTTFormPicker(title: "Purchase Date", value: model.purchaseDate.xttFormatted())
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = isNew ? "New Equipment" : "Edit Equipment"
        xttApplyBaseBackground()
        xttSetupNav()
        xttBuildForm()
        xttEnableTapToDismissKeyboard()
    }

    private func xttSetupNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self, action: #selector(xttCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                            target: self, action: #selector(xttSave))
    }

    private func xttBuildForm() {
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

        // Image picker button
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        imageButton.heightAnchor.constraint(equalToConstant: 150).isActive = true
        imageButton.backgroundColor = XTTTheme.Color.fieldBackground
        imageButton.xttRoundCorners(XTTTheme.Metric.fieldRadius)
        imageButton.tintColor = XTTTheme.Color.accent
        imageButton.addTarget(self, action: #selector(xttPickImage), for: .touchUpInside)
        imageButton.imageView?.contentMode = .scaleAspectFill
        imageButton.clipsToBounds = true
        xttRefreshImageButton()
        stack.addArrangedSubview(imageButton)

        stack.addArrangedSubview(nameField)
        stack.addArrangedSubview(categoryPicker)
        stack.addArrangedSubview(brandField)
        stack.addArrangedSubview(modelField)
        stack.addArrangedSubview(serialField)
        stack.addArrangedSubview(datePicker)
        stack.addArrangedSubview(locationField)
        stack.addArrangedSubview(notesField)

        // Favorite row
        let favLabel = UILabel()
        favLabel.text = "Mark as Favorite"
        favLabel.font = XTTTheme.Font.bodyMedium()
        favLabel.textColor = XTTTheme.Color.primaryText
        favoriteSwitch.isOn = equipment.isFavorite
        favoriteSwitch.onTintColor = XTTTheme.Color.accent
        let favRow = UIStackView(arrangedSubviews: [favLabel, favoriteSwitch])
        favRow.axis = .horizontal
        stack.addArrangedSubview(favRow)

        categoryPicker.addTarget(self, action: #selector(xttPickCategory), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(xttPickDate), for: .touchUpInside)
    }

    private func xttRefreshImageButton() {
        let img = pickedImage ?? XTTDataManager.shared.xttImage(named: equipment.imageFileName)
        if let img = img {
            imageButton.setImage(img.withRenderingMode(.alwaysOriginal), for: .normal)
            imageButton.setTitle(nil, for: .normal)
        } else {
            imageButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
            imageButton.setTitle("  Add Photo", for: .normal)
        }
    }

    // MARK: - Pickers
    @objc private func xttPickCategory() {
        let sheet = UIAlertController(title: "Category", message: nil, preferredStyle: .actionSheet)
        for cat in XTTEquipmentCategory.allCases {
            sheet.addAction(UIAlertAction(title: cat.rawValue, style: .default) { [weak self] _ in
                self?.selectedCategory = cat
                self?.categoryPicker.xttSetValue(cat.rawValue)
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.popoverPresentationController?.sourceView = categoryPicker
        present(sheet, animated: true)
    }

    @objc private func xttPickDate() {
        let alert = UIAlertController(title: "Purchase Date", message: "\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.date = selectedDate
        picker.maximumDate = Date()
        if #available(iOS 14.0, *) { picker.preferredDatePickerStyle = .wheels }
        picker.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(picker)
        NSLayoutConstraint.activate([
            picker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50)
        ])
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.selectedDate = picker.date
            self?.datePicker.xttSetValue(picker.date.xttFormatted())
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.popoverPresentationController?.sourceView = datePicker
        present(alert, animated: true)
    }

    @objc private func xttPickImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    // MARK: - Save / cancel
    @objc private func xttCancel() { dismiss(animated: true) }

    @objc private func xttSave() {
        view.endEditing(true)
        guard !nameField.value.trimmingCharacters(in: .whitespaces).isEmpty else {
            xttShowAlert(title: "Name Required", message: "Please enter a name for this equipment.")
            return
        }
        if let img = pickedImage, let name = XTTDataManager.shared.xttSaveImage(img) {
            equipment.imageFileName = name
        }
        equipment.name = nameField.value
        equipment.brand = brandField.value
        equipment.model = modelField.value
        equipment.serialNumber = serialField.value
        equipment.location = locationField.value
        equipment.notes = notesField.value
        equipment.category = selectedCategory
        equipment.purchaseDate = selectedDate
        equipment.isFavorite = favoriteSwitch.isOn
        XTTDataManager.shared.xttUpsert(equipment: equipment)
        dismiss(animated: true)
    }
}

extension XTTEquipmentEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            pickedImage = image
            xttRefreshImageButton()
        }
        picker.dismiss(animated: true)
    }
}
