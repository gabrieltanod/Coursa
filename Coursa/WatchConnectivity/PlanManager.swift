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
    
    static let shared = PlanManager()
    
//    @Published var name: String = ""
//    @Published var kind: RunKind?
//    @Published var targetDistance: Double = 0.0
//    @Published var targetHRZone: HRZone?
//    @Published var recPace: String = ""
    @Published var finalPlan: GeneratedPlan?
    var syncService: SyncService?
    var planSession: PlanSessionStore?
    
//    func buttonSendPlanTapped() -> GeneratedPlan? {
//        
//        let plan = RunningPlan(
//            date: Date(),
//            name: self.name,
//            kind: self.kind,
//            targetDistance: self.targetDistance,
//            targetHRZone: self.targetHRZone,
//            recPace: self.recPace
//        )
//        
//        sendPlanToWatchOS(plan)
//        
//        return plan
//    }
    
    
//    func sendPlanToWatchOS(_ plan: GeneratedPlan) {
//        guard let service = syncService else {
//            print("PlanManager: SyncService not configured; cannot send plan.")
//            return
//        }
//        DispatchQueue.main.async {
//            service.sendPlanToWatchOS(plan: plan)
//        }
//    }
    
    func sendPlanToWatchOS(_ plan: GeneratedPlan) {
        guard let service = syncService else {
            print("PlanManager: SyncService not configured; cannot send plan.")
            return
        }
        
        // You're already on the main thread from the button tap,
        // so you can call this directly.
        service.sendPlanToWatchOS(plan: plan)
    }

    func buttonSendPlanTapped() {
        guard let plan = finalPlan else {
            print("❌ PlanManager: No GeneratedPlan available to send")
            return
        }
            
        sendPlanToWatchOS(plan)
    }
}

extension PlanManager {
    func applyWatchSummary(_ summary: RunningSummary) {
        // 1. Load the persisted GeneratedPlan from UserDefaults
        let store = UserDefaultsPlanStore.shared
        guard var plan = store.load() else {
            print("[PlanManager] No GeneratedPlan available for summary")
            return
        }
        
        // 2. Find the ScheduledRun that matches this summary.id
        guard let index = plan.runs.firstIndex(where: { $0.id == summary.id }) else {
            print("[PlanManager] Could not find ScheduledRun with id \(summary.id)")
            return
        }
        
        // 3. Update that run’s data
        var run = plan.runs[index]
        run.status = .completed
        run.actual.elapsedSec = Int(summary.totalTime)
        run.actual.distanceKm = summary.totalDistance
        run.actual.avgHR = Int(summary.averageHeartRate)
        run.actual.avgPaceSecPerKm = Int(summary.averagePace)
        
        plan.runs[index] = run
        
        // 4. Save back and (optionally) propagate if you later inject a session store
        store.save(plan)
        
        planSession?.generatedPlan = plan
        
        print("[PlanManager] Applied summary to run \(summary.id) and saved plan")
    }
}
