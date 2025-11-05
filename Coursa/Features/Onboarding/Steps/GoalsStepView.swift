import SwiftUI

struct GoalsStepView: View {
    let onGoalSelected: (Goal) -> Void

    var body: some View {
        VStack() {
            VStack(alignment: .leading) {
                OnboardingHeaderQuestion(question: "What is your goal?", caption: "Help Coursa determine the best plan for you based on your goals.")
                    .padding(.bottom, 40)

                LazyVStack(spacing: 12) {
                    ForEach(Goal.allCases) { goal in
                        Button(action: {
                            onGoalSelected(goal)
                        }) {
                            HStack {
                                Text(goal.rawValue)
                                    .font(.body)
                                    .font(.custom("Helvetica Neue", size: 22))
                                    .foregroundColor(Color("white-500"))

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color("white-500"))
                                    .font(.caption)
                            }
                            .customFrameModifier(isActivePage: false, isSelected: false)
                        }
                        .contentShape(Rectangle())
                    }
                }

                Spacer()
            }
            .padding(.top, 60)
            
            Button("Placeholder") {
            }
            .buttonStyle(CustomButtonStyle(isDisabled: true))
            .hidden()
        }
    }
}

#Preview {
    GoalsStepView { _ in }
}
