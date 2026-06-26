//
//  XTTMaintenanceHistoryViewController.swift
//  XMaintainPro
//

import UIKit

final class XTTMaintenanceHistoryViewController: UIViewController {

    private let plan: XTTMaintenancePlan
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyState = XTTEmptyStateView(icon: "clock.arrow.circlepath",
                                               title: "No History Yet",
                                               message: "Completed maintenance for this plan will appear here.")

    init(plan: XTTMaintenancePlan) {
        self.plan = plan
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private var records: [XTTMaintenanceRecord] {
        // history rolled up by plan name + equipment (seed records use placeholder planId)
        XTTDataManager.shared.store.maintenanceRecords
            .filter { $0.planId == plan.id || ($0.planName == plan.planName && $0.equipmentId == plan.equipmentId) }
            .sorted { $0.completedDate > $1.completedDate }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "History"
        xttApplyBaseBackground()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.register(XTTListCardCell.self, forCellReuseIdentifier: XTTListCardCell.reuseID)
        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 24, right: 0)
        view.addSubview(tableView)
        tableView.xttPinEdges(to: view)
        emptyState.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyState)
        emptyState.xttPinEdges(to: view)
        emptyState.isHidden = !records.isEmpty

        let complete = XTTPrimaryButton(title: "Mark Completed Now", colors: XTTTheme.Color.gradientGreen)
        complete.translatesAutoresizingMaskIntoConstraints = false
        complete.addTarget(self, action: #selector(xttComplete), for: .touchUpInside)
        view.addSubview(complete)
        NSLayoutConstraint.activate([
            complete.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            complete.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            complete.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        tableView.contentInset.bottom = 90
    }

    @objc private func xttComplete() {
        XTTDataManager.shared.xttCompleteMaintenance(plan)
        tableView.reloadData()
        emptyState.isHidden = !records.isEmpty
        xttShowToast("Maintenance logged")
    }
}

extension XTTMaintenanceHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { records.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: XTTListCardCell.reuseID, for: indexPath) as! XTTListCardCell
        let r = records[indexPath.row]
        cell.xttConfigure(icon: "checkmark.seal.fill",
                          gradient: XTTTheme.Color.gradientGreen,
                          title: r.planName,
                          subtitle: r.completedDate.xttFormatted(.long),
                          detail: r.notes.isEmpty ? "Completed" : r.notes,
                          badgeText: "Done",
                          badgeColor: XTTTheme.Color.success)
        return cell
    }
}
