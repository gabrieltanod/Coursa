//
//  PlanDetailView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 28/10/25.
//

import SwiftUI

struct PlanDetailView: View {
    let run: ScheduledRun
    @Environment(\.dismiss) private var dismiss
    @State private var isRunning = false
    @State private var didComplete = false
    @State private var showingInfoSheet = false

    enum CountdownStep: Hashable {
        case idle
        case number(Int)
        case start

        var stateType: String {
            switch self {
            case .idle:
                return "idle"
            case .number(let n):
                // include the number so each numeric step has a unique id for transitions
                return "number_\(n)"
            case .start:
                return "start"
            }
        }
    }

    @State private var isCountingDown = false
    @State private var countdownStep: CountdownStep = .idle

    // Inside PlanDetailView struct
    @State private var showDuringRunView = false  // <--- ADD THIS

    @ObservedObject var syncService = SyncService.shared
    @State private var plan: RunningPlan?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color("black-500").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    GeometryReader { geo in
                        ZStack(alignment: .bottom) {
                            Image("CoursaImages/Running_Easy")
                                .resizable()
                                .scaledToFill()
                                .frame(
                                    width: geo.size.width,
                                    height: geo.size.height
                                )
                                .clipped()
                                .overlay(
                                    ZStack {
                                        overlayColor.opacity(0.55)
                                        LinearGradient(
                                            colors: [
                                                .clear, Color("black-500"),
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    }
                                )

                            VStack(alignment: .center) {
                                Text(formattedDate)
                                    .font(.custom("Helvetica Neue", size: 14))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.bottom, 11)

                                Text(run.title)
                                    .font(.custom("Helvetica Neue", size: 34))
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.bottom, 17)
                                metricsRow
                                    .padding(.bottom, 24)
                                SmallCard(backgroundColor: Color("black-300")) {
                                    HStack {
                                        Spacer()
                                        Text("You cannot begin this plan until its scheduled date.")
                                            .font(.custom("Helvetica Neue", size: 16))
                                            .fontWeight(.regular)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 24)
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.5)

                    // Body content
                    VStack(alignment: .leading, spacing: 24) {
                        HStack(spacing: 8) {
                            SmallCard {
                                VStack(alignment: .leading) {
                                    Text("Keep conversational")
                                        .font(
                                            .custom("Helvetica Neue", size: 14)
                                        )
                                        .foregroundColor(.white)

                                    HStack(alignment: .center, spacing: 5) {
                                        Text("pace for")
                                            .font(
                                                .custom(
                                                    "Helvetica Neue",
                                                    size: 14
                                                )
                                            )
                                            .foregroundColor(.white)

                                        Button {
                                            showingInfoSheet.toggle()
                                        } label: {
                                            Image(systemName: "info.circle")
                                                .font(
                                                    .custom(
                                                        "Helvetica Neue",
                                                        size: 12
                                                    )
                                                )
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                Spacer()

                                Text(conversationalPaceMinutesText)
                                    .font(.custom("Helvetica Neue", size: 28))
                                    .foregroundColor(Color("green-500"))
                                    .bold()
                            }

                            SmallCard {
                                Text("Recommended Pace")
                                    .lineLimit(2, reservesSpace: true)
                                    .font(.custom("Helvetica Neue", size: 16))
                                    .foregroundColor(.white)

                                Spacer()

                                Text("7:30/km")
                                    .font(.custom("Helvetica Neue", size: 28))
                                    .foregroundColor(Color("green-500"))
                                    .bold()
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.custom("Helvetica Neue", size: 20))
                                .foregroundColor(.white)

                            Text(descriptionText)
                                .font(.custom("Helvetica Neue", size: 15))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 142)
            }

            if plan?.date == Date() {
                VStack {
                    Button("Let's go!") {
                        // 1. ✅ Clear previous summary so the sheet doesn't pop up immediately
                        syncService.summary = nil

                        startCountdownSequence()

                        if let plan = plan {
                            print("🚀 Starting run: \(plan.name)")
                            syncService.sendPlanToWatchOS(plan: plan)
                            syncService.sendStartWorkoutCommand(planID: plan.id)
                        } else {
                            print("❌ No plan available to start.")
                        }
                    }
                    .buttonStyle(CustomButtonStyle(isDisabled: plan?.date != Date()))
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity)

            }
            
            if isCountingDown {
                Color("black-500")
                    .ignoresSafeArea()

                Group {
                    switch countdownStep {

                    case .idle:
                        EmptyView()

                    case .number(let num):
                        VStack(spacing: 32) {
                            Text("\(num)")
                                .font(.custom("Helvetica Neue", size: 96))
                                .bold()
                                .foregroundColor(Color("orange-500"))
                                .transition(.opacity.combined(with: .scale))
                                .id(num)

                            Text("Be Ready!")
                                .font(.custom("Helvetica Neue", size: 30))
                                .bold()
                                .foregroundColor(Color("orange-500"))
                        }

                    case .start:
                        Text("START!")
                            .font(.custom("Helvetica Neue", size: 64))
                            .bold()
                            .foregroundColor(Color("green-500"))
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .id(countdownStep.stateType)
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showingInfoSheet) {
            RunningNotesModalView()
                .presentationDetents([.fraction(0.35)])
        }
        .fullScreenCover(isPresented: $showDuringRunView) {
            DuringRunView(syncService: syncService, plan: plan)
        }
        .onChange(of: syncService.summary) { oldValue, newValue in
            if newValue != nil {
                print("iOS: 🏁 Summary received! Closing 'During Run' screen...")
                showDuringRunView = false
            }
        }
        .onAppear {
            syncService.connect()

            self.plan = RunningPlan(
                id: run.id,
                date: run.date,
                name: run.title,
                kind: run.template.kind,
                targetDuration: run.template.targetDurationSec,
                targetDistance: run.template.targetDistanceKm,
                targetHRZone: run.template.targetHRZone,
                recPace: nil
            )
        }
    }

    // Metrics row under title
    private var metricsRow: some View {
        HStack(spacing: 20) {
            if plan?.kind == .maf {
                if let duration = run.template.targetDurationSec {
                    Label {
                        Text("\(duration/60) min")
                    } icon: {
                        Image(systemName: "clock.fill")
                    }
                }
            } else {
                if let distance = run.template.targetDistanceKm {
                    Label {
                        Text("\(Int(distance)) km")
                    } icon: {
                        Image("distance-icon")
                    }
                }
            }
            Text("|")
            if let z = run.template.targetHRZone {
                Label {
                    Text("Heart Rate Zone \(z.rawValue)")

                } icon: {
                    Image(systemName: "heart.fill")
                }
            }
        }
        .font(.custom("Helvetica Neue", size: 15))
        .foregroundColor(Color("white-500"))
        .labelStyle(.titleAndIcon)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: run.date)
    }

    private var descriptionText: String {
        if let notes = run.template.notes, !notes.isEmpty {
            return notes
        } else {
            return
                "This session is designed to support your endurance with controlled effort and clear structure. Run at a comfortable pace, stay relaxed, and focus on finishing strong."
        }
    }

    // Color tint for header image based on run kind
    private var overlayColor: Color {
        switch run.template.kind {
        case .easy:
            return Color("easy")
        case .long:
            return Color("long")
        case .maf:
            return Color("maf")
        case .tempo:
            return Color("maf")
        case .intervals:
            return Color("maf")
        case .recovery:
            return Color("easy")
        }
    }

    private static func mmText(_ seconds: Int) -> String {
        let m = seconds / 60
        return "\(m) min"
    }

    private var conversationalPaceMinutesText: String {
        if let dur = run.template.targetDurationSec {
            let m = dur / 60
            return "\(m) min"
        } else {
            return "-- min"
        }
    }

    func startCountdownSequence() {
        // Do countdown on a Task to allow async sleeps without blocking UI
        Task {
            // begin countdown UI
            await MainActor.run {
                isCountingDown = true
                countdownStep = .idle
            }

            // 3
            await MainActor.run { withAnimation { countdownStep = .number(3) } }
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            // 2
            await MainActor.run { withAnimation { countdownStep = .number(2) } }
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            // 1
            await MainActor.run { withAnimation { countdownStep = .number(1) } }
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            // START!
            await MainActor.run { withAnimation { countdownStep = .start } }
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            // finish countdown and start run
            await MainActor.run {
                isCountingDown = false
                countdownStep = .idle
                isRunning = true
            }

            showDuringRunView = true
        }
    }
}

#Preview("Plan Detail") {
    let sampleTemplate = RunTemplate(
        name: "Easy Run",
        kind: .maf,
        focus: .base,
        targetDurationSec: 1800,
        targetDistanceKm: 3.0,
        targetHRZone: .z2,
        notes:
            "This is a very long description that repeats. This is a very long description that repeats.This is a very long description that repeats. This is a very long description that repeats.This is a very long description that repeats. This is a very long description that repeats.This is a very long description that repeats. This is a very long description that repeats.This is a very long description that repeats. This is a very long description that repeats."
    )

    let sampleRun = ScheduledRun(
        date: Date(),
        template: sampleTemplate,
        status: .planned
    )

    return NavigationStack {
        PlanDetailView(run: sampleRun)
            .preferredColorScheme(.dark)
    }
}
