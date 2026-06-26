//
//  XTTMaintenanceListViewController.swift
//  XMaintainPro
//
//  Maintenance plans — list, filter, complete, edit, history.
//

import UIKit

final class XTTMaintenanceListViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchController = UISearchController(searchResultsController: nil)
    private let emptyState = XTTEmptyStateView(icon: "calendar.badge.clock",
                                               title: "No Maintenance Plans",
                                               message: "Create a plan to schedule recurring maintenance for your equipment.")
    private let equipmentId: String?
    private var searchText = ""
    private var sortNewest = false

    init(equipmentId: String? = nil) {
        self.equipmentId = equipmentId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private var plans: [XTTMaintenancePlan] {
        var list = XTTDataManager.shared.store.plans
        if let id = equipmentId { list = list.filter { $0.equipmentId == id } }
        if !searchText.isEmpty {
            list = list.filter { $0.planName.localizedCaseInsensitiveContains(searchText) }
        }
        return list.sorted { sortNewest ? $0.createdAt > $1.createdAt : $0.nextDate < $1.nextDate }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Maintenance"
        xttApplyBaseBackground()
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(xttAdd)),
            UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain,
                            target: self, action: #selector(xttToggleSort))
        ]
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search plans"
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
        emptyState.isHidden = !plans.isEmpty
    }

    @objc private func xttAdd() {
        let vc = XTTMaintenanceEditViewController(plan: nil, presetEquipmentId: equipmentId)
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    @objc private func xttToggleSort() {
        sortNewest.toggle()
        xttReload()
        xttShowToast(sortNewest ? "Sorted by newest" : "Sorted by next date")
    }
}

extension XTTMaintenanceListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { plans.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: XTTListCardCell.reuseID, for: indexPath) as! XTTListCardCell
        let p = plans[indexPath.row]
        let status = XTTDataManager.shared.xttResolvedStatus(for: p)
        let days = Date().xttDaysUntil(p.nextDate)
        let when = days == 0 ? "Due today" : (days > 0 ? "Due in \(days)d" : "\(-days)d overdue")
        cell.xttConfigure(icon: "calendar.badge.clock",
                          gradient: XTTTheme.Color.gradientPurple,
                          title: p.planName,
                          subtitle: "\(XTTDataManager.shared.xttEquipmentName(p.equipmentId)) · \(p.cycle.rawValue)",
                          detail: "\(when) · \(p.nextDate.xttFormatted(.medium))",
                          badgeText: status.rawValue,
                          badgeColor: XTTColorMap.maintenanceStatus(status))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = XTTMaintenanceEditViewController(plan: plans[indexPath.row])
        present(UINavigationController(rootViewController: vc), animated: true)
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let p = plans[indexPath.row]
        let complete = UIContextualAction(style: .normal, title: "Complete") { [weak self] _, _, done in
            XTTDataManager.shared.xttCompleteMaintenance(p)
            self?.xttReload()
            self?.xttShowToast("Maintenance logged · next cycle scheduled")
            done(true)
        }
        complete.backgroundColor = XTTTheme.Color.success
        complete.image = UIImage(systemName: "checkmark.circle.fill")
        return UISwipeActionsConfiguration(actions: [complete])
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let p = plans[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            self?.xttConfirmDelete(message: "Delete plan \"\(p.planName)\"?") {
                XTTDataManager.shared.xttDeletePlan(p.id)
                self?.xttReload()
            }
            done(false)
        }
        let history = UIContextualAction(style: .normal, title: "History") { [weak self] _, _, done in
            self?.navigationController?.pushViewController(XTTMaintenanceHistoryViewController(plan: p), animated: true)
            done(true)
        }
        history.backgroundColor = XTTTheme.Color.accent
        return UISwipeActionsConfiguration(actions: [delete, history])
    }
}

extension XTTMaintenanceListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        xttReload()
    }
}
