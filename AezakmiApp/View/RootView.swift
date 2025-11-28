//
//  RootView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var container: AppContainer
    
    @State private var animationPlayed: Bool = false
    var body: some View {
        if !animationPlayed {
            LoadingView(isAnimationPlayed: $animationPlayed)
        } else {
            TabView {
                ScannerView(scannerViewModel: container.scannerViewModel)
                    .tabItem {
                        VStack {
                            Image(systemName: "wifi")
                            Text("Сканирование")
                        }
                    }
                SessionsHistoryView()
                    .tabItem {
                        VStack {
                            Image(systemName: "folder")
                            Text("История")
                        }
                    }
            }
        }
    }
}
