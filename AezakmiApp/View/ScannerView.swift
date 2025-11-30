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
    @State private var picker: DeviceType = .lan
    
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
                            switch picker {
                            case .lan:
                                ForEach(scannerViewModel.lanDevices) { device in
                                    LanDeviceCardView(device: device)
                                }
                            case .bt:
                                ForEach(scannerViewModel.bluetoothDevices) { device in
                                    BluetoothDeviceCardView(device: device)
                                }
                            }
                        }
                        .padding(.top, 20)
                        .padding(.horizontal)
                    }
                }
                
                VStack {
                    Spacer()
                    
                    Button {
                        scannerViewModel.startScanning(timeout: 5)
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
                   ScanAnimationView(count: scannerViewModel.devicesCount)
                }
            }
        }
    }
}
