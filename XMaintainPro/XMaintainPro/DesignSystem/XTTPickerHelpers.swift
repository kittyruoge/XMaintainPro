//
//  XTTPickerHelpers.swift
//  XMaintainPro
//
//  Shared action-sheet helpers for selecting equipment / enum values / dates.
//

import UIKit

extension UIViewController {

    /// Presents an action sheet to choose an equipment. Returns nil selection allowed via "Unassigned".
    func xttPresentEquipmentPicker(allowUnassigned: Bool = true,
                                   from source: UIView?,
                                   onPick: @escaping (XTTEquipment?) -> Void) {
        let sheet = UIAlertController(title: "Select Equipment", message: nil, preferredStyle: .actionSheet)
        if allowUnassigned {
            sheet.addAction(UIAlertAction(title: "Unassigned", style: .default) { _ in onPick(nil) })
        }
        for e in XTTDataManager.shared.store.equipment {
            sheet.addAction(UIAlertAction(title: e.name, style: .default) { _ in onPick(e) })
        }
        if XTTDataManager.shared.store.equipment.isEmpty {
            sheet.message = "No equipment available. Add equipment first."
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.popoverPresentationController?.sourceView = source
        sheet.popoverPresentationController?.sourceRect = source?.bounds ?? .zero
        present(sheet, animated: true)
    }

    /// Presents an action sheet for a list of string options.
    func xttPresentOptions(title: String,
                           options: [String],
                           from source: UIView?,
                           onPick: @escaping (Int) -> Void) {
        let sheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for (i, opt) in options.enumerated() {
            sheet.addAction(UIAlertAction(title: opt, style: .default) { _ in onPick(i) })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.popoverPresentationController?.sourceView = source
        sheet.popoverPresentationController?.sourceRect = source?.bounds ?? .zero
        present(sheet, animated: true)
    }

    /// Presents a wheel date picker inside an alert.
    func xttPresentDatePicker(title: String,
                              initial: Date,
                              minDate: Date? = nil,
                              maxDate: Date? = nil,
                              onPick: @escaping (Date) -> Void) {
        let alert = UIAlertController(title: title, message: "\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.date = initial
        picker.minimumDate = minDate
        picker.maximumDate = maxDate
        if #available(iOS 14.0, *) { picker.preferredDatePickerStyle = .wheels }
        picker.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(picker)
        NSLayoutConstraint.activate([
            picker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50)
        ])
        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in onPick(picker.date) })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
