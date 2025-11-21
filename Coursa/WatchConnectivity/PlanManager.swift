//
//  PlanManager.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 11/11/25.
//


import Foundation
import Combine
import SwiftUI

/**
 * A singleton manager responsible for coordinating running plan creation, synchronization, and workout summary processing.
 *
 * `PlanManager` serves as the central coordinator between the iOS app and watchOS for running plans and workout data.
 * It manages the creation of running plans from user input, handles synchronization with the Apple Watch via `SyncService`,
 * and processes workout summaries received from completed runs.
 *
 * ## Key Responsibilities
 *
 * - **Plan Creation**: Converts user input (name, kind, distance, HR zone, pace) into `RunningPlan` objects
 * - **Watch Synchronization**: Sends running plans to watchOS through `SyncService`
 * - **Summary Processing**: Receives and applies `RunningSummary` data from completed workouts to update stored plans
 * - **Data Persistence**: Coordinates with `UserDefaultsPlanStore` to maintain plan data across app sessions
 *
 * ## Usage Pattern
 *
 * 1. User fills in plan details via published properties (`name`, `kind`, `targetDistance`, etc.)
 * 2. Call `buttonSendPlanTapped()` to create and send the plan to watchOS
 * 3. When a workout completes on watchOS, `applyWatchSummary(_:)` processes the results
 *
 * ## Dependencies
 *
 * - `SyncService`: Handles WatchConnectivity communication with watchOS
 * - `PlanSessionStore`: Manages in-memory plan state and persistence coordination
 * - `UserDefaultsPlanStore`: Provides plan data persistence
 *
 * ## Thread Safety
 *
 * This class conforms to `ObservableObject` and should be used from the main thread.
 * Internal operations that interact with `SyncService` are dispatched to the main queue.
 */

/**
 * Published property for the running plan name entered by the user.
 */

/**
 * Published property for the type of run (easy, tempo, intervals, etc.) selected by the user.
 */

/**
 * Published property for the target distance in kilometers set by the user.
 */

/**
 * Published property for the target heart rate zone selected by the user.
 */

/**
 * Published property for the recommended pace string provided to the user.
 */

/**
 * Published property containing the final running plan after creation.
 */

/**
 * Optional reference to the sync service used for watchOS communication.
 * Must be configured before attempting to send plans to watchOS.
 */

/**
 * Optional reference to the plan session store for coordinating plan state.
 * Used when applying workout summaries to update stored plan data.
 */

/**
 * Creates a new `RunningPlan` from the current user input and sends it to watchOS.
 *
 * This method combines all the published properties (`name`, `kind`, `targetDistance`, etc.)
 * into a `RunningPlan` object, sends it to the Apple Watch via `SyncService`, and returns
 * the created plan for immediate use.
 *
 * - Returns: The newly created `RunningPlan` object, or `nil` if creation fails
 *
 * ## Side Effects
 *
 * - Updates `finalPlan` with the created plan
 * - Triggers watchOS synchronization via `sendPlanToWatchOS(_:)`
 */

/**
 * Sends a running plan to watchOS through the configured sync service.
 *
 * - Parameter plan: The `RunningPlan` to synchronize with the Apple Watch
 *
 * ## Behavior
 *
 * - Checks that `syncService` is properly configured before attempting transmission
 * - Dispatches the sync operation to the main queue for thread safety
 * - Logs an error message if no sync service is available
 */

/**
 * Processes a workout summary received from watchOS and updates the corresponding scheduled run.
 *
 * This method handles the integration of completed workout data from the Apple Watch back into
 * the stored training plan. It locates the matching `ScheduledRun`, updates its status and metrics,
 * and persists the changes.
 *
 * - Parameter summary: The `RunningSummary` containing workout completion data from watchOS
 *
 * ## Process Flow
 *
 * 1. Loads the current `GeneratedPlan` from `UserDefaultsPlanStore`
 * 2. Locates the `ScheduledRun` matching the summary's ID
 * 3. Updates the run's status to `.completed` and fills in actual metrics:
 *    - Elapsed time from `totalTime`
 *    - Distance from `totalDistance`
 *    - Average heart rate from `averageHeartRate`
 *    - Average pace from `averagePace`
 *    - Heart rate zone duration breakdown
 * 4. Saves the updated plan back to storage
 * 5. Optionally propagates changes to the attached `PlanSessionStore`
 *
 * ## Error Handling
 *
 * - Logs errors if no stored plan is available
 * - Logs errors if no matching run is found for the summary ID
 * - Continues execution gracefully in error cases without crashing
 */
class PlanManager: NSObject, ObservableObject {
    
    static let shared = PlanManager()
    
    @Published var name: String = ""
    @Published var kind: RunKind?
    @Published var targetDistance: Double = 0.0
    @Published var targetHRZone: HRZone?
    @Published var recPace: String = ""
    @Published var finalPlan: RunningPlan?
    var syncService: SyncService?
    var planSession: PlanSessionStore?
    
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
        run.actual.zoneDuration = summary.zoneDuration

        plan.runs[index] = run

        // 4. Save back and (optionally) propagate if you later inject a session store
        store.save(plan)
        
        planSession?.generatedPlan = plan

        print("[PlanManager] Applied summary to run \(summary.id) and saved plan")
    }
}
