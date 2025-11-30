//
//  SessionDetailsView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 28.11.2025.
//

import SwiftUI

struct SessionDetailView: View {
    @ObservedObject var viewModel: SessionDetailViewModel
    let sessionDate: Date
    
    var body: some View {
        ScrollView {
            VStack {
                Picker("Тип устройств", selection: $viewModel.deviceTypeFilter) {
                    ForEach(DeviceType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
                if viewModel.deviceTypeFilter == .lan {
                    Picker("Сортировка LAN", selection: $viewModel.lanSort) {
                        ForEach(LanSortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Section("LAN") {
                        ForEach(viewModel.lanDevices) { device in
                            NavigationLink {
                                LanDeviceDetailView(device: device)
                            } label: {
                                LanDeviceCardView(device: device)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            
            if viewModel.deviceTypeFilter == .bt {
                Section("Bluetooth") {
                    ForEach(viewModel.btDevices) { device in
                        NavigationLink {
                            BluetoothDeviceDetailView(device: device)
                        } label: {
                            VStack(alignment: .leading) {
                                BluetoothDeviceCardView(device: device)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle(sessionDate.formatted(date: .abbreviated, time: .standard))
    }
}
