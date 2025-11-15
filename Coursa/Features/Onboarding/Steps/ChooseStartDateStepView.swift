import SwiftUI

struct ChooseStartDateStepView: View {
    let onFinish: (Date) -> Void
    let onboardingData: OnboardingData
    @State private var activeSheet: Bool = false
    @State private var selectedDate: Date?
    @State private var selectedId: Int?
    
    
    @EnvironmentObject var syncService: SyncService
    @EnvironmentObject var planManager: PlanManager
    
    private var selectedDateBinding: Binding<Date> {
        Binding<Date>(
            get: { selectedDate ?? Date() },
            set: { selectedDate = $0 }
        )
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                OnboardingHeaderQuestion(
                    question: "When do you want to start your plan?",
                    caption: "Pick your training plan starting date."
                )
                .padding(.bottom, 90)
                
                VStack(alignment: .leading, spacing: 12) {
                    Button(action: {
                        selectedDate = Date()
                        selectedId = 0
                    }) {
                        HStack {
                            Text("Today")
                                .font(.body)
                                .font(.custom("Helvetica Neue", size: 22))
                                .foregroundColor(Color("white-500"))
                            Spacer()
                        }
                        .customFrameModifier(
                            isActivePage: true,
                            isSelected: selectedId == 0
                        )
                        .contentShape(Rectangle())  // This makes the whole area of HStack tappable
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        selectedDate = Date(timeIntervalSinceNow: 86400)
                        selectedId = 1
                    }) {
                        HStack {
                            Text("Tomorrow")
                                .font(.body)
                                .font(.custom("Helvetica Neue", size: 22))
                                .foregroundColor(Color("white-500"))
                            Spacer()
                        }
                        .customFrameModifier(
                            isActivePage: true,
                            isSelected: selectedId == 1
                        )
                        .contentShape(Rectangle())  // This makes the whole area of HStack tappable
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        selectedDate = FindNextWeekMonday()
                        selectedId = 2
                    }) {
                        HStack {
                            Text("Monday (Next Week)")
                                .font(.body)
                                .font(.custom("Helvetica Neue", size: 22))
                                .foregroundColor(Color("white-500"))
                            Spacer()
                        }
                        .customFrameModifier(
                            isActivePage: true,
                            isSelected: selectedId == 2
                        )
                        .contentShape(Rectangle())  // This makes the whole area of HStack tappable
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        activeSheet = true
                        selectedId = 3
                    }) {
                        HStack {
                            
                            if selectedId == 3 {
                                Text(
                                    selectedDate?.formatted(
                                        date: .abbreviated,
                                        time: .omitted
                                    ) ?? ""
                                )
                                .font(.custom("Helvetica Neue", size: 18))
                                .foregroundColor(Color("white-400"))
                            } else {
                                Text("Select Date")
                                    .font(.custom("Helvetica Neue", size: 18))
                                    .foregroundColor(Color("black-400"))
                            }
                            Spacer()
                            Label("", systemImage: "calendar")
                                .foregroundStyle(Color("white-500"))
                        }
                        .customFrameModifier(
                            isActivePage: true,
                            isSelected: selectedId == 3
                        )
                        .contentShape(Rectangle())  // This makes the whole area of HStack tappabl
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                Button("Generate Plan") {
                    let startDate = selectedDate ?? Date()
                    
                    // Generate the plan
                    var dataWithStartDate = onboardingData
                    dataWithStartDate.startDate = startDate
                    
                    if let generatedPlan = PlanMapper.generatePlan(from: dataWithStartDate) {
                        // Store the plan in planManager
                        planManager.finalPlan = generatedPlan
                        
                        // Save the plan
                        StoreManager.shared.currentPlanStore.save(generatedPlan)
                        
                        // Send plan to WatchOS
                        planManager.sendPlanToWatchOS(generatedPlan)
                        
                        // Continue with onboarding flow
                        onFinish(startDate)
                    } else {
                        print("❌ Failed to generate plan")
                        // Still call onFinish to continue the flow
                        onFinish(startDate)
                    }
                }
                .buttonStyle(CustomButtonStyle(isDisabled: selectedDate == nil))
                .controlSize(.large)
                .disabled(selectedDate == nil)
                
                
            }
        }
        .sheet(isPresented: $activeSheet) {
            DatePicker(
                "Start Date",
                selection: selectedDateBinding,
                in: Date()...,
                displayedComponents: [.date]
            )
            .onAppear {
                if selectedDate == nil {
                    selectedDateBinding.wrappedValue = Date()
                }
            }
            .datePickerStyle(.graphical)
            .padding()
            .cornerRadius(12)
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    ChooseStartDateStepView(onFinish: { _ in }, onboardingData: OnboardingData())
}
