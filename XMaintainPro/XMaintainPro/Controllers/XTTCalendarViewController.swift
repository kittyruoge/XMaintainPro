//
//  XTTCalendarViewController.swift
//  XMaintainPro
//
//  Maintenance calendar: month grid with task markers + day agenda.
//

import UIKit

final class XTTCalendarViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let monthLabel = UILabel()
    private let weekdayRow = UIStackView()
    private let gridStack = UIStackView()
    private let agendaStack = UIStackView()

    private let segmented = UISegmentedControl(items: ["Today", "Upcoming", "Completed"])

    private var displayedMonth = Date()
    private var selectedDate = Date()
    private let calendar = Calendar.current

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calendar"
        navigationItem.largeTitleDisplayMode = .always
        xttApplyBaseBackground()
        xttBuild()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        xttRenderGrid()
        xttRenderAgenda()
    }

    private func xttBuild() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.xttPinEdges(to: view)

        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])

        // Calendar card
        let calCard = UIView()
        calCard.xttApplyCardStyle()
        calCard.translatesAutoresizingMaskIntoConstraints = false

        monthLabel.font = XTTTheme.Font.headline()
        monthLabel.textColor = XTTTheme.Color.primaryText

        let prev = UIButton(type: .system)
        prev.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        prev.tintColor = XTTTheme.Color.accent
        prev.addTarget(self, action: #selector(xttPrevMonth), for: .touchUpInside)
        let next = UIButton(type: .system)
        next.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        next.tintColor = XTTTheme.Color.accent
        next.addTarget(self, action: #selector(xttNextMonth), for: .touchUpInside)

        let headerRow = UIStackView(arrangedSubviews: [monthLabel, UIView(), prev, next])
        headerRow.axis = .horizontal
        headerRow.spacing = 16
        headerRow.alignment = .center

        weekdayRow.axis = .horizontal
        weekdayRow.distribution = .fillEqually
        for d in ["S","M","T","W","T","F","S"] {
            let l = UILabel()
            l.text = d
            l.font = XTTTheme.Font.caption()
            l.textColor = XTTTheme.Color.secondaryText
            l.textAlignment = .center
            weekdayRow.addArrangedSubview(l)
        }

        gridStack.axis = .vertical
        gridStack.spacing = 6

        let calInner = UIStackView(arrangedSubviews: [headerRow, weekdayRow, gridStack])
        calInner.axis = .vertical
        calInner.spacing = 12
        calInner.translatesAutoresizingMaskIntoConstraints = false
        calCard.addSubview(calInner)
        calInner.xttPinEdges(to: calCard, insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        container.addArrangedSubview(calCard)

        // Agenda segmented + list
        segmented.selectedSegmentIndex = 0
        segmented.selectedSegmentTintColor = XTTTheme.Color.accent
        segmented.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmented.addTarget(self, action: #selector(xttSegmentChanged), for: .valueChanged)
        container.addArrangedSubview(segmented)

        agendaStack.axis = .vertical
        agendaStack.spacing = 12
        container.addArrangedSubview(agendaStack)
    }

    // MARK: - Grid
    @objc private func xttPrevMonth() {
        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
        xttRenderGrid()
    }
    @objc private func xttNextMonth() {
        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
        xttRenderGrid()
    }
    @objc private func xttSegmentChanged() { xttRenderAgenda() }

    private func xttRenderGrid() {
        gridStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let df = DateFormatter()
        df.dateFormat = "LLLL yyyy"
        df.locale = Locale(identifier: "en_US")
        monthLabel.text = df.string(from: displayedMonth)

        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let firstDay = calendar.dateComponents([.year,.month], from: displayedMonth) as DateComponents?,
              let firstDate = calendar.date(from: firstDay) else { return }

        let daysInMonth = calendar.range(of: .day, in: .month, for: displayedMonth)?.count ?? 30
        let firstWeekday = calendar.component(.weekday, from: firstDate) - 1   // 0 = Sunday
        _ = monthInterval

        // dates with tasks
        let plansThisMonth = XTTDataManager.shared.store.plans.filter {
            calendar.isDate($0.nextDate, equalTo: displayedMonth, toGranularity: .month)
        }
        let markedDays = Set(plansThisMonth.map { calendar.component(.day, from: $0.nextDate) })

        var dayCounter = 1
        let totalCells = firstWeekday + daysInMonth
        let rows = Int(ceil(Double(totalCells) / 7.0))

        for row in 0..<rows {
            let weekRow = UIStackView()
            weekRow.axis = .horizontal
            weekRow.distribution = .fillEqually
            weekRow.spacing = 6
            for col in 0..<7 {
                let index = row * 7 + col
                if index < firstWeekday || dayCounter > daysInMonth {
                    weekRow.addArrangedSubview(UIView())
                } else {
                    let day = dayCounter
                    let cellDate = calendar.date(bySetting: .day, value: day, of: firstDate) ?? firstDate
                    weekRow.addArrangedSubview(xttDayCell(day: day, date: cellDate, marked: markedDays.contains(day)))
                    dayCounter += 1
                }
            }
            gridStack.addArrangedSubview(weekRow)
        }
    }

    private func xttDayCell(day: Int, date: Date, marked: Bool) -> UIView {
        let container = UIControl()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let label = UILabel()
        label.text = "\(day)"
        label.font = XTTTheme.Font.subhead()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)

        if isSelected {
            container.backgroundColor = XTTTheme.Color.accent
            label.textColor = .white
        } else if isToday {
            container.backgroundColor = XTTTheme.Color.accent.withAlphaComponent(0.15)
            label.textColor = XTTTheme.Color.accent
        } else {
            label.textColor = XTTTheme.Color.primaryText
        }
        container.xttRoundCorners(10)

        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        if marked {
            let dot = UIView()
            dot.backgroundColor = isSelected ? .white : XTTTheme.Color.warning
            dot.xttRoundCorners(2)
            dot.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(dot)
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 4),
                dot.heightAnchor.constraint(equalToConstant: 4),
                dot.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                dot.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4)
            ])
        }

        container.addAction(UIAction { [weak self] _ in
            self?.selectedDate = date
            self?.segmented.selectedSegmentIndex = 0
            self?.xttRenderGrid()
            self?.xttRenderAgenda()
        }, for: .touchUpInside)
        return container
    }

    // MARK: - Agenda
    private func xttRenderAgenda() {
        agendaStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let dm = XTTDataManager.shared
        var items: [(String, String, UIColor, String)] = []   // title, subtitle, color, icon

        switch segmented.selectedSegmentIndex {
        case 0: // selected day's tasks
            let dayPlans = dm.store.plans.filter { calendar.isDate($0.nextDate, inSameDayAs: selectedDate) }
            let header = UILabel()
            header.text = calendar.isDateInToday(selectedDate) ? "Today · \(selectedDate.xttFormatted())" : selectedDate.xttFormatted(.full)
            header.font = XTTTheme.Font.bodyMedium()
            header.textColor = XTTTheme.Color.secondaryText
            agendaStack.addArrangedSubview(header)
            items = dayPlans.map { (
                $0.planName,
                dm.xttEquipmentName($0.equipmentId),
                XTTColorMap.priority($0.priority),
                "calendar.badge.clock"
            )}
        case 1: // upcoming
            items = dm.xttUpcomingPlans.prefix(20).map { p in
                let days = Date().xttDaysUntil(p.nextDate)
                let when = days == 0 ? "Today" : (days > 0 ? "in \(days)d" : "\(-days)d overdue")
                return (p.planName, "\(dm.xttEquipmentName(p.equipmentId)) · \(when)",
                        days < 0 ? XTTTheme.Color.danger : XTTTheme.Color.accent, "clock.fill")
            }
        default: // completed
            items = dm.store.maintenanceRecords.prefix(20).map { r in
                (r.planName, "\(dm.xttEquipmentName(r.equipmentId)) · \(r.completedDate.xttFormatted())",
                 XTTTheme.Color.success, "checkmark.seal.fill")
            }
        }

        if items.isEmpty {
            let card = UIView()
            card.xttApplyCardStyle(radius: 16)
            card.translatesAutoresizingMaskIntoConstraints = false
            let label = UILabel()
            label.text = "Nothing scheduled here."
            label.font = XTTTheme.Font.subhead()
            label.textColor = XTTTheme.Color.secondaryText
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            label.xttPinEdges(to: card, insets: UIEdgeInsets(top: 22, left: 16, bottom: 22, right: 16))
            agendaStack.addArrangedSubview(card)
            return
        }

        for item in items {
            agendaStack.addArrangedSubview(xttAgendaRow(title: item.0, subtitle: item.1, color: item.2, icon: item.3))
        }
    }

    private func xttAgendaRow(title: String, subtitle: String, color: UIColor, icon: String) -> UIView {
        let card = UIView()
        card.xttApplyCardStyle(radius: 16)
        card.translatesAutoresizingMaskIntoConstraints = false

        let bar = UIView()
        bar.backgroundColor = color
        bar.xttRoundCorners(2)
        bar.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = XTTTheme.Font.bodyMedium()
        titleLabel.textColor = XTTTheme.Color.primaryText

        let subLabel = UILabel()
        subLabel.text = subtitle
        subLabel.font = XTTTheme.Font.caption()
        subLabel.textColor = XTTTheme.Color.secondaryText

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subLabel])
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(bar)
        card.addSubview(iconView)
        card.addSubview(textStack)
        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            bar.topAnchor.constraint(equalTo: card.topAnchor),
            bar.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            bar.widthAnchor.constraint(equalToConstant: 4),
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            textStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            textStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            textStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        return card
    }
}
