//
//  HealthKitManager.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 20/11/25.
//

// HealthKitManager.swift (Target: iOS App)
import Combine
import Foundation
import HealthKit

class HealthKitManager: NSObject, ObservableObject {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    func requestAuthorization() {
        // These MUST match the types you requested on WatchOS exactly
        let typesToShare: Set = [
            HKObjectType.workoutType()
        ]
        
        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .runningSpeed)!,
            HKObjectType.activitySummaryType(),
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if success {
                print("iOS: ✅ HealthKit Authorization request sent")
            } else {
                print("iOS: ❌ HealthKit Authorization failed: \(String(describing: error))")
            }
        }
    }
}
