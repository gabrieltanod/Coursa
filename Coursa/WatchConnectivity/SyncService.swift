//
//  SyncService.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 10/11/25.
//

import Combine
import Foundation
import WatchConnectivity

#if os(iOS)
import UIKit
import SwiftUI
#endif

class SyncService: NSObject, WCSessionDelegate, ObservableObject {
    
    @Published var summary: RunningSummary?
    @Published var plan: RunningPlan?
    @Published var isSessionActivated: Bool = false
    
    private var session: WCSession = .default
    
#if os(iOS)
    private var pendingRunningPlan: RunningPlan?
    private weak var planSession: PlanSessionStore?
#endif
    
#if os(watchOS)
    // MARK: - Watch-only activation / retry state
    
    /// Whether we're currently trying to activate WCSession
    @Published var isActivationInProgress: Bool = false
    
    /// Timer used to poll activation state in the simulator
    private var activationRetryTimer: Timer?
    
    /// How many times we've retried activation
    private var activationRetryCount: Int = 0
    
    /// Max number of retries before giving up (simulator safety)
    private let maxActivationRetries: Int = 3
    
    /// Delay between activation checks, in seconds
    private let activationRetryDelay: TimeInterval = 5.0
    
    /// Summary that couldn't be sent yet (queued until session is activated)
    private var pendingSummary: RunningSummary?
#endif
    
#if os(iOS)
    init(
        session: WCSession = .default,
        planSession: PlanSessionStore? = nil
    ) {
        super.init()
        self.session = session
        self.planSession = planSession
        self.session.delegate = self
        print("iOS: SyncService initialized")
        self.connect()
    }
#else
    init(session: WCSession = .default) {
        super.init()
        self.session = session
        self.session.delegate = self
        print("watchOS: SyncService initialized")
        self.connect()
    }
#endif
    
#if os(iOS)
    func attach(planSession: PlanSessionStore) {
        print(
            "iOS: attaching PlanSessionStore (\(Unmanaged.passUnretained(planSession).toOpaque())) to SyncService (\(Unmanaged.passUnretained(self).toOpaque()))"
        )
        self.planSession = planSession
    }
#endif
    
    func connect() {
        guard WCSession.isSupported() else {
            print("WCSession is not supported on this device")
            return
        }
        
#if os(watchOS)
        // Check if iOS companion app is installed (warning only in simulators)
        // NOTE: In simulators, isCompanionAppInstalled may return false even when iOS app is running
        // We'll still attempt activation regardless, as simulators have limitations
        if !session.isCompanionAppInstalled {
            print(
                "watchOS: ⚠️ WARNING - iOS companion app appears not installed: \(session.isCompanionAppInstalled)"
            )
            print("watchOS: NOTE: In simulators, this check is unreliable. Attempting activation anyway...")
            print("watchOS: Make sure:")
            print("  1. iOS app is running in iOS Simulator FIRST")
            print("  2. Watch app is launched from 'Watch Coursa via iOS Coursa' scheme")
            print("  3. Both simulators are running the same app")
            print("watchOS: Proceeding with activation attempt despite warning...")
        } else {
            print("watchOS: ✅ iOS companion app is installed: \(session.isCompanionAppInstalled)")
        }
        print("watchOS: Activation state before activate(): \(session.activationState.rawValue)")
#endif
        
#if os(iOS)
        // Check if watch app is installed (warning only, still try to activate)
        if !session.isWatchAppInstalled {
            print("iOS: WARNING - Watch app is not installed on paired watch")
        }
        
        print("iOS: Watch app installed: \(session.isWatchAppInstalled), Paired: \(session.isPaired)")
#endif
        
        if session.activationState == .activated {
            print("WCSession already activated")
            DispatchQueue.main.async {
                self.isSessionActivated = true
            }
#if os(watchOS)
            // Send any pending summary
            sendPendingSummaryIfNeeded()
#endif
        } else {
            let stateDescription: String
            switch session.activationState {
            case .notActivated:
                stateDescription = "notActivated"
            case .inactive:
                stateDescription = "inactive"
            case .activated:
                stateDescription = "activated"
            @unknown default:
                stateDescription =
                "unknown(\(session.activationState.rawValue))"
            }
            
            print(
                "Activating WCSession... (Current state: \(stateDescription))"
            )
#if os(watchOS)
            isActivationInProgress = true
            activationRetryCount = 0
#endif
            session.activate()
            
#if os(watchOS)
            // Set up a timer to check activation status and retry if needed (for simulator scenarios)
            scheduleActivationCheck()
#endif
        }
    }
    
#if os(watchOS)
    /// Schedule a check to see if activation completed, and retry if needed
    private func scheduleActivationCheck() {
        // Cancel any existing timer
        activationRetryTimer?.invalidate()
        
        // Check activation status after a delay
        // Use RunLoop.main to ensure timer runs on main thread
        activationRetryTimer = Timer.scheduledTimer(
            withTimeInterval: activationRetryDelay,
            repeats: false
        ) { [weak self] _ in
            guard let self = self else { return }
            
            // Check activation state directly (may have changed even if delegate didn't fire)
            let currentState = self.session.activationState
            
            print(
                "watchOS: Activation check #\(self.activationRetryCount + 1) - Current state: \(currentState.rawValue)"
            )
            
            // If activated, update state and send pending data
            if currentState == .activated {
                print("watchOS: ✅ Activation detected (state check)!")
                DispatchQueue.main.async {
                    self.isSessionActivated = true
                    self.isActivationInProgress = false
                    self.activationRetryCount = 0
                    self.activationRetryTimer?.invalidate()
                    self.sendPendingSummaryIfNeeded()
                }
                return
            }
            
            // If still not activated and haven't exceeded retry limit
            if self.activationRetryCount < self.maxActivationRetries
                && !self.isSessionActivated
            {
                self.activationRetryCount += 1
                print(
                    "watchOS: Retry attempt #\(self.activationRetryCount)/\(self.maxActivationRetries)"
                )
                print("watchOS: Calling session.activate() again...")
                
                // Retry activation
                DispatchQueue.main.async {
                    self.isActivationInProgress = true
                    self.session.activate()
                }
                
                // Schedule next check
                self.scheduleActivationCheck()
            } else if self.activationRetryCount >= self.maxActivationRetries
            {
                print(
                    "watchOS: ❌ Max activation retries (\(self.maxActivationRetries)) reached"
                )
                print("watchOS: Current state: \(currentState.rawValue)")
                print(
                    "watchOS: ⚠️ SIMULATOR LIMITATION: This is expected behavior in simulators."
                )
                print(
                    "watchOS: The session may activate later, or you may need to test on physical devices."
                )
                DispatchQueue.main.async {
                    self.isActivationInProgress = false
                    self.activationRetryTimer?.invalidate()
                }
            }
        }
        
        // Add timer to main run loop
        if let timer = activationRetryTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    /// Manual retry method that can be called from UI if needed
    func retryActivation() {
        guard session.activationState != .activated else {
            print("watchOS: Session is already activated")
            return
        }
        
        print("watchOS: Manual activation retry requested")
        activationRetryCount = 0
        isActivationInProgress = true
        session.activate()
        scheduleActivationCheck()
    }
#endif
    
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        // Note: This delegate may not be called reliably in simulators
#if os(watchOS)
        print(
            "watchOS: activationDidCompleteWith delegate called - State: \(activationState.rawValue), Error: \(String(describing: error))"
        )
#endif
        
        DispatchQueue.main.async {
#if os(watchOS)
            // Don't set isActivationInProgress = false here if not activated
            // Let the retry mechanism handle it
            if activationState == .activated {
                self.isActivationInProgress = false
            }
#endif
            
            let stateDescription: String
            switch activationState {
            case .notActivated:
                stateDescription = "notActivated"
            case .inactive:
                stateDescription = "inactive"
            case .activated:
                stateDescription = "activated"
            @unknown default:
                stateDescription = "unknown(\(activationState.rawValue))"
            }
            
            if activationState == .activated {
                self.isSessionActivated = true
#if os(iOS)
                print("iOS: ✅ WCSession activated successfully")
                print("iOS: Session reachable: \(session.isReachable)")
                print(
                    "iOS: Watch app installed: \(session.isWatchAppInstalled)"
                )
                print(
                    "iOS: Activation state: \(session.activationState.rawValue)"
                )
#endif
#if os(watchOS)
                print("watchOS: ✅ WCSession activated successfully")
                print("watchOS: Session reachable: \(session.isReachable)")
                print(
                    "watchOS: Companion app installed: \(session.isCompanionAppInstalled)"
                )
                print(
                    "watchOS: Activation state: \(session.activationState.rawValue)"
                )
                // Cancel retry timer since we're activated
                self.activationRetryTimer?.invalidate()
                self.isActivationInProgress = false
                self.activationRetryCount = 0
                // Send any pending summary now that session is activated
                self.sendPendingSummaryIfNeeded()
#endif
            } else {
                self.isSessionActivated = false
                if let error = error {
#if os(iOS)
                    print(
                        "iOS: ❌ WCSession activation failed with error: \(error.localizedDescription)"
                    )
#endif
#if os(watchOS)
                    print(
                        "watchOS: ❌ WCSession activation failed with error: \(error.localizedDescription)"
                    )
                    print("watchOS: Full error: \(error)")
                    print(
                        "watchOS: Activation state: \(session.activationState.rawValue)"
                    )
                    print("watchOS: Troubleshooting:")
                    print(
                        "  - Is iPhone app running? (Required for watchOS activation)"
                    )
                    print(
                        "  - Is iOS companion app installed? \(session.isCompanionAppInstalled)"
                    )
                    print(
                        "  - SIMULATOR LIMITATION: WatchConnectivity has known issues in simulators"
                    )
                    print(
                        "  - Try: Restart both simulators, launch iOS app first, then Watch app"
                    )
                    print(
                        "  - Best: Test on physical devices for reliable behavior"
                    )
#endif
                } else {
#if os(iOS)
                    print(
                        "iOS: ❌ WCSession activation failed. State: \(stateDescription)"
                    )
#endif
#if os(watchOS)
                    print(
                        "watchOS: ❌ WCSession activation failed. State: \(stateDescription)"
                    )
                    print(
                        "watchOS: Activation state: \(session.activationState.rawValue)"
                    )
                    print("watchOS: Troubleshooting:")
                    print(
                        "  - Is iPhone app running? (Required for watchOS activation)"
                    )
                    print(
                        "  - Is iOS companion app installed? \(session.isCompanionAppInstalled)"
                    )
                    print(
                        "  - SIMULATOR LIMITATION: WatchConnectivity has known issues in simulators"
                    )
                    print(
                        "  - Try: Restart both simulators, launch iOS app first, then Watch app"
                    )
                    print(
                        "  - Best: Test on physical devices for reliable behavior"
                    )
#endif
                }
            }
        }
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("iOS: WCSession became inactive")
        DispatchQueue.main.async {
            self.isSessionActivated = false
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("iOS: WCSession deactivated, reactivating...")
        DispatchQueue.main.async {
            self.isSessionActivated = false
        }
        // Reactivate session
        session.activate()
    }
#endif
    
    // ========================================== MARK: - Receive Summary (iOS from watchOS) ==========================================
    
#if os(iOS)
    // Receive message from watchOS
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        print("iOS: Received message from watchOS")
        decodeAndStoreSummary(from: message)
    }
    
    // Receive message with reply handler
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        print("iOS: Received message from watchOS (with reply handler)")
        decodeAndStoreSummary(from: message)
        replyHandler(["status": "received"])
    }
    
    // Receive application context
    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        print("iOS: Received application context from watchOS")
        decodeAndStoreSummary(from: applicationContext)
    }
#endif
    
    private func decodeAndStoreSummary(from dictionary: [String: Any]) {
        print("📱 iOS: decodeAndStoreSummary received keys:", dictionary.keys)
        
        // MARK: - Decode ID
        let idString: String = {
            if let s = dictionary["id"] as? String { return s }
            if let uuid = dictionary["id"] as? UUID { return uuid.uuidString }
            if let nsuuid = dictionary["id"] as? NSUUID { return nsuuid.uuidString }
            print("📱 iOS: ❗ id missing or wrong type, generating fallback UUID")
            return UUID().uuidString
        }()
        
        // MARK: - Helper for converting to Double
        func toDouble(_ value: Any?) -> Double? {
            if let d = value as? Double { return d }
            if let n = value as? NSNumber { return n.doubleValue }
            if let s = value as? String { return Double(s) }
            return nil
        }
        
        // MARK: - Decode standard numeric fields
        guard
            let totalTime = toDouble(dictionary["totalTime"]),
            let totalDistance = toDouble(dictionary["totalDistance"]),
            let averageHeartRate = toDouble(dictionary["averageHeartRate"]),
            let averagePace = toDouble(dictionary["averagePace"])
        else {
            print("📱 iOS: ❌ Failed to decode numeric fields:", dictionary)
            return
        }
        
        // MARK: - Decode zoneDuration safely
        var zoneDuration: [Int: Double] = [:]
        if let raw = dictionary["zoneDuration"] as? [String: Any] {
            for (k, v) in raw {
                if let keyInt = Int(k), let val = toDouble(v) {
                    zoneDuration[keyInt] = val
                }
            }
        } else {
            print("📱 iOS: ⚠️ zoneDuration missing or unknown format")
        }
        
        // Ensure all expected zones exist (1...5) even if missing
        for zone in 1...5 {
            zoneDuration[zone] = zoneDuration[zone] ?? 0
        }
        
        // MARK: - Build Summary
        let summary = RunningSummary(
            id: idString,
            totalTime: totalTime,
            totalDistance: totalDistance,
            averageHeartRate: averageHeartRate,
            averagePace: averagePace,
            zoneDuration: zoneDuration
        )
        
        // MARK: - Store + Apply
        DispatchQueue.main.async {
            self.summary = summary
            print("📱 iOS: ✅ Summary stored:", summary)
            
    #if os(iOS)
            if let planSession = self.planSession {
                print("📱 iOS: Applying summary to PlanSessionStore")
                planSession.apply(summary: summary)
            } else {
                print("📱 iOS: ⚠️ No PlanSessionStore attached, summary not applied")
            }
    #endif
        }
    }
    
    // ========================================== MARK: - Receive Plan (watchOS from iOS ) ==========================================
    
#if os(watchOS)
    // Receive message from watchOS
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        print("watchOS: Received message from iOS")
        decodeAndStorePlan(from: message)
    }
    
    // Receive message with reply handler
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        print("watchOS: Received message from watchOS (with reply handler)")
        decodeAndStorePlan(from: message)
        replyHandler(["status": "received"])
    }
    
    // Receive application context
    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        print("watchOS: Received application context from iOS")
        decodeAndStorePlan(from: applicationContext)
    }
#endif
    
    private func decodeAndStorePlan(from dictionary: [String: Any]) {
        // Handle UUID as String (since Dictionary can't store UUID directly)
        var id: UUID
        if let idString = dictionary["id"] as? String {
            id = UUID(uuidString: idString) ?? UUID()
        } else if let idUUID = dictionary["id"] as? UUID {
            id = idUUID
        } else {
            id = UUID()
        }
        
        // Decode values safely
        guard let date = dictionary["date"] as? Date,
              let name = dictionary["name"] as? String,
              let kindRaw = dictionary["kind"] as? String,
              let kind = RunKind(rawValue: kindRaw),
              let targetDuration = dictionary["targetDuration"] as? Int,
              let targetDistance = dictionary["targetDistance"] as? Double,
              let hrZoneRaw = dictionary["targetHRZone"] as? Int,
              let targetHRZone = HRZone(rawValue: hrZoneRaw),
              let recPace = dictionary["recPace"] as? String
        else {
#if os(watchOS)
            print(
                "watchOS: Failed to decode Running Plan from dictionary. Keys: \(dictionary.keys)"
            )
#endif
#if os(iOS)
            print(
                "iOS: Failed to decode Running Plan from dictionary. Keys: \(dictionary.keys)"
            )
#endif
            return
        }
        
        let decodedPlan = RunningPlan(
            id: id.uuidString,
            date: date,
            name: name,
            kind: kind,
            targetDuration: targetDuration,
            targetDistance: targetDistance,
            targetHRZone: targetHRZone,
            recPace: recPace
        )
        
        DispatchQueue.main.async {
            self.plan = decodedPlan
#if os(watchOS)
            print(
                "watchOS: Successfully decoded and stored PlanTest. Name: \(decodedPlan.name), Target Distance: \(decodedPlan.targetDistance)km"
            )
#endif
        }
    }
    
    // ========================================== MARK: - Send Summary (watchOS to iOS) ==========================================
    
#if os(watchOS)
    func sendSummaryToiOS(summary: RunningSummary) {
        sendSummaryData(summary: summary)
    }
    
    private func sendSummaryData(summary: RunningSummary) {
        // Ensure session is activated
        guard session.activationState == .activated else {
            let stateDescription: String
            switch session.activationState {
            case .notActivated: stateDescription = "notActivated"
            case .inactive: stateDescription = "inactive"
            case .activated: stateDescription = "activated"
            @unknown default: stateDescription = "unknown(\(session.activationState.rawValue))"
            }
            print("watchOS: ❌ Cannot send summary - Session is not activated. Current state: \(stateDescription)")
            print("watchOS: Queueing summary for later...")
            pendingSummary = summary
            return
        }
        
        // Convert zone keys to strings for WatchConnectivity
        let stringKeyZones = summary.zoneDuration.reduce(into: [String: Double]()) { result, pair in
            result["\(pair.key)"] = pair.value
        }
        
        // Prepare dictionary
        let data: [String: Any] = [
            "id": summary.id,
            "totalTime": summary.totalTime,
            "totalDistance": summary.totalDistance,
            "averageHeartRate": summary.averageHeartRate,
            "averagePace": summary.averagePace,
            "zoneDuration": stringKeyZones
        ]
        
        print("watchOS: Attempting to send summary (activationState: activated, isReachable: \(session.isReachable))")
        
        // Use updateApplicationContext (works even when iOS is not reachable)
        do {
            try session.updateApplicationContext(data)
            print("watchOS: ✅ Successfully sent summary via updateApplicationContext")
            print("watchOS: sending summary data types:", summary.id, type(of: summary.id), type(of: summary.zoneDuration))
        } catch {
            print("watchOS: ❌ Error updating application context: \(error.localizedDescription)")
            
            // Fallback with sendMessage if reachable
            if session.isReachable {
                print("watchOS: Trying sendMessage as fallback...")
                session.sendMessage(
                    data,
                    replyHandler: { reply in
                        print("watchOS: ✅ Message sent successfully via sendMessage. Reply: \(reply)")
                    },
                    errorHandler: { error in
                        print("watchOS: ❌ Error sending message: \(error.localizedDescription)")
                        print("watchOS: Queueing summary for retry...")
                        self.pendingSummary = summary
                    }
                )
            } else {
                print("watchOS: Session is not reachable. Queueing summary for later...")
                pendingSummary = summary
            }
        }
    }
    
    private func sendPendingSummaryIfNeeded() {
        guard let pending = pendingSummary,
              session.activationState == .activated
        else {
            return
        }
        
        print(
            "watchOS: Sending pending summary now that session is activated..."
        )
        // Clear pending first
        pendingSummary = nil
        // Send it
        sendSummaryData(summary: pending)
    }
#endif
    
    // ========================================== MARK: - Send Plan (iOS to watchOS) ==========================================
    
#if os(iOS)
    func sendPlanToWatchOS(plan: RunningPlan) {
        // Check activation state first
        if session.activationState == .activated {
            // Session is activated - send immediately
            sendRunningPlanData(plan: plan)
        } else {
            // Session not activated yet - queue it
            print(
                "iOS: Session not activated (State: \(session.activationState.rawValue)). Queueing summary..."
            )
            pendingRunningPlan = plan
            // Don't call activate() here - it's already being called in connect()
            // Just wait for activation to complete, then sendPendingSummaryIfNeeded() will handle it
        }
    }
    
    private func sendRunningPlanData(plan: RunningPlan) {
        // Double-check activation state before attempting to send
        guard session.activationState == .activated else {
            let stateDescription: String
            switch session.activationState {
            case .notActivated:
                stateDescription = "notActivated"
            case .inactive:
                stateDescription = "inactive"
            case .activated:
                stateDescription = "activated"
            @unknown default:
                stateDescription =
                "unknown(\(session.activationState.rawValue))"
            }
            print(
                "iOS: ❌ Cannot send plan - Session is not activated. Current state: \(stateDescription)"
            )
            print("iOS: Queueing plan for later...")
            pendingRunningPlan = plan
            return
        }
        
        // ✅ Convert everything to property-list–safe types
        let data: [String: Any] = [
            "id": plan.id,  // UUID → String
            "date": plan.date,  // Date is allowed
            "name": plan.name,  // String
            "kind": plan.kind?.rawValue ?? 0,  // RunKind → Int
            "targetDuration": plan.targetDuration ?? 0,  // RunKind → Int
            "targetDistance": plan.targetDistance ?? 0.0,  // Double
            "targetHRZone": plan.targetHRZone?.rawValue ?? 0,  // HRZone → Int
            "recPace": plan.recPace ?? "",  // String
        ]
        
        print(
            "iOS: Attempting to send plan (activationState: activated, isReachable: \(session.isReachable))"
        )
        
        // Use updateApplicationContext (works even when not reachable)
        do {
            try session.updateApplicationContext(data)
            print(
                "iOS: ✅ Successfully sent plan via updateApplicationContext"
            )
        } catch {
            print(
                "iOS: ❌ Error updating application context: \(error.localizedDescription)"
            )
            print("iOS: Error details: \(error)")
            
            // If updateApplicationContext fails, try sendMessage as fallback (if reachable)
            if session.isReachable {
                print("iOS: Trying sendMessage as fallback...")
                session.sendMessage(
                    data,
                    replyHandler: { reply in
                        print(
                            "iOS: ✅ Message sent successfully via sendMessage. Reply: \(reply)"
                        )
                    },
                    errorHandler: { error in
                        print(
                            "iOS: ❌ Error sending message: \(error.localizedDescription)"
                        )
                        print("iOS: Queueing send for retry...")
                        self.pendingRunningPlan = plan
                    }
                )
            } else {
                print(
                    "iOS: Session is not reachable. Queueing summary for later..."
                )
                pendingRunningPlan = plan
            }
        }
    }
    
    private func sendPendingRunningPlanIfNeeded() {
        guard let plan = pendingRunningPlan,
              session.activationState == .activated
        else {
            return
        }
        
        print(
            "iOS: Sending pending summary now that session is activated..."
        )
        // Clear pending first
        pendingRunningPlan = nil
        // Send it
        sendRunningPlanData(plan: plan)
    }
#endif
}
