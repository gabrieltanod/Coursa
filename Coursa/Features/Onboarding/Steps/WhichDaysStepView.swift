import SwiftUI

struct WhichDaysStepView: View {
    let onContinue: (Set<Int>) -> Void

    @State private var selectedDays: Set<Int> = []

    private let weekdays = Calendar.current.weekdaySymbols
    private let weekdayIndices = Array(1...7)  // Sunday = 1, Monday = 2, etc.

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    OnboardingHeaderQuestion(
                        question: "Which Days You’re Free to Run?",
                        caption:
                            "Space out your available days to ensure balanced rest and training days."
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)

                    if selectedDays.count < 3 {
                        Text("Please select at least 3 days.")
                            .font(Font.custom("Helvetica Neue", size: 17))
                            .font(.body)
                            .fontWeight(.regular)
                            .foregroundStyle(Color("green-500"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 24)

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
                                    .foregroundColor(Color("white-500"))

                                Spacer()

                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color("grey-70"), lineWidth: 1)
                                    .frame(width: 20, height: 20)
                                    .overlay {
                                        if selectedDays.contains(weekdayIndex) {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(
                                                    Color("green-500")
                                                )
                                                .fontWeight(.semibold)
                                        } else {
                                            EmptyView()
                                        }
                                    }
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
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button("Next") {
                onContinue(selectedDays)
            }
            .buttonStyle(CustomButtonStyle())
            .disabled(selectedDays.isEmpty)
            .padding(.horizontal)
        }
        .background(Color("black-500"))
    }
}

#Preview {
    WhichDaysStepView { _ in }
}
