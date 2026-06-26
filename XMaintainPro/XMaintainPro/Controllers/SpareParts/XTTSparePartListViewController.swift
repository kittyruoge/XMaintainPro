//
//  XTTSparePartListViewController.swift
//  XMaintainPro
//

import UIKit

final class XTTSparePartListViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchController = UISearchController(searchResultsController: nil)
    private let emptyState = XTTEmptyStateView(icon: "shippingbox.fill",
                                               title: "No Spare Parts",
                                               message: "Track inventory of spare parts and adjust quantities as you use them.")
    private let equipmentId: String?
    private var searchText = ""

    init(equipmentId: String? = nil) {
        self.equipmentId = equipmentId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private var parts: [XTTSparePart] {
        var list = XTTDataManager.shared.store.spareParts
        if let id = equipmentId { list = list.filter { $0.equipmentId == id } }
        if !searchText.isEmpty {
            list = list.filter {
                $0.partName.localizedCaseInsensitiveContains(searchText) ||
                $0.partNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
        return list.sorted { $0.partName < $1.partName }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Spare Parts"
        xttApplyBaseBackground()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(xttAdd))
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search parts"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(XTTSparePartCell.self, forCellReuseIdentifier: XTTSparePartCell.reuseID)
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
        emptyState.isHidden = !parts.isEmpty
    }

    @objc private func xttAdd() {
        let vc = XTTSparePartEditViewController(part: nil, presetEquipmentId: equipmentId)
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

extension XTTSparePartListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { parts.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: XTTSparePartCell.reuseID, for: indexPath) as! XTTSparePartCell
        let p = parts[indexPath.row]
        cell.xttConfigure(part: p)
        cell.onStep = { [weak self] delta in
            XTTDataManager.shared.xttAdjustPartQuantity(p.id, delta: delta)
            self?.xttReload()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = XTTSparePartEditViewController(part: parts[indexPath.row])
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let p = parts[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            self?.xttConfirmDelete(message: "Delete \"\(p.partName)\"?") {
                XTTDataManager.shared.xttDeletePart(p.id)
                self?.xttReload()
            }
            done(false)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension XTTSparePartListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        xttReload()
    }
}

// MARK: - Spare part cell with stepper
final class XTTSparePartCell: UITableViewCell {
    static let reuseID = "XTTSparePartCell"
    var onStep: ((Int) -> Void)?

    private let card = UIView()
    private let nameLabel = UILabel()
    private let subLabel = UILabel()
    private let qtyLabel = UILabel()
    private let minusButton = UIButton(type: .system)
    private let plusButton = UIButton(type: .system)
    private let lowStockPill = XTTStatusPill(text: "Low", color: XTTTheme.Color.danger)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        xttBuild()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func xttBuild() {
        card.xttApplyCardStyle(radius: 18)
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)

        nameLabel.font = XTTTheme.Font.bodyMedium()
        nameLabel.textColor = XTTTheme.Color.primaryText
        subLabel.font = XTTTheme.Font.caption()
        subLabel.textColor = XTTTheme.Color.secondaryText

        qtyLabel.font = .systemFont(ofSize: 20, weight: .bold)
        qtyLabel.textColor = XTTTheme.Color.accent
        qtyLabel.textAlignment = .center
        qtyLabel.translatesAutoresizingMaskIntoConstraints = false
        qtyLabel.widthAnchor.constraint(equalToConstant: 36).isActive = true

        xttStyleStep(minusButton, system: "minus")
        xttStyleStep(plusButton, system: "plus")
        minusButton.addTarget(self, action: #selector(xttMinus), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(xttPlus), for: .touchUpInside)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, subLabel])
        textStack.axis = .vertical
        textStack.spacing = 3
        let stepStack = UIStackView(arrangedSubviews: [minusButton, qtyLabel, plusButton])
        stepStack.axis = .horizontal
        stepStack.spacing = 6
        stepStack.alignment = .center
        stepStack.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [textStack, stepStack])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(row)

        lowStockPill.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(lowStockPill)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            lowStockPill.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            lowStockPill.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10)
        ])
    }

    private func xttStyleStep(_ button: UIButton, system: String) {
        button.setImage(UIImage(systemName: system), for: .normal)
        button.tintColor = XTTTheme.Color.accent
        button.backgroundColor = XTTTheme.Color.accent.withAlphaComponent(0.12)
        button.xttRoundCorners(9)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 34).isActive = true
        button.heightAnchor.constraint(equalToConstant: 34).isActive = true
    }

    func xttConfigure(part: XTTSparePart) {
        nameLabel.text = part.partName
        let supplier = part.supplier.isEmpty ? "" : " · \(part.supplier)"
        subLabel.text = "\(part.partNumber.isEmpty ? "No P/N" : part.partNumber)\(supplier)"
        qtyLabel.text = "\(part.quantity)"
        lowStockPill.isHidden = part.quantity > 2
    }

    @objc private func xttMinus() { onStep?(-1) }
    @objc private func xttPlus() { onStep?(1) }
}
