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
    
    @MainActor
    func isAuthorized() -> Bool {
        // For HealthKit, we need to check differently because:
        // - Read permissions can return .notDetermined even when granted (privacy feature)
        // - We can only reliably check write permissions with .sharingAuthorized
        
        // Check write permission (workout type)
        let workoutType = HKObjectType.workoutType()
        let workoutStatus = healthStore.authorizationStatus(for: workoutType)
        
        print("DEBUG: Workout authorization status: \(workoutStatus.rawValue)")
        // 0 = notDetermined, 1 = sharingDenied, 2 = sharingAuthorized
        
        // If workout sharing is explicitly authorized, we consider HealthKit connected
        // If it's denied, definitely not authorized
        // If notDetermined, check if we've requested before by trying to query
        
        switch workoutStatus {
        case .sharingAuthorized:
            print("DEBUG: HealthKit is authorized (sharingAuthorized)")
            return true
        case .sharingDenied:
            print("DEBUG: HealthKit is denied")
            return false
        case .notDetermined:
            // For read-only types, we can't reliably determine authorization status
            // So we'll assume not authorized if workout type is notDetermined
            print("DEBUG: HealthKit status is notDetermined")
            return false
        @unknown default:
            print("DEBUG: HealthKit unknown status")
            return false
        }
    }
}
