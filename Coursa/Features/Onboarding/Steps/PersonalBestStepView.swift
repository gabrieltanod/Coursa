import SwiftUI

struct PersonalBestStepView: View {
    let onContinue: (Double?, String?) -> Void
    
    @State private var distanceKm = ""
    @State private var durationText = ""
    
    private var isValid: Bool {
        !distanceKm.isEmpty && !durationText.isEmpty &&
        Double(distanceKm) != nil && isValidTimeFormat(durationText)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("What's your personal best?")
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Form {
                Section {
                    HStack {
                        Text("Distance (km)")
                        Spacer()
                        TextField("5.0", text: $distanceKm)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Duration (hh:mm:ss)")
                        Spacer()
                        TextField("00:25:30", text: $durationText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                    }
                } header: {
                    Text("Leave blank if you don't have a personal best")
                        .font(.caption)
                }
            }
            
            Spacer()
            
            Button("Continue") {
                let distance = distanceKm.isEmpty ? nil : Double(distanceKm)
                let duration = durationText.isEmpty ? nil : durationText
                onContinue(distance, duration)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isValid && !distanceKm.isEmpty && !durationText.isEmpty)
            .padding(.horizontal)
        }
    }
    
    private func isValidTimeFormat(_ time: String) -> Bool {
        let components = time.split(separator: ":")
        return components.count >= 2 && components.allSatisfy { Int($0) != nil }
    }
}

#Preview {
    PersonalBestStepView { _, _ in }
}
