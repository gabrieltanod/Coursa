import SwiftUI

struct GoalsStepView: View {
    let onGoalSelected: (Goal) -> Void

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                OnboardingHeaderQuestion(question: "What is your goal?", caption: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
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
                            .padding()
                            .background(Color("black-400"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color("grey-70"), lineWidth: 1.5)
                            )
                            .cornerRadius(20)
                        }
                        .contentShape(Rectangle())
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .background(Color("black-500"))
        }
    }
}

#Preview {
    GoalsStepView { _ in }
}
