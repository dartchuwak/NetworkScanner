//
//  BluetoothDeviceDetailView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 29.11.2025.
//

import SwiftUI
import CoreBluetooth

struct BluetoothDeviceDetailView: View {
    let device: BluetoothDeviceModel
    var body: some View {
        VStack {
            HStack {
                Text(device.name)
                Text(device.rssi.description)
            }
            Text(device.uuid)
            Text(device.state)
        }
    }
}
