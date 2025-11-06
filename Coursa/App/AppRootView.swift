//
//  AppRootView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 24/10/25.
//

import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var router: AppRouter
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false

    @State private var showSplash = true

    var body: some View {
        ZStack {
            // --- Your existing routing below ---
            if router.didOnboard {
                if let existing = OnboardingStore.load() {
                    CoreTabView(onboardingData: existing)
                } else {
                    CoreTabView(onboardingData: OnboardingData())
                }
            } else {
                NavigationStack(path: $router.path) {
                    if hasSeenWelcome {
                        OnboardingFlowView { finishedData in
                            OnboardingStore.save(finishedData)
                            router.goToCoreApp() // swaps roots, no back button
                        }
                        .navigationDestination(for: Route.self) { route in
                            switch route {
                            case .plan(let data):
                                PlanView(vm: PlanViewModel(data: data))
                            case .home:
                                HomeView()
                            case .coreApp(let data):
                                CoreTabView(onboardingData: data)
                            }
                        }
                    } else {
                        WelcomeView {
                            hasSeenWelcome = true
                        }
                    }
                }
                .task {
                    if OnboardingStore.load() != nil {
                        router.didOnboard = true
                    }
                }
            }
            // --- Your existing routing above ---

            // Hard-coded splash overlay (blocks UI until dismissed)
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(999)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showSplash = false
                            }
                        }
                    }
            }
        }
    }
}

// Minimal, self-contained Welcome screen that matches your mock
private struct WelcomeView: View {
    var onNext: () -> Void

    var body: some View {
        ZStack {
            // Hero image
            Image("CoursaImages/OnboardRun")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                // Fallback if asset missing: dark background
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.2),
                            Color.black.opacity(0),
                            Color.black.opacity(0.15)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Subtle bottom gradient for text/button legibility
            LinearGradient(
                colors: [.clear, .black.opacity(0.85)],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .center, spacing: 8) {
                // Top spacer to push text down a bit like the mock
                Spacer().frame(height: 30)

                Text("Welcome to Coursa")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)

                Text("Join us on your endurance journey.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white.opacity(0.9))

                Spacer()

                // Bottom CTA
                Button(action: onNext) {
                    Text("Next")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: 350)
                        .padding(.vertical, 16)
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .accessibilityLabel("Next")

            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .preferredColorScheme(.dark)
        .navigationBarHidden(true)
    }
}

#Preview {
    
}
