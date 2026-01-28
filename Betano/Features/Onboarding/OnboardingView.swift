import SwiftUI
import UserNotifications

struct OnboardingView: View {
    @StateObject private var storage = StorageService.shared
    @State private var currentPage = 0
    @State private var selectedFocus: TrainingFocus?
    @State private var selectedLevel: ExperienceLevel?
    
    var body: some View {
        ZStack {
            AppColors.backgroundPrimary
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                WelcomePageView(onContinue: { currentPage = 1 })
                    .tag(0)
                
                FocusPageView(selectedFocus: $selectedFocus, onContinue: { currentPage = 2 })
                    .tag(1)
                
                LevelPageView(selectedLevel: $selectedLevel, onContinue: { currentPage = 3 })
                    .tag(2)
                
                NotificationsPageView(onComplete: completeOnboarding)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
        }
    }
    
    private func completeOnboarding() {
        if let focus = selectedFocus {
            storage.preferences.trainingFocus = focus
        }
        if let level = selectedLevel {
            storage.preferences.experienceLevel = level
        }
        storage.onboardingCompleted = true
    }
}

// MARK: - Welcome Page
struct WelcomePageView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            
            Image("onboarding_welcome")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 280)
            
            VStack(spacing: AppSpacing.sm) {
                Text("SprintBolt")
                    .font(AppFonts.h1)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Unleash Your Speed")
                    .font(AppFonts.bodyLarge)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            PrimaryButton(title: "Continue", action: onContinue)
                .padding(.horizontal, AppSpacing.lg)
            
            Spacer().frame(height: 60)
        }
    }
}

// MARK: - Focus Page
struct FocusPageView: View {
    @Binding var selectedFocus: TrainingFocus?
    let onContinue: () -> Void
    
    let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer().frame(height: AppSpacing.xxl)
            
            Image("onboarding_focus")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200)
            
            Text("What's Your Focus?")
                .font(AppFonts.h2)
                .foregroundColor(AppColors.textPrimary)
            
            LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                ForEach(TrainingFocus.allCases, id: \.self) { focus in
                    FocusCard(
                        focus: focus,
                        isSelected: selectedFocus == focus,
                        action: { selectedFocus = focus }
                    )
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            
            Spacer()
            
            PrimaryButton(title: "Continue", action: onContinue)
                .padding(.horizontal, AppSpacing.lg)
                .opacity(selectedFocus != nil ? 1 : 0.5)
                .disabled(selectedFocus == nil)
            
            Spacer().frame(height: 60)
        }
    }
}

struct FocusCard: View {
    let focus: TrainingFocus
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
                Image(systemName: focus.icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? AppColors.boltRed : AppColors.textSecondary)
                
                Text(focus.title)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(AppColors.backgroundCard)
            .overlay(
                RoundedRectangle(cornerRadius: AppCorners.medium)
                    .stroke(isSelected ? AppColors.boltRed : Color.clear, lineWidth: 2)
            )
            .cornerRadius(AppCorners.medium)
        }
    }
}

// MARK: - Level Page
struct LevelPageView: View {
    @Binding var selectedLevel: ExperienceLevel?
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer().frame(height: AppSpacing.xxl)
            
            Image("onboarding_level")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200)
            
            Text("Your Experience")
                .font(AppFonts.h2)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: AppSpacing.md) {
                ForEach(ExperienceLevel.allCases, id: \.self) { level in
                    LevelCard(
                        level: level,
                        isSelected: selectedLevel == level,
                        action: { selectedLevel = level }
                    )
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            
            Spacer()
            
            PrimaryButton(title: "Continue", action: onContinue)
                .padding(.horizontal, AppSpacing.lg)
                .opacity(selectedLevel != nil ? 1 : 0.5)
                .disabled(selectedLevel == nil)
            
            Spacer().frame(height: 60)
        }
    }
}

struct LevelCard: View {
    let level: ExperienceLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.title)
                        .font(AppFonts.h3)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(level.subtitle)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.boltRed)
                }
            }
            .padding(AppSpacing.md)
            .background(AppColors.backgroundCard)
            .overlay(
                RoundedRectangle(cornerRadius: AppCorners.medium)
                    .stroke(isSelected ? AppColors.boltRed : Color.clear, lineWidth: 2)
            )
            .cornerRadius(AppCorners.medium)
        }
    }
}

// MARK: - Notifications Page
struct NotificationsPageView: View {
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            
            Image("onboarding_notifications")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200)
            
            VStack(spacing: AppSpacing.sm) {
                Text("Stay on Track")
                    .font(AppFonts.h2)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Get audio cues during workouts even when screen is off")
                    .font(AppFonts.bodyLarge)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.lg)
            }
            
            Spacer()
            
            VStack(spacing: AppSpacing.md) {
                PrimaryButton(title: "Enable Notifications") {
                    requestNotifications()
                    onComplete()
                }
                
                TextButton(title: "Maybe Later", action: onComplete)
            }
            .padding(.horizontal, AppSpacing.lg)
            
            Spacer().frame(height: 60)
        }
    }
    
    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                StorageService.shared.preferences.soundEnabled = granted
            }
        }
    }
}

#Preview {
    OnboardingView()
}
