//
//  XTTEquipmentDetailViewController.swift
//  XMaintainPro
//
//  Full equipment profile + related records and quick navigation.
//

import UIKit

final class XTTEquipmentDetailViewController: UIViewController {

    private let equipmentId: String
    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    private var equipment: XTTEquipment? { XTTDataManager.shared.xttEquipment(by: equipmentId) }

    init(equipmentId: String) {
        self.equipmentId = equipmentId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        xttApplyBaseBackground()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self, action: #selector(xttEdit))
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.xttPinEdges(to: view)
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -30)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        xttReload()
    }

    private func xttReload() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let e = equipment else {
            navigationController?.popViewController(animated: true)
            return
        }
        xttHeroCard(e)
        xttInfoCard(e)
        xttRelatedCard(e)
        xttDangerCard(e)
    }

    private func xttHeroCard(_ e: XTTEquipment) {
        let card = UIView()
        card.xttApplyCardStyle()
        card.translatesAutoresizingMaskIntoConstraints = false

        let banner: UIView
        if let img = XTTDataManager.shared.xttImage(named: e.imageFileName) {
            let iv = UIImageView(image: img)
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            banner = iv
        } else {
            let g = XTTGradientView(colors: XTTTheme.Color.gradientBlue)
            let icon = UIImageView(image: UIImage(systemName: e.category.icon))
            icon.tintColor = UIColor.white.withAlphaComponent(0.9)
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            g.addSubview(icon)
            NSLayoutConstraint.activate([
                icon.centerXAnchor.constraint(equalTo: g.centerXAnchor),
                icon.centerYAnchor.constraint(equalTo: g.centerYAnchor),
                icon.widthAnchor.constraint(equalToConstant: 56),
                icon.heightAnchor.constraint(equalToConstant: 56)
            ])
            banner = g
        }
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.heightAnchor.constraint(equalToConstant: 150).isActive = true
        banner.layer.cornerRadius = XTTTheme.Metric.cardRadius
        banner.layer.cornerCurve = .continuous
        banner.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        banner.clipsToBounds = true

        let name = UILabel()
        name.text = e.name
        name.font = XTTTheme.Font.title()
        name.textColor = XTTTheme.Color.primaryText
        name.numberOfLines = 0

        let pill = XTTStatusPill(text: e.category.rawValue, color: XTTTheme.Color.accent)
        let favIcon = UIImageView(image: UIImage(systemName: e.isFavorite ? "star.fill" : "star"))
        favIcon.tintColor = XTTTheme.Color.warning
        favIcon.setContentHuggingPriority(.required, for: .horizontal)
        let pillRow = UIStackView(arrangedSubviews: [pill, UIView(), favIcon])
        pillRow.axis = .horizontal
        pillRow.alignment = .center

        let textStack = UIStackView(arrangedSubviews: [name, pillRow])
        textStack.axis = .vertical
        textStack.spacing = 10
        textStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(banner)
        card.addSubview(textStack)
        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: card.topAnchor),
            banner.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            textStack.topAnchor.constraint(equalTo: banner.bottomAnchor, constant: 14),
            textStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            textStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        stack.addArrangedSubview(card)
    }

    private func xttInfoCard(_ e: XTTEquipment) {
        let rows = UIStackView()
        rows.axis = .vertical
        rows.addArrangedSubview(XTTDetailRow(label: "Brand", value: e.brand))
        rows.addArrangedSubview(xttSep())
        rows.addArrangedSubview(XTTDetailRow(label: "Model", value: e.model))
        rows.addArrangedSubview(xttSep())
        rows.addArrangedSubview(XTTDetailRow(label: "Serial", value: e.serialNumber))
        rows.addArrangedSubview(xttSep())
        rows.addArrangedSubview(XTTDetailRow(label: "Purchased", value: e.purchaseDate.xttFormatted()))
        rows.addArrangedSubview(xttSep())
        rows.addArrangedSubview(XTTDetailRow(label: "Location", value: e.location))
        if !e.notes.isEmpty {
            rows.addArrangedSubview(xttSep())
            rows.addArrangedSubview(XTTDetailRow(label: "Notes", value: e.notes))
        }
        stack.addArrangedSubview(xttTitledCard("Information", content: rows))
    }

    private func xttRelatedCard(_ e: XTTEquipment) {
        let dm = XTTDataManager.shared
        let plans = dm.store.plans.filter { $0.equipmentId == e.id }.count
        let repairs = dm.store.repairs.filter { $0.equipmentId == e.id }.count
        let parts = dm.store.spareParts.filter { $0.equipmentId == e.id }.count
        let warranties = dm.store.warranties.filter { $0.equipmentId == e.id }.count
        let docs = dm.xttDocuments(forEquipment: e.id).count

        let rows = UIStackView()
        rows.axis = .vertical
        rows.spacing = 0
        rows.addArrangedSubview(xttNavRow(icon: "calendar.badge.clock", tint: XTTTheme.Color.purple,
                                          title: "Maintenance Plans", count: plans, action: #selector(xttOpenPlans)))
        rows.addArrangedSubview(xttSep())
        rows.addArrangedSubview(xttNavRow(icon: "wrench.fill", tint: XTTTheme.Color.warning,
                                          title: "Repair History", count: repairs, action: #selector(xttOpenRepairs)))
        rows.addArrangedSubview(xttSep())
        rows.addArrangedSubview(xttNavRow(icon: "shippingbox.fill", tint: XTTTheme.Color.teal,
                                          title: "Spare Parts", count: parts, action: #selector(xttOpenParts)))
        rows.addArrangedSubview(xttSep())
        rows.addArrangedSubview(xttNavRow(icon: "checkmark.shield.fill", tint: XTTTheme.Color.success,
                                          title: "Warranty", count: warranties, action: #selector(xttOpenWarranty)))
        rows.addArrangedSubview(xttSep())
        rows.addArrangedSubview(xttNavRow(icon: "doc.fill", tint: XTTTheme.Color.accent,
                                          title: "Documents", count: docs, action: #selector(xttOpenDocs)))
        stack.addArrangedSubview(xttTitledCard("Related Records", content: rows))
    }

    private func xttDangerCard(_ e: XTTEquipment) {
        let deleteButton = XTTSoftButton(title: "Delete Equipment", tint: XTTTheme.Color.danger)
        deleteButton.addTarget(self, action: #selector(xttDelete), for: .touchUpInside)
        stack.addArrangedSubview(deleteButton)
    }

    // MARK: - Builders
    private func xttTitledCard(_ title: String, content: UIView) -> UIView {
        let header = UILabel()
        header.text = title
        header.font = XTTTheme.Font.headline()
        header.textColor = XTTTheme.Color.primaryText

        let card = UIView()
        card.xttApplyCardStyle()
        card.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)
        content.xttPinEdges(to: card, insets: UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16))

        let wrap = UIStackView(arrangedSubviews: [header, card])
        wrap.axis = .vertical
        wrap.spacing = 8
        return wrap
    }

    private func xttSep() -> UIView {
        let v = UIView()
        v.backgroundColor = XTTTheme.Color.separator
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return v
    }

    private func xttNavRow(icon: String, tint: UIColor, title: String, count: Int, action: Selector) -> UIView {
        let iconBg = UIView()
        iconBg.backgroundColor = tint.withAlphaComponent(0.15)
        iconBg.xttRoundCorners(9)
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        let iv = UIImageView(image: UIImage(systemName: icon))
        iv.tintColor = tint
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iv)

        let label = UILabel()
        label.text = title
        label.font = XTTTheme.Font.bodyMedium()
        label.textColor = XTTTheme.Color.primaryText

        let countLabel = UILabel()
        countLabel.text = "\(count)"
        countLabel.font = XTTTheme.Font.bodyMedium()
        countLabel.textColor = XTTTheme.Color.secondaryText

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = XTTTheme.Color.separator
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [iconBg, label, UIView(), countLabel, chevron])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        row.isUserInteractionEnabled = true
        row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))

        NSLayoutConstraint.activate([
            iconBg.widthAnchor.constraint(equalToConstant: 34),
            iconBg.heightAnchor.constraint(equalToConstant: 34),
            iv.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iv.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iv.widthAnchor.constraint(equalToConstant: 18),
            iv.heightAnchor.constraint(equalToConstant: 18)
        ])
        return row
    }

    // MARK: - Actions
    @objc private func xttEdit() {
        guard let e = equipment else { return }
        let vc = XTTEquipmentEditViewController(equipment: e)
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    @objc private func xttDelete() {
        guard let e = equipment else { return }
        xttConfirmDelete(message: "Delete \"\(e.name)\" and all its related records?") { [weak self] in
            XTTDataManager.shared.xttDeleteEquipment(e.id)
            self?.navigationController?.popViewController(animated: true)
        }
    }
    @objc private func xttOpenPlans() {
        navigationController?.pushViewController(XTTMaintenanceListViewController(equipmentId: equipmentId), animated: true)
    }
    @objc private func xttOpenRepairs() {
        navigationController?.pushViewController(XTTRepairListViewController(equipmentId: equipmentId), animated: true)
    }
    @objc private func xttOpenParts() {
        navigationController?.pushViewController(XTTSparePartListViewController(equipmentId: equipmentId), animated: true)
    }
    @objc private func xttOpenWarranty() {
        navigationController?.pushViewController(XTTWarrantyListViewController(equipmentId: equipmentId), animated: true)
    }
    @objc private func xttOpenDocs() {
        navigationController?.pushViewController(XTTDocumentListViewController(equipmentId: equipmentId), animated: true)
    }
}
