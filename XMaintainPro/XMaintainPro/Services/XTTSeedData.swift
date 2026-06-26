//
//  XTTSeedData.swift
//  XMaintainPro
//
//  Realistic demo data for the test account (test001 / abc001).
//

import Foundation

enum XTTSeedData {

    static func xttSeedTestAccount() {
        let dm = XTTDataManager.shared
        // Configure the manager to point at the test account store before seeding.
        dm.xttConfigure(forGuest: false, username: "test001")

        // Only seed once if empty.
        guard dm.store.equipment.isEmpty else { return }

        // MARK: Equipment
        let cnc = XTTEquipment(name: "CNC Milling Machine",
                               category: .machinery,
                               brand: "Haas",
                               model: "VF-2SS",
                               serialNumber: "HA-2019-44821",
                               purchaseDate: Date.xttFrom(daysFromNow: -540),
                               location: "Workshop A · Bay 1",
                               notes: "High-speed vertical machining center. Primary production unit.",
                               isFavorite: true)

        let compressor = XTTEquipment(name: "Air Compressor",
                                      category: .machinery,
                                      brand: "Atlas Copco",
                                      model: "GA 22",
                                      serialNumber: "AC-22-77310",
                                      purchaseDate: Date.xttFrom(daysFromNow: -380),
                                      location: "Utility Room",
                                      notes: "Rotary screw compressor, 30 HP.")

        let forklift = XTTEquipment(name: "Electric Forklift",
                                    category: .vehicle,
                                    brand: "Toyota",
                                    model: "8FBE20",
                                    serialNumber: "TY-FL-90233",
                                    purchaseDate: Date.xttFrom(daysFromNow: -220),
                                    location: "Warehouse",
                                    notes: "2-ton electric counterbalance forklift.",
                                    isFavorite: true)

        let hvac = XTTEquipment(name: "Rooftop HVAC Unit",
                                category: .hvac,
                                brand: "Carrier",
                                model: "48TC",
                                serialNumber: "CR-HV-55120",
                                purchaseDate: Date.xttFrom(daysFromNow: -700),
                                location: "Rooftop · North",
                                notes: "Packaged rooftop unit serving the main floor.")

        let server = XTTEquipment(name: "Edge Server Rack",
                                  category: .electronics,
                                  brand: "Dell",
                                  model: "PowerEdge R750",
                                  serialNumber: "DL-SV-11002",
                                  purchaseDate: Date.xttFrom(daysFromNow: -120),
                                  location: "IT Room",
                                  notes: "Production edge compute node.")

        [cnc, compressor, forklift, hvac, server].forEach { dm.xttUpsert(equipment: $0) }

        // MARK: Maintenance plans
        dm.xttUpsert(plan: XTTMaintenancePlan(planName: "Spindle Lubrication",
                                              equipmentId: cnc.id,
                                              cycle: .weekly,
                                              nextDate: Date.xttFrom(daysFromNow: 0),
                                              priority: .high,
                                              status: .scheduled,
                                              notes: "Apply spindle grease, inspect ways."))
        dm.xttUpsert(plan: XTTMaintenancePlan(planName: "Coolant Replacement",
                                              equipmentId: cnc.id,
                                              cycle: .monthly,
                                              nextDate: Date.xttFrom(daysFromNow: 9),
                                              priority: .medium,
                                              status: .scheduled))
        dm.xttUpsert(plan: XTTMaintenancePlan(planName: "Filter & Oil Check",
                                              equipmentId: compressor.id,
                                              cycle: .monthly,
                                              nextDate: Date.xttFrom(daysFromNow: -2),
                                              priority: .high,
                                              status: .scheduled,
                                              notes: "Replace intake filter if clogged."))
        dm.xttUpsert(plan: XTTMaintenancePlan(planName: "Battery Inspection",
                                              equipmentId: forklift.id,
                                              cycle: .weekly,
                                              nextDate: Date.xttFrom(daysFromNow: 2),
                                              priority: .medium,
                                              status: .scheduled))
        dm.xttUpsert(plan: XTTMaintenancePlan(planName: "Refrigerant Pressure Check",
                                              equipmentId: hvac.id,
                                              cycle: .quarterly,
                                              nextDate: Date.xttFrom(daysFromNow: 21),
                                              priority: .low,
                                              status: .scheduled))
        dm.xttUpsert(plan: XTTMaintenancePlan(planName: "Firmware & Fan Audit",
                                              equipmentId: server.id,
                                              cycle: .quarterly,
                                              nextDate: Date.xttFrom(daysFromNow: 40),
                                              priority: .medium,
                                              status: .scheduled))

        // MARK: Maintenance history records
        [
            XTTMaintenanceRecord(planId: "seed", planName: "Spindle Lubrication",
                                 equipmentId: cnc.id,
                                 completedDate: Date.xttFrom(daysFromNow: -7),
                                 notes: "Completed on schedule. Ways in good condition."),
            XTTMaintenanceRecord(planId: "seed", planName: "Battery Inspection",
                                 equipmentId: forklift.id,
                                 completedDate: Date.xttFrom(daysFromNow: -5),
                                 notes: "Topped up cells, cleaned terminals."),
            XTTMaintenanceRecord(planId: "seed", planName: "Filter & Oil Check",
                                 equipmentId: compressor.id,
                                 completedDate: Date.xttFrom(daysFromNow: -32),
                                 notes: "Replaced intake filter.")
        ].forEach { dm.xttAddMaintenanceRecord($0) }

        // MARK: Repairs
        dm.xttUpsert(repair: XTTRepair(equipmentId: cnc.id,
                                       repairDate: Date.xttFrom(daysFromNow: -45),
                                       problem: "Spindle overheating during long runs.",
                                       solution: "Replaced spindle bearing and recalibrated cooling loop.",
                                       cost: 1240.50,
                                       technician: "M. Reyes"))
        dm.xttUpsert(repair: XTTRepair(equipmentId: compressor.id,
                                       repairDate: Date.xttFrom(daysFromNow: -88),
                                       problem: "Pressure drop and audible leak.",
                                       solution: "Resealed discharge valve, replaced gasket.",
                                       cost: 320.00,
                                       technician: "D. Patel"))
        dm.xttUpsert(repair: XTTRepair(equipmentId: forklift.id,
                                       repairDate: Date.xttFrom(daysFromNow: -15),
                                       problem: "Lift motor intermittent fault.",
                                       solution: "Replaced worn contactor and checked wiring harness.",
                                       cost: 540.75,
                                       technician: "M. Reyes"))

        // MARK: Spare parts
        dm.xttUpsert(part: XTTSparePart(partName: "Spindle Bearing",
                                        partNumber: "SB-7204-CTP",
                                        equipmentId: cnc.id,
                                        quantity: 4,
                                        supplier: "Precision Bearings Co.",
                                        price: 89.90))
        dm.xttUpsert(part: XTTSparePart(partName: "Intake Air Filter",
                                        partNumber: "AF-GA22-01",
                                        equipmentId: compressor.id,
                                        quantity: 2,
                                        supplier: "Atlas Copco Parts",
                                        price: 42.00))
        dm.xttUpsert(part: XTTSparePart(partName: "Hydraulic Seal Kit",
                                        partNumber: "HS-8FBE-220",
                                        equipmentId: forklift.id,
                                        quantity: 1,
                                        supplier: "Toyota Material Handling",
                                        price: 156.25))
        dm.xttUpsert(part: XTTSparePart(partName: "Air Filter (HVAC)",
                                        partNumber: "MERV13-2025",
                                        equipmentId: hvac.id,
                                        quantity: 8,
                                        supplier: "FilterDirect",
                                        price: 18.50))

        // MARK: Warranties
        dm.xttUpsert(warranty: XTTWarranty(equipmentId: server.id,
                                           warrantyStart: Date.xttFrom(daysFromNow: -120),
                                           warrantyEnd: Date.xttFrom(daysFromNow: 610),
                                           supplier: "Dell ProSupport"))
        dm.xttUpsert(warranty: XTTWarranty(equipmentId: forklift.id,
                                           warrantyStart: Date.xttFrom(daysFromNow: -220),
                                           warrantyEnd: Date.xttFrom(daysFromNow: 18),
                                           supplier: "Toyota Material Handling",
                                           notes: "Powertrain coverage only."))
        dm.xttUpsert(warranty: XTTWarranty(equipmentId: cnc.id,
                                           warrantyStart: Date.xttFrom(daysFromNow: -540),
                                           warrantyEnd: Date.xttFrom(daysFromNow: -175),
                                           supplier: "Haas Automation"))

        // MARK: Documents
        dm.xttUpsert(document: XTTDocument(equipmentId: cnc.id,
                                           title: "Operator Manual",
                                           type: .pdf))
        dm.xttUpsert(document: XTTDocument(equipmentId: hvac.id,
                                           title: "Wiring Diagram",
                                           type: .image))
        dm.xttUpsert(document: XTTDocument(equipmentId: server.id,
                                           title: "Rack Layout",
                                           type: .file))

        dm.xttSave()
    }
}
