//
//  SyncService.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 10/11/25.
//

import Foundation
import WatchConnectivity
import Combine
//import SwiftData

class SyncService: NSObject, WCSessionDelegate, ObservableObject {
    
    @Published var summary: RunningSummary?
    @Published var plan: GeneratedPlan?
    @Published var isSessionActivated: Bool = false
    
    private var session: WCSession = .default
    
#if os(iOS)
    // Queue for messages pending activation
    private var pendingRunningPlan: GeneratedPlan?
#endif
    
#if os(watchOS)
    // Queue for messages pending activation
    private var pendingSummary: RunningSummary?
    private var isActivationInProgress: Bool = false
    private var activationRetryTimer: Timer?
    private var activationRetryCount: Int = 0
    private let maxActivationRetries: Int = 5
    private let activationRetryDelay: TimeInterval = 3.0
#endif
    
    init(session: WCSession = .default) {
        super.init()
        self.session = session
        self.session.delegate = self
#if os(iOS)
        print("iOS: SyncService initialized")
#endif
#if os(watchOS)
        print("watchOS: SyncService initialized")
#endif
        
        self.connect()
    }
    
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
            print("watchOS: ⚠️ WARNING - iOS companion app appears not installed: \(session.isCompanionAppInstalled)")
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
#if os(iOS)
                // Send any pending plan
                self.sendPendingRunningPlanIfNeeded()
#endif
            }
#if os(watchOS)
            // Send any pending summary
//            sendPendingSummaryIfNeeded()
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
                stateDescription = "unknown(\(session.activationState.rawValue))"
            }
            
            print("Activating WCSession... (Current state: \(stateDescription))")
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
        activationRetryTimer = Timer.scheduledTimer(withTimeInterval: activationRetryDelay, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            // Check activation state directly (may have changed even if delegate didn't fire)
            let currentState = self.session.activationState
            
            print("watchOS: Activation check #\(self.activationRetryCount + 1) - Current state: \(currentState.rawValue)")
            
            // If activated, update state and send pending data
            if currentState == .activated {
                print("watchOS: ✅ Activation detected (state check)!")
                DispatchQueue.main.async {
                    self.isSessionActivated = true
                    self.isActivationInProgress = false
                    self.activationRetryCount = 0
                    self.activationRetryTimer?.invalidate()
//                    self.sendPendingSummaryIfNeeded()
                }
                return
            }
            
            // If still not activated and haven't exceeded retry limit
            if self.activationRetryCount < self.maxActivationRetries && !self.isSessionActivated {
                self.activationRetryCount += 1
                print("watchOS: Retry attempt #\(self.activationRetryCount)/\(self.maxActivationRetries)")
                print("watchOS: Calling session.activate() again...")
                
                // Retry activation
                DispatchQueue.main.async {
                    self.isActivationInProgress = true
                    self.session.activate()
                }
                
                // Schedule next check
                self.scheduleActivationCheck()
            } else if self.activationRetryCount >= self.maxActivationRetries {
                print("watchOS: ❌ Max activation retries (\(self.maxActivationRetries)) reached")
                print("watchOS: Current state: \(currentState.rawValue)")
                print("watchOS: ⚠️ SIMULATOR LIMITATION: This is expected behavior in simulators.")
                print("watchOS: The session may activate later, or you may need to test on physical devices.")
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
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Note: This delegate may not be called reliably in simulators
#if os(watchOS)
        print("watchOS: activationDidCompleteWith delegate called - State: \(activationState.rawValue), Error: \(error?.localizedDescription ?? "none")")
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
                print("iOS: Watch app installed: \(session.isWatchAppInstalled)")
                print("iOS: Activation state: \(session.activationState.rawValue)")
                // Send any pending plan now that session is activated
                self.sendPendingRunningPlanIfNeeded()
#endif
#if os(watchOS)
                print("watchOS: ✅ WCSession activated successfully")
                print("watchOS: Session reachable: \(session.isReachable)")
                print("watchOS: Companion app installed: \(session.isCompanionAppInstalled)")
                print("watchOS: Activation state: \(session.activationState.rawValue)")
                // Cancel retry timer since we're activated
                self.activationRetryTimer?.invalidate()
                self.isActivationInProgress = false
                self.activationRetryCount = 0
                // Send any pending summary now that session is activated
//                self.sendPendingSummaryIfNeeded()
#endif
            } else {
                self.isSessionActivated = false
                if let error = error {
#if os(iOS)
                    print("iOS: ❌ WCSession activation failed with error: \(error.localizedDescription)")
#endif
#if os(watchOS)
                    print("watchOS: ❌ WCSession activation failed with error: \(error.localizedDescription)")
                    print("watchOS: Full error: \(error)")
                    print("watchOS: Activation state: \(session.activationState.rawValue)")
                    print("watchOS: Troubleshooting:")
                    print("  - Is iPhone app running? (Required for watchOS activation)")
                    print("  - Is iOS companion app installed? \(session.isCompanionAppInstalled)")
                    print("  - SIMULATOR LIMITATION: WatchConnectivity has known issues in simulators")
                    print("  - Try: Restart both simulators, launch iOS app first, then Watch app")
                    print("  - Best: Test on physical devices for reliable behavior")
#endif
                } else {
#if os(iOS)
                    print("iOS: ❌ WCSession activation failed. State: \(stateDescription)")
#endif
#if os(watchOS)
                    print("watchOS: ❌ WCSession activation failed. State: \(stateDescription)")
                    print("watchOS: Activation state: \(session.activationState.rawValue)")
                    print("watchOS: Troubleshooting:")
                    print("  - Is iPhone app running? (Required for watchOS activation)")
                    print("  - Is iOS companion app installed? \(session.isCompanionAppInstalled)")
                    print("  - SIMULATOR LIMITATION: WatchConnectivity has known issues in simulators")
                    print("  - Try: Restart both simulators, launch iOS app first, then Watch app")
                    print("  - Best: Test on physical devices for reliable behavior")
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
   func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
       print("iOS: Received message from watchOS")
       decodeAndStoreSummary(from: message)
   }
   
   // Receive message with reply handler
   func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
       print("iOS: Received message from watchOS (with reply handler)")
       decodeAndStoreSummary(from: message)
       replyHandler(["status": "received"])
   }
   
   // Receive application context
   func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
       print("iOS: Received application context from watchOS")
       decodeAndStoreSummary(from: applicationContext)
   }
#endif
   
#if os(iOS)
   private func decodeAndStoreSummary(from dictionary: [String: Any]) {
       print("📱 iOS: decodeAndStoreSummary received keys:", dictionary.keys)
       
       guard
           let totalTime = (dictionary["totalTime"] as? Double) ?? (dictionary["totalTime"] as? NSNumber)?.doubleValue,
           let totalDistance = (dictionary["totalDistance"] as? Double) ?? (dictionary["totalDistance"] as? NSNumber)?.doubleValue,
           let averageHeartRate = (dictionary["averageHeartRate"] as? Double) ?? (dictionary["averageHeartRate"] as? NSNumber)?.doubleValue,
           let averagePace = (dictionary["averagePace"] as? Double) ?? (dictionary["averagePace"] as? NSNumber)?.doubleValue
       else {
           print("📱 iOS: ❌ Failed to decode RunningSummary from dictionary. Values:", dictionary)
           return
       }
       
       let idString = dictionary["id"] as? String ?? UUID().uuidString
       
       let decodedSummary = RunningSummary(
           id: idString,
           totalTime: totalTime,
           totalDistance: totalDistance,
           averageHeartRate: averageHeartRate,
           averagePace: averagePace
       )
       
       DispatchQueue.main.async {
           self.summary = decodedSummary
           print("📱 iOS: ✅ Summary stored: \(decodedSummary)")
           
           // Update the plan with this summary data
           self.updatePlanWithSummary(decodedSummary)
       }
   }
   
   private func updatePlanWithSummary(_ summary: RunningSummary) {
       let store = StoreManager.shared.currentPlanStore
       guard var plan = store.load() else {
           print("⚠️ iOS: No plan found to update with summary")
           return
       }
       
       let calendar = Calendar.current
       let today = Date()
       
       // Find the run for today's date
       guard let runIndex = plan.runs.firstIndex(where: { run in
           calendar.isDate(run.date, inSameDayAs: today)
       }) else {
           print("⚠️ iOS: No run found for today's date")
           return
       }
       
       // Update the run's actual metrics from summary
       plan.runs[runIndex].actual.elapsedSec = Int(summary.totalTime)
       plan.runs[runIndex].actual.distanceKm = summary.totalDistance
       plan.runs[runIndex].actual.avgHR = Int(summary.averageHeartRate)
       // Convert pace from minutes per km to seconds per km
       plan.runs[runIndex].actual.avgPaceSecPerKm = Int(summary.averagePace * 60)
       
       // Mark as completed
       plan.runs[runIndex].status = .completed
       
       // Save the updated plan
       store.save(plan)
       
       // Save summary to SwiftData
       if let summaryStore = StoreManager.shared.currentSummaryStore {
           summaryStore.save(summary, runId: plan.runs[runIndex].id)
       }
       
       // Update the published plan if it matches
       if self.plan?.runs.count == plan.runs.count {
           self.plan = plan
       }
       
       // Post notification to refresh PlanView
       NotificationCenter.default.post(name: NSNotification.Name("PlanUpdated"), object: nil)
       
       print("✅ iOS: Updated run for \(today) with summary data and marked as completed")
   }
#endif
   
   
    
    // ========================================== MARK: - Receive Plan (watchOS from iOS ) ==========================================
    
#if os(watchOS)
    // Receive message from watchOS
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("watchOS: Received message from iOS")
        decodeAndStorePlan(from: message)
    }
    
    // Receive message with reply handler
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("watchOS: Received message from watchOS (with reply handler)")
        decodeAndStorePlan(from: message)
        replyHandler(["status": "received"])
    }
    
    // Receive application context
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("watchOS: Received application context from iOS")
        decodeAndStorePlan(from: applicationContext)
    }
#endif
    
    private func decodeAndStorePlan(from dictionary: [String: Any]) {
        
        // Extract raw Data
        guard let data = dictionary["generatedPlan"] as? Data else {
#if os(watchOS)
            print("watchOS: ❌ No generatedPlan data found in dictionary")
#endif
            return
        }
        
        do {
            // Decode with JSONDecoder
            let decoded = try JSONDecoder().decode(GeneratedPlan.self, from: data)
            
            DispatchQueue.main.async {
                self.plan = decoded   // <-- store it properly
#if os(watchOS)
                print("watchOS: ✅ Successfully decoded GeneratedPlan with \(decoded.runs.count) runs")
//                print("watchOS: Plan Title: \(decoded.plan.title)")
#endif
            }
            
        } catch {
#if os(watchOS)
            print("watchOS: ❌ Failed to decode GeneratedPlan:", error)
#endif
        }
    }
    
    
    
   // ========================================== MARK: - Send Summary (watchOS to iOS) ==========================================
   
#if os(watchOS)
   func sendSummaryToiOS(summary: RunningSummary) {
       // Check activation state first
       if session.activationState == .activated {
           // Session is activated - send immediately
           sendSummaryData(summary: summary)
       } else {
           // Session not activated yet - queue it
           print("watchOS: Session not activated (State: \(session.activationState.rawValue)). Queueing summary...")
           pendingSummary = summary
           // Don't call activate() here - it's already being called in connect()
           // Just wait for activation to complete, then sendPendingSummaryIfNeeded() will handle it
       }
   }
   
   private func sendSummaryData(summary: RunningSummary) {
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
               stateDescription = "unknown(\(session.activationState.rawValue))"
           }
           print("watchOS: ❌ Cannot send summary - Session is not activated. Current state: \(stateDescription)")
           print("watchOS: Queueing summary for later...")
           pendingSummary = summary
           return
       }
       
       let data: [String: Any] = [
           "id": summary.id,
           "totalTime": summary.totalTime,
           "totalDistance": summary.totalDistance,
           "averageHeartRate": summary.averageHeartRate,
           "averagePace": summary.averagePace
           //            "elevationGain": summary.elevationGain,
           //            "zoneDuration": summary.zoneDuration
       ]
       
       print("watchOS: Attempting to send summary (activationState: activated, isReachable: \(session.isReachable))")
       
       // Use updateApplicationContext (works even when not reachable)
       do {
           try session.updateApplicationContext(data)
           print("watchOS: ✅ Successfully sent summary via updateApplicationContext")
       } catch {
           print("watchOS: ❌ Error updating application context: \(error.localizedDescription)")
           print("watchOS: Error details: \(error)")
           
           // If updateApplicationContext fails, try sendMessage as fallback (if reachable)
           if session.isReachable {
               print("watchOS: Trying sendMessage as fallback...")
               session.sendMessage(data, replyHandler: { reply in
                   print("watchOS: ✅ Message sent successfully via sendMessage. Reply: \(reply)")
               }, errorHandler: { error in
                   print("watchOS: ❌ Error sending message: \(error.localizedDescription)")
                   print("watchOS: Queueing summary for retry...")
                   self.pendingSummary = summary
               })
           } else {
               print("watchOS: Session is not reachable. Queueing summary for later...")
               pendingSummary = summary
           }
       }
   }
   
   private func sendPendingSummaryIfNeeded() {
       guard let pending = pendingSummary, session.activationState == .activated else {
           return
       }
       
       print("watchOS: Sending pending summary now that session is activated...")
       // Clear pending first
       pendingSummary = nil
       // Send it
       sendSummaryData(summary: pending)
   }
#endif
    
    
    // ==========================================
    // MARK: - Send GeneratedPlan (iOS → watchOS)
    // ==========================================
    
#if os(iOS)
    func sendPlanToWatchOS(plan: GeneratedPlan) {
        
        // Session not yet activated → queue it
        guard session.activationState == .activated else {
            print("iOS: Session not activated. Queuing GeneratedPlan for later…")
            pendingRunningPlan = plan
            return
        }
        
        // Activated → send now
        sendGeneratedPlan(plan)
    }
    
    private func sendGeneratedPlan(_ plan: GeneratedPlan) {
        
        guard session.activationState == .activated else {
            print("iOS: ❌ Cannot send – session not activated. Queuing…")
            pendingRunningPlan = plan
            return
        }
        
        print("iOS: Attempting to send GeneratedPlan (isReachable: \(session.isReachable))")
        
        do {
            // 👉 ENCODE ENTIRE PLAN AS JSON
            let encoded = try JSONEncoder().encode(plan)
            
            // 👉 Put into application context
            let payload: [String: Any] = [
                "generatedPlan": encoded
            ]
            
            try session.updateApplicationContext(payload)
            
            print("iOS: ✅ Successfully sent GeneratedPlan via updateApplicationContext")
            
        } catch {
            print("iOS: ❌ Failed to send GeneratedPlan: \(error.localizedDescription)")
            pendingRunningPlan = plan
            
            // Optional fallback if reachable
            if session.isReachable {
                print("iOS: Attempting sendMessage fallback…")
                
                session.sendMessage(
                    ["generatedPlan": try? JSONEncoder().encode(plan)],
                    replyHandler: { reply in
                        print("iOS: ✅ Fallback sendMessage succeeded: \(reply)")
                    },
                    errorHandler: { err in
                        print("iOS: ❌ Fallback sendMessage failed: \(err)")
                        self.pendingRunningPlan = plan
                    }
                )
            }
        }
    }
    
    private func sendPendingRunningPlanIfNeeded() {
        guard let plan = pendingRunningPlan,
              session.activationState == .activated else { return }
        
        print("iOS: Sending previously queued GeneratedPlan…")
        
        pendingRunningPlan = nil
        sendGeneratedPlan(plan)
    }
#endif
}
