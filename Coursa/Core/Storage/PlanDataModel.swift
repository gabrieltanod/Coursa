//
//  PlanDataModel.swift
//  Coursa
//
//  Created by Auto on 11/11/25.
//
//  SwiftData models for GeneratedPlan and RunningSummary persistence

import Foundation
import SwiftData

// MARK: - SwiftData Models

@Model
final class StoredGeneratedPlan {
    @Attribute(.unique) var id: String
    var planType: String // Plan enum rawValue
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \StoredScheduledRun.plan) var runs: [StoredScheduledRun] = []
    
    init(id: String = UUID().uuidString, planType: String, createdAt: Date = Date(), runs: [StoredScheduledRun] = []) {
        self.id = id
        self.planType = planType
        self.createdAt = createdAt
        self.runs = runs
    }
    
    // Convert to GeneratedPlan
    func toGeneratedPlan() -> GeneratedPlan? {
        guard let plan = Plan(rawValue: planType) else { return nil }
        let scheduledRuns = runs.compactMap { $0.toScheduledRun() }
        return GeneratedPlan(plan: plan, runs: scheduledRuns)
    }
    
    // Create from GeneratedPlan
    static func from(_ plan: GeneratedPlan) -> StoredGeneratedPlan {
        let stored = StoredGeneratedPlan(
            planType: plan.plan.rawValue,
            createdAt: Date()
        )
        let runs = plan.runs.map { StoredScheduledRun.from($0) }
        stored.runs = runs
        // Set the plan relationship for each run
        for run in runs {
            run.plan = stored
        }
        return stored
    }
}

@Model
final class StoredScheduledRun {
    @Attribute(.unique) var id: String
    var date: Date
    var status: String // RunStatus enum rawValue
    @Relationship(deleteRule: .cascade) var template: StoredRunTemplate?
    @Relationship(deleteRule: .cascade) var actual: StoredRunMetrics?
    var plan: StoredGeneratedPlan?
    
    init(id: String = UUID().uuidString, date: Date, status: String, template: StoredRunTemplate? = nil, actual: StoredRunMetrics? = nil) {
        self.id = id
        self.date = date
        self.status = status
        self.template = template
        self.actual = actual
    }
    
    func toScheduledRun() -> ScheduledRun? {
        guard let template = template?.toRunTemplate(),
              let status = RunStatus(rawValue: status) else { return nil }
        
        var run = ScheduledRun(
            id: id,
            date: date,
            template: template,
            status: status
        )
        run.actual = actual?.toRunMetrics() ?? RunMetrics()
        return run
    }
    
    static func from(_ run: ScheduledRun) -> StoredScheduledRun {
        let stored = StoredScheduledRun(
            id: run.id,
            date: run.date,
            status: run.status.rawValue
        )
        stored.template = StoredRunTemplate.from(run.template)
        stored.actual = StoredRunMetrics.from(run.actual)
        return stored
    }
}

@Model
final class StoredRunTemplate {
    var id: String
    var name: String
    var kind: String // RunKind enum rawValue
    var focus: String // RunFocus enum rawValue
    var targetDurationSec: Int?
    var targetDistanceKm: Double?
    var targetHRZone: Int? // HRZone rawValue
    var notes: String?
    
    init(id: String = UUID().uuidString, name: String, kind: String, focus: String, targetDurationSec: Int? = nil, targetDistanceKm: Double? = nil, targetHRZone: Int? = nil, notes: String? = nil) {
        self.id = id
        self.name = name
        self.kind = kind
        self.focus = focus
        self.targetDurationSec = targetDurationSec
        self.targetDistanceKm = targetDistanceKm
        self.targetHRZone = targetHRZone
        self.notes = notes
    }
    
    func toRunTemplate() -> RunTemplate? {
        guard let kind = RunKind(rawValue: kind),
              let focus = RunFocus(rawValue: focus) else { return nil }
        
        var template = RunTemplate(
            id: id,
            name: name,
            kind: kind,
            focus: focus,
            targetDurationSec: targetDurationSec,
            targetDistanceKm: targetDistanceKm,
            notes: notes
        )
        if let hrZoneRaw = targetHRZone, let hrZone = HRZone(rawValue: hrZoneRaw) {
            template.targetHRZone = hrZone
        }
        return template
    }
    
    static func from(_ template: RunTemplate) -> StoredRunTemplate {
        return StoredRunTemplate(
            id: template.id,
            name: template.name,
            kind: template.kind.rawValue,
            focus: template.focus.rawValue,
            targetDurationSec: template.targetDurationSec,
            targetDistanceKm: template.targetDistanceKm,
            targetHRZone: template.targetHRZone?.rawValue,
            notes: template.notes
        )
    }
}

@Model
final class StoredRunMetrics {
    var elapsedSec: Int?
    var distanceKm: Double?
    var avgPaceSecPerKm: Int?
    var avgHR: Int?
    
    init(elapsedSec: Int? = nil, distanceKm: Double? = nil, avgPaceSecPerKm: Int? = nil, avgHR: Int? = nil) {
        self.elapsedSec = elapsedSec
        self.distanceKm = distanceKm
        self.avgPaceSecPerKm = avgPaceSecPerKm
        self.avgHR = avgHR
    }
    
    func toRunMetrics() -> RunMetrics {
        var metrics = RunMetrics()
        metrics.elapsedSec = elapsedSec
        metrics.distanceKm = distanceKm
        metrics.avgPaceSecPerKm = avgPaceSecPerKm
        metrics.avgHR = avgHR
        return metrics
    }
    
    static func from(_ metrics: RunMetrics) -> StoredRunMetrics {
        return StoredRunMetrics(
            elapsedSec: metrics.elapsedSec,
            distanceKm: metrics.distanceKm,
            avgPaceSecPerKm: metrics.avgPaceSecPerKm,
            avgHR: metrics.avgHR
        )
    }
}

@Model
final class StoredRunningSummary {
    @Attribute(.unique) var id: String
    var runId: String? // Link to ScheduledRun
    var totalTime: Double
    var totalDistance: Double
    var averageHeartRate: Double
    var averagePace: Double
    var createdAt: Date
    
    init(id: String = UUID().uuidString, runId: String? = nil, totalTime: Double, totalDistance: Double, averageHeartRate: Double, averagePace: Double, createdAt: Date = Date()) {
        self.id = id
        self.runId = runId
        self.totalTime = totalTime
        self.totalDistance = totalDistance
        self.averageHeartRate = averageHeartRate
        self.averagePace = averagePace
        self.createdAt = createdAt
    }
    
    func toRunningSummary() -> RunningSummary {
        var summary = RunningSummary(
            totalTime: totalTime,
            totalDistance: totalDistance,
            averageHeartRate: averageHeartRate,
            averagePace: averagePace
        )
        summary.id = id
        return summary
    }
    
    static func from(_ summary: RunningSummary, runId: String? = nil) -> StoredRunningSummary {
        return StoredRunningSummary(
            id: summary.id,
            runId: runId,
            totalTime: summary.totalTime,
            totalDistance: summary.totalDistance,
            averageHeartRate: summary.averageHeartRate,
            averagePace: summary.averagePace
        )
    }
}

