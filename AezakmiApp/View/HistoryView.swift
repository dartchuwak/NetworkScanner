//
//  HistoryView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var context
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\ScanSession.timeStamp, order: .reverse)]
    )
    
    private var sessions: FetchedResults<ScanSession>
    
    @State private var picker: DeviceType = .bt
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sessions, id: \.objectID) { session in
                    NavigationLink {
                        SessionDetailView(session: session)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(session.timeStamp ?? Date(), style: .date)
                            Text("LAN: \((session.lanDevices as? Set<LanDeviceEntity>)?.count ?? 0)")
                            Text("BT: \((session.bluetoothDevices as? Set<BluetoothDeviceEntity>)?.count ?? 0)")
                        }
                    }
                }
            }
            .navigationTitle("Scan Sessions")
        }
    }
}

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

#Preview {
    HistoryView()
}
