import Foundation
import SwiftUI
import UIKit

@MainActor
public class ForceUpdateWindow {
    // MARK: Init

    private let appStoreURL: URL?
    private let appearance: ForceUpdateAppearance

    public init(
        appStoreURL: URL?,
        appearance: ForceUpdateAppearance
    ) {
        self.appStoreURL = appStoreURL
        self.appearance = appearance
    }

    // MARK: Properties

    private var window: UIWindow!

    // MARK: Start

    public func show() {
        // NOTE: if multiple scenes are supported this code may NOT work properly,
        // as this would only add a window on top of the active `windowScene`.
        // To fix this, a window per `windowScene` would need to be shown.
        let windowScene = UIApplication.shared
            .connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first

        if let windowScene = windowScene as? UIWindowScene {
            window = UIWindow(windowScene: windowScene)
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
        }

        let viewController = UIHostingController(
            rootView: ForceUpdateScreen(
                appStoreURL: appStoreURL,
                appearance: appearance
            )
        )
        viewController.modalPresentationStyle = .fullScreen

        window.rootViewController = viewController
        window.windowLevel = UIWindow.Level.alert + 1
        window.makeKeyAndVisible()
    }
}
