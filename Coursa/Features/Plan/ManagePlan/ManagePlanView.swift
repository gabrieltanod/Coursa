//
//  ManagePlanView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 11/11/25.
//

import SwiftUI

struct ManagePlanView: View {
    @StateObject private var vm: ManagePlanViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showSchedulePicker = false

    // Default initializer: uses shared store
    init(store: PlanStore = UserDefaultsPlanStore.shared) {
        _vm = StateObject(wrappedValue: ManagePlanViewModel(store: store))
    }

    var body: some View {
        ZStack {
            Color("black-500").ignoresSafeArea()

            VStack(spacing: 24) {
//                header

                VStack(spacing: 16) {
                    ManageRow(
                        title: "Goal",
                        value: vm.plan.displayName
                    ) {
                        // hook up goal picker later
                    }

                    ManageRow(
                        title: "Schedule",
                        value: vm.selectedDays.weekdayShortString()
                    ) {
                        showSchedulePicker = true
                    }

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
        .sheet(isPresented: $showSchedulePicker) {
            SchedulePickerView(selectedDays: $vm.selectedDays)
                .preferredColorScheme(.dark)
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

// MARK: - Schedule Picker

struct SchedulePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDays: Set<Int>

    private let days: [(label: String, weekday: Int)] = [
        ("Mon", 2), ("Tue", 3), ("Wed", 4),
        ("Thu", 5), ("Fri", 6), ("Sat", 7), ("Sun", 1)
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(days, id: \.weekday) { day in
                    Button {
                        toggle(day.weekday)
                    } label: {
                        HStack {
                            Text(day.label)
                            Spacer()
                            if selectedDays.contains(day.weekday) {
                                Image(systemName: "checkmark.circle.fill")
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color.black)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("black-500"))
            .navigationTitle("Schedule")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func toggle(_ weekday: Int) {
        if selectedDays.contains(weekday) {
            selectedDays.remove(weekday)
        } else {
            selectedDays.insert(weekday)
        }
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
