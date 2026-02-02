import Foundation

@MainActor
final class AccessGateStorageManager {
    static let shared = AccessGateStorageManager()

    private let userDefaults = UserDefaults.standard

    private let accessGateShouldShowWebViewKey = "accessgate.shouldShowWebView.v1"
    private let accessGateURLKey = "accessgate.url.v1"
    private let accessGateWasNetworkErrorKey = "accessgate.wasNetworkError.v1"

    private init() {}

    var accessGateResult: Bool? {
        userDefaults.object(forKey: accessGateShouldShowWebViewKey) as? Bool
    }

    var accessGateURL: String? {
        userDefaults.string(forKey: accessGateURLKey)
    }

    var accessGateWasNetworkError: Bool {
        (userDefaults.object(forKey: accessGateWasNetworkErrorKey) as? Bool) ?? false
    }

    func saveAccessGateResult(shouldShowWebView: Bool, url: String?) {
        userDefaults.set(shouldShowWebView, forKey: accessGateShouldShowWebViewKey)
        if let url {
            userDefaults.set(url, forKey: accessGateURLKey)
        } else {
            userDefaults.removeObject(forKey: accessGateURLKey)
        }
        userDefaults.synchronize()
    }

    func recordAccessGateNetworkError() {
        userDefaults.set(true, forKey: accessGateWasNetworkErrorKey)
        userDefaults.synchronize()
    }

    func clearAccessGateNetworkErrorFlag() {
        userDefaults.removeObject(forKey: accessGateWasNetworkErrorKey)
        userDefaults.synchronize()
    }
}
