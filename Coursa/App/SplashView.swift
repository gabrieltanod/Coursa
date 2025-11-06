//
//  SplashView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 06/11/25.
//

import SwiftUI

struct SplashView: View {
    @State private var appear = false

    var body: some View {
        ZStack {
            // Background
            Color("black-500") // #2D2A2B in your assets
                .ignoresSafeArea()

            // Centered logo
            Image("logo-black")   // PDF vector in Assets
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .opacity(appear ? 1 : 0.3)
                .scaleEffect(appear ? 1.0 : 0.92)
                .animation(.easeOut(duration: 0.35), value: appear)
        }
        .onAppear { appear = true }
//        .preferredColorScheme(.dark)
        .statusBarHidden(true) // keep it clean while splash is visible
    }
}

#Preview("SplashView – Preview") {
    SplashView()
}
