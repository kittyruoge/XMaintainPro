//
//  XTTModels.swift
//  XMaintainPro
//
//  Codable domain models for the maintenance lifecycle.
//

import Foundation

// MARK: - User
struct XTTUser: Codable {
    var username: String
    var displayName: String
    var email: String
    var createdAt: Date

    init(username: String, displayName: String, email: String, createdAt: Date = Date()) {
        self.username = username
        self.displayName = displayName
        self.email = email
        self.createdAt = createdAt
    }
}

// MARK: - Equipment
enum XTTEquipmentCategory: String, Codable, CaseIterable {
    case machinery = "Machinery"
    case electronics = "Electronics"
    case vehicle = "Vehicle"
    case hvac = "HVAC"
    case tools = "Tools"
    case appliance = "Appliance"
    case other = "Other"

    var icon: String {
        switch self {
        case .machinery: return "gearshape.2.fill"
        case .electronics: return "cpu.fill"
        case .vehicle: return "car.fill"
        case .hvac: return "wind"
        case .tools: return "wrench.and.screwdriver.fill"
        case .appliance: return "washer.fill"
        case .other: return "shippingbox.fill"
        }
    }
}

struct XTTEquipment: Codable, Identifiable {
    var id: String
    var name: String
    var category: XTTEquipmentCategory
    var brand: String
    var model: String
    var serialNumber: String
    var purchaseDate: Date
    var location: String
    var notes: String
    var imageFileName: String?
    var isFavorite: Bool
    var createdAt: Date

    init(id: String = UUID().uuidString,
         name: String,
         category: XTTEquipmentCategory = .machinery,
         brand: String = "",
         model: String = "",
         serialNumber: String = "",
         purchaseDate: Date = Date(),
         location: String = "",
         notes: String = "",
         imageFileName: String? = nil,
         isFavorite: Bool = false,
         createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.category = category
        self.brand = brand
        self.model = model
        self.serialNumber = serialNumber
        self.purchaseDate = purchaseDate
        self.location = location
        self.notes = notes
        self.imageFileName = imageFileName
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }
}

// MARK: - Maintenance Plan
enum XTTMaintenanceCycle: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case biannual = "Every 6 Months"
    case yearly = "Yearly"

    var days: Int {
        switch self {
        case .daily: return 1
        case .weekly: return 7
        case .monthly: return 30
        case .quarterly: return 90
        case .biannual: return 182
        case .yearly: return 365
        }
    }
}

enum XTTPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}

enum XTTMaintenanceStatus: String, Codable, CaseIterable {
    case scheduled = "Scheduled"
    case inProgress = "In Progress"
    case completed = "Completed"
    case overdue = "Overdue"
}

struct XTTMaintenancePlan: Codable, Identifiable {
    var id: String
    var planName: String
    var equipmentId: String
    var cycle: XTTMaintenanceCycle
    var nextDate: Date
    var priority: XTTPriority
    var status: XTTMaintenanceStatus
    var notes: String
    var createdAt: Date

    init(id: String = UUID().uuidString,
         planName: String,
         equipmentId: String,
         cycle: XTTMaintenanceCycle = .monthly,
         nextDate: Date = Date(),
         priority: XTTPriority = .medium,
         status: XTTMaintenanceStatus = .scheduled,
         notes: String = "",
         createdAt: Date = Date()) {
        self.id = id
        self.planName = planName
        self.equipmentId = equipmentId
        self.cycle = cycle
        self.nextDate = nextDate
        self.priority = priority
        self.status = status
        self.notes = notes
        self.createdAt = createdAt
    }
}

// MARK: - Maintenance History record
struct XTTMaintenanceRecord: Codable, Identifiable {
    var id: String
    var planId: String
    var planName: String
    var equipmentId: String
    var completedDate: Date
    var notes: String

    init(id: String = UUID().uuidString,
         planId: String,
         planName: String,
         equipmentId: String,
         completedDate: Date = Date(),
         notes: String = "") {
        self.id = id
        self.planId = planId
        self.planName = planName
        self.equipmentId = equipmentId
        self.completedDate = completedDate
        self.notes = notes
    }
}

// MARK: - Repair
struct XTTRepair: Codable, Identifiable {
    var id: String
    var equipmentId: String
    var repairDate: Date
    var problem: String
    var solution: String
    var cost: Double
    var technician: String
    var notes: String
    var photoFileNames: [String]
    var createdAt: Date

    init(id: String = UUID().uuidString,
         equipmentId: String,
         repairDate: Date = Date(),
         problem: String = "",
         solution: String = "",
         cost: Double = 0,
         technician: String = "",
         notes: String = "",
         photoFileNames: [String] = [],
         createdAt: Date = Date()) {
        self.id = id
        self.equipmentId = equipmentId
        self.repairDate = repairDate
        self.problem = problem
        self.solution = solution
        self.cost = cost
        self.technician = technician
        self.notes = notes
        self.photoFileNames = photoFileNames
        self.createdAt = createdAt
    }
}

// MARK: - Spare Part
struct XTTSparePart: Codable, Identifiable {
    var id: String
    var partName: String
    var partNumber: String
    var equipmentId: String
    var quantity: Int
    var supplier: String
    var price: Double
    var notes: String
    var createdAt: Date

    init(id: String = UUID().uuidString,
         partName: String,
         partNumber: String = "",
         equipmentId: String = "",
         quantity: Int = 0,
         supplier: String = "",
         price: Double = 0,
         notes: String = "",
         createdAt: Date = Date()) {
        self.id = id
        self.partName = partName
        self.partNumber = partNumber
        self.equipmentId = equipmentId
        self.quantity = quantity
        self.supplier = supplier
        self.price = price
        self.notes = notes
        self.createdAt = createdAt
    }
}

// MARK: - Warranty
enum XTTWarrantyStatus: String, Codable {
    case active = "Active"
    case expiringSoon = "Expiring Soon"
    case expired = "Expired"
}

struct XTTWarranty: Codable, Identifiable {
    var id: String
    var equipmentId: String
    var warrantyStart: Date
    var warrantyEnd: Date
    var supplier: String
    var notes: String
    var createdAt: Date

    init(id: String = UUID().uuidString,
         equipmentId: String,
         warrantyStart: Date = Date(),
         warrantyEnd: Date = Date.xttFrom(daysFromNow: 365),
         supplier: String = "",
         notes: String = "",
         createdAt: Date = Date()) {
        self.id = id
        self.equipmentId = equipmentId
        self.warrantyStart = warrantyStart
        self.warrantyEnd = warrantyEnd
        self.supplier = supplier
        self.notes = notes
        self.createdAt = createdAt
    }

    var remainingDays: Int { Date().xttDaysUntil(warrantyEnd) }

    var status: XTTWarrantyStatus {
        let d = remainingDays
        if d < 0 { return .expired }
        if d <= 30 { return .expiringSoon }
        return .active
    }
}

// MARK: - Document
enum XTTDocumentType: String, Codable {
    case image = "Image"
    case pdf = "PDF"
    case file = "File"

    var icon: String {
        switch self {
        case .image: return "photo.fill"
        case .pdf: return "doc.richtext.fill"
        case .file: return "doc.fill"
        }
    }
}

struct XTTDocument: Codable, Identifiable {
    var id: String
    var equipmentId: String
    var title: String
    var type: XTTDocumentType
    var fileName: String?
    var createdAt: Date

    init(id: String = UUID().uuidString,
         equipmentId: String,
         title: String,
         type: XTTDocumentType = .file,
         fileName: String? = nil,
         createdAt: Date = Date()) {
        self.id = id
        self.equipmentId = equipmentId
        self.title = title
        self.type = type
        self.fileName = fileName
        self.createdAt = createdAt
    }
}

// MARK: - Aggregate store (one blob per user)
struct XTTDataStore: Codable {
    var equipment: [XTTEquipment] = []
    var plans: [XTTMaintenancePlan] = []
    var maintenanceRecords: [XTTMaintenanceRecord] = []
    var repairs: [XTTRepair] = []
    var spareParts: [XTTSparePart] = []
    var warranties: [XTTWarranty] = []
    var documents: [XTTDocument] = []
}
