# Coursa 🏃‍♂️💨

Coursa is a modern endurance training application designed to help runners achieve their goals through personalized, adaptive training plans. Built with SwiftUI and integrated deeply with the Apple ecosystem, Coursa provides a seamless experience across iOS and watchOS.

## Features ✨

- **Adaptive Training Plans**: Generate personalized running schedules based on your current fitness level and goals (Endurance, Speed, Base Building).
- **Apple Watch Companion**: Track your runs in real-time with a standalone watchOS app that syncs data back to your iPhone.
- **HealthKit Integration**: Seamlessly reads and writes workout data, heart rate, and distance to Apple Health.
- **Smart Statistics**: Visualize your progress with weekly comparisons of pace, aerobic (Zone 2) time, and consistency trends.
- **Zone Training**: Focus on "Zone 2" training to build a solid aerobic base with real-time feedback.
- **Dark Mode First**: A sleek, battery-saving dark UI designed for runners.

## Tech Stack 🛠️

- **Language**: Swift 5
- **UI Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Data Flow**: Combine, ObservableObject
- **Connectivity**: WatchConnectivity (WCSession) for bi-directional phone/watch syncing.
- **Persistence**: UserDefaults (for plans), HealthKit (for workouts).

## Requirements 📱

- iOS 17.0+
- watchOS 10.0+
- Xcode 15.0+

## Getting Started 🚀

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/coursa.git
    ```
2.  **Open the project**:
    Open `Coursa.xcodeproj` in Xcode.
3.  **Select the Target**:
    Select the `Coursa` scheme for the iOS app or `CoursaWatch Watch App` for the watch.
4.  **Build and Run**:
    Press `Cmd + R` to run on your simulator or device.

> **Note**: For full functionality (HealthKit, WatchConnectivity), you will need to run on physical devices with a valid development signature.

## Architecture 🏗️

The app follows the **MVVM** pattern to separate UI logic from business rules.
- **Views**: SwiftUI Views (e.g., `HomeView`, `StatisticsView`).
- **ViewModels**: `ObservableObject` classes (e.g., `HomeViewModel`, `StatisticsViewModel`) that prepare data for the view.
- **Stores/Services**: `PlanSessionStore`, `HealthKitManager`, `SyncService` manage data persistence and external integrations.

## Contributing 🤝

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## License 📄

Distributed under the MIT License. See `LICENSE` for more information.
