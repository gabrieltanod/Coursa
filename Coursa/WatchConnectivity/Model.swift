//
//  RunningSummary.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 30/10/25.
//

import Foundation


struct RunningPlan: Codable, Hashable, Sendable, Identifiable{
    var id = UUID()
    let date: Date
    let title: String
    let targetDistance: String
    let intensity: String
    let recPace: String
}


struct RunningSummary: Codable, Hashable, Sendable, Identifiable{
    var id = UUID()
    let totalTime: Double
    let totalDistance: Double
    let averageHeartRate: Double
    let averagePace: Double
    let elevationGain: Double
    let zoneDuration: [Int: Double]
}
