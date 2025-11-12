//
//  AppRootView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 24/10/25.
//
import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            NavigationStack(path: $router.path) {
                ZStack {
                    if router.didOnboard {
                        if let existing = OnboardingStore.load() {
                            CoreTabView(onboardingData: existing)
                        } else {
                            CoreTabView(onboardingData: OnboardingData())
                        }
                    } else {
                        if hasSeenWelcome {
                            OnboardingFlowView { finishedData in
                                OnboardingStore.save(finishedData)
                                router.goToCoreApp()
                            }
                        } else {
                            WelcomeView {
                                hasSeenWelcome = true
                            }
                        }
                    }
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
            }
            .onAppear {
                // If we have onboarding data saved, skip onboarding on fresh launch
                if !router.didOnboard, OnboardingStore.load() != nil {
                    router.didOnboard = true
                }
            }

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
                            Color.black.opacity(0.15),
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
                }
                .buttonStyle(CustomButtonStyle(isDisabled: false))

            }
            .padding(.horizontal, 24)
//            .padding(.bottom, 24)
        }
        .preferredColorScheme(.dark)
        .navigationBarHidden(true)
    }
}

#Preview {
    AppRootView()
        .environmentObject(AppRouter())
        .preferredColorScheme(.dark)
}
