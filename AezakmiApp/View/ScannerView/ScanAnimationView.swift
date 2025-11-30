//
//  ScanAnimationView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 29.11.2025.
//

import SwiftUI
import Lottie

struct ScanAnimationView: View {
    
    @EnvironmentObject var viewModel: ScannerViewModel
    let count: Int
    let progress: CGFloat
    
    private var clampedProgress: CGFloat {
        CGFloat(min(max(progress, 0), 1))
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 24) {
                Spacer()
                LottieView(animation: .named("networkScan"))
                    .playing(loopMode: .loop)
                    .frame(height: 300)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.gray.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.blue)
                            .frame(width: geo.size.width * clampedProgress)
                    }
                }
                .frame(height: 10)
                .padding(.horizontal)
                
                VStack(alignment: .center, spacing: 12) {
                    Text("Найдено \(count) устройств")
                        .font(.headline)
                    stopScanButton
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 32)
                Spacer()
            }
        }
    }
}

private extension ScanAnimationView {
    var stopScanButton: some View {
        Button {
            if viewModel.isScanActive {
                viewModel.stopScanning()
            } else {
                viewModel.showScanerAnimationView = false
            }
            
        } label: {
            Text(viewModel.isScanActive ? "Остановить сканирование" : "Посмотреть устройства")
                .font(.headline)
        }
        
    }
}
