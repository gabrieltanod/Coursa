import SwiftUI

enum WhatToShow {
    case showDatePicker
    case showGenderPicker
    case showWeightPicker
    case showHeightPicker
}

struct PersonalInfoStepView: View {
    let onContinue: (PersonalInfo) -> Void
    
    @State private var date: Date = Date()
    @State private var gender = ""
    @State private var weightKg = ""
    @State private var heightCm = ""
    @State private var showDatePicker: Bool = false
    @FocusState private var focusedField: Field?
    
    private enum Field: Hashable {
        case weight
        case height
    }
    
    private var isValid: Bool {
        !gender.isEmpty && !weightKg.isEmpty && !heightCm.isEmpty
        && Double(weightKg) != nil && Double(heightCm) != nil
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            VStack (alignment: .leading, spacing: 12){
                Text("Tell us about yourself")
                    .font(.title2)
                    .font(.custom("Helvetica Neue", size: 22))
                    .fontWeight(.medium)
                    .foregroundStyle(Color("white-500"))
                    .padding(.vertical, 24)
                
                // DoB Button
                Button(action: {
                    showDatePicker = true
                }) {
                    HStack {
                        Text("Date of Birth")
                            .font(.body)
                            .font(.custom("Helvetica Neue", size: 22))
                            .foregroundColor(Color("white-500"))
                        Spacer()
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .font(.custom("Helvetica Neue", size: 18))
                            .foregroundColor(Color("white-400"))
                        Label("", systemImage: "calendar")
                            .foregroundStyle(Color("white-500"))
                    }
                    .customFrameModifier()
                    .contentShape(Rectangle()) // This makes the whole area of HStack tappable
                }
                .buttonStyle(.plain)

                
                // Gender Button
                Button(action: { /* no-op to keep design; picker handles input */ }) {
                    HStack {
                        Text("Gender")
                            .font(.body)
                            .font(.custom("Helvetica Neue", size: 22))
                            .foregroundColor(Color("white-500"))
                        Spacer()
                        Text("")
                            .font(.custom("Helvetica Neue", size: 18))
                            .foregroundColor(Color("white-400"))
                        Label("", systemImage: "figure")
                            .foregroundStyle(Color("white-500"))
                    }
                    .customFrameModifier()
                    .contentShape(Rectangle()) // This makes the whole area of HStack tappable
                }
                .buttonStyle(.plain)
                
                // Weight Button
                Button(action: {  }) {
                    HStack {
                        Text("Weight")
                            .font(.body)
                            .font(.custom("Helvetica Neue", size: 22))
                            .foregroundColor(Color("white-500"))
                        Spacer()
                        TextField("70.0", text: $weightKg)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                            .focused($focusedField, equals: .weight)
                        Label("", systemImage: "scalemass.fill")
                            .foregroundStyle(Color("white-500"))
                    }
                }
                .customFrameModifier()
                .contentShape(Rectangle()) // This makes the whole area of HStack tappable
                
                // Height Button
                Button(action: {  }) {
                    HStack {
                        Text("Height")
                            .font(.body)
                            .font(.custom("Helvetica Neue", size: 22))
                            .foregroundColor(Color("white-500"))
                        Spacer()
                        TextField("75.0", text: $heightCm)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                            .focused($focusedField, equals: .height)
                        Label("", systemImage: "ruler.fill")
                            .foregroundStyle(Color("white-500"))
                    }
                }
                .customFrameModifier()
                .contentShape(Rectangle()) // This makes the whole area of HStack tappable
                
                
                Spacer()
                
                Button("Continue") {
                    let personalInfo = PersonalInfo(
                        age: convertDateToAge(date: date),
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
            .sheet(isPresented: $showDatePicker) {
                SwiftUI.DatePicker(
                    "Start Date",
                    selection: $date,
                    in: ...Date(),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .cornerRadius(12)
                .presentationDetents([.medium, .large])
            }
            .background(Color("black-500"))
            
        }
    }
}

#Preview {
    PersonalInfoStepView { _ in }
}
