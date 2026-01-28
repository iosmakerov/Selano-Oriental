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

struct WelcomePageView: View {
    let onContinue: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    Spacer(minLength: AppSpacing.xl)
                    
                    Image("onboarding_welcome")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: min(280, geometry.size.width * 0.7))
                        .frame(maxHeight: geometry.size.height * 0.35)
                    
                    VStack(spacing: AppSpacing.sm) {
                        Text("Selano Oriental")
                            .font(AppFonts.h1)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Unleash Your Speed")
                            .font(AppFonts.bodyLarge)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer(minLength: AppSpacing.lg)
                    
                    PrimaryButton(title: "Continue", action: onContinue)
                        .padding(.horizontal, AppSpacing.lg)
                    
                    Spacer(minLength: AppSpacing.lg)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }
}

struct FocusPageView: View {
    @Binding var selectedFocus: TrainingFocus?
    let onContinue: () -> Void
    
    let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.md) {
                    Spacer(minLength: AppSpacing.lg)
                    
                    Image("onboarding_focus")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: min(160, geometry.size.width * 0.4))
                        .frame(maxHeight: geometry.size.height * 0.2)
                    
                    Text("What's Your Focus?")
                        .font(AppFonts.h2)
                        .foregroundColor(AppColors.textPrimary)
                    
                    LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
                        ForEach(TrainingFocus.allCases, id: \.self) { focus in
                            FocusCard(
                                focus: focus,
                                isSelected: selectedFocus == focus,
                                action: { selectedFocus = focus }
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    Spacer(minLength: AppSpacing.lg)
                    
                    PrimaryButton(title: "Continue", action: onContinue)
                        .padding(.horizontal, AppSpacing.lg)
                        .opacity(selectedFocus != nil ? 1 : 0.5)
                        .disabled(selectedFocus == nil)
                    
                    Spacer(minLength: AppSpacing.lg)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }
}

struct FocusCard: View {
    let focus: TrainingFocus
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                Image(systemName: focus.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? AppColors.boltRed : AppColors.textSecondary)
                
                Text(focus.title)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .padding(.horizontal, AppSpacing.sm)
            .background(AppColors.backgroundCard)
            .overlay(
                RoundedRectangle(cornerRadius: AppCorners.medium)
                    .stroke(isSelected ? AppColors.boltRed : Color.clear, lineWidth: 2)
            )
            .cornerRadius(AppCorners.medium)
        }
    }
}

struct LevelPageView: View {
    @Binding var selectedLevel: ExperienceLevel?
    let onContinue: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.md) {
                    Spacer(minLength: AppSpacing.lg)
                    
                    Image("onboarding_level")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: min(160, geometry.size.width * 0.4))
                        .frame(maxHeight: geometry.size.height * 0.2)
                    
                    Text("Your Experience")
                        .font(AppFonts.h2)
                        .foregroundColor(AppColors.textPrimary)
                    
                    VStack(spacing: AppSpacing.sm) {
                        ForEach(ExperienceLevel.allCases, id: \.self) { level in
                            LevelCard(
                                level: level,
                                isSelected: selectedLevel == level,
                                action: { selectedLevel = level }
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    Spacer(minLength: AppSpacing.lg)
                    
                    PrimaryButton(title: "Continue", action: onContinue)
                        .padding(.horizontal, AppSpacing.lg)
                        .opacity(selectedLevel != nil ? 1 : 0.5)
                        .disabled(selectedLevel == nil)
                    
                    Spacer(minLength: AppSpacing.lg)
                }
                .frame(minHeight: geometry.size.height)
            }
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

struct NotificationsPageView: View {
    let onComplete: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    Spacer(minLength: AppSpacing.xl)
                    
                    Image("onboarding_notifications")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: min(160, geometry.size.width * 0.4))
                        .frame(maxHeight: geometry.size.height * 0.25)
                    
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
                    
                    Spacer(minLength: AppSpacing.lg)
                    
                    VStack(spacing: AppSpacing.md) {
                        PrimaryButton(title: "Enable Notifications") {
                            requestNotifications()
                            onComplete()
                        }
                        
                        TextButton(title: "Maybe Later", action: onComplete)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    Spacer(minLength: AppSpacing.lg)
                }
                .frame(minHeight: geometry.size.height)
            }
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
