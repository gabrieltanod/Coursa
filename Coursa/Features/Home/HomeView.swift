//
//  HomeView.swift
//  Coursa
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @EnvironmentObject private var planSession: PlanSessionStore
    @EnvironmentObject private var syncService: SyncService
    @State private var selectedWeekIndex: Int = 0
    @State private var showAdjustCard = true
    private let calendar = Calendar.current

    var body: some View {
        ZStack {
            Color("black-500").ignoresSafeArea()

            Ellipse()
                .fill(Color.white.opacity(0.7))
                .frame(width: 261, height: 278)
                .blur(radius: 175)
                .offset(x: -250, y: -370)

            Ellipse()
                .fill(Color.white.opacity(1))
                .frame(width: 261, height: 162)
                .blur(radius: 175)
                .offset(x: 350, y: 294)  // adjust as needed
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 16) {
                header

                calendarStrip

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        if showAdjustCard {
                            SmallCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Adjust your plan")
                                        .font(
                                            .system(size: 18, weight: .semibold)
                                        )
                                        .foregroundColor(Color("white-500"))

                                    Text(
                                        "Confirm the adjustment to ensure your runs this week are realistic and on track. Review the changes before your next run."
                                    )
                                    .font(.system(size: 14))
                                    .foregroundColor(
                                        Color("white-500").opacity(0.7)
                                    )
                                    .fixedSize(
                                        horizontal: false,
                                        vertical: true
                                    )

                                    Button(action: {
                                        // TEMP PlanViewModel just for debug adapt
                                        if let onboarding =
                                            OnboardingStore.load()
                                        {
                                            let debugVM = PlanViewModel(
                                                data: onboarding
                                            )
                                            debugVM
                                                .debugCompleteThisWeekAndAdapt()
                                        }

                                        // Reload shared plan so Home/Plan stay in sync
                                        planSession.generatedPlan =
                                            UserDefaultsPlanStore.shared.load()

                                        // Hide the card after one use
                                        showAdjustCard = false
                                    }) {
                                        Text("Adjust")
                                            .font(
                                                .system(
                                                    size: 16,
                                                    weight: .semibold
                                                )
                                            )
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(
                                                    cornerRadius: 999
                                                )
                                                .fill(Color.white)
                                            )
                                            .foregroundColor(.black)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.top, 4)
                                }
                            }
                        }

                        sessionsSection

                        planProgressCard

                        weeklyProgressSection

                        weeklyMetricsRow

                        Spacer(minLength: 0)
                    }
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.never)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
    }

    // MARK: - Header

    private var header: some View {
        let weekCount = calendarWeeks.count
        // Clamp index safely in case weeks are not yet loaded
        let safeIndex =
            weekCount > 0 ? min(max(selectedWeekIndex, 0), weekCount - 1) : 0

        return HStack(spacing: 12) {
            HStack(spacing: 2) {
                Text("Week \(weekCount == 0 ? 1 : safeIndex + 1)")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(Color("white-500"))

                VStack(spacing: 0) {
                    Text("")
                    if weekCount > 0 {
                        Text("/\(weekCount)")
                            .font(.system(size: 17, weight: .medium))
                            .baselineOffset(4)
                            .foregroundStyle(Color("white-500").opacity(0.9))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            NavigationLink {
                CalendarView()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 40, height: 40)
                        .maybeGlassEffect()
                    Image(systemName: "calendar")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color("white-500"))
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var planProgressCard: some View {
        let allRuns = planSession.allRuns.sorted { $0.date < $1.date }

        // Session-based progress: completed + skipped sessions over total sessions
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

        // Distance completed: prefer actual distance, fall back to template targetDistanceKm
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

        // Target distance = sum of template targets (ignore nils)
        let targetKm =
            allRuns
            .compactMap { $0.template.targetDistanceKm }
            .reduce(0, +)

        // Progress based on completed distance vs total planned distance
        // let progress = targetKm > 0 ? completedKm / targetKm : 0

        let title = planTitle(from: allRuns)

        return PlanProgressCard(
            title: title,
            progress: progress,
            completedKm: completedKm,
            targetKm: targetKm
        )
        .padding(.top, 20)
    }

    // MARK: - Calendar Strip (week-based)

    private var calendarStrip: some View {
        let weeks = calendarWeeks

        return TabView(selection: $selectedWeekIndex) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { index, days in
                HStack(spacing: 10) {
                    ForEach(days, id: \.self) { date in
                        let isSelected = calendar.isDate(
                            date,
                            inSameDayAs: vm.selectedDate
                        )
                        let hasRun = vm.hasRun(on: date)

                        VStack(spacing: 6) {
                            Text(weekdayString(for: date).uppercased())
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(
                                    Color("white-500").opacity(
                                        isSelected ? 1.0 : 0.6
                                    )
                                )

                            Text(dayString(for: date))
                                .font(.system(size: 17, weight: .semibold))
                                .frame(width: 32, height: 32)
                                .foregroundStyle(
                                    isSelected ? .black : Color("white-500")
                                )
                                .background(
                                    Circle()
                                        .fill(
                                            isSelected
                                                ? Color("white-500") : .clear
                                        )
                                )

                            if let run = vm.runs.first(where: {
                                calendar.isDate($0.date, inSameDayAs: date)
                            }) {
                                let kind = run.template.kind
                                let colorName: String = {
                                    switch kind {
                                    case .long:
                                        return "long"  // asset for Long Run
                                    case .easy:
                                        return "easy"  // asset for Easy Run
                                    default:
                                        return "maf"  // asset for MAF / other runs
                                    }
                                }()

                                Circle()
                                    .fill(Color(colorName))
                                    .frame(width: 6, height: 6)
                                    .offset(y: 2)
                            } else {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 6, height: 6)
                                    .offset(y: 2)
                            }

                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.selectedDate = date
                        }
                    }
                }
                .tag(index)
                .frame(maxWidth: .infinity)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 80)
    }

    // Weeks from first plan week to last plan week, each exactly 7 days.
    // No pre-plan weeks → no empty calendar before your plan.
    private var calendarWeeks: [[Date]] {
        guard let firstRunDate = vm.runs.first?.date,
            let lastRunDate = vm.runs.last?.date
        else {
            return []
        }

        let startComponents = calendar.dateComponents(
            [.yearForWeekOfYear, .weekOfYear],
            from: firstRunDate
        )
        let endComponents = calendar.dateComponents(
            [.yearForWeekOfYear, .weekOfYear],
            from: lastRunDate
        )

        guard let startOfFirstWeek = calendar.date(from: startComponents),
            let startOfLastWeek = calendar.date(from: endComponents)
        else {
            return []
        }

        var weeks: [[Date]] = []
        var currentWeekStart = startOfFirstWeek

        while currentWeekStart <= startOfLastWeek {
            var days: [Date] = []
            for offset in 0..<7 {
                if let d = calendar.date(
                    byAdding: .day,
                    value: offset,
                    to: currentWeekStart
                ) {
                    days.append(d)
                }
            }
            weeks.append(days)

            guard
                let next = calendar.date(
                    byAdding: .day,
                    value: 7,
                    to: currentWeekStart
                )
            else {
                break
            }
            currentWeekStart = next
        }

        return weeks
    }

    private func weekdayString(for date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "EEE"
        return f.string(from: date)
    }

    private func dayString(for date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "d"
        return f.string(from: date)
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

    // MARK: - Sessions List

    private var sessionsSection: some View {
        let sessions = vm.sessions(on: vm.selectedDate)

        return VStack(alignment: .leading, spacing: 12) {
            if sessions.isEmpty {
                EmptyState()
            } else {
                ForEach(sessions) { run in
                    NavigationLink {
                        PlanDetailView(run: run)
                    } label: {
                        RunningSessionCard(run: run)
                    }
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            sendRunToWatch(run)
                        }
                    )
                }
            }
        }
    }

    private var weeklyProgressSection: some View {
        // Example numbers – replace with your real computed values
        let allRuns = planSession.allRuns.sorted { $0.date < $1.date }
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

        // Target distance = sum of template targets (ignore nils)
        let targetKm =
            allRuns
            .compactMap { $0.template.targetDistanceKm }
            .reduce(0, +)

        return WeeklyProgressCard(
            title: "Weekly Progress",
            progressText: "\(Int(completedKm)) / \(Int(targetKm)) KM"
        )
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
                title: "Duration in HR Zone 2",
                primaryValue: "1:43:37",
                secondaryValue: "1:26:15",
                footer: "Your Duration in Zone 2 Last Week and Two Week Ago"
            )
        }
    }

    private func sendRunToWatch(_ run: ScheduledRun) {
        // Derive a simple recommended pace from the template if possible
        let recPace: String
        if let duration = run.template.targetDurationSec,
            let distance = run.template.targetDistanceKm,
            distance > 0
        {
            let secPerKm = Double(duration) / distance
            let minutes = Int(secPerKm) / 60
            let seconds = Int(secPerKm) % 60
            recPace = String(format: "%d:%02d /km", minutes, seconds)
        } else {
            recPace = "Easy"
        }

        let plan = RunningPlan(from: run, recPace: recPace)
        print("[HomeView] Sending plan to watch for run id: \(run.id)")
        syncService.sendPlanToWatchOS(plan: plan)
    }
}

#Preview("HomeView") {
    NavigationStack {
        HomeView()
            .background(Color("black-500"))
            .preferredColorScheme(.dark)
    }
}
