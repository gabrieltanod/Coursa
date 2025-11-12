//
//  ContentView.swift
//  CoursaWatch Watch App
//
//  Created by Gabriel Tanod on 23/10/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var syncService: SyncService
    
    var body: some View {
        VStack(spacing: 20) {
            if syncService.isSessionActivated {
                Text("Watch Connect")
                    .foregroundColor(.green)
            } else {
                Text("Watch Connect")
                    .foregroundColor(.orange)
            }
            
            // Check if data summary has been received
            if let plan = syncService.plan {
                // Display Total Time from Summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Time: \(plan.title)")
                    
                    Text("Distance: \(plan.targetDistance)")
                    
                    Text("intensity: \(plan.intensity)")
                    
                    Text("Rec Pace: \(plan.recPace)")
                }
                .padding()
                
            } else {
                Text("Waiting for data from iOS...")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .padding()
        .onAppear {
            print("WatchOS App Started. SyncService activated.")
        }
    }
}

#Preview {
    ContentView()
}
