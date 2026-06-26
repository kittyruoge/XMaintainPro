//
//  XTTDocumentListViewController.swift
//  XMaintainPro
//
//  Per-equipment document attachments: images, PDFs, and file references.
//

import UIKit
import QuickLook
import UniformTypeIdentifiers

final class XTTDocumentListViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyState = XTTEmptyStateView(icon: "doc.on.doc.fill",
                                               title: "No Documents",
                                               message: "Attach images, PDFs, or file references to keep manuals and diagrams handy.")
    private let equipmentId: String?
    private var previewURL: URL?

    init(equipmentId: String? = nil) {
        self.equipmentId = equipmentId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private var documents: [XTTDocument] {
        if let id = equipmentId { return XTTDataManager.shared.xttDocuments(forEquipment: id) }
        return XTTDataManager.shared.store.documents
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Documents"
        xttApplyBaseBackground()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(xttAdd))
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(XTTListCardCell.self, forCellReuseIdentifier: XTTListCardCell.reuseID)
        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 24, right: 0)
        view.addSubview(tableView)
        tableView.xttPinEdges(to: view)
        emptyState.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyState)
        emptyState.xttPinEdges(to: view)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        xttReload()
    }
    private func xttReload() {
        tableView.reloadData()
        emptyState.isHidden = !documents.isEmpty
    }

    @objc private func xttAdd() {
        guard equipmentId != nil || !XTTDataManager.shared.store.equipment.isEmpty else {
            xttShowAlert(title: "Add Equipment First", message: "Documents must be attached to a piece of equipment.")
            return
        }
        let sheet = UIAlertController(title: "Add Document", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Photo / Image", style: .default) { [weak self] _ in self?.xttPickImage() })
        sheet.addAction(UIAlertAction(title: "File / PDF", style: .default) { [weak self] _ in self?.xttPickFile() })
        sheet.addAction(UIAlertAction(title: "Reference Only", style: .default) { [weak self] _ in self?.xttAddReference() })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(sheet, animated: true)
    }

    private func xttTargetEquipmentId(_ completion: @escaping (String) -> Void) {
        if let id = equipmentId { completion(id); return }
        xttPresentEquipmentPicker(allowUnassigned: false, from: view) { e in
            if let e = e { completion(e.id) }
        }
    }

    private func xttPickImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    private func xttPickFile() {
        let types: [UTType] = [.pdf, .image, .plainText, .data]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func xttAddReference() {
        let alert = UIAlertController(title: "Document Reference", message: "Enter a title for this document.", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "e.g. Operator Manual" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            let title = alert.textFields?.first?.text ?? ""
            guard !title.isEmpty else { return }
            self?.xttTargetEquipmentId { id in
                let doc = XTTDocument(equipmentId: id, title: title, type: .file)
                XTTDataManager.shared.xttUpsert(document: doc)
                self?.xttReload()
            }
        })
        present(alert, animated: true)
    }
}

extension XTTDocumentListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { documents.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: XTTListCardCell.reuseID, for: indexPath) as! XTTListCardCell
        let d = documents[indexPath.row]
        cell.xttConfigure(icon: d.type.icon,
                          gradient: XTTTheme.Color.gradientTeal,
                          title: d.title,
                          subtitle: "\(XTTDataManager.shared.xttEquipmentName(d.equipmentId)) · \(d.type.rawValue)",
                          detail: d.createdAt.xttFormatted(),
                          badgeText: d.fileName != nil ? "Open" : "Ref",
                          badgeColor: XTTTheme.Color.teal)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let d = documents[indexPath.row]
        if let url = XTTDataManager.shared.xttFileURL(named: d.fileName) {
            previewURL = url
            let preview = QLPreviewController()
            preview.dataSource = self
            navigationController?.pushViewController(preview, animated: true)
        } else {
            xttShowAlert(title: d.title, message: "This is a reference entry with no attached file.")
        }
    }
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let d = documents[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            self?.xttConfirmDelete(message: "Delete \"\(d.title)\"?") {
                XTTDataManager.shared.xttDeleteDocument(d.id)
                self?.xttReload()
            }
            done(false)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension XTTDocumentListViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int { previewURL == nil ? 0 : 1 }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        (previewURL ?? URL(fileURLWithPath: "")) as QLPreviewItem
    }
}

extension XTTDocumentListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage,
              let name = XTTDataManager.shared.xttSaveImage(image) else { return }
        xttTargetEquipmentId { [weak self] id in
            let doc = XTTDocument(equipmentId: id, title: "Image \(Date().xttFormatted(.short))", type: .image, fileName: name)
            XTTDataManager.shared.xttUpsert(document: doc)
            self?.xttReload()
        }
    }
}

extension XTTDocumentListViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        let ext = url.pathExtension.isEmpty ? "dat" : url.pathExtension
        guard let data = try? Data(contentsOf: url),
              let name = XTTDataManager.shared.xttSaveFileData(data, ext: ext) else { return }
        let type: XTTDocumentType = ext.lowercased() == "pdf" ? .pdf : (["png","jpg","jpeg","heic"].contains(ext.lowercased()) ? .image : .file)
        xttTargetEquipmentId { [weak self] id in
            let doc = XTTDocument(equipmentId: id, title: url.deletingPathExtension().lastPathComponent, type: type, fileName: name)
            XTTDataManager.shared.xttUpsert(document: doc)
            self?.xttReload()
        }
    }
}
