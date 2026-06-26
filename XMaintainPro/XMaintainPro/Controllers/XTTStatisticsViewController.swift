//
//  XTTStatisticsViewController.swift
//  XMaintainPro
//
//  Statistics dashboard with UIKit-drawn bar and donut charts.
//

import UIKit

final class XTTStatisticsViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Statistics"
        navigationItem.largeTitleDisplayMode = .always
        xttApplyBaseBackground()
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
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        xttRender()
    }

    private func xttRender() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let dm = XTTDataManager.shared

        // Summary tiles
        let row1 = UIStackView(); row1.axis = .horizontal; row1.distribution = .fillEqually; row1.spacing = 12
        row1.addArrangedSubview(xttStatTile("\(dm.store.equipment.count)", "Total Equipment", "gearshape.2.fill", XTTTheme.Color.gradientBlue))
        row1.addArrangedSubview(xttStatTile("\(dm.store.plans.count)", "Maintenance Plans", "calendar.badge.clock", XTTTheme.Color.gradientPurple))
        let row2 = UIStackView(); row2.axis = .horizontal; row2.distribution = .fillEqually; row2.spacing = 12
        row2.addArrangedSubview(xttStatTile("\(dm.store.repairs.count)", "Total Repairs", "wrench.fill", XTTTheme.Color.gradientOrange))
        row2.addArrangedSubview(xttStatTile(String(format: "$%.0f", dm.xttTotalRepairCost), "Repair Cost", "dollarsign.circle.fill", XTTTheme.Color.gradientGreen))
        stack.addArrangedSubview(row1)
        stack.addArrangedSubview(row2)

        // Equipment by category bar chart
        let categoryData = xttCategoryCounts()
        stack.addArrangedSubview(xttChartCard(title: "Equipment by Category",
                                              chart: XTTBarChartView(data: categoryData)))

        // Warranty donut
        let warrantyData = xttWarrantyData()
        stack.addArrangedSubview(xttChartCard(title: "Warranty Status",
                                              chart: XTTDonutChartView(segments: warrantyData)))

        // Maintenance status breakdown
        let statusData = xttStatusData()
        stack.addArrangedSubview(xttChartCard(title: "Maintenance Status",
                                              chart: XTTBarChartView(data: statusData)))

        // Cost summary card
        stack.addArrangedSubview(xttCostCard())
    }

    // MARK: - Data
    private func xttCategoryCounts() -> [XTTChartDatum] {
        let equip = XTTDataManager.shared.store.equipment
        return XTTEquipmentCategory.allCases.compactMap { cat in
            let count = equip.filter { $0.category == cat }.count
            return count > 0 ? XTTChartDatum(label: cat.rawValue, value: Double(count), color: XTTTheme.Color.accent) : nil
        }
    }

    private func xttWarrantyData() -> [XTTChartDatum] {
        let w = XTTDataManager.shared.store.warranties
        let active = w.filter { $0.status == .active }.count
        let soon = w.filter { $0.status == .expiringSoon }.count
        let expired = w.filter { $0.status == .expired }.count
        var result: [XTTChartDatum] = []
        if active > 0 { result.append(XTTChartDatum(label: "Active", value: Double(active), color: XTTTheme.Color.success)) }
        if soon > 0 { result.append(XTTChartDatum(label: "Expiring", value: Double(soon), color: XTTTheme.Color.warning)) }
        if expired > 0 { result.append(XTTChartDatum(label: "Expired", value: Double(expired), color: XTTTheme.Color.danger)) }
        return result
    }

    private func xttStatusData() -> [XTTChartDatum] {
        let plans = XTTDataManager.shared.store.plans
        let dm = XTTDataManager.shared
        let resolved = plans.map { dm.xttResolvedStatus(for: $0) }
        var result: [XTTChartDatum] = []
        for s in XTTMaintenanceStatus.allCases {
            let count = resolved.filter { $0 == s }.count
            if count > 0 {
                result.append(XTTChartDatum(label: s.rawValue, value: Double(count), color: XTTColorMap.maintenanceStatus(s)))
            }
        }
        return result
    }

    // MARK: - Builders
    private func xttStatTile(_ value: String, _ label: String, _ icon: String, _ gradient: [UIColor]) -> UIView {
        let tile = XTTGradientView(colors: gradient)
        tile.xttRoundCorners(18)
        tile.translatesAutoresizingMaskIntoConstraints = false
        tile.heightAnchor.constraint(equalToConstant: 100).isActive = true

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = UIColor.white.withAlphaComponent(0.85)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = .white
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.6
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        let nameLabel = UILabel()
        nameLabel.text = label
        nameLabel.font = XTTTheme.Font.caption()
        nameLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        tile.addSubview(iconView); tile.addSubview(valueLabel); tile.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: tile.topAnchor, constant: 14),
            iconView.leadingAnchor.constraint(equalTo: tile.leadingAnchor, constant: 14),
            valueLabel.leadingAnchor.constraint(equalTo: tile.leadingAnchor, constant: 14),
            valueLabel.trailingAnchor.constraint(equalTo: tile.trailingAnchor, constant: -14),
            valueLabel.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -2),
            nameLabel.leadingAnchor.constraint(equalTo: tile.leadingAnchor, constant: 14),
            nameLabel.bottomAnchor.constraint(equalTo: tile.bottomAnchor, constant: -14)
        ])
        return tile
    }

    private func xttChartCard(title: String, chart: UIView) -> UIView {
        let header = UILabel()
        header.text = title
        header.font = XTTTheme.Font.headline()
        header.textColor = XTTTheme.Color.primaryText

        let card = UIView()
        card.xttApplyCardStyle()
        card.translatesAutoresizingMaskIntoConstraints = false
        chart.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(chart)
        chart.xttPinEdges(to: card, insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))

        let wrap = UIStackView(arrangedSubviews: [header, card])
        wrap.axis = .vertical
        wrap.spacing = 8
        return wrap
    }

    private func xttCostCard() -> UIView {
        let dm = XTTDataManager.shared
        let rows = UIStackView()
        rows.axis = .vertical
        rows.addArrangedSubview(XTTDetailRow(label: "Total Repair Cost", value: String(format: "$%.2f", dm.xttTotalRepairCost), valueColor: XTTTheme.Color.accent))
        let avg = dm.store.repairs.isEmpty ? 0 : dm.xttTotalRepairCost / Double(dm.store.repairs.count)
        rows.addArrangedSubview(XTTDetailRow(label: "Avg. per Repair", value: String(format: "$%.2f", avg)))
        let partsValue = dm.store.spareParts.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        rows.addArrangedSubview(XTTDetailRow(label: "Spare Parts Value", value: String(format: "$%.2f", partsValue)))
        return xttChartCard(title: "Cost Summary", chart: rows)
    }
}

// MARK: - Chart datum
struct XTTChartDatum {
    let label: String
    let value: Double
    let color: UIColor
}

// MARK: - Bar chart
final class XTTBarChartView: UIView {
    private let data: [XTTChartDatum]
    init(data: [XTTChartDatum]) {
        self.data = data
        super.init(frame: .zero)
        backgroundColor = .clear
        heightAnchor.constraint(equalToConstant: CGFloat(max(1, data.count)) * 38 + 8).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ rect: CGRect) {
        guard !data.isEmpty, let ctx = UIGraphicsGetCurrentContext() else {
            xttDrawEmpty(rect); return
        }
        let maxValue = data.map { $0.value }.max() ?? 1
        let labelWidth: CGFloat = 90
        let rowHeight: CGFloat = 38
        let barMaxWidth = rect.width - labelWidth - 50

        for (i, datum) in data.enumerated() {
            let y = CGFloat(i) * rowHeight + 8
            // label
            let labelAttrs: [NSAttributedString.Key: Any] = [
                .font: XTTTheme.Font.subhead(),
                .foregroundColor: XTTTheme.Color.secondaryText
            ]
            (datum.label as NSString).draw(in: CGRect(x: 0, y: y + 4, width: labelWidth - 8, height: 20), withAttributes: labelAttrs)

            // bar background
            let barWidth = max(6, barMaxWidth * CGFloat(datum.value / maxValue))
            let barRect = CGRect(x: labelWidth, y: y, width: barWidth, height: 22)
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: 6)
            ctx.setFillColor(datum.color.cgColor)
            path.fill()

            // value
            let valueAttrs: [NSAttributedString.Key: Any] = [
                .font: XTTTheme.Font.caption(),
                .foregroundColor: XTTTheme.Color.primaryText
            ]
            (String(Int(datum.value)) as NSString).draw(at: CGPoint(x: labelWidth + barWidth + 8, y: y + 4), withAttributes: valueAttrs)
        }
    }

    private func xttDrawEmpty(_ rect: CGRect) {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: XTTTheme.Font.subhead(),
            .foregroundColor: XTTTheme.Color.secondaryText
        ]
        ("No data yet" as NSString).draw(at: CGPoint(x: 4, y: 8), withAttributes: attrs)
    }
}

// MARK: - Donut chart
final class XTTDonutChartView: UIView {
    private let segments: [XTTChartDatum]
    private let legend = UIStackView()

    init(segments: [XTTChartDatum]) {
        self.segments = segments
        super.init(frame: .zero)
        backgroundColor = .clear
        heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ rect: CGRect) {
        guard !segments.isEmpty, let ctx = UIGraphicsGetCurrentContext() else {
            let attrs: [NSAttributedString.Key: Any] = [
                .font: XTTTheme.Font.subhead(),
                .foregroundColor: XTTTheme.Color.secondaryText
            ]
            ("No data yet" as NSString).draw(at: CGPoint(x: 4, y: 8), withAttributes: attrs)
            return
        }
        let total = segments.reduce(0) { $0 + $1.value }
        guard total > 0 else { return }

        let diameter = min(rect.height, 130)
        let center = CGPoint(x: diameter / 2 + 8, y: rect.height / 2)
        let radius = diameter / 2
        let lineWidth: CGFloat = 24

        var startAngle = -CGFloat.pi / 2
        for segment in segments {
            let angle = CGFloat(segment.value / total) * 2 * .pi
            let path = UIBezierPath(arcCenter: center, radius: radius - lineWidth / 2,
                                    startAngle: startAngle, endAngle: startAngle + angle, clockwise: true)
            ctx.setStrokeColor(segment.color.cgColor)
            ctx.setLineWidth(lineWidth)
            ctx.setLineCap(.butt)
            path.stroke()
            startAngle += angle
        }

        // center total
        let totalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: XTTTheme.Color.primaryText
        ]
        let totalStr = "\(Int(total))" as NSString
        let size = totalStr.size(withAttributes: totalAttrs)
        totalStr.draw(at: CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2), withAttributes: totalAttrs)

        // legend
        let legendAttrs: [NSAttributedString.Key: Any] = [
            .font: XTTTheme.Font.subhead(),
            .foregroundColor: XTTTheme.Color.primaryText
        ]
        var ly: CGFloat = (rect.height - CGFloat(segments.count) * 24) / 2
        let lx = diameter + 28
        for segment in segments {
            let dotRect = CGRect(x: lx, y: ly + 4, width: 12, height: 12)
            ctx.setFillColor(segment.color.cgColor)
            UIBezierPath(roundedRect: dotRect, cornerRadius: 3).fill()
            ("\(segment.label) (\(Int(segment.value)))" as NSString).draw(at: CGPoint(x: lx + 20, y: ly), withAttributes: legendAttrs)
            ly += 24
        }
    }
}
