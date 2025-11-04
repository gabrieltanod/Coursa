import SwiftUI

// Features/Home/HomeView.swift
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        VStack(spacing: 20) {
            Text("🏠 Home View")
                .font(.title.bold())

            Button("View My Plan") {
                if let data = OnboardingStore.load() {
                    router.path.append(Route.plan(data))
                }
            }

            Button("Reset App") {
                router.reset()
            }
            .tint(.red)
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Home")
    }
}

#Preview {
    HomeView()
}
