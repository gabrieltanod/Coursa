//
//  HealthKitConnectedView.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 02/12/25.
//

import SwiftUI

struct HealthKitConnectedView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Apple Health")
                    .font(.title2).bold()
                    .padding(.top, 12)
                
                Text("""
                Apple Health is currently connected to Coursa.
                
                We use Health App to track the running metrics needed. This provides real-time tracking, personalizes your training plan, and records all your workouts seamlessly back into your Health history.
                
                These include:
                • Heart rate
                • Running activity
                • Distance metrics
                
                If you want to disable Apple Health integration, you'll need to do so through your iPhone's Settings app.
                """)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
                
                Spacer()
                
                // Button to open Settings
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "gear")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Open Settings")
                            .font(.system(size: 17, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(20)
                }
                .padding(.top, 16)
                .padding(.bottom, 20)
            }
            .padding()
        }
        .background(Color("black-500").ignoresSafeArea())
    }
}

#Preview {
    HealthKitConnectedView()
        .preferredColorScheme(.dark)
}
