import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storage = StorageService.shared
    
    @State private var showClearHistoryAlert = false
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {

                        SettingsSection(title: "Sound & Haptics") {
                            SettingsToggle(
                                title: "Sound Effects",
                                icon: "speaker.wave.2.fill",
                                isOn: Binding(
                                    get: { storage.preferences.soundEnabled },
                                    set: { storage.preferences.soundEnabled = $0 }
                                )
                            )
                            
                            SettingsToggle(
                                title: "Haptic Feedback",
                                icon: "hand.tap.fill",
                                isOn: Binding(
                                    get: { storage.preferences.hapticEnabled },
                                    set: { storage.preferences.hapticEnabled = $0 }
                                )
                            )
                            
                        }
                        

                        SettingsSection(title: "Timer Preferences") {
                            CountdownSelector(
                                value: Binding(
                                    get: { storage.preferences.defaultCountdown },
                                    set: { storage.preferences.defaultCountdown = $0 }
                                )
                            )
                            
                            SettingsToggle(
                                title: "Keep Screen On",
                                icon: "sun.max.fill",
                                isOn: Binding(
                                    get: { storage.preferences.keepScreenOn },
                                    set: { storage.preferences.keepScreenOn = $0 }
                                )
                            )
                            
                            SettingsToggle(
                                title: "Background Audio",
                                icon: "airplayaudio",
                                isOn: Binding(
                                    get: { storage.preferences.backgroundAudioEnabled },
                                    set: { storage.preferences.backgroundAudioEnabled = $0 }
                                )
                            )
                        }
                        

                        SettingsSection(title: "About") {
                            SettingsRow(
                                title: "Version",
                                icon: "info.circle.fill",
                                value: appVersion
                            )
                        }
                        

                        SettingsSection(title: "Data") {
                            SettingsButton(
                                title: "Clear History",
                                icon: "trash.fill",
                                isDestructive: true
                            ) {
                                showClearHistoryAlert = true
                            }
                            
                            SettingsButton(
                                title: "Reset to Defaults",
                                icon: "arrow.counterclockwise",
                                isDestructive: true
                            ) {
                                showResetAlert = true
                            }
                        }
                        

                        Text("Consult a physician before starting any exercise program.")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.md)
                    }
                    .padding(.top, AppSpacing.md)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.boltRed)
                }
            }
            .alert("Clear History?", isPresented: $showClearHistoryAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    storage.clearHistory()
                }
            } message: {
                Text("This will delete all your workout history. This action cannot be undone.")
            }
            .alert("Reset Settings?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    storage.resetToDefaults()
                }
            } message: {
                Text("This will reset all settings to their default values.")
            }
        }
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.md)
            
            VStack(spacing: 1) {
                content
            }
            .background(AppColors.backgroundCard)
            .cornerRadius(AppCorners.medium)
            .padding(.horizontal, AppSpacing.md)
        }
    }
}

struct SettingsToggle: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    var badge: String? = nil
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.boltRed)
                .frame(width: 28)
            
            Text(title)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
            
            if let badge = badge {
                Text(badge)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppColors.backgroundElevated)
                    .cornerRadius(4)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppColors.boltRed)
                .disabled(badge != nil)
        }
        .padding(AppSpacing.md)
        .background(AppColors.backgroundCard)
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    let value: String
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.boltRed)
                .frame(width: 28)
            
            Text(title)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(AppSpacing.md)
        .background(AppColors.backgroundCard)
    }
}

struct SettingsLink: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.boltRed)
                    .frame(width: 28)
                
                Text(title)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textMuted)
            }
            .padding(AppSpacing.md)
            .background(AppColors.backgroundCard)
        }
    }
}

struct SettingsButton: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isDestructive ? AppColors.error : AppColors.boltRed)
                    .frame(width: 28)
                
                Text(title)
                    .font(AppFonts.body)
                    .foregroundColor(isDestructive ? AppColors.error : AppColors.textPrimary)
                
                Spacer()
            }
            .padding(AppSpacing.md)
            .background(AppColors.backgroundCard)
        }
    }
}

struct CountdownSelector: View {
    @Binding var value: Int
    let options = [3, 5, 10]
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "timer")
                .font(.system(size: 18))
                .foregroundColor(AppColors.boltRed)
                .frame(width: 28)
            
            Text("Default Countdown")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        value = option
                    } label: {
                        HStack {
                            Text("\(option) seconds")
                            if value == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text("\(value)s")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textMuted)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.backgroundCard)
    }
}

#Preview {
    SettingsView()
}
