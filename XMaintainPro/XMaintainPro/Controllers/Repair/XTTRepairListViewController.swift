//
//  XTTRepairListViewController.swift
//  XMaintainPro
//

import UIKit

final class XTTRepairListViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchController = UISearchController(searchResultsController: nil)
    private let emptyState = XTTEmptyStateView(icon: "wrench.and.screwdriver.fill",
                                               title: "No Repair Records",
                                               message: "Log a repair to keep a full service history for your equipment.")
    private let equipmentId: String?
    private var searchText = ""

    init(equipmentId: String? = nil) {
        self.equipmentId = equipmentId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private var repairs: [XTTRepair] {
        var list = XTTDataManager.shared.store.repairs
        if let id = equipmentId { list = list.filter { $0.equipmentId == id } }
        if !searchText.isEmpty {
            list = list.filter {
                $0.problem.localizedCaseInsensitiveContains(searchText) ||
                $0.technician.localizedCaseInsensitiveContains(searchText)
            }
        }
        return list.sorted { $0.repairDate > $1.repairDate }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Repairs"
        xttApplyBaseBackground()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(xttAdd))
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search repairs"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

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
        emptyState.isHidden = !repairs.isEmpty
    }

    @objc private func xttAdd() {
        let vc = XTTRepairEditViewController(repair: nil, presetEquipmentId: equipmentId)
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

extension XTTRepairListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { repairs.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: XTTListCardCell.reuseID, for: indexPath) as! XTTListCardCell
        let r = repairs[indexPath.row]
        cell.xttConfigure(icon: "wrench.fill",
                          gradient: XTTTheme.Color.gradientOrange,
                          title: r.problem.isEmpty ? "Repair" : r.problem,
                          subtitle: "\(XTTDataManager.shared.xttEquipmentName(r.equipmentId)) · \(r.repairDate.xttFormatted())",
                          detail: r.technician.isEmpty ? "No technician" : "By \(r.technician)",
                          badgeText: String(format: "$%.0f", r.cost),
                          badgeColor: XTTTheme.Color.warning)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = XTTRepairEditViewController(repair: repairs[indexPath.row])
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let r = repairs[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            self?.xttConfirmDelete(message: "Delete this repair record?") {
                XTTDataManager.shared.xttDeleteRepair(r.id)
                self?.xttReload()
            }
            done(false)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension XTTRepairListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        xttReload()
    }
}
