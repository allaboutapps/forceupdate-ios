import Combine
import Foundation
import os

/// A controller that handles all the ForceUpdate feature logic.
public actor ForceUpdateController {
    // MARK: Interface

    /// JSONDecoder used for decoding the App Store lookup result
    public let appStoreLookupDecoder: JSONDecoder

    /// JSONDecoder used for decoding the Public Version lookup result
    public let publicVersionLookupDecoder: JSONDecoder

    /// Configures the timeout used for fetching App Store informations
    public let appStoreLookupTimeout: TimeInterval

    /// Configures the timeout used for fetching version info from configured version URL
    public let publicVersionLookupTimeout: TimeInterval

    /// Configures the URL for fetching the public version JSON file hosted by you
    public let publicVersionURL: URL

    /// Configures the URL for fetching the App Store information of your already published app.
    ///
    /// Defaults to `https://itunes.apple.com/lookup?bundleId=\(Bundle.main.bundleIdentifier)&country=at`
    public let appStoreLookupURL: URL

    public init(
        publicVersionURL: URL,
        appStoreLookupURL: URL = URL(
            string: "https://itunes.apple.com/lookup?bundleId=\(Bundle.main.bundleIdentifier!)&country=at"
        )!,
        appStoreLookupDecoder: JSONDecoder = Decoders.iso801,
        publicVersionLookupDecoder: JSONDecoder = Decoders.standardJSON,
        appStoreLookupTimeout: TimeInterval = 120.0,
        publicVersionLookupTimeout: TimeInterval = 120.0
    ) {
        self.publicVersionURL = publicVersionURL
        self.appStoreLookupURL = appStoreLookupURL
        self.appStoreLookupDecoder = appStoreLookupDecoder
        self.publicVersionLookupDecoder = publicVersionLookupDecoder
        self.appStoreLookupTimeout = appStoreLookupTimeout
        self.publicVersionLookupTimeout = publicVersionLookupTimeout
    }

    /// AsyncSequence that emits a value if the force update screen should be displayed. Returns AppStore URL of the app.
    public private(set) nonisolated lazy var onForceUpdateNeededAsyncSequence = onForceUpdateNeededSubject.values

    /// Combine Publisher that emits a value if the force update screen should be displayed. Returns AppStore URL of the app.
    public private(set) nonisolated lazy var onForceUpdateNeededPublisher = onForceUpdateNeededSubject.eraseToAnyPublisher()

    /// Returns true, if a newer update of the application is available in the AppStore.
    /// This does NOT mean a force update.
    public private(set) var isUpdateAvailable: Bool = false

    /// Returns true, if a force update of the application is needed.
    public private(set) var isForceUpdateNeeded: Bool = false

    /// Returns the date of the last check of AppStore API and project version JSON.
    public private(set) var lastCheck: Date?

    /// Returns the current version of the app.
    public private(set) var appVersion: SemanticVersion? = Bundle.main.semanticAppVersion

    /// Returns the current version of the app on the AppStore.
    public private(set) var appStoreVersion: SemanticVersion?

    /// Returns the current minimum project version from the project version JSON.
    public private(set) var minimumProjectVersion: SemanticVersion?

    /// Returns the AppStore look up result, if available.
    public private(set) var appStoreLookUp: AppStoreLookUpResult?

    /// Checks for updates. Thread-safe.
    /// Fetches current version from AppStore and from project version JSON.
    public func checkForUpdate() async {
        if let checkForUpdateTask {
            return await checkForUpdateTask.value
        }

        let checkForUpdateTask = Task<Void, Never> { [weak self] in
            guard let self else { return }
            return await self.internalCheckForUpdate()
        }

        self.checkForUpdateTask = checkForUpdateTask
        defer { self.checkForUpdateTask = nil }
        return await checkForUpdateTask.value
    }

    // MARK: Private

    private var checkForUpdateTask: Task<Void, Never>?
    private nonisolated let onForceUpdateNeededSubject = PassthroughSubject<URL?, Never>()

    private func internalCheckForUpdate() async {
        os_log(.info, "checking for app update...")

        // load infos in parallel
        async let appStoreInfoLoad = fetchAppStoreInfo()
        async let forceUpdateInfoLoad = fetchForceUpdateInfo()

        // wait for parallel loading to finish
        let (appStoreInfo, forceUpdateInfo) = await (appStoreInfoLoad, forceUpdateInfoLoad)

        let safeAppVersion = Bundle.main.semanticAppVersion
        let safeAppStoreVersion = SemanticVersion(appStoreInfo?.version)
        let safeMinimumProjectVersion = SemanticVersion(forceUpdateInfo?.iOS.minSupportedVersion)

        appVersion = safeAppVersion
        appStoreVersion = safeAppStoreVersion
        minimumProjectVersion = safeMinimumProjectVersion
        isUpdateAvailable = safeAppVersion < safeAppStoreVersion
        isForceUpdateNeeded = safeAppVersion < safeMinimumProjectVersion
        lastCheck = .now
        appStoreLookUp = appStoreInfo

        if isForceUpdateNeeded {
            let url = URL(appStoreInfo?.trackViewUrl)
            onForceUpdateNeededSubject.send(url)
        }
    }

    private func fetchAppStoreInfo() async -> AppStoreLookUpResult? {
        let request = URLRequest(
            url: appStoreLookupURL,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: appStoreLookupTimeout
        )

        let responseData = try? await URLSession.shared.data(for: request)

        guard let (data, _) = responseData else {
            return nil
        }

        do {
            let result = try appStoreLookupDecoder.decode(AppStoreLookUp.self, from: data)
            return result.results.first
        } catch {
            return nil
        }
    }

    private func fetchForceUpdateInfo() async -> ProjectVersion? {
        let request = URLRequest(
            url: publicVersionURL,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: publicVersionLookupTimeout
        )

        let responseData = try? await URLSession.shared.data(for: request)

        guard let (data, _) = responseData else {
            return nil
        }

        return try? publicVersionLookupDecoder.decode(ProjectVersion.self, from: data)
    }
}
