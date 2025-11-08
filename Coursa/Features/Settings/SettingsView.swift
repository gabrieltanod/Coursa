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
        Form {
            Section("General") {
                Text(".settings")
            }

            #if DEBUG
            Section("Debug") {
                Button(role: .destructive) {
                    router.reset(hard: true)
                } label: {
                    Label("Reset App (Debug)", systemImage: "arrow.clockwise.circle.fill")
                }
            }
            #endif
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
