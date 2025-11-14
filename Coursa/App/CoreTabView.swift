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
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }

            NavigationStack {
                PlanView(vm: PlanViewModel(data: onboardingData))
            }
            .tabItem {
                Label("Plan", systemImage: "figure.run")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(Color("green-500"))
    }
}
