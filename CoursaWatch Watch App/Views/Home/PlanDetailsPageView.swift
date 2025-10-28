//
//  HomePageView.swift
//  TestCoursa
//
//  Created by Chairal Octavyanz on 26/10/25.
//

import SwiftUI

struct PlanDetailsPageView: View {
    // Variabel yang Anda teruskan (walaupun 'plan' sudah mencakupnya)
    let title: String
    let targetDistance: String
    let intensity: String
    let description: String
    
    let plan: Plan
    
//    @Binding var isRootSessionActive: Bool
    @State private var navPath = NavigationPath()
    @Binding var appState: AppState
    
    @State private var isCountingDown = false
    
    // Enum untuk mengelola state countdown
    enum CountdownStep: Hashable {
        case idle
        case paceRec
        case number(Int)
        case start
        
        // ID untuk "tipe" state, bukan nilainya
        var stateType: String {
            switch self {
            case .idle: return "idle"
            case .paceRec: return "pace"
            case .number: return "number" // Kunci: Sama untuk 3, 2, 1
            case .start: return "start"
            }
        }
    }
    
    @State private var countdownStep: CountdownStep = .idle
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text(plan.title)
                            .font(.system(size: 20, weight: .semibold))
                        Text(plan.targetDistance)
                            .font(.system(size: 14, weight: .medium))
                        Text(plan.intensity)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.white)
                    
                    // Deskripsi
                    Text(plan.description)
                        .font(.system(size: 12, weight: .regular))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.8))
                        .cornerRadius(8)
                        .lineSpacing(6)
                    
                    // Start Button
                    Button(action: {
                        startCountdownSequence()
                    }) {
                        Text("Start")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color("secondary"))
                            .foregroundColor(.black)
                            .cornerRadius(15)
                    }
                    .buttonStyle(.plain)
                    
                }
                .padding(.horizontal, 9)
                .padding(.top, 10) // Padding kecil di atas
                .padding(.bottom, 20) // Padding kecil di bawah
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .ignoresSafeArea(edges: .bottom) // Biarkan scroll view mengisi
            }
            .disabled(isCountingDown)
            
            
            // --- COUNTDOWN OVERLAY (DI DEPAN) ---
            if isCountingDown {
                Color.black
                    .ignoresSafeArea()
                
                Group {
                    switch countdownStep {
                        
                    case .idle:
                        EmptyView()
                        
                    case .paceRec:
                        VStack {
                            VStack(spacing: 8) {
                                Text("RECOMMENDED PACE")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color("secondary"))
                                
                                Text("7:30/KM")
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundColor(Color("secondary"))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .transition(.opacity.combined(with: .scale))
                        
                    case .number(let num):
                        VStack{
                            Text("\(num)") // Tampilkan angkanya
                                .font(.system(size: 96, weight: .semibold))
                                .foregroundColor(.orange)
                                .padding(.bottom, 20)
                                .transition(.opacity.combined(with: .scale))
                                .id(num)
                            
                            Text("Be Ready!")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.orange)
                        }
                        
                    case .start:
                        Text("START!")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundColor(.yellow)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .ignoresSafeArea()
                .id(countdownStep.stateType)
            }
            
        }
        .navigationBarBackButtonHidden(isCountingDown)
    }
    
    
    // Fungsi helper (Anda harus menambahkannya)
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yy"
        return formatter.string(from: date)
    }
    
    // Fungsi Countdown (Tidak berubah)
    func startCountdownSequence() {
        Task {
            isCountingDown = true
            
            withAnimation { countdownStep = .paceRec }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            withAnimation { countdownStep = .number(3) }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            withAnimation { countdownStep = .number(2) }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            withAnimation { countdownStep = .number(1) }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            withAnimation { countdownStep = .start }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            appState = .running
        }
    }
}


