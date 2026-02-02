import SwiftUI
import Combine

@MainActor
final class AppStateManager: ObservableObject {
    static let shared = AppStateManager()

    @Published var isLoading = true
    @Published var shouldShowWebView = false
    @Published var webViewURL: String?

    private init() {
        Task {
            await checkAccessGate()
        }
    }

    func checkAccessGate() async {
        isLoading = true

        do {
            let result = try await AccessGateService.shared.checkGate()
            switch result {
            case .showWebView(let url):
                self.webViewURL = url
                self.shouldShowWebView = true
                self.isLoading = false
            case .showWhitePart, .networkFallback:
                self.shouldShowWebView = false
                self.isLoading = false
            }
        } catch {
            self.shouldShowWebView = false
            self.isLoading = false
        }
    }
}
