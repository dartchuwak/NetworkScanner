//
//  DeviceType.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import Foundation

enum SessionsSortOption: String, CaseIterable, Identifiable {
    case dateDesc = "По дате (новые сверху)"
    case dateAsc  = "По дате (старые сверху)"
    
    var id: Self { self }
}

enum DeviceType: String, CaseIterable, Identifiable {
    case lan = "LAN"
    case bt  = "Bluetooth"
    
    var id: Self { self }
}

enum LanSortOption: String, CaseIterable, Identifiable {
    case name = "По имени"
    case ip   = "По IP"
    
    var id: Self { self }
}
