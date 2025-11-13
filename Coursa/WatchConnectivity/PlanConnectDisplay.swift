//
//  PlanConnectDisplay.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 11/11/25.
//



import Foundation
import SwiftUI


// Dummy UI buat test watchconnectivity

struct PlanConnectDisplay: View {
    
    @EnvironmentObject var syncService: SyncService
    @EnvironmentObject var planManager: PlanManager
    
    // Dummy Data
    let myPlan = RunningPlan(
        date: Date(), title: "Easy Run", targetDistance: "3km", intensity: "HR Zone 2", recPace: "7:30/KM"
    )
    
    var body: some View {
        VStack(spacing: 20) {
            
            if syncService.isSessionActivated {
                Text("Plan View")
                    .foregroundColor(.green)
                    .font(.headline)
            } else {
                Text("Plan View")
                    .foregroundColor(.orange)
                    .font(.headline)
            }
            
            VStack {
                Text("\(myPlan.date)")
                Text("\(myPlan.title)")
                Text("\(myPlan.targetDistance)")
                Text("\(myPlan.intensity)")
                Text("\(myPlan.recPace)")
            }
            
            
            Button(action: { planManager.sendPlanToWatchOS(myPlan) }) {
                Text("Send Plan to Watch")
            }
        }
        .padding()
    }
}

