//
//  ContentView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import SwiftUI

import SwiftUI

struct ScannerView: View {
    @ObservedObject var viewModel: ScannerViewModel
    @State private var picker: DeviceType = .lan
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    deviceTypePicker
                    devicesList
                }
                scanButton
                if viewModel.showScanerAnimationView {
                    ScanAnimationView(
                        count: viewModel.devicesCount,
                        progress: viewModel.scanProgress
                    )
                    .environmentObject(viewModel)
                    .transition(.opacity)
                }
            }
            .alert(item: $viewModel.scanError) { error in
                Alert(
                    title: Text(error.title),
                    message: Text(error.localizedDescription),
                    dismissButton: .default(Text("ОК")) {
                        viewModel.scanError = nil
                    }
                )
            }
        }
        
    }
}

private extension ScannerView {
    
    var deviceTypePicker: some View {
        Picker("Вид устройства", selection: $picker) {
            ForEach(DeviceType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.top, 16)
    }
    
    @ViewBuilder
    var devicesList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                switch picker {
                case .lan:
                    ForEach(viewModel.lanDevices) { device in
                        NavigationLink {
                            LanDeviceDetailView(device: device)
                        } label: {
                            LanDeviceCardView(device: device)
                        }
                    }
                    
                case .bt:
                    ForEach(viewModel.bluetoothDevices) { device in
                        NavigationLink {
                            BluetoothDeviceDetailView(device: device)
                        } label: {
                            BluetoothDeviceCardView(device: device)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
        }
    }
    
    var scanButton: some View {
        VStack {
            Spacer()
            Button {
                viewModel.startScanning(timeout: 5)
            } label: {
                Text(viewModel.isScanActive ? "Сканирование…" : "Начать сканирование")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(viewModel.isScanActive ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .disabled(viewModel.isScanActive)
        }
    }
}
