import Foundation

enum AccessGateResult {
    case showWebView(url: String)
    case showWhitePart
    case networkFallback
}

enum AccessGateError: LocalizedError {
    case invalidURL
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid tracker URL"
        case .invalidResponse:
            return "Invalid response from tracker"
        }
    }
}

final class AccessGateService {
    static let shared = AccessGateService()

    private var trackerURL = ""

    private init() {}

    func checkGate() async throws -> AccessGateResult {
        if await AccessGateStorageManager.shared.accessGateWasNetworkError {
            await AccessGateStorageManager.shared.clearAccessGateNetworkErrorFlag()
        }

        if let savedResult = await AccessGateStorageManager.shared.accessGateResult {
            if savedResult, let url = await AccessGateStorageManager.shared.accessGateURL {
                return .showWebView(url: url)
            } else {
                return .showWhitePart
            }
        }

        return try await fetchGateResult()
    }

    func setTrackerURL(_ url: String) {
        trackerURL = url
    }

    private func fetchGateResult() async throws -> AccessGateResult {
        guard let url = URL(string: trackerURL) else {
            throw AccessGateError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.httpMethod = "GET"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AccessGateError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 404:
                await AccessGateStorageManager.shared.saveAccessGateResult(shouldShowWebView: false, url: nil)
                return .showWhitePart
            default:
                await AccessGateStorageManager.shared.saveAccessGateResult(shouldShowWebView: true, url: trackerURL)
                return .showWebView(url: trackerURL)
            }

        } catch {
            if let savedResult = await AccessGateStorageManager.shared.accessGateResult {
                if savedResult, let url = await AccessGateStorageManager.shared.accessGateURL {
                    return .showWebView(url: url)
                } else {
                    return .showWhitePart
                }
            }

            await AccessGateStorageManager.shared.recordAccessGateNetworkError()
            return .networkFallback
        }
    }
}
