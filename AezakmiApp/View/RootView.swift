//
//  RootView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var container: AppContainer
    @State private var isAnimationPlayed = false
    
    var body: some View {
        if !isAnimationPlayed {
            LoadingView(isAnimationPlayed: $isAnimationPlayed)
        } else {
            TabView {
                ScannerView(viewModel: container.makeScannerViewModel())
                    .tabItem {
                        Image(systemName: "wifi")
                        Text("Сканирование")
                    }
                
                HistoryView(viewModel: container.makeHistoryViewModel())
                    .tabItem {
                        Image(systemName: "folder")
                        Text("История")
                    }
            }
        }
    }
}
