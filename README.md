# uni_links_macos
A macOS implementation of the uni_links package for Flutter

## Installation
Add the following to your `pubspec.yaml`:
```yaml
dependencies:
    # ... your other dependencies
    uni_links2: ^0.6.0+2
    uni_links_macos:
        git: https://github.com/SamJakob/uni_links_macos.git
```

Then, to set up the links in your Xcode project you can just follow the [for iOS](https://github.com/avioli/uni_links/tree/master/uni_links#for-ios) section in the `uni_links` package.

### NOTE:
You will need to add a temporary workaround to bridge the delegate methods in the plugin to those of your app because `addApplicationDelegate` is not currently implemented on the Flutter Plugin registrant for macOS (see [flutter/flutter#41471](https://github.com/flutter/flutter/issues/41471)).

You can do this by copying the following into the `AppDelegate.swift` class in your project's macOS/Runner directory:

```swift
// Add this import!
import uni_links_macos

// This class declaration will already exist.
@NSApplicationMain
class AppDelegate: FlutterAppDelegate {

  // Add the following three methods!

  override func application(_ application: NSApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool {
    return UniLinksMacosPlugin.getInstance()?.application(application, continue: userActivity, restorationHandler: restorationHandler) ?? false;
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(AppDelegate.handleEvent(_:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL));
  }

  @objc func handleEvent(_ event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
    UniLinksMacosPlugin.getInstance()?.handleEvent(event, withReplyEvent: withReplyEvent);
  }
```