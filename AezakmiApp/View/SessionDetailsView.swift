//
//  SessionDetailsView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 28.11.2025.
//

import SwiftUI


struct SessionDetailView: View {
    let session: ScanSession
    
    var lanDevices: [LanDeviceEntity] {
        (session.lanDevices as? Set<LanDeviceEntity> ?? [])
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
    
    var btDevices: [BluetoothDeviceEntity] {
        (session.bluetoothDevices as? Set<BluetoothDeviceEntity> ?? [])
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
    
    var body: some View {
        List {
            Section("LAN") {
                ForEach(lanDevices) { device in
                    VStack(alignment: .leading) {
                        Text(device.name ?? "—")
                        Text("IP: \(device.ip ?? "—")")
                        Text("MAC: \(device.mac ?? "—")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("Bluetooth") {
                ForEach(btDevices) { device in
                    VStack(alignment: .leading) {
                        Text(device.name ?? "—")
                        Text("UUID: \(device.uuid)")
                        Text("RSSI: \(device.rssi)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
