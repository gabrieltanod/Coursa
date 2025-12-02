//
//  StatisticsView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 18/11/25.
//

import SwiftUI

struct StatisticsView: View {

    @StateObject private var viewModel: StatisticsViewModel
    
    // Allow injection for previews/tests
    init(viewModel: StatisticsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

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
                    
                    if let progressData = viewModel.planProgress {
                        PlanProgressCard(
                            title: progressData.title,
                            progress: progressData.progress,
                            completedKm: progressData.completedKm,
                            targetKm: progressData.targetKm
                        )
                        .padding(.top, 20)
                    }
                    
                    if let metrics = viewModel.weeklyMetrics {
                        weeklyMetricsRow(metrics: metrics)
                    }
                    
                    recentActivitySection
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
        .navigationTitle("Statistics")
        .foregroundStyle(Color.white)
        .sheet(isPresented: $viewModel.showAerobicInfo) {
            aerobicInfoSheet
        }
    }

    private func weeklyMetricsRow(metrics: WeeklyMetricsData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                MetricDetailCard(
                    title: "Average Pace",
                    primaryValue: metrics.thisWeekPace,
                    secondaryValue: metrics.lastWeekPace,
                    footer: "Vs Last Week",
                    comparisonTrend: metrics.paceTrend
                )

                MetricDetailCard(
                    title: "Aerobic Time",
                    primaryValue: metrics.thisWeekAerobic,
                    secondaryValue: metrics.lastWeekAerobic,
                    footer: "Vs Last Week",
                    showInfoButton: true,
                    onInfoTapped: { viewModel.showAerobicInfo = true },
                    comparisonTrend: metrics.aerobicTrend
                )
            }

            if !metrics.summaryMessage.isEmpty {
                SummaryCard(message: metrics.summaryMessage)
            }
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Activity")
                    .font(.custom("Helvetica Neue", size: 17, relativeTo: .body))
                    .fontWeight(.medium)
                    .foregroundStyle(Color("white-500"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                
                Spacer()
                
                if viewModel.hasRecentActivity {
                    NavigationLink {
                        RunHistoryView()
                    } label: {
                        Text("See All")
                            .font(.custom("Helvetica Neue", size: 15, relativeTo: .callout))
                            .fontWeight(.light)
                            .foregroundStyle(Color("white-500"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                    }
                }
            }
            
            if !viewModel.hasRecentActivity {
                VStack(spacing: 12) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 64, weight: .regular))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.9),
                                    Color.gray.opacity(0.7),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    Text("No Recent Activity")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Color("white-500"))
                }
                .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 379)
            } else {
                ForEach(viewModel.recentRuns) { run in
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

                            Text(
                                "This is the amount of time you spent in your aerobic zone (or Zone 2). During this time, your effort level is moderate, you can still speak in full sentences but you're working hard enough to feel a benefit."
                            )
                            .font(.system(size: 16))
                            .foregroundStyle(Color("white-700"))
                            .lineSpacing(4)

                            Text("Benefits")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color("white-500"))
                                .padding(.top, 8)

                            Text(
                                "Training here is the single best way to increase your stamina, boost your energy efficiency, and protect against injury."
                            )
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
                        viewModel.showAerobicInfo = false
                    }
                    .foregroundStyle(Color("green-500"))
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    let planSession = PlanSessionStore()
    #if DEBUG
        planSession.loadDebugSampleDataForStatistics()
    #endif

    return NavigationStack {
        StatisticsView(viewModel: StatisticsViewModel(planSession: planSession))
            .background(Color("black-500"))
            .preferredColorScheme(.dark)
    }
}
