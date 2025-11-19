//
//  StatisticsView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 18/11/25.
//

import SwiftUI

struct StatisticsView: View {

    @EnvironmentObject private var planSession: PlanSessionStore

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
        case .base:
            return "Base Builder"
        case .endurance:
            return "Endurance Plan"
        case .speed:
            return "Speed Plan"
        default:
            return "Your Plan"
        }
    }

    private var weeklyMetricsRow: some View {
        HStack(spacing: 12) {
            MetricDetailCard(
                title: "Average Pace",
                primaryValue: "8:25/km",
                secondaryValue: "8:45/km",
                footer: "Average Pace Last Week and Two Week Ago"
            )

            MetricDetailCard(
                title: "Aerobic Time",
                primaryValue: "1:43:37",
                secondaryValue: "1:26:15",
                footer: "Your Duration in Zone 2 Last Week and Two Week Ago"
            )
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
}

#Preview {
    StatisticsView()
}
