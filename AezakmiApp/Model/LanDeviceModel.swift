//
//  LanDeviceModel 2.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 30.11.2025.
//

import Foundation

struct LanDeviceModel: Identifiable {
    var name: String
    var ipAddress: String
    var macAddress: String
    let id: String
    
    init(name: String, ipAdress: String, macAddress: String, id: String = UUID().uuidString) {
        self.name = name
        self.ipAddress = ipAdress
        self.macAddress = macAddress
        self.id = id
    }
}
