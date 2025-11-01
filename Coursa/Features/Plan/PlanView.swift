//
//  PlanView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 24/10/25.
//

// PlanView.swift (update)
import SwiftUI

struct PlanView: View {
    @StateObject var vm: PlanViewModel

    var body: some View {
        VStack(spacing: 16) {
            // (keep your controls if you still want them in MVP)
            header()

            if let generated = vm.generatedPlan {
                let sorted = generated.runs.sorted { $0.date < $1.date }
                let allGroups = groupByWeek(sorted)
                let now = Date()
                // Pick the first plan week whose first run is today or in the future
                let currentIndex = allGroups.firstIndex { group in
                    guard let first = group._value.first?.date else { return false }
                    return first >= Calendar.current.startOfDay(for: now)
                } ?? 0
                let thisWeekGroup = allGroups[currentIndex]
                let thisWeekRuns = thisWeekGroup._value
                let upcomingGroups = Array(allGroups.dropFirst(currentIndex + 1))

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        // This Week header shows the plan week range (e.g., 2 Nov – 8 Nov)
                        Text(weekTitle(for: thisWeekGroup._value.first?.date))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 4)

                        ForEach(thisWeekRuns) { run in
                            NavigationLink { PlanDetailView(run: run) } label: {
                                RunningSessionCard(run: run)
                            }
                        }
                        Divider().padding(.vertical, 4)

                        if !upcomingGroups.isEmpty {
                            Text("Upcoming").font(.headline)
                            ForEach(upcomingGroups, id: \._key) { group in
                                // Subheader shows date range for that plan week
                                Text(weekTitle(for: group._value.first?.date))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                WeekSummaryCard(title: weekNumberTitle(for: group._value.first?.date), runs: group._value)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            } else {
                Spacer()
                Text("No plan yet").foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(.horizontal)
//        .navigationTitle("Your Plan")
        .onAppear {
            if vm.recommendedPlan == nil { vm.computeRecommendation() }
            if vm.generatedPlan == nil { vm.generatePlan() }
        }
    }

    // MARK: - Small pieces

    @ViewBuilder
    private func header() -> some View {
        if let plan = vm.recommendedPlan {
            VStack(alignment: .center, spacing: 4) {
                Text(plan.rawValue)
                    .font(.largeTitle)
//                Text("Auto-generated from your onboarding").font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    // group runs by [year, weekOfYear] so weeks don’t mix across years
    private struct WeekKey: Hashable, Comparable { let year: Int; let week: Int; static func < (l: WeekKey, r: WeekKey) -> Bool { (l.year, l.week) < (r.year, r.week) } }
    private struct WeekGroup: Identifiable { let id = UUID(); let _key: WeekKey; let _value: [ScheduledRun] }
    private func groupByWeek(_ runs: [ScheduledRun]) -> [WeekGroup] {
        let cal = Calendar.current
        let groups = Dictionary(grouping: runs) { run -> WeekKey in
            WeekKey(year: cal.component(.yearForWeekOfYear, from: run.date),
                    week: cal.component(.weekOfYear, from: run.date))
        }
        return groups.keys.sorted().map { key in
            WeekGroup(_key: key, _value: groups[key]!.sorted { $0.date < $1.date })
        }
    }

    private func weekTitle(for date: Date?) -> String {
        guard let date else { return "This Week" }
        let cal = Calendar.current
        let start = cal.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        let end = cal.date(byAdding: .day, value: 6, to: start) ?? date
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("d MMM")
        return "\(df.string(from: start)) – \(df.string(from: end))"
    }

    private func weekNumberTitle(for date: Date?) -> String {
        guard let date else { return "Week 1" }
        let allRuns = vm.generatedPlan?.runs.sorted(by: { $0.date < $1.date }) ?? []
        let groups = groupByWeek(allRuns)
        guard let idx = groups.firstIndex(where: { group in
            group._value.contains { Calendar.current.isDate($0.date, equalTo: date, toGranularity: .weekOfYear) }
        }) else { return "Week 1" }
        return "Week \(idx + 1)"
    }
}
