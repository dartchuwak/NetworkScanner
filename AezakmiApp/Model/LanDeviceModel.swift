//
//  LanDeviceModel.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import Foundation

struct LanDeviceModel: Identifiable {
    var name: String
    var ipAdress: String
    var macAddress: String
    var id: String { macAddress }
}
