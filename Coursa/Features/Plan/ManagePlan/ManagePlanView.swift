//
//  ManagePlanView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 11/11/25.
//
//  Summary
//  -------
//  A focused surface to tweak plan configuration (goal, schedule)
//  without touching historical sessions.
//
//  Responsibilities
//  ----------------
//  - Display current settings with clean, tappable rows.
//  - Let users change selected days (schedule).
//  - Route saves to ViewModel; button reflects "has changes" state.
//

import SwiftUI

struct ManagePlanView: View {
    @StateObject private var vm: ManagePlanViewModel
    @Environment(\.dismiss) private var dismiss

    // Default initializer: uses shared store and receives PlanSessionStore from environment
    init(store: PlanStore = UserDefaultsPlanStore.shared, planSession: PlanSessionStore? = nil) {
        _vm = StateObject(wrappedValue: ManagePlanViewModel(store: store, planSession: planSession))
    }

    var body: some View {
        ZStack {
            Color("black-500").ignoresSafeArea()

            VStack(spacing: 24) {
//                header

                VStack(spacing: 16) {
                    NavigationLink {
                        ScheduleEditView(selectedDays: $vm.selectedDays)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Schedule")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.6))
                                Text(vm.selectedDays.weekdayShortString())
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            Spacer()
                            Image(systemName: "pencil")
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding()
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)

                    ManageRow(
                        title: "Personal Best",
                        value: "Coming soon"
                    ) { }
                }
                .padding(.horizontal, 20)

                Spacer()

                Button {
                    if vm.hasChanges {
                        vm.saveChanges()
                    }
                    dismiss()
                } label: {
                    Text(vm.hasChanges ? "Save Changes" : "Done")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(vm.hasChanges ? Color.white : Color.white.opacity(0.15))
                        .foregroundColor(.black)
                        .cornerRadius(18)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .disabled(!vm.hasChanges)
            }
        }
        .navigationTitle("Manage Plan")

    }
    
//    private var header: some View {
//        HStack (alignment: .center){
////            Button {
////                dismiss()
////            } label: {
////                Circle()
////                    .fill(Color.white.opacity(0.06))
////                    .frame(width: 32, height: 32)
////                    .overlay(
////                        Image(systemName: "chevron.left")
////                            .foregroundColor(.white)
////                            .font(.system(size: 17, weight: .semibold))
////                    )
////            }
//            Text("Manage Plan")
//                .foregroundColor(.white)
//                .font(.system(size: 20, weight: .semibold))
//
//            Spacer()
//
//            // spacer to balance the back button
//            Color.clear.frame(width: 32, height: 32)
//        }
//        .padding(.horizontal, 20)
//        .padding(.top, 16)
//    }
}

// MARK: - Row component

struct ManageRow: View {
    let title: String
    let value: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                    Text(value)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                Spacer()
                Image(systemName: "pencil")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .background(Color.white.opacity(0.06))
            .cornerRadius(16)
        }
    }
}


// MARK: - Schedule Editor

struct ScheduleEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDays: Set<Int>
    
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
        ZStack {
            Color("black-500").ignoresSafeArea()
            
            VStack {
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

                Button("Done") {
                    if selectedDays.count >= 3 {
                        dismiss()
                    }
                }
                .buttonStyle(CustomButtonStyle(isDisabled: selectedDays.count < 3))
                .disabled(selectedDays.count < 3)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helpers

private extension Set where Element == Int {
    func weekdayShortString() -> String {
        let map: [Int: String] = [
            1: "Sun", 2: "Mon", 3: "Tue", 4: "Wed",
            5: "Thu", 6: "Fri", 7: "Sat"
        ]
        let sorted = self.sorted()
        let labels = sorted.compactMap { map[$0] }
        return labels.isEmpty ? "Not set" : labels.joined(separator: ", ")
    }
}

private extension Plan {
    var displayName: String {
        switch self {
        case .baseBuilder: return "Base Endurance Plan"
        case .endurance:   return "Endurance"
        case .speed:       return "Speed"
        case .halfMarathonPrep: return "Half Marathon Prep"
        }
    }
}
