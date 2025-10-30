import SwiftUI

struct PersonalBestStepView: View {
    let onContinue: (Double?, String?) -> Void

    @State private var selectedHour = 0
    @State private var selectedMinute = 0
    @State private var selectedSecond = 0
    @State private var distanceKm = ""
    @State private var durationText = ""
    @State private var showDurationWheel: Bool = false

    let hours = Array(0...23)
    let minutes = Array(0...59)
    let seconds = Array(0...59)

    private var isValid: Bool {
        !distanceKm.isEmpty && !durationText.isEmpty
            && Double(distanceKm) != nil && isValidTimeFormat(durationText)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                OnboardingHeaderQuestion(
                    question: "Your personal best",
                    caption: ""
                )
            }

            Group {
                Text("Fill in your ")
                    + Text("current PB")
                    .foregroundStyle(Color("green-500"))
                    + Text(" to determine your current performance.")
            }
            .foregroundStyle(Color("white-800"))

            HStack(spacing: 8) {
                Button(action: {
                    distanceKm = "3"
                }) {
                    Text("🏃🏿‍♂️ 3K")
                        .foregroundStyle(Color("white-500"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .cornerRadius(20)
                        .background(
                            distanceKm == "3"
                                ? Color("black-200") : Color("black-400")
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color("grey-70"), lineWidth: 1.5)
                        )
                        .cornerRadius(20)
                }

                Button(action: {
                    distanceKm = "5"
                }) {
                    Text("👏 5K")
                        .foregroundStyle(Color("white-500"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .cornerRadius(20)
                        .background(
                            distanceKm == "5"
                                ? Color("black-200") : Color("black-400")
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color("grey-70"), lineWidth: 1.5)
                        )
                        .cornerRadius(20)
                }

                Button(action: {
                    distanceKm = "10"
                }) {
                    Text("🔥 10K")
                        .foregroundStyle(Color("white-500"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .cornerRadius(20)
                        .background(
                            distanceKm == "10"
                                ? Color("black-200") : Color("black-400")
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color("grey-70"), lineWidth: 1.5)
                        )
                        .cornerRadius(20)

                }
                Spacer()
            }
            .padding(.vertical, 28)

            Button(action: { showDurationWheel = true }) {
                HStack {
                    if selectedHour != 0 && selectedMinute != 0
                        && selectedSecond != 0
                    {
                        Text(
                            "\(selectedHour)h : \(String(format: "%02d", selectedMinute))m : \(String(format: "%02d", selectedSecond))s"
                        )
                        .font(.body)
                        .font(.custom("Helvetica Neue", size: 22))
                        .fontWeight(.regular)
                        .foregroundStyle(Color("white-500"))
                    } else if selectedMinute != 0 && selectedSecond != 0 {
                        Text(
                            "\(String(format: "%02d", selectedMinute))m : \(String(format: "%02d", selectedSecond))s"
                        )
                        .font(.body)
                        .font(.custom("Helvetica Neue", size: 22))
                        .fontWeight(.regular)
                        .foregroundStyle(Color("white-500"))
                    } else if selectedSecond != 0{
                        Text("\(String(format: "%02d", selectedSecond))s")
                            .font(.body)
                            .font(.custom("Helvetica Neue", size: 22))
                            .fontWeight(.regular)
                            .foregroundStyle(Color("white-500"))
                    } else {
                        Text("Duration")
                            .font(.body)
                            .font(.custom("Helvetica Neue", size: 22))
                            .fontWeight(.regular)
                            .foregroundStyle(Color("white-500"))
                    }
                    Spacer()
                }
                .customFrameModifier()
                .contentShape(Rectangle())  // This makes the whole area of HStack tappable
            }
            .buttonStyle(.plain)

            Spacer()

            Button("Continue") {
                let distance = distanceKm.isEmpty ? nil : Double(distanceKm)
                let duration = durationText.isEmpty ? nil : durationText
                onContinue(distance, duration)
            }
            .buttonStyle(CustomButtonStyle())
            .disabled(!isValid && !distanceKm.isEmpty && !durationText.isEmpty)
        }
        .padding(24)
        .background(Color("black-500"))
        .sheet(
            isPresented: $showDurationWheel,
            content: {
                VStack {
                    HStack(spacing: 4) {
                        Picker("Hour", selection: $selectedHour) {
                            ForEach(hours, id: \.self) { hour in
                                Text("\(hour)h")
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 60)
                        .onChange(of: selectedHour) { _ in
                            durationText =
                                "\(selectedHour):\(String(format: "%02d", selectedMinute)):\(String(format: "%02d", selectedSecond))"
                        }

                        Text(":")

                        Picker("Minute", selection: $selectedMinute) {
                            ForEach(minutes, id: \.self) { min in
                                Text(String(format: "%02dm", min))
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 100)
                        .onChange(of: selectedMinute) { _ in
                            durationText =
                                "\(selectedHour):\(String(format: "%02d", selectedMinute)):\(String(format: "%02d", selectedSecond))"
                        }

                        Text(":")

                        Picker("Second", selection: $selectedSecond) {
                            ForEach(seconds, id: \.self) { sec in
                                Text(String(format: "%02ds", sec))
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 60)
                        .onChange(of: selectedSecond) { _ in
                            durationText =
                                "\(selectedHour):\(String(format: "%02d", selectedMinute)):\(String(format: "%02d", selectedSecond))"
                        }
                    }
                    .labelsHidden()

                    if selectedHour != 0 && selectedMinute != 0
                        && selectedSecond != 0
                    {
                        Text(
                            "\(selectedHour)h : \(String(format: "%02d", selectedMinute))m : \(String(format: "%02d", selectedSecond))s"
                        )
                        .font(.title2)
                        .padding(.top)
                    } else if selectedMinute != 0 && selectedSecond != 0 {
                        Text(
                            "\(String(format: "%02d", selectedMinute))m : \(String(format: "%02d", selectedSecond))s"
                        )
                        .font(.title2)
                        .padding(.top)
                    } else {
                        Text("\(String(format: "%02d", selectedSecond))s")
                            .font(.title2)
                            .padding(.top)
                    }

                }
                .presentationDetents([.medium])
                .padding(24)
            }
        )
    }

    private func isValidTimeFormat(_ time: String) -> Bool {
        let components = time.split(separator: ":")
        return components.count >= 2 && components.allSatisfy { Int($0) != nil }
    }
}

#Preview {
    PersonalBestStepView { _, _ in }
}
