import SwiftUI

struct ChooseStartDateStepView: View {
    let onFinish: (Date) -> Void
    
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("When do you want to start?")
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Spacer()
            
            VStack(spacing: 16) {
                
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button("Finish") {
                onFinish(selectedDate)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
        }
    }
}

#Preview {
    ChooseStartDateStepView { _ in }
}
