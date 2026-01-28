import SwiftUI

struct ContentView: View {
    @StateObject private var storage = StorageService.shared
    @StateObject private var achievementService = AchievementService.shared
    @State private var selectedTab = 0
    @State private var selectedWorkout: Workout?
    
    var body: some View {
        ZStack {
            Group {
                if !storage.onboardingCompleted {
                    OnboardingView()
                } else {
                    mainTabView
                }
            }
            .fullScreenCover(item: $selectedWorkout) { workout in
                ActiveSessionView(workout: workout)
            }
            

            if let achievement = achievementService.newlyUnlocked {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        achievementService.dismissNewAchievement()
                    }
                
                AchievementUnlockedView(achievement: achievement) {
                    achievementService.dismissNewAchievement()
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(100)
            }
        }
        .animation(.spring(response: 0.4), value: achievementService.newlyUnlocked != nil)
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            QuickStartView(selectedWorkout: $selectedWorkout)
                .tabItem {
                    Image(systemName: "bolt.fill")
                    Text("Quick Start")
                }
                .tag(0)
            
            WorkoutsView(selectedWorkout: $selectedWorkout)
                .tabItem {
                    Image(systemName: "list.bullet.rectangle.portrait")
                    Text("Workouts")
                }
                .tag(1)
            
            HistoryView(selectedWorkout: $selectedWorkout)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("History")
                }
                .tag(2)
        }
        .tint(AppColors.boltRed)
        .onAppear {
            configureTabBarAppearance()
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.backgroundSecondary)
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppColors.textMuted)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(AppColors.textMuted)]
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.boltRed)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(AppColors.boltRed)]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
}
