//
//  PlanModels.swift
//  Coursa
//
//  Created by Gabriel Tanod on 27/10/25.
//

// ABSTRACT : ini data model buat semua

import Foundation

// MARK: - Plan Enum
enum Plan: String, CaseIterable, Identifiable, Codable, Hashable {
    case baseBuilder = "🏃🏿‍♂️ General Training"
    case endurance = "🧡 Endurance"
    case speed = "💨 Speed"
    case halfMarathonPrep = "🏁 Half Marathon Prep"
    
    var id: String { rawValue }
}

// Replace DayWorkout + old GeneratedPlan with this:
struct GeneratedPlan: Codable, Equatable, Hashable {
    let plan: Plan
    var runs: [ScheduledRun]
}


// MARK: - Core Run Types

enum RunKind: String, Codable, CaseIterable, Identifiable {
    case easy, long, tempo, intervals, recovery, maf
    var id: String { rawValue }
}

enum RunFocus: String, Codable, CaseIterable, Identifiable {
    case endurance, speed, base
    var id: String { rawValue }
}

enum HRZone: Int, Codable, CaseIterable, Identifiable {
    case z1 = 1, z2, z3, z4, z5
    var id: Int { rawValue }
}

// MARK: - Run Templates & Sessions

struct RunTemplate: Codable, Hashable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var name: String
    var kind: RunKind
    var focus: RunFocus
    var targetDurationSec: Int?
    var targetDistanceKm: Double?
    var targetHRZone: HRZone?
    var notes: String?
}

enum RunStatus: String, Codable, Equatable, Hashable {
    case planned, inProgress, completed, skipped
}

struct RunMetrics: Codable, Hashable, Equatable {
    var elapsedSec: Int?
    var distanceKm: Double?
    var avgPaceSecPerKm: Int?
    var avgHR: Int?
    var zoneDuration: [Int: Double] = [:]
}

struct ScheduledRun: Identifiable, Codable, Equatable, Hashable {
    var id: String = UUID().uuidString
    var date: Date
    var template: RunTemplate
    var status: RunStatus = .planned
    var actual: RunMetrics = .init()
    
    var title: String { template.name }
    var subtitle: String {
        var parts: [String] = []
        if let d = template.targetDurationSec { parts.append(Self.mmss(d)) }
        if let km = template.targetDistanceKm { parts.append("\(km.clean) km") }
        if let z = template.targetHRZone { parts.append("HR Zone \(z.rawValue)") }
        return parts.joined(separator: "  •  ")
    }
    
    private static func mmss(_ sec: Int) -> String {
        let m = sec / 60, s = sec % 60
        return String(format: "%d:%02d", m, s)
    }
}


// MARK: - Running Plan Data Model for Send Data to WatchOS

struct RunningPlan: Identifiable, Codable, Hashable{
    var id: String = UUID().uuidString
    var date: Date
    var name: String
    var kind: RunKind?
    var targetDuration: Int?
    var targetDistance: Double?
    var targetHRZone: HRZone?
    var recPace: String?
}

extension RunningPlan {
    init(from scheduledRun: ScheduledRun, recPace: String) {
        self.id = scheduledRun.id
        self.date = scheduledRun.date
        self.name = scheduledRun.template.name
        self.kind = scheduledRun.template.kind
        self.targetDuration = scheduledRun.template.targetDurationSec
        self.targetDistance = scheduledRun.template.targetDistanceKm
        self.targetHRZone = scheduledRun.template.targetHRZone
        self.recPace = recPace
    }
}

// MARK: - Running Plan Data Model for Send Data to WatchOS

struct RunningSummary: Identifiable, Codable, Hashable, Sendable {
    var id: String
    var totalTime: Double
    var totalDistance: Double
    var averageHeartRate: Double
    var averagePace: Double
    var zoneDuration: [Int: Double]
}

extension RunningSummary {
    init(from scheduledRun: ScheduledRun) {
        self.id = scheduledRun.id
        
        // Use values from scheduledRun.actual (RunMetrics)
        let metrics = scheduledRun.actual
        self.totalTime = Double(metrics.elapsedSec ?? 0)
        self.totalDistance = metrics.distanceKm ?? 0
        self.averageHeartRate = Double(metrics.avgHR ?? 0)
        self.averagePace = Double(metrics.avgPaceSecPerKm ?? 0)
        self.zoneDuration = metrics.zoneDuration
    }
}


private extension Double {
    var clean: String {
        truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

// MARK: - Plan & User Ownership

struct TrainingPlan: Codable, Hashable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var focus: RunFocus
    var durationWeeks: Int
    var library: [RunTemplate]
}

struct PlanInstance: Codable, Identifiable {
    var id: String = UUID().uuidString
    var plan: TrainingPlan
    var startDate: Date
    var scheduled: [ScheduledRun]
    var canceledAt: Date? = nil

    var completedCount: Int { scheduled.filter { $0.status == .completed }.count }
    var totalCount: Int { scheduled.count }
    var progress: Double { totalCount == 0 ? 0 : Double(completedCount) / Double(totalCount) }
}

extension PlanInstance: Equatable {
    static func == (lhs: PlanInstance, rhs: PlanInstance) -> Bool {
        lhs.id == rhs.id
    }
}

extension PlanInstance: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct UserProfile: Codable, Hashable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var activePlan: PlanInstance?
}

extension RunMetrics {
    static var empty: RunMetrics {
        RunMetrics(
            elapsedSec: nil,
            distanceKm: nil,
            avgPaceSecPerKm: nil,
            avgHR: nil,
            zoneDuration: [:]
        )
    }
}
