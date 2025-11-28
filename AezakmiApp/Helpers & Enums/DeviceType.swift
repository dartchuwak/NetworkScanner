//
//  DeviceType.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import Foundation

enum  DeviceType: String, CaseIterable {
    case bt = "Bluetooth"
    case lan = "LAN"
}

enum DeviceTypeSort: String, CaseIterable, Identifiable {
    case all = "Все"
    case lan = "LAN"
    case bt  = "Bluetooth"
    
    var id: Self { self }
}

enum LanSortOption: String, CaseIterable, Identifiable {
    case name = "По имени"
    case ip   = "По IP"
    
    var id: Self { self }
}
