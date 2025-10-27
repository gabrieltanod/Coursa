import SwiftUI

struct GoalsStepView: View {
    let onGoalSelected: (Goal) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("What's your main goal?")
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Spacer()
            
            LazyVStack(spacing: 12) {
                ForEach(Goal.allCases) { goal in
                    Button(action: {
                        onGoalSelected(goal)
                    }) {
                        HStack {
                            Text(goal.rawValue)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .contentShape(Rectangle())
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

#Preview {
    GoalsStepView { _ in }
}

