//
//  ChoosePlanStepView.swift
//  Coursa
//
//  Created by Zikar Nurizky on 29/10/25.
//

import SwiftUI

struct ChoosePlanStepView: View {
    let onContinue: (Plan) -> Void

    @State private var selectedPlan: Plan?

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text("Choose your training plan")
                    .font(.title2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 40)
                    .foregroundStyle(Color("white-500"))

                LazyVStack(spacing: 12) {
                    ForEach(Plan.allCases) { plan in
                        Button(action: {
                            selectedPlan = plan
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(plan.rawValue)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(Color("white-500"))

                                    Text(planDescription(for: plan))
                                        .font(.caption)
                                        .foregroundColor(Color("white-500"))
                                        .multilineTextAlignment(.leading)
                                }

                                Spacer()
                                
                                Label("", systemImage: "chevron.right")

                                if selectedPlan == plan {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding()
                            .background(
                                selectedPlan == plan
                                    ? Color.blue.opacity(0.1)
                                    : Color("black-400")
                            )
                            .cornerRadius(12)
                        }
                        .contentShape(Rectangle())
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button("Continue") {
                if let plan = selectedPlan {
                    onContinue(plan)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedPlan == nil)
            .padding(.horizontal)
        }
        .background(Color("black-500"))
    }

    private func planDescription(for plan: Plan) -> String {
        switch plan {
        case .baseBuilder:
            return "Build a solid running foundation"
        case .endurance:
            return "Improve your endurance"
        case .speed:
            return "kenceng laik useynbold"
        case .halfMarathonPrep:
            return "Prepare for half marathon distance"
        }
    }
}

#Preview {
    ChoosePlanStepView { _ in }
}
