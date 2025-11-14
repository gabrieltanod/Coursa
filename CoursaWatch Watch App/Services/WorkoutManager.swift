//
//  WorkoutManager.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 28/10/25.
//

import Foundation
import HealthKit
import CoreLocation
import Combine
import WatchKit
import SwiftUI

class WorkoutManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // Healthkit Property
    let healthStore = HKHealthStore()
    var workoutSession: HKWorkoutSession?
    var workoutBuilder: HKLiveWorkoutBuilder?
    
    // Core Location Property [Deprecated]
    let locationManager = CLLocationManager()
    
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
    @Published var zoneDurationTracker: [Int: TimeInterval] = [:]
    
    @Published var currentZone: Int = 1
    private let userMaxHeartRate: Double = 180.0 // still static data
    private var hapticTimer: Timer?
    
    // SyncService - can be injected from environment or will use own instance
    @Published var syncService: SyncService?
    
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
            HKObjectType.activitySummaryType()
        ]
        
        // HealthKit Permission
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if !success {
                print("Izin HealthKit ditolak.")
            }
        }
        
        // Core Location Permission [Deprecated]
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    // MARK: Start Running Session
    func startWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
            
            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )
            
            workoutBuilder?.delegate = self
            
            let startDate = Date()
            self.workoutStartDate = startDate
            workoutSession?.startActivity(with: startDate)
            workoutBuilder?.beginCollection(withStart: Date()) { (success, error) in
                if !success {
                    print("Gagal memulai collection: \(error?.localizedDescription ?? "N/A")")
                }
            }
            
            // [Deprecated]
            locationManager.startUpdatingLocation()
            
            DispatchQueue.main.async {
                self.workoutIsActive = true
            }
            
        } catch {
            print("Gagal memulai sesi workout: \(error.localizedDescription)")
        }
    }
    
    // MARK: Stop Running Session
    func stopWorkoutAndReturnSummary() -> RunningSummary? {
        
        workoutSession?.end()
        locationManager.stopUpdatingLocation()
        
        hapticTimer?.invalidate()
        hapticTimer = nil
        
        let endDate = Date()
        let totalTime: TimeInterval
        if let start = self.workoutStartDate {
            totalTime = endDate.timeIntervalSince(start)
        } else {
            totalTime = 0
        }
        
        guard totalTime > 0 else {
            self.workoutIsActive = false
            return nil
        }
        
        let summary = RunningSummary(
            totalTime: totalTime,
            totalDistance: self.distance,
            averageHeartRate: self.averageHeartRate,
            averagePace: self.averagePace,
            elevationGain: self.elevationGain,
            zoneDuration: self.zoneDurationTracker
        )
        
        sendSummaryToiOS(summary)
        
        self.workoutIsActive = false
        self.heartRate = 0
        self.distance = 0
        self.pace = 0
        
        // [Deprecated]
        self.elevation = 0
        
        return summary
    }
    
    func sendSummaryToiOS(_ summary: RunningSummary) {
        let service = getSyncService()
        DispatchQueue.main.async {
            service.sendSummaryToiOS(summary: summary)
        }
    }
    
    
    // MARK: Delegate Core Location [DEPRECATED]
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        
        let currentAltitude = latestLocation.altitude
        
        if self.lastAltitude > 0 {
            let altitudeChange = currentAltitude - self.lastAltitude
            if altitudeChange > 0 {
                DispatchQueue.main.async {
                    self.elevationGain += altitudeChange
                }
            }
        }
        
        self.lastAltitude = currentAltitude
        
        DispatchQueue.main.async {
            self.elevation = latestLocation.altitude
        }
    }
    
    private func calculateZone(from heartRate: Double) -> Int {
        guard userMaxHeartRate > 0 else { return 0 }
        
        let hrPercentage = (heartRate / userMaxHeartRate) * 100.0
        
        // Sesuaikan persentase ini jika perlu
        if hrPercentage < 60 { return 1 }
        else if hrPercentage < 70 { return 2 }
        else if hrPercentage < 80 { return 3 }
        else if hrPercentage < 90 { return 4 }
        else { return 5 }
    }
    
    private func checkZoneAlerts(newHR: Double) {
        let newZone = calculateZone(from: newHR)
        
        DispatchQueue.main.async {
            self.currentZone = newZone
        }
        
        if newZone > 2 {
            if hapticTimer == nil {
                playHighZoneHaptic()
                hapticTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
                    self?.playHighZoneHaptic()
                }
            }
        }
        else {
            hapticTimer?.invalidate()
            hapticTimer = nil
        }
    }
    
    private func playHighZoneHaptic() {
        DispatchQueue.main.async {
            let device = WKInterfaceDevice.current()
            device.play(.notification)
        }
    }
    
    
}


// MARK: - 7. (DELEGATE) HealthKit Live Data
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        
        var currentTotalDistance: Double = 0
        var currentDuration: Double = 0
        
        for type in collectedTypes {
            
            guard let quantityType = type as? HKQuantityType else { continue }
            guard let statistics = workoutBuilder.statistics(for: quantityType) else { continue }
            
            // Update UI di Main Thread
            DispatchQueue.main.async {
                switch quantityType {
                case HKObjectType.quantityType(forIdentifier: .heartRate):
                    let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                    let latestHeartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                    self.heartRate = latestHeartRate
                    
                    // Save AVG HR
                    let averageHR = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                    self.averageHeartRate = averageHR
                    
                    // Save current HR
                    let latestHR = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                    self.heartRate = latestHR
                    
                    // Alert Logic
                    self.checkZoneAlerts(newHR: latestHeartRate)
                    
                case HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning):
                    let distanceUnit = HKUnit.meterUnit(with: .kilo)
                    let totalDistance = statistics.sumQuantity()?.doubleValue(for: distanceUnit) ?? 0
                    self.distance = totalDistance
                    currentTotalDistance = totalDistance
                    
                case HKObjectType.quantityType(forIdentifier: .runningSpeed):
                    if let speed = statistics.mostRecentQuantity()?.doubleValue(for: .meter().unitDivided(by: .second())) , speed > 0 {
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
        
        DispatchQueue.main.async() {
            
        }
    }
}

