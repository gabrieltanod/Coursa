import SwiftUI

struct PersonalBestStepView: View {
    let onContinue: (Double?, String?) -> Void
    
    @State private var selectedHour = -1
    @State private var selectedMinute = -1
    @State private var selectedSecond = -1
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
        VStack(alignment: .leading, spacing: 27) {
            VStack(alignment: .leading) {
                OnboardingHeaderQuestion(
                    question: "What is your best run?",
                    caption: "Fill the furthest distance you ran in the last 1–3 months and your best time. If you don't have a record yet, try your first 3K!"
                )
            }
            
            HStack(spacing: 8) {
                Button(action: {
                    distanceKm = "3"
                }) {
                    Text("3K")
                        .foregroundStyle(Color("white-500"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .cornerRadius(20)
                        .background(
                            distanceKm == "3"
                            ? Color("black-200") : Color("black-400")
                        )
                        .overlay(
                            Group {
                                if distanceKm == "3"{
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("white-500"), lineWidth: 1.5)
                                }
                            }
                        )
                        .cornerRadius(20)
                }
                
                Button(action: {
                    distanceKm = "5"
                }) {
                    Text("5K")
                        .foregroundStyle(Color("white-500"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .cornerRadius(20)
                        .background(
                            distanceKm == "5"
                            ? Color("black-200") : Color("black-400")
                        )
                    
                        .overlay(
                            Group {
                                if distanceKm == "5"{
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("white-500"), lineWidth: 1.5)
                                }
                            }
                        )
                        .cornerRadius(20)
                }
                
                Button(action: {
                    distanceKm = "10"
                }) {
                    Text("10K")
                        .foregroundStyle(Color("white-500"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .cornerRadius(20)
                        .background(
                            distanceKm == "10"
                            ? Color("black-200") : Color("black-400")
                        )
                        .overlay(
                            Group {
                                if distanceKm == "10"{
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("white-500"), lineWidth: 1.5)
                                }
                            }
                        )
                        .cornerRadius(20)
                    
                }
                Spacer()
            }
            
            Button(action: { showDurationWheel = true }) {
                HStack {
                    if selectedHour > 0
                    {
                        Text(
                            "\(selectedHour)h : \(String(format: "%02d", selectedMinute))m : \(String(format: "%02d", selectedSecond))s"
                        )
                        .font(.body)
                        .font(.custom("Helvetica Neue", size: 22))
                        .fontWeight(.regular)
                        .foregroundStyle(Color("white-500"))
                    } else if selectedMinute > 0 {
                        Text(
                            "\(String(format: "%02d", selectedMinute))m : \(String(format: "%02d", selectedSecond))s"
                        )
                        .font(.body)
                        .font(.custom("Helvetica Neue", size: 22))
                        .fontWeight(.regular)
                        .foregroundStyle(Color("white-500"))
                    }
                    else if selectedSecond > 0 {
                        Text("\(String(format: "%02d", selectedSecond))s")
                            .font(.body)
                            .font(.custom("Helvetica Neue", size: 22))
                            .fontWeight(.regular)
                            .foregroundStyle(Color("white-500"))
                    } else if selectedHour <= 0 && selectedMinute <= 0 && selectedSecond <= 0{
                        Text("Duration")
                            .font(.body)
                            .font(.custom("Helvetica Neue", size: 22))
                            .fontWeight(.regular)
                            .foregroundStyle(Color("white-500"))
                    }
                    Spacer()
                }
                .customFrameModifier(isActivePage: false, isSelected: false)
                .contentShape(Rectangle())  // This makes the whole area of HStack tappable
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Button("Next") {
                let distance = distanceKm.isEmpty ? nil : Double(distanceKm)
                let duration = durationText.isEmpty ? nil : durationText
                onContinue(distance, duration)
            }
            .buttonStyle(
                CustomButtonStyle(
                    isDisabled: !isValid
                )
            )
            .disabled(!isValid)
        }
        .sheet(
            isPresented: $showDurationWheel,
            content: {
                NavigationStack {
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
                            .onAppear {
                                if selectedHour < 0 {
                                    selectedHour = 1
                                }
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
                            .onAppear {
                                if selectedMinute < 0 {
                                    selectedMinute = 1
                                }
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
                            .onAppear {
                                if selectedSecond < 0 {
                                    selectedSecond = 1
                                }
                            }
                        }
                        .labelsHidden()
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showDurationWheel = false
                            } label: {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color("white-500"))
                            }
                        }
                    }
                    .presentationDetents([.medium])
                    .padding(24)
                }
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
