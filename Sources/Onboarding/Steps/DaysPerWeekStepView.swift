import SwiftUI

struct DaysPerWeekStepView: View {
    let onContinue: (Int) -> Void
    
    @State private var selectedDays = 2
    
    private let daysOptions = [2, 3, 4, 5, 6]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How many days per week?")
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Spacer()
            
            LazyVStack(spacing: 12) {
                ForEach(daysOptions, id: \.self) { days in
                    Button(action: {
                        selectedDays = days
                    }) {
                        HStack {
                            Text("\(days) days")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedDays == days {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding()
                        .background(selectedDays == days ? Color.blue.opacity(0.1) : Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .contentShape(Rectangle())
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button("Continue") {
                onContinue(selectedDays)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
        }
    }
}

#Preview {
    DaysPerWeekStepView { _ in }
}

