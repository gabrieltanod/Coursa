//
//  RunHistoryView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 19/11/25.
//

import SwiftUI

struct RunHistoryView: View {
    @EnvironmentObject private var planSession: PlanSessionStore

    var body: some View {
        // Activity tab: completed & skipped runs
        let activitySource =
            planSession.generatedPlan
            ?? UserDefaultsPlanStore.shared.load()

        let activity = (activitySource?.runs ?? [])
            .filter {
                $0.status == .completed || $0.status == .skipped
            }
            .sorted { $0.date > $1.date }

        if activity.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 36, weight: .regular))
                    .foregroundStyle(
                        Color("white-500").opacity(0.8)
                    )

                Text("No activity yet")
                    .font(.headline)
                    .foregroundStyle(Color("white-500"))

                Text("Completed and skipped runs will appear here.")
                    .font(.subheadline)
                    .foregroundStyle(
                        Color("white-500").opacity(0.7)
                    )
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .padding(.top, 32)
        } else {
            let monthGroups = groupByMonth(activity)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    ForEach(monthGroups) { group in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(monthYearTitle(for: group._key))
                                .font(
                                    .system(
                                        size: 15,
                                        weight: .semibold
                                    )
                                )
                                .foregroundStyle(Color("white-500"))

                            LazyVStack(
                                alignment: .leading,
                                spacing: 12
                            ) {
                                ForEach(group._value) { run in
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
                .padding(.vertical, 8)
                .padding(.horizontal, 24)
            }
            .background(Color("black-500"))
            .navigationTitle(Text("Recent Activity"))

        }
    }

    // MARK: - Month grouping for history

    private struct MonthKey: Hashable, Comparable {
        let year: Int
        let month: Int

        static func < (l: MonthKey, r: MonthKey) -> Bool {
            (l.year, l.month) < (r.year, r.month)
        }
    }

    private struct MonthGroup: Identifiable {
        let id = UUID()
        let _key: MonthKey
        let _value: [ScheduledRun]
    }

    private func groupByMonth(_ runs: [ScheduledRun]) -> [MonthGroup] {
        let cal = Calendar.current
        let groups = Dictionary(grouping: runs) { run -> MonthKey in
            let comps = cal.dateComponents([.year, .month], from: run.date)
            return MonthKey(
                year: comps.year ?? 0,
                month: comps.month ?? 1
            )
        }

        // Newest month first
        return groups.keys.sorted(by: >).map { key in
            MonthGroup(
                _key: key,
                _value: groups[key]!.sorted { $0.date > $1.date }
            )
        }
    }

    private func monthYearTitle(for key: MonthKey) -> String {
        var comps = DateComponents()
        comps.year = key.year
        comps.month = key.month

        let cal = Calendar.current
        let date = cal.date(from: comps) ?? Date()

        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}
