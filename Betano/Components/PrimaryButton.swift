import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    
    var body: some View {
        Button(action: {
            HapticService.shared.lightImpact()
            action()
        }) {
            Text(title)
                .font(AppFonts.button)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(isEnabled ? AppColors.boltRed : AppColors.backgroundElevated)
                .cornerRadius(AppCorners.medium)
        }
        .disabled(!isEnabled)
        .accessibilityLabel(title)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticService.shared.lightImpact()
            action()
        }) {
            Text(title)
                .font(AppFonts.button)
                .foregroundColor(AppColors.boltRed)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(AppColors.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: AppCorners.medium)
                        .stroke(AppColors.boltRed, lineWidth: 1.5)
                )
                .cornerRadius(AppCorners.medium)
        }
        .accessibilityLabel(title)
    }
}

struct TextButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
        }
        .accessibilityLabel(title)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Continue", action: {})
        SecondaryButton(title: "Cancel", action: {})
        TextButton(title: "Maybe Later", action: {})
    }
    .padding()
    .background(AppColors.backgroundPrimary)
}
