//
//  SettingsView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 03/11/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            Color("black-500").ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text("Settings")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(Color("white-500"))
                    .padding(.top, 8)

                VStack(spacing: 16) {
                    SettingsCard(
                        icon: Image(systemName: "applewatch"),
                        iconBackground: Color.white.opacity(0.12),
                        title: "Connect Apple Watch",
                        subtitle: "Apple Watch can upload directly to Coursa."
                    ) {
                        // TODO: Hook up Apple Watch flow
                    }

                    SettingsCard(
                        icon: Image(systemName: "heart.fill"),
                        iconBackground: Color.white.opacity(0.12),
                        title: "Apple Health",
                        subtitle: "Connect with Apple's Health app."
                    ) {
                        // TODO: Hook up HealthKit
                    }

                    SettingsCard(
                        icon: Image(systemName: "list.bullet.rectangle"),
                        iconBackground: Color.white.opacity(0.12),
                        title: "Privacy Notes",
                        subtitle: "See how your data is utilized."
                    ) {
                        // TODO: Show privacy info
                    }
                }

                Spacer()

                #if DEBUG
                VStack(alignment: .leading, spacing: 8) {
                    Text("Debug")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color("white-500").opacity(0.6))

                    Button(role: .destructive) {
                        router.reset(hard: true)
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Reset App (Debug)")
                                .font(.system(size: 15, weight: .medium))
                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(0.04))
                        )
                    }
                    .buttonStyle(.plain)
                }
                #endif
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppRouter())
        .preferredColorScheme(.dark)
}
