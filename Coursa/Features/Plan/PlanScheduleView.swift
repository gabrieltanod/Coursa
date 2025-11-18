//
//  PlanScheduleView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 18/11/25.
//

import SwiftUI

/// Reusable list of planned sessions, used by PlanView and HomeView.
struct PlanScheduleView: View {
    @EnvironmentObject private var planSession: PlanSessionStore

    var body: some View {
        if let generated = planSession.generatedPlan
            ?? UserDefaultsPlanStore.shared.load()
        {
            let allRuns = generated.runs.sorted { $0.date < $1.date }
            let weekGroups = groupByWeek(allRuns)

            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach(weekGroups.indices, id: \.self) { index in
                        let group = weekGroups[index]
                        WeeklyPlanOverviewCard(
                            weekIndex: index + 1,
                            runs: group._value,
                            onSeeOverview: nil,
                            showsButton: false  // 👈 no button here
                        )
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
            }
            .background(Color("black-500"))
            .navigationTitle("Plan Overview")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ManagePlanView()
                            .environmentObject(planSession)
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color("white-500"))
                    }
                }
            }
        } else {
            NoPlanPlaceholder()
        }
    }
}

// MARK: - Helpers

private struct NoPlanPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.run")
                .font(.system(size: 56, weight: .regular))
                .foregroundStyle(Color.gray.opacity(0.8))
                .padding(.bottom, 6)

            Text("No Plan")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color("white-500"))

            Text("Pick your preferred plan to get started.")
                .font(.system(size: 14))
                .foregroundStyle(Color("white-500").opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("black-500"))
    }
}

// MARK: - Week grouping

private struct WeekKey: Hashable, Comparable {
    let year: Int
    let week: Int

    static func < (lhs: WeekKey, rhs: WeekKey) -> Bool {
        (lhs.year, lhs.week) < (rhs.year, rhs.week)
    }
}

private struct WeekGroup: Identifiable {
    let id = UUID()
    let _key: WeekKey
    let _value: [ScheduledRun]
}

private func groupByWeek(_ runs: [ScheduledRun]) -> [WeekGroup] {
    let cal = Calendar.current
    let groups = Dictionary(grouping: runs) { run -> WeekKey in
        WeekKey(
            year: cal.component(.yearForWeekOfYear, from: run.date),
            week: cal.component(.weekOfYear, from: run.date)
        )
    }
    return groups.keys.sorted().map { key in
        WeekGroup(
            _key: key,
            _value: groups[key]!.sorted { $0.date < $1.date }
        )
    }
}
