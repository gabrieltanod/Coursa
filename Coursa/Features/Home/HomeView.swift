//
//  HomeView.swift
//  Coursa
//
//  Created by Gabriel Tanod
//
// six men

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @EnvironmentObject private var planSession: PlanSessionStore
    @EnvironmentObject private var syncService: SyncService
    @State private var selectedWeekIndex: Int = 0
    @State private var showAdjustCard = true
    @State private var showDynamicPlanCard = true
    @State private var showPlanSchedule = false
    @State private var showReviewSheet = false
    private let calendar = Calendar.current

    var body: some View {
        ZStack {
            Color("black-500").ignoresSafeArea()

            //            Ellipse()
            //                .fill(Color.white.opacity(0.7))
            //                .frame(width: 261, height: 278)
            //                .blur(radius: 175)
            //                .offset(x: -250, y: -370)
            //
            //            Ellipse()
            //                .fill(Color.white.opacity(1))
            //                .frame(width: 261, height: 162)
            //                .blur(radius: 175)
            //                .offset(x: 350, y: 294)  // adjust as needed
            //                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 16) {
                header

                calendarStrip

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        if showAdjustCard {
                            SmallCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Improve your plan")
                                        .font(
                                            .system(size: 20, weight: .medium)
                                        )
                                        .foregroundColor(Color("white-500"))

                                    Text(
                                        "We adapt your plan to better fit your performance. These changes will assist you for next week’s plan. Take a quick moment to review and confirm."
                                    )
                                    .lineLimit(4)
                                    .font(.system(size: 15))
                                    .foregroundColor(
                                        Color("white-700")
                                    )

                                    Button(action: {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        showReviewSheet = true
                                    }) {
                                        Text("Review Now")
                                            .font(.system(size: 15, weight: .medium))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 16)
                                            .background(
                                                RoundedRectangle(
                                                    cornerRadius: 16
                                                )
                                                .fill(Color.white)
                                            )
                                            .foregroundColor(.black)
                                    }
                                    .padding(.top, 20)
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        if showDynamicPlanCard {
                            dynamicPlanCard
                        }

                        sessionsSection

                        Divider()

                        let weekRuns = planSession.allRuns.filter {
                            calendar.isDate(
                                $0.date,
                                equalTo: vm.selectedDate,
                                toGranularity: .weekOfYear
                            )
                        }

                        // Hidden navigation link driven by state
                        NavigationLink(
                            destination: PlanScheduleView(),
                            isActive: $showPlanSchedule
                        ) {
                            EmptyView()
                        }
                        .hidden()

                        WeeklyPlanOverviewCard(
                            weekIndex: selectedWeekIndex + 1,
                            runs: weekRuns,
                            onSeeOverview: {
                                showPlanSchedule = true
                            },
                            showsButton: true
                        )

                        //                        planProgressCard
                        //                        weeklyProgressSection
                        //                        weeklyMetricsRow

                        Spacer(minLength: 0)
                    }
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.never)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .onAppear {
                // Use the plan already loaded into PlanSessionStore
                if let stored = planSession.generatedPlan {
                    // Always prioritize today's date if we have runs today
                    let today = Date()
                    let hasRunToday = stored.runs.contains { run in
                        calendar.isDate(run.date, inSameDayAs: today)
                    }

                    if hasRunToday {
                        vm.selectedDate = today
                        // Find which week contains today and set selectedWeekIndex accordingly
                        let weeks = calendarWeeks
                        for (index, week) in weeks.enumerated() {
                            if week.contains(where: {
                                calendar.isDate($0, inSameDayAs: today)
                            }) {
                                selectedWeekIndex = index
                                break
                            }
                        }
                    } else {
                        // Set selectedDate to the first run in the plan
                        if let firstDate = stored.runs.sorted(by: {
                            $0.date < $1.date
                        }).first?.date {
                            vm.selectedDate = firstDate
                            selectedWeekIndex = 0
                        }
                    }
                }
            }
            .onChange(of: planSession.generatedPlan) { newPlan in
                // React to plan changes (like from Scenario 2)
                guard let plan = newPlan else { return }

                let today = Date()
                let hasRunToday = plan.runs.contains { run in
                    calendar.isDate(run.date, inSameDayAs: today)
                }

                if hasRunToday {
                    vm.selectedDate = today
                    // Find which week contains today and set selectedWeekIndex accordingly
                    let weeks = calendarWeeks
                    for (index, week) in weeks.enumerated() {
                        if week.contains(where: {
                            calendar.isDate($0, inSameDayAs: today)
                        }) {
                            selectedWeekIndex = index
                            break
                        }
                    }
                } else {
                    // Set selectedDate to the first run in the plan
                    if let firstDate = plan.runs.sorted(by: {
                        $0.date < $1.date
                    }).first?.date {
                        vm.selectedDate = firstDate
                        selectedWeekIndex = 0
                    }
                }
            }
            .sheet(isPresented: $showReviewSheet) {
                // Build review rows from this week's runs so the sheet is ready for real data
                let allRuns = planSession.allRuns.sorted { $0.date < $1.date }
                let thisWeekRuns = allRuns.filter { run in
                    calendar.isDate(
                        run.date,
                        equalTo: Date(),
                        toGranularity: .weekOfYear
                    )
                }

                let reviewRows: [ReviewPlanSheet.ReviewSessionRow] =
                    thisWeekRuns.map { run in
                        // Session name
                        let sessionName = run.title

                        // Distance text (prefer actual distance, fallback to template target)
                        let distanceKm: String
                        if let actual = run.actual.distanceKm {
                            distanceKm = String(format: "%.1f", actual)
                        } else if let target = run.template.targetDistanceKm {
                            distanceKm = String(format: "%.1f", target)
                        } else {
                            distanceKm = "-"
                        }

                        // Average HR text
                        let heartRateText: String
                        if let hr = run.actual.avgHR {
                            heartRateText = String(Int(hr))
                        } else {
                            heartRateText = "-"
                        }

                        return ReviewPlanSheet.ReviewSessionRow(
                            session: sessionName,
                            distanceText: distanceKm,
                            heartRateText: heartRateText,
                            isDone: run.status == .completed
                        )
                    }

                NavigationStack {
                    ReviewPlanSheet(
                        onDismiss: {
                            showReviewSheet = false
                        },
                        onAdjust: {
                            // TEMP: reuse debug adapt for now
                            if let onboarding = OnboardingStore.load() {
                                let debugVM = PlanViewModel(data: onboarding)
                                debugVM.debugCompleteThisWeekAndAdapt()
                            }

                            // Reload shared plan so Home/Plan stay in sync
                            planSession.generatedPlan = UserDefaultsPlanStore.shared
                                .load()

                            // Hide the card after confirming
                            showAdjustCard = false
                            showReviewSheet = false
                        },
                        onKeepCurrent: {
                            // Keep existing plan, just hide the card
                            showAdjustCard = false
                            showReviewSheet = false
                        },
                        rows: reviewRows
                    )
                    .navigationTitle("Review Plan")
                    .navigationBarTitleDisplayMode(.inline)
                    .preferredColorScheme(.dark)
                }
                .presentationDragIndicator(.visible)
            }
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

    private var dynamicPlanCard: some View {
        SmallCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Text("Dynamic Plan")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color("white-500"))

                    Spacer()

                    Button(action: {
                        showDynamicPlanCard = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("white-500"))
                            .padding(4)
                    }
                    .buttonStyle(.plain)
                }

                Text(
                    "We will adjust your plan according to your weekly performance. This feature will equip you with the best fitted plan for your next run!"
                )
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color("white-700"))
                .fixedSize(horizontal: false, vertical: true)
            }
        }
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
                        let isToday = calendar.isDateInToday(date)

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
                                    isSelected
                                        ? .black
                                        : (isToday ? .red : Color("white-500"))
                                )
                                .background(
                                    Circle()
                                        .fill(
                                            isSelected
                                                ? Color("white-500") : .clear
                                        )
                                )

                            if let run = planSession.allRuns.first(where: {
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
        .onChange(of: selectedWeekIndex) { newIndex in
            let weeks = calendarWeeks
            guard weeks.indices.contains(newIndex) else { return }

            let days = weeks[newIndex]
            let currentWeekday = calendar.component(
                .weekday,
                from: vm.selectedDate
            )

            // Try to keep the same weekday when switching weeks; otherwise fall back to first day
            if let matchedDay = days.first(where: {
                calendar.component(.weekday, from: $0) == currentWeekday
            }) {
                vm.selectedDate = matchedDay
            } else if let firstDay = days.first {
                vm.selectedDate = firstDay
            }
        }
    }

    // Weeks from first plan week to last plan week, each exactly 7 days.
    // No pre-plan weeks → no empty calendar before your plan.
    private var calendarWeeks: [[Date]] {
        let runs = planSession.allRuns.sorted { $0.date < $1.date }

        guard let firstRunDate = runs.first?.date,
            let lastRunDate = runs.last?.date
        else {
            return []
        }

        // Compute week boundaries and force them to start on Monday
        guard
            let rawStart = calendar.dateInterval(
                of: .weekOfYear,
                for: firstRunDate
            )?.start,
            let rawEnd = calendar.dateInterval(
                of: .weekOfYear,
                for: lastRunDate
            )?.start
        else {
            return []
        }

        // Shift both to Monday
        let startOfFirstWeek =
            calendar.nextDate(
                after: rawStart,
                matching: DateComponents(weekday: 2),
                matchingPolicy: .nextTimePreservingSmallerComponents
            ) ?? rawStart
        let startOfLastWeek =
            calendar.nextDate(
                after: rawEnd,
                matching: DateComponents(weekday: 2),
                matchingPolicy: .nextTimePreservingSmallerComponents
            ) ?? rawEnd

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
        case .base, .endurance:
            return "Endurance Plan"
        case .speed:
            return "Speed Plan"
        default:
            return "Your Plan"
        }
    }

    // MARK: - Sessions List

    private var sessionsSection: some View {
        let sessions = planSession.allRuns
            .filter { calendar.isDate($0.date, inSameDayAs: vm.selectedDate) }
            .sorted { $0.date < $1.date }

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

    private func sendRunToWatch(_ run: ScheduledRun) {
        // Derive a simple recommended pace from the template if possible
//        let recPace: String
//        if let duration = run.template.targetDurationSec,
//            let distance = run.template.targetDistanceKm,
//            distance > 0
//        {
//            let secPerKm = Double(duration) / distance
//            let minutes = Int(secPerKm) / 60
//            let seconds = Int(secPerKm) % 60
//            recPace = String(format: "%d:%02d /km", minutes, seconds)
//        } else {
//            recPace = "Easy"
//        }

        let plan = RunningPlan(from: run)
        print("[HomeView] Sending plan to watch for run id: \(run.id)")
        syncService.sendPlanToWatchOS(plan: plan)
    }
}

#Preview("HomeView") {
    // Lightweight preview setup
    let planSession = PlanSessionStore(
        planStore: UserDefaultsPlanStore.shared
    )
    let syncService = SyncService()

    NavigationStack {
        HomeView()
            .background(Color("black-500"))
            .preferredColorScheme(.dark)
    }
    .environmentObject(planSession)
    .environmentObject(syncService)
}
