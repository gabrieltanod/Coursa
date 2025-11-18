import SwiftUI

struct WhichDaysStepView: View {
    let onContinue: (Set<Int>) -> Void

    @State private var selectedDays: Set<Int> = []

    private let weekdays = Calendar.current.weekdaySymbols
    private let weekdayIndices = Array(1...7)  // Sunday = 1, Monday = 2, etc.
    
    func makeColoredCaption() -> AttributedString {
        var string = AttributedString("Choose the days that work best for you. We recommend 3-4 days of training as the most ideal.")

        if let range = string.range(of: "3-4 days") {
            var container = AttributeContainer()
            container.foregroundColor = Color("green-500")
            container.font = .custom("Helvetica Neue", size: 17)
            string[range].setAttributes(container)
        }

        return string
    }

    var body: some View {
        VStack() {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 8) {
                    OnboardingHeaderQuestion(
                        question: "When do you usually run?",
                        caption: makeColoredCaption()
                    )
                }
                .padding(.bottom, 20)

                
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
                                    .font(.custom("Helvetica Neue", size: 17))
                                    .foregroundColor(
                                        (selectedDays.count >= 4 && !selectedDays.contains(weekdayIndex))
                                            ? Color("black-400")
                                            : Color("white-500")
                                    )

                                Spacer()

                                ZStack {
                                    // Fill respects the rounded shape; avoids overflow beyond border
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(selectedDays.contains(weekdayIndex) ? Color("white-500") : Color.clear)

                                    // Border drawn above the fill
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(selectedDays.count >= 4 ? Color("grey-70") : Color("grey-10") , lineWidth: 1)

                                    if selectedDays.contains(weekdayIndex) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Color("black-500"))
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(width: 20, height: 20)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                            .background(Color("black-450"))
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
            .disabled(selectedDays.count < 3)
        }
    }
}

#Preview {
    WhichDaysStepView { _ in }
}
