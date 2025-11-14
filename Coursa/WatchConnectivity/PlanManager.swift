//
//  PlanManager.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 11/11/25.
//


import Foundation
import Combine
import SwiftUI

class PlanManager: NSObject, ObservableObject {
    
    
    @Published var name: String = ""
    @Published var kind: RunKind?
    @Published var targetDistance: Double = 0.0
    @Published var targetHRZone: HRZone?
    @Published var recPace: String = ""
    
    @Published var finalPlan: RunningPlan?
    
    var syncService: SyncService?
    
    func buttonSendPlanTapped() -> RunningPlan? {
        
        let plan = RunningPlan(
            date: Date(),
            name: self.name,
            kind: self.kind,
            targetDistance: self.targetDistance,
            targetHRZone: self.targetHRZone,
            recPace: self.recPace
        )
        
        sendPlanToWatchOS(plan)
        
        return plan
    }

    
    func sendPlanToWatchOS(_ plan: RunningPlan) {
        guard let service = syncService else {
            print("PlanManager: SyncService not configured; cannot send plan.")
            return
        }
        DispatchQueue.main.async {
            service.sendPlanToWatchOS(plan: plan)
        }
    }
    
    
}
