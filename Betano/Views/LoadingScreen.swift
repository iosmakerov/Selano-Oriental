import SwiftUI

struct LoadingScreen: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            AppColors.backgroundPrimary
                .ignoresSafeArea(.all)

            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.boltRed))
                    .scaleEffect(1.5)

                Text("Loading...")
                    .foregroundColor(AppColors.textSecondary)
                    .font(.headline)
            }
        }
        .preferredColorScheme(.dark)
    }
}
