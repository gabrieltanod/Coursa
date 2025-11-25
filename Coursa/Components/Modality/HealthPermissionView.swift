//
//  HealthPermissionView.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 20/11/25.
//

import SwiftUI

struct HealthPermissionView: View {
    // Use this to dismiss the sheet when "Set UpLater" is tapped
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    // State to show loading spinner during request
    @State private var isRequesting = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).opacity(0.1)
                .background(Color.black)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 20)
                
                Text("Permission for Apple Health")
                    .font(.custom("Helvetica Neue", size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer().frame(height: 40)
                
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .frame(width: 150, height: 150)
                        .shadow(color: .white.opacity(0.1), radius: 15, x: 0, y: 0)
                    
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60)
                        .foregroundColor(.red)
                        .offset(x: -20, y: 20)
                }
                
                Spacer().frame(height: 40)
                
                Text("Coursa uses Health App to track the running metrics needed. This will provide real-time tracking, personalizing you training plan, and record all your workouts seamlessly back into your Health history. These include:")
                    .font(.custom("Helvetica Neue", size: 17))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                
                Spacer().frame(height: 30)
                
                VStack(alignment: .leading, spacing: 16) {
                    PermissionCheckItem(text: "Heart rate")
                    PermissionCheckItem(text: "Running activity")
                    PermissionCheckItem(text: "Distance metrics")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer().frame(height: 30)
                
                Text("We are committed to protecting your data. All information is used strictly to improve your experience.")
                    .font(.custom("Helvetica Neue", size: 17))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        handleSetUp()
                    }) {
                        HStack {
                            if isRequesting {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Text("Set Up")
                                    .font(.custom("Helvetica Neue", size: 17))
                                    .fontWeight(.medium)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(20)
                    }
                    .disabled(isRequesting)
                    
                    Button(action: {
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    }) {
                        Text("Set Up Later")
                            .font(.custom("Helvetica Neue", size: 17))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Actions
    func handleSetUp() {
        isRequesting = true
        HealthKitManager.shared.requestAuthorization()
        
        // Delay to allow HealthKit dialog to show, then dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isRequesting = false
            hasCompletedOnboarding = true
            dismiss()
        }
    }
}

// MARK: - Helper View for Checklist
struct PermissionCheckItem: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.custom("Helvetica Neue", size: 20))
                .foregroundColor(.white)
            
            Text(text)
                .font(.custom("Helvetica Neue", size: 17))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Preview
#Preview {
    HealthPermissionView()
        .preferredColorScheme(.dark)
}
