import SwiftUI

// Features/Home/HomeView.swift
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var selectedDayIndex: Int = 0

    // Simple mocked week data to match the quick UI mock
    private let week: [DayItem] = [
        .init(label: "MON", date: "18", hasRun: true),
        .init(label: "TUE", date: "19", hasRun: false),
        .init(label: "WED", date: "20", hasRun: false),
        .init(label: "THU", date: "21", hasRun: false),
        .init(label: "FRI", date: "22", hasRun: true, isCircled: true),
        .init(label: "SAT", date: "23", hasRun: false),
        .init(label: "SUN", date: "24", hasRun: true)
    ]

    var body: some View {
        VStack(spacing: 24) {
            // Header with a calendar button
            HStack {
                Spacer()
                Button(action: { /* open calendar */ }) {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .padding(12)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 4)

            // Week strip (non‑scrolling)
            WeekStrip(week: week, selectedIndex: $selectedDayIndex)
                .padding(.horizontal)

            Spacer(minLength: 8)

            // Center content – Rest Day card
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 96, height: 96)
                    Image(systemName: "clock")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(.primary)
                }

                Text("Rest Day")
                    .font(.title.bold())

                Text("Rest days are where the real gains happen. Don't skip your day off!")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                Button("Reset App") {
                    router.reset()
                }
            }

            Spacer()
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Dashboard")
    }
}

// MARK: - Small helper views
private struct WeekStrip: View {
    let week: [DayItem]
    @Binding var selectedIndex: Int

    var body: some View {
        HStack(spacing: 24) {
            ForEach(week.indices, id: \.self) { i in
                DayPill(day: week[i], isSelected: i == selectedIndex)
                    .onTapGesture { selectedIndex = i }
            }
        }
    }
}

private struct DayPill: View {
    let day: DayItem
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(day.label)
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            ZStack {
                if isSelected {
                    Circle()
                        .strokeBorder(Color.primary, lineWidth: 2)
                        .frame(width: 28, height: 28)
                }
                Text(day.date)
                    .font(.subheadline.weight(.semibold))
            }

            Circle()
                .fill(day.hasRun ? Color.green.opacity(0.9) : Color.secondary.opacity(0.4))
                .frame(width: 6, height: 6)
                .opacity(day.hasRun || isSelected ? 1 : 0.6)
        }
        .frame(minWidth: 30)
    }
}

private struct QuickActionIcon: View {
    let systemName: String
    let title: String
    var isActive: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: systemName)
                .font(.title3)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(radius: isActive ? 8 : 0, y: isActive ? 2 : 0)
                )
            Text(title)
                .font(.caption2)
                .foregroundStyle(isActive ? .primary : .secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct DayItem: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let date: String
    var hasRun: Bool = false
    var isCircled: Bool = false
}

#Preview {
    NavigationStack { HomeView() }
        .environmentObject(AppRouter())
}
