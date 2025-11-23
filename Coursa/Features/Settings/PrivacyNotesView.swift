//
//  PrivacyNotesView.swift
//  Coursa
//

//  Created by Zikar Nurizky on 15/11/25.
//

import SwiftUI

struct PrivacyNotesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Privacy Notes")
                    .font(.title2).bold()
                    .padding(.top, 12)
                Text("""
                Effective Date: 13 November 2025\n
                This Privacy Policy explains how Coursa handles user information in connection with our iOS running application. We are fully committed to protecting your privacy.\n
                1. Our Core Privacy Principles\n
                Local Storage: Your personal and health data never leaves your device, except for anonymous analytics data that cannot personally identify you.\n
                No Accounts: The Coursa application does not require an account, email, or username login. We do not store identifiers that allow us to link the data to your identity outside of your device.\n
                2. Information We Handle and Collect\n
                We handle two main categories of information:\n
                A. User-Provided Data (Personal Data)\n
                You provide this information when you first set up your running profile. This data is stored locally on your device only and is used to calculate accurate running metrics and customize your training plan.\n
                Basic Profile Data (Date of Birth, Gender, Height, Weight) used to calculate estimated calories burned, Body Mass Index (BMI), and adjust the running plan to be realistic. We do not collect Names, Email Addresses, Phone Numbers, or Physical Addresses.\n
                B. Health and Fitness Data\n
                With your explicit consent, we access data from Apple Health (HealthKit) and Apple Watch for the app’s core functionality:\n
                HealthKit (Apple Health) such as Run Session Data, Distance, Pace, Heart Rate, Active Calories, to monitor running performance and enable the automatic adjustment feature for your training plan.\n
                Local Activity Data (Running history tracked by Coursa) to store your progress records, displayed as your running history within the application.\n
                3. Strict HealthKit Policy\n
                We comply with the Apple App Store Review Guidelines, specifically regarding the use of HealthKit data.\n
                Health and Fitness Data from HealthKit will never be shared with any third party.\n
                This data will never be used for marketing, advertising, or any purpose outside of Coursa’s core functionality dedicated to health and fitness improvement.\n
                4. Data Sharing and Third Parties (Analytics)\n
                We only share anonymous and non-identifying data for internal analysis purposes:\n
                Internal Analytics: We use third-party analytics tools (e.g., Crashlytics or similar anonymous analytics tools) solely to track general app usage metrics and identify bugs or crashes.\n
                Data Shared: This data only includes technical, non-identifiable information (e.g., device type, iOS version, feature usage frequency).\n
                Purpose: To improve the stability and performance of the Coursa application.\n
                5. Data Storage and Security (Local Storage)\n
                The security of your data is paramount.\n
                Local Storage: All personal data (profile, run history, and HealthKit data) is stored exclusively and encrypted on your device (Local Storage). We do not maintain copies of this data on our servers.\n
                Backup: If you enable device backups (e.g., iCloud Backup or iTunes Backup), Coursa data may be included in those backups and is subject to Apple’s privacy policies.\n
                Data Loss: Because data is stored locally, if you delete the app without backing up your device, all your running data will be permanently lost and cannot be recovered by us.\n
                6. User Rights and Control\n
                You maintain full control over your data:\n
                Access and Modification: You can access, modify, or delete your profile data directly within the application settings.\n
                Revocation of HealthKit Permission: You can revoke or limit Coursa's access to HealthKit data at any time through your iOS device's Privacy settings.\n
                Data Deletion: Deleting the application from your device will delete your local data (excluding anonymous analytics data).\n
                7. Changes to This Privacy Policy\n
                We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page, [Mention in-app notification if applicable], and updating the Effective Date at the top.\n
                8. Contact Us\n
                If you have any questions about this Privacy Policy, please contact us:\n
                Entity: Coursa\n
                Support Email: gabriel.tanod@gmail.com\n
                """)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(Color("black-500").ignoresSafeArea())
    }
}

#Preview {
    PrivacyNotesView()
}

