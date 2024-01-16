import Foundation
import SwiftUI

/// Used to configure the appearance of the Force Update Screen.
/// Uses default localizations if either `titleText`, `messageText` or `toAppStoreButtonTitle` are not set.
public struct ForceUpdateAppearance {
    public let image: Image
    public let imageForegroundColor: Color
    public let titleText: String
    public let messageText: String
    public let toAppStoreButtonTitle: String
    public let toAppStoreButtonTintColor: Color

    public init(
        image: Image = Image(systemName: "app.badge"),
        imageForegroundColor: Color,
        titleText: String? = nil,
        messageText: String? = nil,
        toAppStoreButtonTitle: String? = nil,
        toAppStoreButtonTintColor: Color
    ) {
        self.image = image
        self.imageForegroundColor = imageForegroundColor
        self.titleText = titleText ?? String(localized: "force_update_title", bundle: Bundle.module)
        self.messageText = messageText ?? String(localized: "force_update_message", bundle: Bundle.module)
        self.toAppStoreButtonTitle = toAppStoreButtonTitle ?? String(localized: "force_update_action_to_app_store", bundle: Bundle.module)
        self.toAppStoreButtonTintColor = toAppStoreButtonTintColor
    }
}
