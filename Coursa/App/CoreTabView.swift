//
//  CoreTabView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 03/11/25.
//

import SwiftUI

struct CoreTabView: View {
    let onboardingData: OnboardingData

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            PlanView(vm: PlanViewModel(data: onboardingData))
                .tabItem {
                    Label("Plan", systemImage: "figure.run")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Color("green-500"))
    }
}
