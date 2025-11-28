//
//  WorkoutManager.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 28/10/25.
//

import Combine
import CoreLocation
import Foundation
import HealthKit
import SwiftUI
import WatchKit

class WorkoutManager: NSObject, ObservableObject{
    
    static let shared = WorkoutManager()  // ✅ singleton
    
    // Healthkit Property
    let healthStore = HKHealthStore()
    var workoutSession: HKWorkoutSession?
    var workoutBuilder: HKLiveWorkoutBuilder?
    @Published var currentRunId: String?  // scheduledRun ID
    
    
    // Real-time Data
    @Published var heartRate: Double = 0
    @Published var distance: Double = 0
    @Published var pace: Double = 0
    @Published var elevation: Double = 0
    @Published var workoutIsActive = false
    @Published var averagePace: Double = 0
    private var workoutStartDate: Date?
    @Published var averageHeartRate: Double = 0
    @Published var elevationGain: Double = 0
    private var lastAltitude: Double = 0
    
    @Published var finalSummary: RunningSummary?
    @Published var zoneDurationTracker: [Int: TimeInterval] = [
        1: 0, 2: 0, 3: 0, 4: 0, 5: 0
    ]
    private var lastSampleDate: Date?
    
    @Published var currentZone: Int = 1
    
    @Published var currentPlan: RunningPlan?

    var syncService: SyncService?

    var userMaxHeartRate: Double {
        if let syncedMax = syncService?.plan?.userMaxHR {
            return syncedMax
        }
        
        if let localMax = currentPlan?.userMaxHR {
            return localMax
        }
        
        return 190.0
    }
    
    private var hapticTimer: Timer?
    
    // MARK: - Plan tracking
    @Published var isCountingDown = false
    @Published var countdownValue = 3
    @Published var isRunning = false
    
    private var countdownTimer: Timer?
    
    @Published var showingSummary: Bool = false
    
    // Lazy initialization of syncService if not provided
    private func getSyncService() -> SyncService {
        if let service = syncService {
            return service
        }
        // Create a new instance if not provided (fallback)
        let service = SyncService()
        syncService = service
        return service
    }
    
    // MARK: Authorization
    func requestAuthorization() {
        let typesToShare: Set = [
            HKObjectType.workoutType()
        ]
        
        // Data yang ingin kita baca (real-time)
        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .runningSpeed)!,
            HKObjectType.activitySummaryType(),
        ]
        
        // HealthKit Permission
        healthStore.requestAuthorization(
            toShare: typesToShare,
            read: typesToRead
        ) { (success, error) in
            if !success {
                print("Izin HealthKit ditolak.")
            }
        }
    }
    
    // MARK: Start Running Session
    func startWorkout() {
        
        print("Watch: 🏃‍♂️ STARTING WORKOUT SESSION")
        
        if self.currentRunId == nil {
            self.currentRunId = UUID().uuidString
        }
        
        self.isRunning = true
        //        isWorkoutActive = true
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor
        
        do {
            workoutSession = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: configuration
            )
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
            
            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )
            
            workoutBuilder?.delegate = self
            
            let startDate = Date()
            self.workoutStartDate = startDate
            workoutSession?.startActivity(with: startDate)
            workoutBuilder?.beginCollection(withStart: Date()) {
                (success, error) in
                if !success {
                    print(
                        "Gagal memulai collection: \(error?.localizedDescription ?? "N/A")"
                    )
                }
            }
            
            DispatchQueue.main.async {
                self.workoutIsActive = true
            }
            
        } catch {
            print("Gagal memulai sesi workout: \(error.localizedDescription)")
        }
    }
    
    func stopWorkoutAndReturnSummary() -> RunningSummary? {
        // 1. Stop the HealthKit Session
        workoutSession?.end()
        
        // 2. End Collection AND Check Success
        let endDate = Date()
        workoutBuilder?.endCollection(withEnd: endDate) { (success, error) in
            
            // 🛑 SAFETY CHECK: Only try to finish if collection ended successfully
            if success {
                self.workoutBuilder?.finishWorkout { (workout, error) in
                    if let workout = workout {
                        print("Watch: ✅ Workout saved successfully. Duration: \(workout.duration)")
                    } else if let error = error {
                        print("Watch: ❌ Failed to finish workout: \(error.localizedDescription)")
                    }
                }
            } else {
                print("Watch: ⚠️ endCollection failed, skipping finishWorkout. Error: \(String(describing: error))")
            }
        }
        
        // 3. Clean up timers
        hapticTimer?.invalidate()
        hapticTimer = nil
        
        // 4. Validation
        let totalTime: TimeInterval
        if let start = self.workoutStartDate {
            totalTime = endDate.timeIntervalSince(start)
        } else {
            totalTime = 0
        }
        
        guard totalTime > 0 else {
            print("[WorkoutManager] ⚠️ Total time is 0")
            DispatchQueue.main.async { self.isRunning = false }
            return nil
        }
        
        // 5. ID & Summary Creation (Your existing logic)
        let runId = currentRunId ?? UUID().uuidString
        
        let summary = RunningSummary(
            id: runId,
            totalTime: totalTime,
            totalDistance: self.distance,
            averageHeartRate: self.averageHeartRate,
            averagePace: self.averagePace,
            zoneDuration: zoneDurationTracker
        )
        
        print("Watch: 📤 Sending summary to iOS...")
        sendSummaryToiOS(summary)
        
        // 6. Update UI
        DispatchQueue.main.async {
            self.finalSummary = summary
            self.showingSummary = true
            self.isRunning = false
            self.isCountingDown = false
        }
        
        self.resetWorkoutData()
        
        return summary
    }
    
    func endWorkout() {
        print("Watch: WorkoutManager stopping session...")
        let _ = stopWorkoutAndReturnSummary()
    }
    
    private func resetWorkoutData() {
        DispatchQueue.main.async {
            self.heartRate = 0
            self.distance = 0
            self.pace = 0
            self.currentRunId = nil
            self.workoutStartDate = nil
        }
    }
    
    // MARK: - Receive start command from iOS
    func receiveStartCommand(planID: String) {
        print("Watch: ⌚️ Received Start Command for ID: \(planID)")
        
        self.currentRunId = planID
        
        // Run on Main Actor to update UI
        DispatchQueue.main.async {
            self.startCountdown()
        }
    }
    
    func startCountdown() {
        self.isCountingDown = true
        self.countdownValue = 3
        
        countdownTimer?.invalidate()
        
        print("Watch: ⏳ Starting Countdown...")
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.countdownValue > 1 {
                self.countdownValue -= 1
                // You can play a haptic here if you want
                WKInterfaceDevice.current().play(.click)
            } else {
                // Countdown finished
                timer.invalidate()
                self.isCountingDown = false
                self.startWorkout()
                WKInterfaceDevice.current().play(.start)
            }
        }
    }
    
    func sendSummaryToiOS(_ summary: RunningSummary) {
        DispatchQueue.main.async {
            SyncService.shared.sendSummaryToiOS(summary: summary)
        }
    }
    
    private func calculateZone(from heartRate: Double) -> Int {
        guard userMaxHeartRate > 0 else { return 0 }
        
        let hrPercentage = (heartRate / userMaxHeartRate) * 100.0
        
        // Sesuaikan persentase ini jika perlu
        if hrPercentage < 60 {
            return 1
        } else if hrPercentage < 70 {
            return 2
        } else if hrPercentage < 80 {
            return 3
        } else if hrPercentage < 90 {
            return 4
        } else {
            return 5
        }
    }
    
    private func checkZoneAlerts(newHR: Double) {
        let newZone = calculateZone(from: newHR)
        
        DispatchQueue.main.async {
            self.currentZone = newZone
        }
        
        if newZone > 2 {
            if hapticTimer == nil {
                
                playHighZoneHaptic()
                
                hapticTimer = Timer.scheduledTimer(
                    withTimeInterval: 30.0,
                    repeats: true
                ) { [weak self] _ in
                    self?.playHighZoneHaptic()
                }
            }
        } else {
            if hapticTimer != nil {
                print("✅ Recovered to Safe Zone. Stopping Alerts.")
                hapticTimer?.invalidate()
                hapticTimer = nil
            }
        }
    }
    
    private func playHighZoneHaptic() {
        guard isRunning else { return }
        DispatchQueue.main.async {
            let device = WKInterfaceDevice.current()
            device.play(.notification)
        }
    }
    
    func processHeartRate(_ stats: HKStatistics) {
        guard isRunning else { return }
        guard let quantity = stats.mostRecentQuantity() else { return }
        
        let heartRate = quantity.doubleValue(for: HKUnit(from: "count/min"))
        let interval = stats.mostRecentQuantityDateInterval()
        let endDate = interval?.end
        
        // First sample
        if lastSampleDate == nil {
            lastSampleDate = endDate
            return
        }
        
        let dt = endDate?.timeIntervalSince(lastSampleDate!)
        lastSampleDate = endDate
        guard dt ?? 0.0 > 0 else { return }
        
        let zone = calculateZone(from: heartRate)
        
        zoneDurationTracker[zone, default: 0] += dt ?? 0.0
    }
    
}

// MARK: - 7. (DELEGATE) HealthKit Live Data
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    
    func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        
        var currentTotalDistance: Double = 0
        var currentDuration: Double = 0
        
        for type in collectedTypes {
            
            guard let quantityType = type as? HKQuantityType else { continue }
            guard let statistics = workoutBuilder.statistics(for: quantityType)
            else { continue }
            
            // Update UI di Main Thread
            DispatchQueue.main.async {
                switch quantityType {
                case HKObjectType.quantityType(forIdentifier: .heartRate):
                    let heartRateUnit = HKUnit.count().unitDivided(
                        by: .minute()
                    )
                    let latestHeartRate =
                    statistics.mostRecentQuantity()?.doubleValue(
                        for: heartRateUnit
                    ) ?? 0
                    self.heartRate = latestHeartRate
                    
                    // Save AVG HR
                    let averageHR =
                    statistics.averageQuantity()?.doubleValue(
                        for: heartRateUnit
                    ) ?? 0
                    self.averageHeartRate = averageHR
                    
                    // Save current HR
                    let latestHR =
                    statistics.mostRecentQuantity()?.doubleValue(
                        for: heartRateUnit
                    ) ?? 0
                    self.heartRate = latestHR
                    
                    // Alert Logic
                    self.checkZoneAlerts(newHR: latestHeartRate)
                    
                    if let stats = workoutBuilder.statistics(for: .init(.heartRate)) {
                        self.processHeartRate(stats)
                    }
                    
                    
                    
                case HKObjectType.quantityType(
                    forIdentifier: .distanceWalkingRunning
                ):
                    let distanceUnit = HKUnit.meterUnit(with: .kilo)
                    let totalDistance =
                    statistics.sumQuantity()?.doubleValue(for: distanceUnit)
                    ?? 0
                    self.distance = totalDistance
                    currentTotalDistance = totalDistance
                    
                case HKObjectType.quantityType(forIdentifier: .runningSpeed):
                    if let speed = statistics.mostRecentQuantity()?.doubleValue(
                        for: .meter().unitDivided(by: .second())
                    ), speed > 0 {
                        let paceSecondsPerKm = 1000.0 / speed
                        self.pace = paceSecondsPerKm / 60.0
                    } else {
                        self.pace = 0
                    }
                    
                default:
                    break
                }
            }
        }
        
        DispatchQueue.main.async {
            if let start = self.workoutStartDate {
                currentDuration = Date().timeIntervalSince(start)
            } else {
                currentDuration = 0
            }
            
            if currentTotalDistance > 0 {
                let totalTimeInMinutes = currentDuration / 60.0
                self.averagePace = totalTimeInMinutes / currentTotalDistance
            } else {
                self.averagePace = 0.0
            }
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        let lastEvent = workoutBuilder.workoutEvents.last
        
        DispatchQueue.main.async {
            
        }
    }
}

