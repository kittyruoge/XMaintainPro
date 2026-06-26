//
//  XTTEquipmentListViewController.swift
//  XMaintainPro
//
//  Equipment list with search, category filter, favorites, empty state.
//

import UIKit

final class XTTEquipmentListViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchController = UISearchController(searchResultsController: nil)
    private let emptyState = XTTEmptyStateView(icon: "gearshape.2.fill",
                                               title: "No Equipment Yet",
                                               message: "Tap + to add your first piece of equipment and start tracking its maintenance.")

    private var selectedCategory: XTTEquipmentCategory?
    private var showFavoritesOnly = false
    private var searchText = ""
    private var chips: [XTTChip] = []

    private var allEquipment: [XTTEquipment] { XTTDataManager.shared.store.equipment }

    private var filtered: [XTTEquipment] {
        allEquipment.filter { e in
            (selectedCategory == nil || e.category == selectedCategory) &&
            (!showFavoritesOnly || e.isFavorite) &&
            (searchText.isEmpty ||
             e.name.localizedCaseInsensitiveContains(searchText) ||
             e.brand.localizedCaseInsensitiveContains(searchText) ||
             e.model.localizedCaseInsensitiveContains(searchText) ||
             e.location.localizedCaseInsensitiveContains(searchText))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        xttApplyBaseBackground()
        xttSetupNav()
        xttSetupFilterBar()
        xttSetupTable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        xttReload()
    }

    private func xttSetupNav() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(xttAddTapped))
        let favButton = UIBarButtonItem(image: UIImage(systemName: "star"),
                                        style: .plain, target: self, action: #selector(xttToggleFavFilter))
        navigationItem.leftBarButtonItem = favButton

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search equipment"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private let filterScroll = UIScrollView()

    private func xttSetupFilterBar() {
        filterScroll.showsHorizontalScrollIndicator = false
        filterScroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterScroll)

        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.translatesAutoresizingMaskIntoConstraints = false
        filterScroll.addSubview(row)

        let allChip = XTTChip(text: "All")
        allChip.isSelectedChip = true
        allChip.tag = -1
        allChip.addTarget(self, action: #selector(xttChipTapped(_:)), for: .touchUpInside)
        chips.append(allChip)
        row.addArrangedSubview(allChip)

        for (i, cat) in XTTEquipmentCategory.allCases.enumerated() {
            let chip = XTTChip(text: cat.rawValue)
            chip.tag = i
            chip.addTarget(self, action: #selector(xttChipTapped(_:)), for: .touchUpInside)
            chips.append(chip)
            row.addArrangedSubview(chip)
        }

        NSLayoutConstraint.activate([
            filterScroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterScroll.heightAnchor.constraint(equalToConstant: 46),
            row.topAnchor.constraint(equalTo: filterScroll.topAnchor, constant: 8),
            row.bottomAnchor.constraint(equalTo: filterScroll.bottomAnchor, constant: -8),
            row.leadingAnchor.constraint(equalTo: filterScroll.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: filterScroll.trailingAnchor, constant: -16)
        ])
    }

    private func xttSetupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(XTTListCardCell.self, forCellReuseIdentifier: XTTListCardCell.reuseID)
        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 24, right: 0)
        view.addSubview(tableView)

        emptyState.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyState)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: filterScroll.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyState.topAnchor.constraint(equalTo: tableView.topAnchor),
            emptyState.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyState.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyState.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func xttReload() {
        tableView.reloadData()
        emptyState.isHidden = !filtered.isEmpty
    }

    // MARK: - Actions
    @objc private func xttAddTapped() {
        let vc = XTTEquipmentEditViewController(equipment: nil)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    @objc private func xttToggleFavFilter() {
        showFavoritesOnly.toggle()
        navigationItem.leftBarButtonItem?.image = UIImage(systemName: showFavoritesOnly ? "star.fill" : "star")
        xttReload()
    }

    @objc private func xttChipTapped(_ sender: XTTChip) {
        chips.forEach { $0.isSelectedChip = ($0 == sender) }
        selectedCategory = sender.tag == -1 ? nil : XTTEquipmentCategory.allCases[sender.tag]
        xttReload()
    }
}

// MARK: - Table
extension XTTEquipmentListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filtered.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: XTTListCardCell.reuseID, for: indexPath) as! XTTListCardCell
        let e = filtered[indexPath.row]
        let planCount = XTTDataManager.shared.store.plans.filter { $0.equipmentId == e.id }.count
        cell.xttConfigure(icon: e.category.icon,
                          gradient: XTTTheme.Color.gradientBlue,
                          title: e.name,
                          subtitle: "\(e.brand) \(e.model)".trimmingCharacters(in: .whitespaces),
                          detail: "\(e.category.rawValue) · \(e.location.isEmpty ? "No location" : e.location)",
                          badgeText: e.isFavorite ? "★" : (planCount > 0 ? "\(planCount) plan\(planCount == 1 ? "" : "s")" : nil),
                          badgeColor: e.isFavorite ? XTTTheme.Color.warning : XTTTheme.Color.accent)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = XTTEquipmentDetailViewController(equipmentId: filtered[indexPath.row].id)
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let e = filtered[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            self?.xttConfirmDelete(message: "Delete \"\(e.name)\" and all its related records?") {
                XTTDataManager.shared.xttDeleteEquipment(e.id)
                self?.xttReload()
                done(true)
            }
            done(false)
        }
        let fav = UIContextualAction(style: .normal, title: e.isFavorite ? "Unstar" : "Star") { [weak self] _, _, done in
            var updated = e
            updated.isFavorite.toggle()
            XTTDataManager.shared.xttUpsert(equipment: updated)
            self?.xttReload()
            done(true)
        }
        fav.backgroundColor = XTTTheme.Color.warning
        return UISwipeActionsConfiguration(actions: [delete, fav])
    }
}

extension XTTEquipmentListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        xttReload()
    }
}
