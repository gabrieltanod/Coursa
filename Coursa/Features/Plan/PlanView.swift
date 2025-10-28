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
                List {
                    // Optional: group by week for "Today / This Week / Next Week" later
                    ForEach(groupByWeek(generated.runs), id: \.key) { week, runs in
                        Section(weekTitle(for: runs.first?.date)) {
                            ForEach(runs) { run in
                                NavigationLink {
                                    PlanDetailView(run: run)   // ⬅️ tap opens detail
                                } label: {
                                    RunSessionCard(run: run)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            } else {
                Spacer()
                Text("No plan yet").foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(.horizontal)
        .navigationTitle("Your Plan")
        .onAppear {
            if vm.recommendedPlan == nil { vm.computeRecommendation() }
            if vm.generatedPlan == nil { vm.generatePlan() }
        }
    }

    // MARK: - Small pieces

    @ViewBuilder
    private func header() -> some View {
        if let plan = vm.recommendedPlan {
            VStack(alignment: .leading, spacing: 4) {
                Text(plan.rawValue).font(.headline)
                Text("Auto-generated from your onboarding").font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    // group runs by ISO week number
    private func groupByWeek(_ runs: [ScheduledRun]) -> [(key: Int, value: [ScheduledRun])] {
        let cal = Calendar.current
        let groups = Dictionary(grouping: runs) { run in
            cal.component(.weekOfYear, from: run.date)
        }
        // sort by week
        return groups.sorted { $0.key < $1.key }
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
}

// A simple cell that matches your lofi (title + specs)
struct RunSessionCard: View {
    let run: ScheduledRun
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(run.title).font(.headline)
            Text(run.subtitle).font(.caption).foregroundStyle(.secondary)
            Text(run.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2).foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}
