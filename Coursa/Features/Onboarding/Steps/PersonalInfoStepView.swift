import SwiftUI

enum WhatToShow: Identifiable {
    case showDatePicker
    case showGenderPicker
    case showWeightPicker
    case showHeightPicker

    var id: String {
        switch self {
        case .showDatePicker: return "dob"
        case .showGenderPicker: return "gender"
        case .showWeightPicker: return "weight"
        case .showHeightPicker: return "height"
        }
    }
}

struct PersonalInfoStepView: View {
    let onContinue: (PersonalInfo) -> Void

    // Fallback: Ini ribet ngatur date kosong
    @State private var date: Date = Date()
    @State private var gender = ""
    @State private var weightKg = ""
    @State private var heightCm = ""
    @State private var activeSheet: WhatToShow?

    private var isValid: Bool {
        !gender.isEmpty && !weightKg.isEmpty && !heightCm.isEmpty
//            && Int(weightKg) != nil && Int(heightCm) != nil
    }

    private let genderOptions = ["Male", "Female", "Other"]
    private let weightOptions = Array(60...150).map { "\($0) kg" }
    private let heightOptions = Array(120...220).map { "\($0) cm" }

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                OnboardingHeaderQuestion(
                    question: "Personal data",
                    caption:
                        "Help Coursa determines the best plan for you based on your goals."
                )
                .padding(.bottom, 24)

                // DoB Button
                Button(action: { activeSheet = .showDatePicker }) {
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
                    .contentShape(Rectangle())  // This makes the whole area of HStack tappable
                }
                .buttonStyle(.plain)

                // Gender Button
                Button(action: { activeSheet = .showGenderPicker }) {
                    HStack {
                        Text("Gender")
                            .font(.body)
                            .font(.custom("Helvetica Neue", size: 22))
                            .foregroundColor(Color("white-500"))
                        Spacer()
                        if gender.isEmpty {
                            Label("", systemImage: "figure")
                                .foregroundStyle(Color("white-500"))
                        } else {
                            Text(gender)
                                .font(.body)
                                .font(.custom("Helvetica Neue", size: 22))
                                .foregroundColor(Color("white-500"))
                        }
                    }
                    .customFrameModifier()
                    .contentShape(Rectangle())  // This makes the whole area of HStack tappable
                }
                .buttonStyle(.plain)

                // Weight Button
                Button(action: { activeSheet = .showWeightPicker }) {
                    HStack {
                        Text("Weight")
                            .font(.body)
                            .font(.custom("Helvetica Neue", size: 22))
                            .foregroundColor(Color("white-500"))
                        Spacer()
                        if weightKg.isEmpty {
                            Label("", systemImage: "scalemass.fill")
                                .foregroundStyle(Color("white-500"))
                        } else {
                            Text(weightKg)
                                .font(.body)
                                .font(.custom("Helvetica Neue", size: 22))
                                .foregroundColor(Color("white-500"))
                        }
                    }
                }
                .customFrameModifier()
                .contentShape(Rectangle())  // This makes the whole area of HStack tappable

                // Height Button
                Button(action: { activeSheet = .showHeightPicker }) {
                    HStack {
                        Text("Height")
                            .font(.body)
                            .font(.custom("Helvetica Neue", size: 22))
                            .foregroundColor(Color("white-500"))
                        Spacer()
                        TextField("75.0", text: $heightCm)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                            .allowsHitTesting(false)
                        if heightCm.isEmpty {
                            Label("", systemImage: "ruler.fill")
                                .foregroundStyle(Color("white-500"))
                        }
                    }
                }
                .customFrameModifier()
                .contentShape(Rectangle())  // This makes the whole area of HStack tappable

                Spacer()

                if !isValid {
                    Text("Please fill out all the fields first")
                        .font(.body)
                        .font(.custom("Helvetica Neue", size: 22))
                        .foregroundStyle(Color("alert"))
                }

                Button("Continue") {
                    let personalInfo = PersonalInfo(
                        age: convertDateToAge(date: date),
                        gender: gender,
                        weightKg: Double(weightKg) ?? 0.0,
                        heightCm: Double(heightCm) ?? 0.0
                    )
                    onContinue(personalInfo)
                }
                .buttonStyle(CustomButtonStyle())
                .disabled(!isValid)
            }
            .padding(24)
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .showDatePicker:
                    DatePicker(
                        "Start Date",
                        selection: $date,
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    .cornerRadius(12)
                    .presentationDetents([.medium, .large])
                case .showGenderPicker:
                    VStack(spacing: 0) {
                        Text("Select Gender")
                            .font(.headline)
                            .padding(.top)
                        Picker("Gender", selection: $gender) {
                            ForEach(genderOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .padding()
                    .presentationDetents([.medium])
                case .showWeightPicker:
                    VStack(spacing: 0) {
                        Text("Select Weight (kg)")
                            .font(.headline)
                            .padding(.top)
                        Picker("Weight", selection: $weightKg) {
                            ForEach(weightOptions, id: \.self) { value in
                                Text(value).tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .padding()
                    .presentationDetents([.medium])
                case .showHeightPicker:
                    VStack(spacing: 0) {
                        Text("Select Height (cm)")
                            .font(.headline)
                            .padding(.top)
                        Picker("Height", selection: $heightCm) {
                            ForEach(heightOptions, id: \.self) { value in
                                Text(value).tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .padding()
                    .presentationDetents([.medium])
                }
            }
            .background(Color("black-500"))

        }
    }
}

#Preview {
    PersonalInfoStepView { _ in }
}
