import WebKit
import Combine

final class WebViewStore: ObservableObject {
    @Published var webView: WKWebView?
    @Published var isLoading = true

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }

    func reload() {
        webView?.reload()
    }

    func saveCurrentState() {
        GlobalWebViewManager.shared.forceSaveCookies()
    }
}
