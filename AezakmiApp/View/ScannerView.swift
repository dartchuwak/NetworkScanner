//
//  ContentView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import SwiftUI

struct ScannerView: View {
    @ObservedObject var scannerViewModel: ScannerViewModel
    @State var isScanActive: Bool = false
    @State private var picker: DeviceType = .bt
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Picker("Вид устройства", selection: $picker) {
                        ForEach(DeviceType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack {
                            if picker == .bt {
                                ForEach(scannerViewModel.bluetoothDevices) { device in
                                    BluetoothDeviceCardView(device: device)
                                }
                                
                            } else {
                                ForEach(scannerViewModel.lanDevices) { device in
                                    LanDeviceCardView(device: device)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationTitle("Поиск")
                
                VStack {
                    Spacer()
                    
                    Button {
                        scannerViewModel.startScanning()
                    } label: {
                        Text("Начать сканирование")
                            .font(.headline)
                            .frame(width: 250, height: 50)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(25)
                            .shadow(radius: 10)
                    }
                    .padding(.bottom, 40)
                }
                
                if scannerViewModel.isScanActive {
                    ProgressView()
                        .scaleEffect(1)
                }
            }
        }
    }
}
