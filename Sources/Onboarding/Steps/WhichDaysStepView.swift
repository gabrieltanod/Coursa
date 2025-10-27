import SwiftUI

struct WhichDaysStepView: View {
    let onContinue: (Set<Int>) -> Void
    
    @State private var selectedDays: Set<Int> = []
    
    private let weekdays = Calendar.current.weekdaySymbols
    private let weekdayIndices = Array(1...7) // Sunday = 1, Monday = 2, etc.
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Which days of the week?")
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Spacer()
            
            LazyVStack(spacing: 12) {
                ForEach(Array(weekdayIndices.enumerated()), id: \.offset) { index, weekdayIndex in
                    Button(action: {
                        if selectedDays.contains(weekdayIndex) {
                            selectedDays.remove(weekdayIndex)
                        } else {
                            selectedDays.insert(weekdayIndex)
                        }
                    }) {
                        HStack {
                            Text(weekdays[index])
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedDays.contains(weekdayIndex) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding()
                        .background(selectedDays.contains(weekdayIndex) ? Color.blue.opacity(0.1) : Color(.systemGray6))
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
            .disabled(selectedDays.isEmpty)
            .padding(.horizontal)
        }
    }
}

#Preview {
    WhichDaysStepView { _ in }
}

