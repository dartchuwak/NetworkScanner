//
//  RootView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import SwiftUI

struct RootView: View {
    
    @State private var animationPlayed: Bool = false
    var body: some View {
        if !animationPlayed {
            LoadingView(isAnimationPlayed: $animationPlayed)
        } else {
            TabView {
                ScannerView()
                    .tabItem {
                        VStack {
                            Image(systemName: "wifi")
                            Text("Сканирование")
                        }
                    }
                HistoryView()
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

#Preview {
    RootView()
}
