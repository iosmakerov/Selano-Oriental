import SwiftUI
import UIKit
import Combine

final class OrientationManager: ObservableObject {
    static let shared = OrientationManager()

    @Published var isWebViewActive = false

    private init() {}

    func setWebViewActive(_ active: Bool) {
        isWebViewActive = active
        updateOrientation()
    }

    private func updateOrientation() {
        if #available(iOS 16.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if isWebViewActive {
                    let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .allButUpsideDown)
                    windowScene.requestGeometryUpdate(geometryPreferences) { _ in }
                } else {
                    let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .portrait)
                    windowScene.requestGeometryUpdate(geometryPreferences) { _ in }
                }
            }
        }
    }
}
