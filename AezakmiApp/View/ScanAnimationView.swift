//
//  ScanAnimationView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 29.11.2025.
//

import SwiftUI
import Lottie

struct ScanAnimationView: View {
    let count: Int
    var body: some View {
        ZStack {
            LottieView(animation: .named("scaner"))
                .playing(loopMode: .loop)
            Text("Найдено \(count) устройств")
        }
    }
}

//#Preview {
//    ScanAnimationView(count: .constant(5))
//}
