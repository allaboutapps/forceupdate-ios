# Force Update iOS

## Getting started
Start by configuring the `ForceUpdateController` singleton. Per default, it uses `Bundle.main.bundleIdentifier` for the App Store lookup of your already published app to get the newest available version from the App Store to set the `isUpdateAvailable` flag.

The `publicVersionURL` is used to configure where to get the latest version info of your app hosted by yourself to set the `isForceUpdateAvailable` flag.

Use the `configure` function before using the `checkForUpdate` function! e.g. in your `AppDelegate`.
```
func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    Task {
        await ForceUpdateController.shared.configure(
            publicVersionURL: .init(string: "https://your-url-where-to-find-public/version.json")!
        )
}

``` 

<br>

## Check for update

To check for updates, call the `checkForUpdate()` function, e.g. in your `AppDelegate`.

```
func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    // call `configure` before calling `checkForUpdate()`
    Task {
        await ForceUpdateController.shared.checkForUpdate()
    }
}
```
### Listen to update

To listen to updates, either use `onForceUpdateNeededAsyncSequence` or `onForceUpdateNeededPublisher`.
Both variables will return an optional `URL` for the App Store page of your app to pass into the `ForceUpdateWindow` for the App Store button.

These variables will be updated after calling `checkForUpdate()`.

```
Task {
    for await url in ForceUpdateController.shared.onForceUpdateNeededAsyncSequence {
        self.presentForceUpdate(url: url)
    }
}
```
<br>

## Showing Force Update Screen

To present the blocking Force Update Screen, just initialize a new `ForceUpdateWindow` and call `start()` on it.
```
func presentForceUpdate(url: URL?) {
    guard forceUpdateWindow == nil else { return }
    forceUpdateWindow = ForceUpdateWindow(
        appStoreURL: url,
        appearance: appearance
    )
    
    forceUpdateWindow?.start()
}
```

### SwiftUI
In SwiftUI, the blocking Force Update Screen can also be used directly as is with the `ForceUpdateScreen`.

```
ForceUpdateScreen(
    appStoreURL: url,
    appearance: appearance
)

```

### Configuring the appearance
The appearance of the blocking Force Update Screen can be configured using the `ForceUpdateAppearance` struct you have to pass to the `ForceUpdateWindow` initializer.

```
ForceUpdateAppearance(
    image: .init(systemName: "app.badge"),
    imageForegroundColor: .green,
    titleText: "New Update available",
    messageText: "Update to the latest version to continue using the app",
    toAppStoreButtonTitle: "Go to App Store",
    toAppStoreButtonTintColor: .green
)
```

**Note:** Per default, the image is set to the system image `app.badge` and the `titleText`, `messageText`and `toAppStoreButtonTitle` are localized with default localizations for German and English.
