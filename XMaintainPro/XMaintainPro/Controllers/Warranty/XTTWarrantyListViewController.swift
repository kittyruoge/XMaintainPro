//
//  XTTWarrantyListViewController.swift
//  XMaintainPro
//

import UIKit

final class XTTWarrantyListViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyState = XTTEmptyStateView(icon: "checkmark.shield.fill",
                                               title: "No Warranties",
                                               message: "Add warranty coverage to get local reminders before they expire.")
    private let equipmentId: String?

    init(equipmentId: String? = nil) {
        self.equipmentId = equipmentId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private var warranties: [XTTWarranty] {
        var list = XTTDataManager.shared.store.warranties
        if let id = equipmentId { list = list.filter { $0.equipmentId == id } }
        return list.sorted { $0.remainingDays < $1.remainingDays }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Warranty"
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
        emptyState.isHidden = !warranties.isEmpty
    }

    @objc private func xttAdd() {
        let vc = XTTWarrantyEditViewController(warranty: nil, presetEquipmentId: equipmentId)
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

extension XTTWarrantyListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { warranties.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: XTTListCardCell.reuseID, for: indexPath) as! XTTListCardCell
        let w = warranties[indexPath.row]
        let remaining = w.remainingDays
        let detail: String
        switch w.status {
        case .active: detail = "\(remaining) days remaining"
        case .expiringSoon: detail = "Expiring in \(remaining) days"
        case .expired: detail = "Expired \(-remaining) days ago"
        }
        cell.xttConfigure(icon: "checkmark.shield.fill",
                          gradient: XTTTheme.Color.gradientGreen,
                          title: XTTDataManager.shared.xttEquipmentName(w.equipmentId),
                          subtitle: "\(w.supplier.isEmpty ? "No supplier" : w.supplier) · ends \(w.warrantyEnd.xttFormatted())",
                          detail: detail,
                          badgeText: w.status.rawValue,
                          badgeColor: XTTColorMap.warranty(w.status))
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = XTTWarrantyEditViewController(warranty: warranties[indexPath.row])
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let w = warranties[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            self?.xttConfirmDelete(message: "Delete this warranty record?") {
                XTTDataManager.shared.xttDeleteWarranty(w.id)
                self?.xttReload()
            }
            done(false)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
