import SwiftUI

struct DaysPerWeekStepView: View {
    let onContinue: (Int) -> Void

    @State private var selectedDays = 2

    private let daysOptions = [2, 3, 4, 5, 6]

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                OnboardingHeaderQuestion(question: "What is your goal?", caption: "Help Coursa determine the best plan for you based on your goals.")
                    .padding(.bottom, 24)


                LazyVStack(spacing: 12) {
                    ForEach(daysOptions, id: \.self) { days in
                        Button(action: {
                            onContinue(days)
                        }) {
                            HStack {
                                Text("\(days) days")
                                    .font(.body)
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
            .padding(24)
        }
        .background(Color("black-500"))
    }
}

#Preview {
    DaysPerWeekStepView { _ in }
}
