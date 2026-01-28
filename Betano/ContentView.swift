import SwiftUI

struct ContentView: View {
    @StateObject private var storage = StorageService.shared
    @State private var selectedTab = 0
    @State private var selectedWorkout: Workout?
    @State private var showActiveSession = false
    @State private var showSettings = false
    
    var body: some View {
        Group {
            if !storage.onboardingCompleted {
                OnboardingView()
            } else {
                mainTabView
            }
        }
        .fullScreenCover(isPresented: $showActiveSession) {
            if let workout = selectedWorkout {
                ActiveSessionView(workout: workout)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            QuickStartView(selectedWorkout: $selectedWorkout, showActiveSession: $showActiveSession)
                .tabItem {
                    Image(systemName: "bolt.fill")
                    Text("Quick Start")
                }
                .tag(0)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        settingsButton
                    }
                }
            
            WorkoutsView(selectedWorkout: $selectedWorkout, showActiveSession: $showActiveSession)
                .tabItem {
                    Image(systemName: "list.bullet.rectangle.portrait")
                    Text("Workouts")
                }
                .tag(1)
            
            HistoryView(selectedWorkout: $selectedWorkout, showActiveSession: $showActiveSession)
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
        .overlay(alignment: .topTrailing) {
            settingsButton
                .padding(.top, 8)
                .padding(.trailing, 16)
        }
    }
    
    private var settingsButton: some View {
        Button {
            showSettings = true
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 18))
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 36, height: 36)
                .background(AppColors.backgroundCard)
                .clipShape(Circle())
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
