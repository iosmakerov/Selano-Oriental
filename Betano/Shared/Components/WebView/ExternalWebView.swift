import SwiftUI
import Combine

struct ExternalWebView: View {
    let urlString: String
    @State private var canGoBack = false
    @State private var canGoForward = false
    @StateObject private var webViewStore = WebViewStore()
    @State private var cancellable: AnyCancellable?

    @State private var screenSize = CGSize.zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .ignoresSafeArea(.all)

                if let url = URL(string: urlString) {
                    ZStack {
                        ExternalWebViewRepresentable(
                            url: url,
                            canGoBack: $canGoBack,
                            canGoForward: $canGoForward,
                            webViewStore: webViewStore
                        )
                        .ignoresSafeArea(.all)
                    }
                    .onAppear {
                        screenSize = geometry.size

                        cancellable = NotificationCenter.default
                            .publisher(for: UIApplication.willResignActiveNotification)
                            .sink { _ in
                                GlobalWebViewManager.shared.forceSaveCookies()
                                webViewStore.saveCurrentState()
                            }
                    }
                    .onDisappear {
                        GlobalWebViewManager.shared.forceSaveCookies()
                        webViewStore.saveCurrentState()

                        cancellable?.cancel()
                        cancellable = nil
                    }
                    .onChange(of: geometry.size) { newSize in
                        if newSize != screenSize {
                            screenSize = newSize
                        }
                    }

                    VStack {
                        Color.black
                            .frame(height: geometry.safeAreaInsets.top)
                            .ignoresSafeArea(.all, edges: .top)
                        Spacer()
                    }

                } else {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("Invalid URL")
                            .font(.title2)
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.1))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
