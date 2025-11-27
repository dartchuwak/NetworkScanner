//
//  LoadingView.swift
//  AezakmiApp
//
//  Created by Evgenii Mikhailov on 27.11.2025.
//

import SwiftUI
import Lottie

struct LoadingView: View {
    @Binding var isAnimationPlayed: Bool
    var body: some View {
        LottieView(animation: .named("loader"))
            .playing()
            .animationDidFinish { _ in
                isAnimationPlayed.toggle()
               }
    }
}
