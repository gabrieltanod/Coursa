import SwiftUI

struct PersonalInfoStepView: View {
    let onContinue: (PersonalInfo) -> Void
    
    @State private var age = ""
    @State private var gender = ""
    @State private var weightKg = ""
    @State private var heightCm = ""
    
    private var isValid: Bool {
        !age.isEmpty && !gender.isEmpty && !weightKg.isEmpty && !heightCm.isEmpty &&
        Int(age) != nil && Double(weightKg) != nil && Double(heightCm) != nil
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Tell us about yourself")
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Form {
                Section {
                    HStack {
                        Text("Age")
                        Spacer()
                        TextField("25", text: $age)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Gender")
                        Spacer()
                        TextField("Male/Female/Other", text: $gender)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                    }
                    
                    HStack {
                        Text("Weight (kg)")
                        Spacer()
                        TextField("70.0", text: $weightKg)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Height (cm)")
                        Spacer()
                        TextField("175.0", text: $heightCm)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
            }
            
            Spacer()
            
            Button("Continue") {
                let personalInfo = PersonalInfo(
                    age: Int(age) ?? 0,
                    gender: gender,
                    weightKg: Double(weightKg) ?? 0.0,
                    heightCm: Double(heightCm) ?? 0.0
                )
                onContinue(personalInfo)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isValid)
            .padding(.horizontal)
        }
    }
}

#Preview {
    PersonalInfoStepView { _ in }
}

