//
//  PlanDetailView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 28/10/25.
//

import SwiftUI

struct PlanDetailView: View {
    let run: ScheduledRun
    @State private var isRunning = false
    @State private var didComplete = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    ZStack(alignment: .bottom) {
                        Image("CoursaImages/Running_Easy")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 260)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    colors: [.clear, .black.opacity(0.9)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        VStack(alignment: .center, spacing: 8) {
                            Text(run.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)

                            HStack(spacing: 12) {
                                if let dur = run.template.targetDurationSec {
                                    Label(Self.mmText(dur), systemImage: "clock")
                                }
                                if let z = run.template.targetHRZone {
                                    Label("HR Zone \(z.rawValue)", systemImage: "heart")
                                }
                                Label(run.template.focus.rawValue.capitalized, systemImage: "bolt")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.bottom, 20)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text(run.template.notes ?? "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut et massa mi. Aliquam in hendrerit urna. Pellentesque sit amet sapien fringilla, mattis ligula consectetur, ultrices mauris. Maecenas vitae mattis tellus. Nullam quis imperdiet augue.")
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.top, 20)

                        Spacer(minLength: 80)
                    }
                }
            }

            // Fixed bottom CTA
            VStack {
                Button {
                    isRunning.toggle()
                } label: {
                    Text(didComplete ? "View Summary" : (isRunning ? "Stop" : "Start Running"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal)
                }
                .padding(.bottom, 24)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color("black-500").ignoresSafeArea())
//        .preferredColorScheme(.dark)
    }

    private static func mmText(_ seconds: Int) -> String {
        let m = seconds / 60
        return "\(m) min"
    }
}
