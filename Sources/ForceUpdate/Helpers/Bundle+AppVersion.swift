import Foundation

extension Bundle {
    var appVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var semanticAppVersion: SemanticVersion? {
        appVersion.flatMap { SemanticVersion($0) }
    }
}
