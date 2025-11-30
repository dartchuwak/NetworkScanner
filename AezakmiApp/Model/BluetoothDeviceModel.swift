//
//  BluetoothDeviceModel.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import Foundation
import CoreBluetooth

struct BluetoothDeviceModel: Hashable, Identifiable {
    let name: String
    let rssi: Int
    let uuid: String
    let state: String
    var id: String { uuid }
}
