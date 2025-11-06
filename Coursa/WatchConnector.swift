//
//  WatchConnector.swift
//  CoursaWatch Watch App
//
//  Created by Chairal Octavyanz on 04/11/25.
//

import Foundation
import WatchConnectivity
import Combine


struct ConnectivityKey {
    static let workoutSummary = "workoutSummary"
}

class ConnectivityService: NSObject, WCSessionDelegate, ObservableObject {
    
    static let shared = ConnectivityService()
    
    @Published var receivedSummary: WorkoutSummary?
    
    private var session: WCSession
    
    override init() {
        self.session = .default
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
    
    func sendWorkoutSummary(_ summary: WorkoutSummary) {
        guard session.isReachable else {
            print("WATCH: iPhone is not reachable.")
            return
        }
        
        do {
            let data = try JSONEncoder().encode(summary)
            let context = [ConnectivityKey.workoutSummary: data]
            
            try session.updateApplicationContext(context)
            print("WATCH: Mengirim application context... ")
        } catch {
            print("WATCH: Error encoding summary: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("SESSION: Activation failed with error: \(error.localizedDescription)")
            return
        }
        print("SESSION: Activation complete, state: \(activationState.rawValue)")
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        // (iOS saja)
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // (iOS saja) - Aktifkan lagi jika perlu
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
            print("iOS: Received application context!")
            
            if let summaryData = applicationContext[ConnectivityKey.workoutSummary] as? Data {
                print("iOS: Got summary data from context!")
                do {
                    let summary = try JSONDecoder().decode(WorkoutSummary.self, from: summaryData)
                    
                    DispatchQueue.main.async {
                        self.receivedSummary = summary
                    }
                } catch {
                    print("iOS: Error decoding context summary: \(error.localizedDescription)")
                }
            }
        }
#endif
}
