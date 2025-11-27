//
//  StatisticsView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 18/11/25.
//

import SwiftUI

struct StatisticsView: View {
    
    @EnvironmentObject private var planSession: PlanSessionStore
    @State private var showAerobicInfo = false
    
    var body: some View {
        ZStack {
            Color("black-500")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Statistics")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(Color("white-500"))
                        .padding(.top, 8)
                    planProgressCard
                    //                    weeklyProgressSection
                    weeklyMetricsRow
                    recentActivitySection
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
        .navigationTitle("Statistics")
        .foregroundStyle(Color.white)
    }
    
    private var planProgressCard: some View {
        let allRuns = planSession.allRuns.sorted { $0.date < $1.date }
        
        let totalSessions = allRuns.count
        let completedOrSkippedSessions = allRuns.filter {
            $0.status == .completed || $0.status == .skipped
        }.count
        
        let progress =
        totalSessions == 0
        ? 0
        : Double(completedOrSkippedSessions) / Double(totalSessions)
#if DEBUG
        let statusCounts = Dictionary(grouping: allRuns, by: { $0.status })
            .mapValues { $0.count }
        print(
            "[HomeView] planProgressCard – totalSessions: \(totalSessions), completedOrSkippedSessions: \(completedOrSkippedSessions), progress: \(progress), statusCounts: \(statusCounts)"
        )
#endif
        
        let completedKm =
        allRuns
            .filter { $0.status == .completed }
            .reduce(0.0) { sum, run in
                if let d = run.actual.distanceKm {
                    return sum + d
                }
                if let t = run.template.targetDistanceKm {
                    return sum + t
                }
                return sum
            }
        
        let targetKm =
        allRuns
            .compactMap { $0.template.targetDistanceKm }
            .reduce(0, +)
        
        let title = planTitle(from: allRuns)
        
        return PlanProgressCard(
            title: title,
            progress: progress,
            completedKm: completedKm,
            targetKm: targetKm
        )
        .padding(.top, 20)
    }
    
    private func planTitle(from runs: [ScheduledRun]) -> String {
        guard let focus = runs.first?.template.focus else {
            return "Your Plan"
        }
        
        switch focus {
        case .base, .endurance:
            return "Endurance Plan"
        case .speed:
            return "Speed Plan"
        default:
            return "Your Plan"
        }
    }
    
    private var weeklyMetricsRow: some View {
        
        let allRuns = planSession.allRuns
            .filter { $0.status == .completed }
            .sorted { $0.date > $1.date }
        
        let cal = Calendar.current
        let now = Date()
        
        // Week ranges
        let thisWeekStart = cal.dateInterval(of: .weekOfYear, for: now)!.start
        let lastWeekStart = cal.date(
            byAdding: .weekOfYear,
            value: -1,
            to: thisWeekStart
        )!
        let lastWeekEnd = thisWeekStart
        
        // Filter runs by week
        let thisWeekRuns = allRuns.filter { $0.date >= thisWeekStart }
        let lastWeekRuns = allRuns.filter {
            $0.date >= lastWeekStart && $0.date < lastWeekEnd
        }
        
        // Compute average paces
        let thisWeekPaceSec = computeAveragePace(for: thisWeekRuns)
        let lastWeekPaceSec = computeAveragePace(for: lastWeekRuns)
        
        // Format
        let thisWeekPaceText = formatPace(thisWeekPaceSec)
        let lastWeekPaceText = formatPace(lastWeekPaceSec)
        
        let thisWeekZone2Seconds = totalZone2SecondsForWeek(offset: 0)
        let lastWeekZone2Seconds = totalZone2SecondsForWeek(offset: 1)
        
        let thisWeekAerobicText = formatHMS(thisWeekZone2Seconds)
        let lastWeekAerobicText = formatHMS(lastWeekZone2Seconds)
#if DEBUG
        print("=== STATISTICS DEBUG ===")
        print("This week runs: \(thisWeekRuns.count)")
        print("Last week runs: \(lastWeekRuns.count)")
        print("This week pace: \(thisWeekPaceText)")
        print("Last week pace: \(lastWeekPaceText)")
        print("This week Z2: \(thisWeekAerobicText)")
        print("Last week Z2: \(lastWeekAerobicText)")
        print("=========================")
#endif
        
        // Calculate trends
        // For pace: lower is better (faster)
        let paceTrend: ComparisonTrend? = {
            if thisWeekPaceSec <= 0 || lastWeekPaceSec <= 0 {
                return nil
            }
            if thisWeekPaceSec < lastWeekPaceSec {
                return .better
            } else if thisWeekPaceSec > lastWeekPaceSec {
                return .worse
            } else {
                return .same
            }
        }()
        
        // For aerobic time: higher is better (more time in zone 2)
        let aerobicTrend: ComparisonTrend? = {
            if thisWeekZone2Seconds == 0 && lastWeekZone2Seconds == 0 {
                return nil
            }
            if thisWeekZone2Seconds > lastWeekZone2Seconds {
                return .better
            } else if thisWeekZone2Seconds < lastWeekZone2Seconds {
                return .worse
            } else {
                return .same
            }
        }()
        
        var summaryMessage: String {
            switch (paceTrend, aerobicTrend) {
                
            case (.better, .better):
                return "Amazing job! You’ve managed to keep up both your aerobic and pace. Keep it this way and you’ll reach your goal in no time!"
                
            case (.better, _):
                return "You’ve increased your pace, but your aerobic time can be better. The first priority is to build your endurance first. Keep up the good work. "
                
            case (_, .better):
                return "Great job at increasing aerobic time, although you can put more effort in your pace. The first priority is to build your endurance first. Keep up the good work. "
                
            case (.worse, .worse):
                return "That week was fantastic for logging consistent work, even if your pace and aerobic time didn't show big jumps. Remember, sticking to the schedule is a huge win for building long-term fitness!"
                
            default:
                return ""
            }
        }
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                MetricDetailCard(
                    title: "Average Pace",
                    primaryValue: thisWeekPaceText,
                    secondaryValue: lastWeekPaceText,
                    footer: "Vs Last Week",
                    comparisonTrend: paceTrend
                )
                
                MetricDetailCard(
                    title: "Aerobic Time",
                    primaryValue: thisWeekAerobicText,
                    secondaryValue: lastWeekAerobicText,
                    footer: "Vs Last Week",
                    showInfoButton: true,
                    onInfoTapped: { showAerobicInfo = true },
                    comparisonTrend: aerobicTrend
                )
            }
            
            if !summaryMessage.isEmpty {
                SummaryCard(message: summaryMessage)
            }
        }
        .sheet(isPresented: $showAerobicInfo) {
            aerobicInfoSheet
        }
    }
    
    private var recentActivitySection: some View {
        let historyRuns = planSession.allRuns
            .filter { $0.status == .completed || $0.status == .skipped }
            .sorted { $0.date > $1.date }
        
        let topThree = Array(historyRuns.prefix(3))
        
        return VStack(alignment: .leading, spacing: 12) {
            if !topThree.isEmpty {
                HStack {
                    Text("Recent Activity")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color("white-500"))
                    
                    Spacer()
                    
                    NavigationLink {
                        // TODO: Hook this up to a full history screen (e.g. Plan history)
                        RunHistoryView()
                    } label: {
                        Text("See All")
                            .font(.system(size: 15, weight: .light))
                            .foregroundStyle(Color("white-500"))
                    }
                }
                
                ForEach(topThree) { run in
                    NavigationLink {
                        RunningSummaryView(run: run)
                    } label: {
                        RunningHistoryCard(
                            run: run,
                            isSkipped: run.status == .skipped
                        )
                    }
                }
            }
        }
    }
    
    private func totalZone2SecondsForWeek(offset: Int) -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        guard
            let thisWeekInterval = calendar.dateInterval(
                of: .weekOfYear,
                for: now
            )
        else {
            return 0
        }
        
        // Figure out which week we’re targeting
        let targetStart: Date
        if offset == 0 {
            targetStart = thisWeekInterval.start
        } else {
            guard
                let shifted = calendar.date(
                    byAdding: .weekOfYear,
                    value: -offset,
                    to: thisWeekInterval.start
                ),
                let interval = calendar.dateInterval(
                    of: .weekOfYear,
                    for: shifted
                )
            else {
                return 0
            }
            targetStart = interval.start
        }
        
        guard
            let targetEnd = calendar.date(
                byAdding: .day,
                value: 7,
                to: targetStart
            )
        else {
            return 0
        }
        
        let interval = DateInterval(start: targetStart, end: targetEnd)
        
        // Runs inside that week
        let weekRuns = planSession.allRuns.filter { interval.contains($0.date) }
        
        // 🔑 Sum Zone 2 seconds from your friend’s zoneDuration dictionary
        let totalSecondsDouble = weekRuns.reduce(0.0) { partial, run in
            let z2 = run.actual.zoneDuration[2] ?? 0  // Zone 2 = key 2
            return partial + z2
        }
        
        return Int(totalSecondsDouble)
    }
    
    /// Format seconds like "1:43:37" or "43:05"
    private func formatHMS(_ seconds: Int) -> String {
        guard seconds > 0 else { return "0:00:00" }
        
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
    
    private func computeAveragePace(for runs: [ScheduledRun]) -> Double {
        let paceValues: [Double] = runs.compactMap { run in
            guard let distance = run.actual.distanceKm, distance > 0,
                  let duration = run.actual.elapsedSec
            else {
                return nil
            }
            return Double(duration) / distance  // seconds per km
        }
        
        guard !paceValues.isEmpty else { return 0 }
        return paceValues.reduce(0, +) / Double(paceValues.count)
    }
    
    private var aerobicInfoSheet: some View {
        NavigationStack {
            ZStack {
                Color("black-500")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("About Aerobic Training")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color("white-500"))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What is Zone 2?")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color("white-500"))
                            
                            Text("This is the amount of time you spent in your aerobic zone (or Zone 2). During this time, your effort level is moderate, you can still speak in full sentences but you're working hard enough to feel a benefit.")
                                .font(.system(size: 16))
                                .foregroundStyle(Color("white-700"))
                                .lineSpacing(4)
                            
                            Text("Benefits")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color("white-500"))
                                .padding(.top, 8)
                            
                            Text("Training here is the single best way to increase your stamina, boost your energy efficiency, and protect against injury.")
                                .font(.system(size: 16))
                                .foregroundStyle(Color("white-700"))
                                .lineSpacing(4)
                        }
                    }
                    .padding(24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showAerobicInfo = false
                    }
                    .foregroundStyle(Color("green-500"))
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func formatPace(_ secondsPerKm: Double) -> String {
        if secondsPerKm <= 0 { return "0:00/km" }
        let minutes = Int(secondsPerKm) / 60
        let seconds = Int(secondsPerKm) % 60
        return String(format: "%d:%02d/km", minutes, seconds)
    }
}

#Preview {
    let planSession = PlanSessionStore()
#if DEBUG
    planSession.loadDebugSampleDataForStatistics()
#endif
    
    return NavigationStack {
        StatisticsView()
            .environmentObject(planSession)
            .background(Color("black-500"))
            .preferredColorScheme(.dark)
    }
}
