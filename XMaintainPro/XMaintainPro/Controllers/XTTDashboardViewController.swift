//
//  XTTDashboardViewController.swift
//  XMaintainPro
//
//  Dashboard with user header, stat tiles, today/upcoming tasks, quick actions.
//

import UIKit

final class XTTDashboardViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        xttApplyBaseBackground()
        xttBuildLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        xttReload()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func xttBuildLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.xttPinEdges(to: view)

        stack.axis = .vertical
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func xttReload() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        xttAddHeader()
        xttAddStatTiles()
        xttAddSection(title: "Maintenance Today", action: nil)
        xttAddTodayCard()
        xttAddSection(title: "Upcoming Tasks", action: nil)
        xttAddUpcoming()
        xttAddSection(title: "Warranty Status", action: nil)
        xttAddWarrantyCard()
        xttAddSection(title: "Recent Repairs", action: nil)
        xttAddRecentRepairs()
        xttAddSection(title: "Quick Actions", action: nil)
        xttAddQuickActions()
    }

    // MARK: - Header
    private func xttAddHeader() {
        let header = XTTGradientView(colors: XTTTheme.Color.gradientBlue)
        header.layer.cornerRadius = 28
        header.layer.cornerCurve = .continuous
        header.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        header.translatesAutoresizingMaskIntoConstraints = false
        header.heightAnchor.constraint(equalToConstant: 168).isActive = true

        let hello = UILabel()
        let auth = XTTAuthService.shared
        let name = auth.isGuest ? "Guest" : (auth.currentUser?.displayName ?? "User")
        hello.text = "Hello, \(name)"
        hello.font = .systemFont(ofSize: 24, weight: .bold)
        hello.textColor = .white
        hello.translatesAutoresizingMaskIntoConstraints = false

        let sub = UILabel()
        sub.text = auth.isGuest ? "Guest mode · data is temporary" : "Here's your maintenance overview"
        sub.font = XTTTheme.Font.subhead()
        sub.textColor = UIColor.white.withAlphaComponent(0.9)
        sub.translatesAutoresizingMaskIntoConstraints = false

        let avatar = UIView()
        avatar.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        avatar.xttRoundCorners(24)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        let initials = UILabel()
        initials.text = String(name.prefix(1)).uppercased()
        initials.textColor = .white
        initials.font = .systemFont(ofSize: 20, weight: .bold)
        initials.translatesAutoresizingMaskIntoConstraints = false
        avatar.addSubview(initials)

        let dateLabel = UILabel()
        dateLabel.text = Date().xttFormatted(.full)
        dateLabel.font = XTTTheme.Font.caption()
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        header.addSubview(hello)
        header.addSubview(sub)
        header.addSubview(avatar)
        header.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            avatar.topAnchor.constraint(equalTo: header.safeAreaLayoutGuide.topAnchor, constant: 8),
            avatar.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -20),
            avatar.widthAnchor.constraint(equalToConstant: 48),
            avatar.heightAnchor.constraint(equalToConstant: 48),
            initials.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            initials.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),

            dateLabel.topAnchor.constraint(equalTo: header.safeAreaLayoutGuide.topAnchor, constant: 14),
            dateLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),

            hello.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
            hello.bottomAnchor.constraint(equalTo: sub.topAnchor, constant: -4),
            sub.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
            sub.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -24)
        ])

        stack.addArrangedSubview(header)
    }

    // MARK: - Stat tiles
    private func xttAddStatTiles() {
        let dm = XTTDataManager.shared
        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.distribution = .fillEqually
        row1.spacing = 12

        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.distribution = .fillEqually
        row2.spacing = 12

        row1.addArrangedSubview(xttTile(value: "\(dm.store.equipment.count)", label: "Equipment",
                                        icon: "gearshape.2.fill", gradient: XTTTheme.Color.gradientBlue))
        row1.addArrangedSubview(xttTile(value: "\(dm.xttUpcomingPlans.count)", label: "Open Tasks",
                                        icon: "checklist", gradient: XTTTheme.Color.gradientPurple))
        row2.addArrangedSubview(xttTile(value: "\(dm.store.repairs.count)", label: "Repairs",
                                        icon: "wrench.fill", gradient: XTTTheme.Color.gradientOrange))
        let expiring = dm.store.warranties.filter { $0.status != .active }.count
        row2.addArrangedSubview(xttTile(value: "\(expiring)", label: "Warranty Alerts",
                                        icon: "checkmark.shield.fill", gradient: XTTTheme.Color.gradientGreen))

        let container = UIStackView(arrangedSubviews: [row1, row2])
        container.axis = .vertical
        container.spacing = 12
        container.isLayoutMarginsRelativeArrangement = true
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stack.addArrangedSubview(container)
    }

    private func xttTile(value: String, label: String, icon: String, gradient: [UIColor]) -> UIView {
        let tile = XTTGradientView(colors: gradient)
        tile.xttRoundCorners(18)
        tile.translatesAutoresizingMaskIntoConstraints = false
        tile.heightAnchor.constraint(equalToConstant: 96).isActive = true

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = UIColor.white.withAlphaComponent(0.85)
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 28, weight: .bold)
        valueLabel.textColor = .white
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        let nameLabel = UILabel()
        nameLabel.text = label
        nameLabel.font = XTTTheme.Font.caption()
        nameLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        tile.addSubview(iconView)
        tile.addSubview(valueLabel)
        tile.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: tile.topAnchor, constant: 14),
            iconView.leadingAnchor.constraint(equalTo: tile.leadingAnchor, constant: 14),
            valueLabel.leadingAnchor.constraint(equalTo: tile.leadingAnchor, constant: 14),
            valueLabel.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: 0),
            nameLabel.leadingAnchor.constraint(equalTo: tile.leadingAnchor, constant: 14),
            nameLabel.bottomAnchor.constraint(equalTo: tile.bottomAnchor, constant: -14)
        ])
        return tile
    }

    // MARK: - Section header row
    private func xttAddSection(title: String, action: (() -> Void)?) {
        let label = UILabel()
        label.text = title
        label.font = XTTTheme.Font.headline()
        label.textColor = XTTTheme.Color.primaryText

        let container = UIStackView(arrangedSubviews: [label])
        container.isLayoutMarginsRelativeArrangement = true
        container.layoutMargins = UIEdgeInsets(top: 4, left: 20, bottom: 0, right: 20)
        stack.addArrangedSubview(container)
    }

    private func xttCardContainer(_ inner: UIView) -> UIView {
        let card = UIView()
        card.xttApplyCardStyle(radius: 18)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        inner.xttPinEdges(to: card, insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))

        let wrap = UIStackView(arrangedSubviews: [card])
        wrap.isLayoutMarginsRelativeArrangement = true
        wrap.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return wrap
    }

    // MARK: - Today card
    private func xttAddTodayCard() {
        let today = XTTDataManager.shared.xttTodayPlans
        if today.isEmpty {
            stack.addArrangedSubview(xttCardContainer(xttEmptyRow(icon: "checkmark.circle.fill",
                                                                  text: "No maintenance scheduled for today. You're all caught up.")))
            return
        }
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 12
        for plan in today.prefix(3) {
            inner.addArrangedSubview(xttTaskRow(plan))
        }
        stack.addArrangedSubview(xttCardContainer(inner))
    }

    private func xttTaskRow(_ plan: XTTMaintenancePlan) -> UIView {
        let dot = UIView()
        dot.backgroundColor = XTTColorMap.priority(plan.priority)
        dot.xttRoundCorners(5)
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 10).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 10).isActive = true

        let title = UILabel()
        title.text = plan.planName
        title.font = XTTTheme.Font.bodyMedium()
        title.textColor = XTTTheme.Color.primaryText

        let sub = UILabel()
        sub.text = XTTDataManager.shared.xttEquipmentName(plan.equipmentId)
        sub.font = XTTTheme.Font.caption()
        sub.textColor = XTTTheme.Color.secondaryText

        let textStack = UIStackView(arrangedSubviews: [title, sub])
        textStack.axis = .vertical
        textStack.spacing = 2

        let pill = XTTStatusPill(text: plan.priority.rawValue, color: XTTColorMap.priority(plan.priority))
        pill.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [dot, textStack, pill])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        return row
    }

    // MARK: - Upcoming
    private func xttAddUpcoming() {
        let upcoming = XTTDataManager.shared.xttUpcomingPlans.filter { !Calendar.current.isDateInToday($0.nextDate) }
        if upcoming.isEmpty {
            stack.addArrangedSubview(xttCardContainer(xttEmptyRow(icon: "calendar.badge.checkmark",
                                                                  text: "No upcoming tasks scheduled.")))
            return
        }
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 12
        for plan in upcoming.prefix(4) {
            let title = UILabel()
            title.text = plan.planName
            title.font = XTTTheme.Font.bodyMedium()
            title.textColor = XTTTheme.Color.primaryText

            let sub = UILabel()
            let days = Date().xttDaysUntil(plan.nextDate)
            let when = days == 0 ? "Today" : (days > 0 ? "in \(days) day\(days == 1 ? "" : "s")" : "\(-days) day\(days == -1 ? "" : "s") overdue")
            sub.text = "\(XTTDataManager.shared.xttEquipmentName(plan.equipmentId)) · \(when)"
            sub.font = XTTTheme.Font.caption()
            sub.textColor = days < 0 ? XTTTheme.Color.danger : XTTTheme.Color.secondaryText

            let textStack = UIStackView(arrangedSubviews: [title, sub])
            textStack.axis = .vertical
            textStack.spacing = 2

            let icon = UIImageView(image: UIImage(systemName: "clock.fill"))
            icon.tintColor = XTTTheme.Color.accent
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.widthAnchor.constraint(equalToConstant: 18).isActive = true

            let row = UIStackView(arrangedSubviews: [icon, textStack])
            row.axis = .horizontal
            row.spacing = 12
            row.alignment = .center
            inner.addArrangedSubview(row)
        }
        stack.addArrangedSubview(xttCardContainer(inner))
    }

    // MARK: - Warranty
    private func xttAddWarrantyCard() {
        let w = XTTDataManager.shared.store.warranties
        if w.isEmpty {
            stack.addArrangedSubview(xttCardContainer(xttEmptyRow(icon: "checkmark.shield",
                                                                  text: "No warranties tracked yet.")))
            return
        }
        let active = w.filter { $0.status == .active }.count
        let soon = w.filter { $0.status == .expiringSoon }.count
        let expired = w.filter { $0.status == .expired }.count

        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 12
        row.addArrangedSubview(xttWarrantyStat(value: active, label: "Active", color: XTTTheme.Color.success))
        row.addArrangedSubview(xttWarrantyStat(value: soon, label: "Expiring", color: XTTTheme.Color.warning))
        row.addArrangedSubview(xttWarrantyStat(value: expired, label: "Expired", color: XTTTheme.Color.danger))
        stack.addArrangedSubview(xttCardContainer(row))
    }

    private func xttWarrantyStat(value: Int, label: String, color: UIColor) -> UIView {
        let v = UILabel()
        v.text = "\(value)"
        v.font = .systemFont(ofSize: 26, weight: .bold)
        v.textColor = color
        v.textAlignment = .center
        let l = UILabel()
        l.text = label
        l.font = XTTTheme.Font.caption()
        l.textColor = XTTTheme.Color.secondaryText
        l.textAlignment = .center
        let s = UIStackView(arrangedSubviews: [v, l])
        s.axis = .vertical
        s.spacing = 2
        return s
    }

    // MARK: - Recent repairs
    private func xttAddRecentRepairs() {
        let repairs = XTTDataManager.shared.store.repairs.prefix(3)
        if repairs.isEmpty {
            stack.addArrangedSubview(xttCardContainer(xttEmptyRow(icon: "wrench.and.screwdriver",
                                                                  text: "No repair records yet.")))
            return
        }
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 12
        for r in repairs {
            let title = UILabel()
            title.text = r.problem.isEmpty ? "Repair" : r.problem
            title.font = XTTTheme.Font.bodyMedium()
            title.textColor = XTTTheme.Color.primaryText
            title.numberOfLines = 1

            let sub = UILabel()
            sub.text = "\(XTTDataManager.shared.xttEquipmentName(r.equipmentId)) · \(r.repairDate.xttFormatted(.short))"
            sub.font = XTTTheme.Font.caption()
            sub.textColor = XTTTheme.Color.secondaryText

            let textStack = UIStackView(arrangedSubviews: [title, sub])
            textStack.axis = .vertical
            textStack.spacing = 2

            let cost = UILabel()
            cost.text = String(format: "$%.0f", r.cost)
            cost.font = XTTTheme.Font.bodyMedium()
            cost.textColor = XTTTheme.Color.accent
            cost.setContentHuggingPriority(.required, for: .horizontal)

            let row = UIStackView(arrangedSubviews: [textStack, cost])
            row.axis = .horizontal
            row.spacing = 12
            row.alignment = .center
            inner.addArrangedSubview(row)
        }
        stack.addArrangedSubview(xttCardContainer(inner))
    }

    // MARK: - Quick actions
    private func xttAddQuickActions() {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 12

        row.addArrangedSubview(xttActionButton(title: "Add\nEquipment", icon: "plus.square.fill.on.square.fill",
                                               gradient: XTTTheme.Color.gradientBlue, action: #selector(xttQuickEquipment)))
        row.addArrangedSubview(xttActionButton(title: "New\nPlan", icon: "calendar.badge.plus",
                                               gradient: XTTTheme.Color.gradientPurple, action: #selector(xttQuickPlan)))
        row.addArrangedSubview(xttActionButton(title: "Log\nRepair", icon: "wrench.adjustable.fill",
                                               gradient: XTTTheme.Color.gradientOrange, action: #selector(xttQuickRepair)))

        let wrap = UIStackView(arrangedSubviews: [row])
        wrap.isLayoutMarginsRelativeArrangement = true
        wrap.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stack.addArrangedSubview(wrap)
    }

    private func xttActionButton(title: String, icon: String, gradient: [UIColor], action: Selector) -> UIView {
        let container = XTTGradientView(colors: gradient)
        container.xttRoundCorners(18)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 96).isActive = true

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title
        label.numberOfLines = 2
        label.font = XTTTheme.Font.caption()
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(iconView)
        container.addSubview(label)
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            iconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4)
        ])
        let tap = UITapGestureRecognizer(target: self, action: action)
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        return container
    }

    private func xttEmptyRow(icon: String, text: String) -> UIView {
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = XTTTheme.Color.success
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 22).isActive = true

        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = XTTTheme.Font.subhead()
        label.textColor = XTTTheme.Color.secondaryText

        let row = UIStackView(arrangedSubviews: [iconView, label])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        return row
    }

    // MARK: - Quick action handlers
    @objc private func xttQuickEquipment() {
        let vc = XTTEquipmentEditViewController(equipment: nil)
        presentXttModal(vc)
    }
    @objc private func xttQuickPlan() {
        let vc = XTTMaintenanceEditViewController(plan: nil)
        presentXttModal(vc)
    }
    @objc private func xttQuickRepair() {
        let vc = XTTRepairEditViewController(repair: nil)
        presentXttModal(vc)
    }
    private func presentXttModal(_ vc: UIViewController) {
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}
