//
//  XTTDataManager.swift
//  XMaintainPro
//
//  Offline-first data layer. JSON per user in Documents, in-memory for guests.
//  Also stores image/PDF/file attachments via FileManager.
//

import UIKit

final class XTTDataManager {
    static let shared = XTTDataManager()
    private init() {}

    // MARK: - State
    private(set) var store = XTTDataStore()
    private var isGuest = true
    private var username: String?

    var xttIsReadOnlyPersistence: Bool { isGuest }   // guests cannot persist/export

    // MARK: - Paths
    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    private var attachmentsURL: URL {
        let url = documentsURL.appendingPathComponent("XTTAttachments", isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }
    private func storeURL(for username: String) -> URL {
        documentsURL.appendingPathComponent("XTTStore_\(username).json")
    }

    // MARK: - Configure session
    func xttConfigure(forGuest guest: Bool, username: String?) {
        self.isGuest = guest
        self.username = username
        if guest {
            store = XTTDataStore()   // fresh temporary data
        } else if let u = username {
            xttLoad(forUsername: u)
        }
    }

    func xttClearGuestData() {
        store = XTTDataStore()
        isGuest = true
        username = nil
    }

    // MARK: - Load / Save
    private func xttLoad(forUsername u: String) {
        let url = storeURL(for: u)
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder.xtt.decode(XTTDataStore.self, from: data) {
            store = decoded
        } else {
            store = XTTDataStore()
        }
    }

    func xttSave() {
        guard !isGuest, let u = username else { return }   // guest data never persists
        if let data = try? JSONEncoder.xtt.encode(store) {
            try? data.write(to: storeURL(for: u), options: .atomic)
        }
    }

    func xttDeleteStore(forUsername u: String) {
        try? FileManager.default.removeItem(at: storeURL(for: u))
    }

    // MARK: - Attachments (FileManager)
    @discardableResult
    func xttSaveImage(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let name = "img_\(UUID().uuidString).jpg"
        let url = attachmentsURL.appendingPathComponent(name)
        do { try data.write(to: url); return name } catch { return nil }
    }

    @discardableResult
    func xttSaveFileData(_ data: Data, ext: String) -> String? {
        let name = "file_\(UUID().uuidString).\(ext)"
        let url = attachmentsURL.appendingPathComponent(name)
        do { try data.write(to: url); return name } catch { return nil }
    }

    func xttImage(named name: String?) -> UIImage? {
        guard let name = name else { return nil }
        let url = attachmentsURL.appendingPathComponent(name)
        return UIImage(contentsOfFile: url.path)
    }

    func xttFileURL(named name: String?) -> URL? {
        guard let name = name else { return nil }
        let url = attachmentsURL.appendingPathComponent(name)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    // MARK: - Equipment CRUD
    func xttUpsert(equipment: XTTEquipment) {
        if let idx = store.equipment.firstIndex(where: { $0.id == equipment.id }) {
            store.equipment[idx] = equipment
        } else {
            store.equipment.insert(equipment, at: 0)
        }
        xttSave()
    }
    func xttDeleteEquipment(_ id: String) {
        store.equipment.removeAll { $0.id == id }
        store.plans.removeAll { $0.equipmentId == id }
        store.repairs.removeAll { $0.equipmentId == id }
        store.warranties.removeAll { $0.equipmentId == id }
        store.documents.removeAll { $0.equipmentId == id }
        xttSave()
    }
    func xttEquipment(by id: String) -> XTTEquipment? {
        store.equipment.first { $0.id == id }
    }
    func xttEquipmentName(_ id: String) -> String {
        xttEquipment(by: id)?.name ?? "Unassigned"
    }

    // MARK: - Maintenance plans
    func xttUpsert(plan: XTTMaintenancePlan) {
        var p = plan
        p.status = xttResolvedStatus(for: p)
        if let idx = store.plans.firstIndex(where: { $0.id == p.id }) {
            store.plans[idx] = p
        } else {
            store.plans.insert(p, at: 0)
        }
        xttSave()
    }
    func xttDeletePlan(_ id: String) {
        store.plans.removeAll { $0.id == id }
        xttSave()
    }
    func xttResolvedStatus(for plan: XTTMaintenancePlan) -> XTTMaintenanceStatus {
        if plan.status == .completed { return .completed }
        if plan.status == .inProgress { return .inProgress }
        return plan.nextDate.xttDaysUntil(Date()) > 0 ? .overdue : .scheduled
    }
    func xttCompleteMaintenance(_ plan: XTTMaintenancePlan, note: String = "") {
        let record = XTTMaintenanceRecord(planId: plan.id,
                                          planName: plan.planName,
                                          equipmentId: plan.equipmentId,
                                          notes: note)
        store.maintenanceRecords.insert(record, at: 0)
        // roll forward to next cycle
        var next = plan
        next.nextDate = Date.xttFrom(daysFromNow: plan.cycle.days)
        next.status = .scheduled
        if let idx = store.plans.firstIndex(where: { $0.id == plan.id }) {
            store.plans[idx] = next
        }
        xttSave()
    }
    func xttHistory(forPlan planId: String) -> [XTTMaintenanceRecord] {
        store.maintenanceRecords.filter { $0.planId == planId }
            .sorted { $0.completedDate > $1.completedDate }
    }

    /// Inserts a maintenance history record directly (used by seed data).
    func xttAddMaintenanceRecord(_ record: XTTMaintenanceRecord) {
        store.maintenanceRecords.insert(record, at: 0)
        xttSave()
    }

    // MARK: - Repairs
    func xttUpsert(repair: XTTRepair) {
        if let idx = store.repairs.firstIndex(where: { $0.id == repair.id }) {
            store.repairs[idx] = repair
        } else {
            store.repairs.insert(repair, at: 0)
        }
        xttSave()
    }
    func xttDeleteRepair(_ id: String) {
        store.repairs.removeAll { $0.id == id }
        xttSave()
    }

    // MARK: - Spare parts
    func xttUpsert(part: XTTSparePart) {
        if let idx = store.spareParts.firstIndex(where: { $0.id == part.id }) {
            store.spareParts[idx] = part
        } else {
            store.spareParts.insert(part, at: 0)
        }
        xttSave()
    }
    func xttDeletePart(_ id: String) {
        store.spareParts.removeAll { $0.id == id }
        xttSave()
    }
    func xttAdjustPartQuantity(_ id: String, delta: Int) {
        guard let idx = store.spareParts.firstIndex(where: { $0.id == id }) else { return }
        store.spareParts[idx].quantity = max(0, store.spareParts[idx].quantity + delta)
        xttSave()
    }

    // MARK: - Warranties
    func xttUpsert(warranty: XTTWarranty) {
        if let idx = store.warranties.firstIndex(where: { $0.id == warranty.id }) {
            store.warranties[idx] = warranty
        } else {
            store.warranties.insert(warranty, at: 0)
        }
        xttSave()
    }
    func xttDeleteWarranty(_ id: String) {
        store.warranties.removeAll { $0.id == id }
        xttSave()
    }

    // MARK: - Documents
    func xttUpsert(document: XTTDocument) {
        if let idx = store.documents.firstIndex(where: { $0.id == document.id }) {
            store.documents[idx] = document
        } else {
            store.documents.insert(document, at: 0)
        }
        xttSave()
    }
    func xttDeleteDocument(_ id: String) {
        store.documents.removeAll { $0.id == id }
        xttSave()
    }
    func xttDocuments(forEquipment id: String) -> [XTTDocument] {
        store.documents.filter { $0.equipmentId == id }
    }

    // MARK: - Export (local JSON string)
    func xttExportJSONString() -> String? {
        guard let data = try? JSONEncoder.xttPretty.encode(store) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func xttWriteExportFile() -> URL? {
        guard let data = try? JSONEncoder.xttPretty.encode(store) else { return nil }
        let url = documentsURL.appendingPathComponent("XMaintainPro_Export.json")
        do { try data.write(to: url, options: .atomic); return url } catch { return nil }
    }

    // MARK: - Stats helpers
    var xttTotalMaintenanceCost: Double { 0 }
    var xttTotalRepairCost: Double { store.repairs.reduce(0) { $0 + $1.cost } }
    var xttUpcomingPlans: [XTTMaintenancePlan] {
        store.plans
            .filter { $0.status != .completed }
            .sorted { $0.nextDate < $1.nextDate }
    }
    var xttTodayPlans: [XTTMaintenancePlan] {
        let cal = Calendar.current
        return store.plans.filter {
            $0.status != .completed && cal.isDateInToday($0.nextDate)
        }
    }
}

// MARK: - JSON coders
extension JSONEncoder {
    static var xtt: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }
    static var xttPretty: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }
}
extension JSONDecoder {
    static var xtt: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }
}
