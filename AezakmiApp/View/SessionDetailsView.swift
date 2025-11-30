//
//  SessionDetailsView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 28.11.2025.
//

import SwiftUI

struct SessionDetailView: View {
    @ObservedObject var viewModel: SessionDetailViewModel
    
    var body: some View {
        List {
            Section {
                Picker("Тип устройств", selection: $viewModel.filter) {
                    ForEach(DeviceType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            if viewModel.filter == .lan {
                Section {
                    Picker("Сортировка LAN", selection: $viewModel.lanSort) {
                        ForEach(LanSortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            
//            if viewModel.filter == .all || viewModel.filter == .lan {
//                Section("LAN") {
//                    ForEach(viewModel.lanDevices, id: \.self) { device in
//                        NavigationLink {
//                            LanDeviceDetailView(device: device)
//                        } label: {
//                            VStack(alignment: .leading) {
//                                Text(device.name ?? "No Name")
//                                    .font(.headline)
//                                Text("IP: \(device.ip)")
//                                Text("MAC: \(device.mac)")
//                            }
//                        }
//                    }
//                }
//            }
            
            if viewModel.filter == .bt {
                Section("Bluetooth") {
                    ForEach(viewModel.btDevices) { device in
                        NavigationLink {
                            BluetoothDeviceDetailView(device: device)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(device.name)
                                Text(device.uuid)
                                Text(device.rssi.description)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Сессия")
        .searchable(text: $viewModel.searchText, prompt: "Имя / IP / UUID")
    }
}
