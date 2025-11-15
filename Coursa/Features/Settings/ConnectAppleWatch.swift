//
//  ConnectAppleWatch.swift
//  Coursa
//
//  Created by Zikar Nurizky on 15/11/25.
//

import SwiftUI

struct ConnectAppleWatch: View {
    @State private var isPaired: Bool = false
    @EnvironmentObject private var syncService: SyncService

    var body: some View {
        VStack(spacing: 0) {
            // Header Text
            Text(isPaired ? "Set Up Complete" : "Connect Apple Watch")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .padding(.top, 20)
                .padding(.bottom, 24)

            // Apple Watch Image Container
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.7, green: 0.8, blue: 0.2),
                        Color(red: 0.3, green: 0.4, blue: 0.1),
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)

                // Apple Watch mockup
                Image("coursa-watch")
            }
            .frame(maxWidth: .infinity)
            .frame(height: 250)

            // Description Text
            Text(
                isPaired
                    ? "Congrats! Now Apple Watch is ready to use with Coursa."
                    : "Our app syncs with Apple Watch to deliver real-time GPS, heart rate, and running metrics right to your wrist, monitoring every run without needing your phone."
            )
            .font(.system(size: 15))
            .foregroundColor(.white.opacity(0.7))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 32)

            // Pair Button (only show when not paired)
            if !isPaired {
                Button(action: {
                    syncService.connect()
                    isPaired = true
                }) {
                    Text("Pair")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            } else {
                Spacer()
                    .frame(height: 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.11, green: 0.11, blue: 0.12))
    }
}

#Preview {
    ConnectAppleWatch()
}
