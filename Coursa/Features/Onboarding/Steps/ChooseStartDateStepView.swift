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
                DatePicker(
                    "Start Date",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Text("Selected: \(selectedDate, style: .date)")
                    .font(.body)
                    .foregroundColor(.secondary)
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
