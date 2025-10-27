import SwiftUI

struct RecommendedPlanStepView: View {
    let recommendedPlan: Plan
    let onContinue: () -> Void
    let onChooseDifferent: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Recommended Plan")
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.top)
            
            VStack(spacing: 16) {
                Image(systemName: "star.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
                
                Text(recommendedPlan.rawValue)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Based on your goals and preferences, we recommend this training plan to help you achieve your objectives.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button("Looks good!") {
                    onContinue()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("Choose a different plan") {
                    onChooseDifferent()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    RecommendedPlanStepView(
        recommendedPlan: .baseBuilder,
        onContinue: {},
        onChooseDifferent: {}
    )
}
