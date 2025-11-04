import SwiftUI

struct WhichDaysStepView: View {
    let onContinue: (Set<Int>) -> Void

    @State private var selectedDays: Set<Int> = []

    private let weekdays = Calendar.current.weekdaySymbols
    private let weekdayIndices = Array(1...7)  // Sunday = 1, Monday = 2, etc.

    var body: some View {
        VStack() {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 8) {
                    OnboardingHeaderQuestion(
                        question: "Which Days You’re Free to Run?",
                        caption:
                            "Space out your available days to ensure balanced rest  and training days."
                    )
                    
                    if selectedDays.count < 3 {
                        Text("Please select at least 3-4 days.")
                            .font(Font.custom("Helvetica Neue", size: 17))
                            .font(.body)
                            .fontWeight(.regular)
                            .foregroundStyle(Color("green-500"))
                    } else {
                        Text("Please select at least 3-4 days.")
                            .font(Font.custom("Helvetica Neue", size: 17))
                            .font(.body)
                            .fontWeight(.regular)
                            .foregroundStyle(Color("green-500"))
                            .opacity(0)
                    }
                }
                .padding(.bottom, 28)

                
                LazyVStack(spacing: 12) {
                    ForEach(Array(weekdayIndices.enumerated()), id: \.offset) {
                        index,
                        weekdayIndex in
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
                                    .font(.custom("Helvetica Neue", size: 22))
                                    .foregroundColor(
                                        (selectedDays.count >= 4 && !selectedDays.contains(weekdayIndex))
                                            ? Color("black-300")
                                            : Color("white-500")
                                    )

                                Spacer()

                                ZStack {
                                    // Fill respects the rounded shape; avoids overflow beyond border
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(selectedDays.contains(weekdayIndex) ? Color("white-500") : Color.clear)

                                    // Border drawn above the fill
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(Color("grey-70"), lineWidth: 1)

                                    if selectedDays.contains(weekdayIndex) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Color("black-500"))
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(width: 20, height: 20)
                            }
                            .padding()
                            .background(Color("black-400"))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color("grey-70"), lineWidth: 1.5)
                            )
                            .cornerRadius(20)
                        }
                        .contentShape(Rectangle())
                        .disabled(selectedDays.count >= 4 && !selectedDays.contains(weekdayIndex))
                    }
                }
            }
            Spacer()

            
            Button("Next") {
                onContinue(selectedDays)
            }
            .buttonStyle(CustomButtonStyle(isDisabled: selectedDays.count < 3))
        }
    }
}

#Preview {
    WhichDaysStepView { _ in }
}
