import Foundation
import SwiftUI

public struct ForceUpdateScreen: View {
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

    // MARK: Body

    public var body: some View {
        ScrollView {
            VStack(spacing: .zero) {
                appearance.image
                    .font(.system(size: 90))
                    .padding(.top, 64)
                    .foregroundColor(appearance.imageForegroundColor)
                VStack(spacing: 20) {
                    Text(appearance.titleText)
                        .font(.largeTitle)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                    Text(appearance.messageText)
                        .font(.body)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 48)
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
        }
        .scrollBounceBehaviorIfAvailable()
        .safeAreaInset(edge: .bottom) {
            Button(
                action: {
                    if let appStoreURL {
                        // open product page of the app in the AppStore
                        UIApplication.shared.open(appStoreURL)
                    } else {
                        // fallback: open AppStore
                        let url = URL(string: "itms-apps://itunes.apple.com/")!
                        UIApplication.shared.open(url)
                    }
                },
                label: {
                    Label(
                        appearance.toAppStoreButtonTitle,
                        systemImage: "arrowshape.turn.up.right.fill"
                    )
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .labelStyle(.centerAlignedLabelStyle)
                }
            )
            .buttonStyle(.borderedProminent)
            .tint(appearance.toAppStoreButtonTintColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.background)
        }
    }
}

// MARK: - Previews

struct ForceUpdateScreen_Previews: PreviewProvider {
    static var previews: some View {
        ForceUpdateScreen(
            appStoreURL: nil,
            appearance: .init(
                image: .init(systemName: "app.badge"),
                imageForegroundColor: .green,
                toAppStoreButtonTintColor: .green
            )
        )
    }
}
