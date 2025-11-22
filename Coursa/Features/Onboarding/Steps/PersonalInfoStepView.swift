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
    
    private var selectedDateBinding: Binding<Date> {
        Binding<Date>(
            get: { date ?? Date() },
            set: { date = $0 }
        )
    }
    @State private var date: Date?
    @State private var gender = ""
    @State private var weightKg = ""
    @State private var heightCm = ""
    @State private var activeSheet: WhatToShow?

    private var isValid: Bool {
        !gender.isEmpty && !weightKg.isEmpty && !heightCm.isEmpty
    }

    private let genderOptions = ["Male", "Female", "Other"]
    private let weightOptions = Array(30...200).map { "\($0) kg" }
    private let heightOptions = Array(100...250).map { "\($0) cm" }

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                OnboardingHeaderQuestion(
                    question: "Tell us about yourself",
                    caption:
                        "Help us create the plan that is perfectly tailored for you. Fill out a few data and we’ll do the rest."
                )
                .padding(.bottom, 40)

                // DoB Button
                LazyVStack(spacing: 12) {
                    Button(action: { activeSheet = .showDatePicker }) {
                        HStack {
                            Text("Date of Birth")
                                .font(.body)
                                .font(.custom("Helvetica Neue", size: 17))
                                .foregroundColor(Color("white-500"))
                            Spacer()
                            if date == nil {
                                Label("", systemImage: "calendar")
                                    .foregroundStyle(Color("white-500"))
                            } else {
                                Text(
                                    date?.formatted(
                                        date: .abbreviated,
                                        time: .omitted
                                    ) ?? ""
                                )
                                .font(.custom("Helvetica Neue", size: 17))
                                .foregroundColor(Color("white-400"))
                            }
                            
                        }
                        .customFrameModifier(isActivePage: false, isSelected: false)
                        .contentShape(Rectangle())  // This makes the whole area of HStack tappable
                    }
                    .buttonStyle(.plain)

                    // Gender Button
                    Button(action: { activeSheet = .showGenderPicker }) {
                        HStack {
                            Text("Gender")
                                .font(.body)
                                .font(.custom("Helvetica Neue", size: 17))
                                .foregroundColor(Color("white-500"))
                            Spacer()
                            if gender.isEmpty {
                                Label("", systemImage: "figure")
                                    .foregroundStyle(Color("white-500"))
                            } else {
                                Text(gender)
                                    .font(.body)
                                    .font(.custom("Helvetica Neue", size: 17))
                                    .foregroundColor(Color("white-500"))
                            }
                        }
                        .customFrameModifier(isActivePage: false, isSelected: false)
                        .contentShape(Rectangle())  // This makes the whole area of HStack tappable
                    }
                    .buttonStyle(.plain)

                    // Weight Button
                    Button(action: { activeSheet = .showWeightPicker }) {
                        HStack {
                            Text("Weight")
                                .font(.body)
                                .font(.custom("Helvetica Neue", size: 17))
                                .foregroundColor(Color("white-500"))
                            Spacer()
                            if weightKg.isEmpty {
                                Label("", systemImage: "scalemass.fill")
                                    .foregroundStyle(Color("white-500"))
                            } else {
                                Text(weightKg)
                                    .font(.body)
                                    .font(.custom("Helvetica Neue", size: 17))
                                    .foregroundColor(Color("white-500"))
                            }
                        }
                    }
                    .customFrameModifier(isActivePage: false, isSelected: false)
                    .contentShape(Rectangle())

                    // Height Button
                    Button(action: { activeSheet = .showHeightPicker }) {
                        HStack {
                            Text("Height")
                                .font(.body)
                                .font(.custom("Helvetica Neue", size: 17))
                                .foregroundColor(Color("white-500"))
                            Spacer()
                            if heightCm.isEmpty {
                                Label("", systemImage: "ruler.fill")
                                    .foregroundStyle(Color("white-500"))
                            } else {
                                Text(heightCm)
                                    .font(.body)
                                    .font(.custom("Helvetica Neue", size: 17))
                                    .foregroundColor(Color("white-500"))
                            }
                        }
                    }
                    .customFrameModifier(isActivePage: false, isSelected: false)
                    .contentShape(Rectangle())
                }

                Spacer()
                Spacer()
                
                if !isValid {
                    HStack{
                        Spacer()
                        Text("Please fill out all the fields first")
                            .font(.body)
                            .font(.custom("Helvetica Neue", size: 22))
                            .foregroundStyle(Color("alert"))
                        Spacer()
                    }
                }

                Button("Next") {
                    let personalInfo = PersonalInfo(
                        age: convertDateToAge(date: date ?? Date()),
                        gender: gender,
                        weightKg: Double(weightKg) ?? 0.0,
                        heightCm: Double(heightCm) ?? 0.0
                    )
                    onContinue(personalInfo)
                }
                .buttonStyle(CustomButtonStyle(isDisabled: !isValid))
                .disabled(!isValid)
                .padding(.top, 16)
                
            }
//            .padding(.top, 36)
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .showDatePicker:
                    DatePicker(
                        "Start Date",
                        selection: selectedDateBinding,
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                    .onAppear {
                        if date == nil {
                            selectedDateBinding.wrappedValue = Date()
                        }
                    }
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
                    .onAppear {
                        if gender.isEmpty { gender = genderOptions.first ?? "" }
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
                    .onAppear {
                        if weightKg.isEmpty { weightKg = weightOptions.first ?? "" }
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
                    .onAppear {
                        if heightCm.isEmpty { heightCm = heightOptions.first ?? "" }
                    }
                    .padding()
                    .presentationDetents([.medium])
                }
            }
        }
    }
}

#Preview {
    PersonalInfoStepView { _ in }
}
