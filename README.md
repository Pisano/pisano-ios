# Pisano Feedback iOS SDK

Pisano Feedback iOS SDK is an SDK that allows you to easily integrate user feedback collection into your iOS applications. With this SDK, you can collect surveys and feedback from your users and improve the user experience.

## 📋 Table of Contents

- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#-installation)
  - [Installation with Swift Package Manager](#installation-with-swift-package-manager)
  - [Installation with CocoaPods](#installation-with-cocoapods)
- [Quick Start](#-quick-start)
- [API Reference](#-api-reference)
  - [CloseStatus](#closestatus)
- [Threading, Timeout and Cancellation](#-threading-timeout-and-cancellation)
- [Logout and User / Tenant Switch](#-logout-and-user--tenant-switch)
- [Usage Examples](#-usage-examples)
- [Configuration](#️-configuration)
- [Frequently Asked Questions](#-frequently-asked-questions)
- [Troubleshooting](#-troubleshooting)

## ✨ Features

- ✅ **Web-Based Feedback Forms**: Modern and flexible web-based form support
- ✅ **Native iOS Integration**: Native iOS SDK (Swift/Objective-C) with WebView-based UI
- ✅ **Objective-C Compatibility**: Can be used in both Swift and Objective-C projects
- ✅ **Flexible View Modes**: Full-screen and bottom sheet view options
- ✅ **Event Tracking**: Ability to track events
- ✅ **Health Check**: Ability to check SDK status
- ✅ **User Information Support**: Ability to send user data
- ✅ **Multi-Language Support**: Ability to display surveys in different languages
- ✅ **Custom Title**: Customizable title support
- ✅ **Non-Blocking**: Network calls never block the calling thread; callbacks arrive on the main thread
- ✅ **Timeout and Cancellation**: `Pisano.requestTimeout` and a cancellable `PisanoTask` for every call
- ✅ **Session Isolation**: `Pisano.clear()` removes all SDK data on logout or user / tenant switch
- ✅ **Privacy**: Credentials in the Keychain, no cached API responses, privacy manifest included

## 📱 Requirements

- iOS 12.0 or higher
- Xcode 12.0 or higher
- Swift 5.0 or higher

## 📦 Installation

### Installation with Swift Package Manager

1. In Xcode, go to **File → Add Package Dependencies...**
2. Enter `https://github.com/Pisano/pisano-ios` and choose **Up to Next Major Version** from `1.1.0`.
3. Add the `PisanoFeedback` product to your app target.

### Installation with CocoaPods

1. Create or edit your `Podfile`:

```ruby
platform :ios, '12.0'
use_frameworks!

target 'YourApp' do
  pod 'Pisano', '~> 1.1'
end
```

2. Run the following command in Terminal:

```bash
pod install
```

3. Open the `.xcworkspace` file with Xcode.

## 🚀 Quick Start

### 1. Initializing the SDK

You must initialize the SDK before using it. The SDK initialization should be done either at application startup (usually in `AppDelegate`) or somewhere before calling the `show()` method.

#### Swift

```swift
import PisanoFeedback

// In AppDelegate
func application(_ application: UIApplication, 
                didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    #if DEBUG
    Pisano.debugMode(true) // Show logs only in debug mode
    #endif
    
    Pisano.boot(appId: "YOUR_APP_ID",
                accessKey: "YOUR_ACCESS_KEY",
                code: "YOUR_CODE",
                apiUrl: "https://api.pisano.co",
                feedbackUrl: "https://web.pisano.co/web_feedback",
                eventUrl: "https://event.pisano.co") { status in
        print("Boot status: \(status.description)")
    }
    
    return true
}
```

#### Objective-C

```objc
#import <PisanoFeedback/PisanoFeedback-Swift.h>

- (BOOL)application:(UIApplication *)application 
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    #if DEBUG
    [Pisano debugMode:YES];
    #endif
    
    [Pisano bootWithAppId:@"YOUR_APP_ID"
               accessKey:@"YOUR_ACCESS_KEY"
                   code:@"YOUR_CODE"
                  apiUrl:@"https://api.pisano.co"
             feedbackUrl:@"https://web.pisano.co/web_feedback"
                eventUrl:@"https://event.pisano.co"
              completion:^(enum CloseStatus status) {
        NSLog(@"Boot status: %@", @(status));
    }];
    
    return YES;
}
```

### 2. Showing the Feedback Widget

#### Basic Usage

```swift
Pisano.show { status in
    print("Feedback closed with status: \(status.description)")
}
```

#### Advanced Usage

```swift
Pisano.show(mode: .bottomSheet,
           title: NSAttributedString(string: "We Value Your Feedback"),
           language: "en",
           customer: [
               "name": "John Doe",
               "email": "john@example.com",
               "phoneNumber": "+1234567890",
               "externalId": "CRM-12345"
           ],
           payload: ["source": "app", "screen": "home"],
           code: nil,
           completion: { status in
               print("Status: \(status.description)")
           })
```

## 📚 API Reference

`boot`, `healthCheck`, `show` and `track` return a `PisanoTask` that can cancel the call (see [Cancellation](#cancellation)); keeping it is optional. Their `completion` is always called asynchronously on the main thread.

### CloseStatus

The `CloseStatus` enum is returned by various SDK methods to indicate the result of an operation.

**CloseStatus Values:**
- `.none`: No status / default value
- `.closed`: User clicked the close button
- `.opened`: Widget opened
- `.sendFeedback`: Feedback was sent
- `.outside`: Closed by clicking outside
- `.displayOnce`: Already shown before
- `.preventMultipleFeedback`: Multiple feedback prevention triggered
- `.channelQuotaExceeded`: Channel quota exceeded
- `.initFailed`: SDK initialization failed
- `.initSucces`: SDK initialized successfully
- `.healthCheckSuccessful`: Health check passed
- `.surveyPassive`: Survey is in passive state
- `.healthCheckFailed`: Health check failed
- `.displayRateLimited`: Not shown due to `display_rate`

### `Pisano.boot()`

Initializes the SDK. This method must be called either at application startup (usually in `AppDelegate`) or before calling the `show()` method.

`code` is required and represents the SDK configuration code that will be used by default.

**Parameters:**
- `appId: String` - Your application's unique ID (required)
- `accessKey: String` - Your API access key (required)
- `code: String` - SDK configuration code (required)
- `apiUrl: String` - API endpoint URL (required)
- `feedbackUrl: String` - Feedback widget URL (required)
- `eventUrl: String?` - Event tracking URL (optional)
- `completion: ((CloseStatus) -> Void)?` - Initialization result callback (optional)
  
  Returns `.initSucces` or `.initFailed`. See [CloseStatus](#closestatus) for all possible values.

**Example:**

```swift
Pisano.boot(appId: "app-123",
           accessKey: "key-456",
           code: "code-789",
           apiUrl: "https://api.pisano.co",
           feedbackUrl: "https://web.pisano.co/web_feedback",
           eventUrl: "https://event.pisano.co") { status in
    switch status {
    case .initSucces:
        print("SDK initialized successfully")
    case .initFailed:
        print("SDK initialization failed")
    default:
        break
    }
}
```

### `Pisano.show()`

Displays the feedback widget.

`code` is optional. If you don’t pass `code` to `Pisano.show(...)`, the SDK uses the `code` provided during `Pisano.boot(...)`.

If backend configuration prevents the survey from being shown due to `display_rate`, completion returns `.displayRateLimited`.

**Parameters:**
- `mode: ViewMode` - View mode (default: `.default`)
  - `.default`: Full-screen overlay
  - `.bottomSheet`: Bottom sheet (iOS 13+)
- `title: NSAttributedString?` - Custom title (optional)
- `language: String?` - Language code (e.g., "en", "tr") (optional)
- `customer: [String: Any]?` - User information (optional)
- `payload: [String: String]?` - Extra data (optional)
- `code: String?` - Override code for this call (optional). If not provided, SDK uses the code passed in `Pisano.boot(...)`.
- `completion: (CloseStatus) -> Void` - Widget close callback
  
  See [CloseStatus](#closestatus) for all possible return values.

**User Information Keys:**
- `name`: User name
- `email`: Email address
- `phoneNumber`: Phone number
- `externalId`: External system ID (CRM, etc.)
- `customAttrs`: Custom attributes (Dictionary)

**Example:**

```swift
Pisano.show(mode: .bottomSheet,
           title: NSAttributedString(
               string: "We Value Your Feedback",
               attributes: [
                   .font: UIFont.boldSystemFont(ofSize: 18),
                   .foregroundColor: UIColor.systemBlue
               ]
           ),
           language: "en",
           customer: [
               "name": "John Doe",
               "email": "john@example.com",
               "externalId": "USER-123"
           ],
           completion: { status in
               switch status {
               case .sendFeedback:
                   print("Feedback sent!")
               case .closed:
                   print("Widget closed")
               default:
                   break
               }
           })
```

### `Pisano.track()`

Tracks an event.

**Parameters:**
- `event: String` - Event name (required)
- `payload: [String: String]?` - Event payload data (optional)
- `customer: [String: Any]?` - User information (optional)
- `language: String?` - Language code (optional)
- `completion: (CloseStatus) -> Void` - Completion callback

**Example:**

```swift
Pisano.track(event: "purchase_completed",
            payload: ["order_id": "12345", "amount": "99.99"],
            customer: ["email": "john@example.com"],
            language: "en") { status in
    print("Event tracked: \(status.description)")
}
```

### `Pisano.healthCheck()`

Checks the SDK status. It is recommended to use this before displaying the feedback widget.

**Parameters:**
- `language: String?` - Language code (optional)
- `customer: [String: Any]?` - User information (optional)
- `payload: [String: String]?` - Extra data (optional)
- `code: String?` - Override code for this call (optional). If not provided, SDK uses the code passed in `Pisano.boot(...)`.
- `completion: (Bool) -> Void` - Health check result (true: successful, false: failed)

**Example:**

```swift
Pisano.healthCheck(customer: ["externalId": "USER-789"],
                   code: nil) { isHealthy in
    if isHealthy {
        Pisano.show()
    } else {
        print("SDK health check failed")
    }
}
```

### `Pisano.debugMode()`

Enables or disables debug mode. Detailed logs are displayed in debug mode.

```swift
#if DEBUG
Pisano.debugMode(true)
#else
Pisano.debugMode(false)
#endif
```

### `Pisano.clear()`

Ends the current session: cancels running calls, closes an open survey and removes all data the SDK stored for this session. Call it on logout and when switching users or tenants, then `boot` again. See [Logout and User / Tenant Switch](#-logout-and-user--tenant-switch) for the full list.

```swift
Pisano.clear()
```

## 🧵 Threading, Timeout and Cancellation

### Threading

| | |
|---|---|
| **Calling thread** | Call `boot`, `healthCheck`, `show`, `track` and `clear` from the **main thread** (recommended). |
| **Blocking** | None of them blocks the calling thread. Network requests run in the background, so calling them at app launch does not freeze the UI. |
| **Callback thread** | Every `completion` is invoked **asynchronously on the main thread**, so you can update the UI directly in it. |

### Timeout

`Pisano.requestTimeout` sets the network timeout, in seconds, for every SDK request. A request fails when the server sends no data for this long. The default is `60`; values `<= 0` reset it to the default. It applies to requests started after it is set.

```swift
Pisano.requestTimeout = 15
```

```objc
Pisano.requestTimeout = 15;
```

### Cancellation

`boot`, `healthCheck`, `show` and `track` return a `PisanoTask`. Keeping it is optional. Call `cancel()` to stop a call you no longer need, for example when the screen that started it is closed. `cancel()` can be called from any thread.

If the call has not finished yet, its network request is cancelled and `completion` is called **once**, on the main thread, with:

| Call | Status on cancel |
|---|---|
| `boot` | `.initFailed` |
| `healthCheck` | `false` |
| `show` | `.none` (widget is not shown) |
| `track` | `.none` |

If the call has already finished, or `show` has already presented the widget, `cancel()` does nothing. `isCancelled` tells whether the call was cancelled.

```swift
let task = Pisano.healthCheck { isHealthy in
    // Main thread
}
// Later, e.g. in viewWillDisappear:
task.cancel()
```

```objc
PisanoTask *task = [Pisano healthCheckWithLanguage:nil customer:nil payload:nil code:nil
                                        completion:^(BOOL isHealthy) { /* main thread */ }];
[task cancel];
```

### Known limitations

- `track`'s `completion` is not called when the event is sent or fails yet; it is only called on `cancel()`.
- Some `show` failures before the widget is presented (for example no boot data or a network error) do not call `completion` yet. Use `cancel()` to end a call you no longer wait for.

## 🔐 Logout and User / Tenant Switch

Call `Pisano.clear()` when a user logs out or when the app switches to another user or tenant (for example another seller in a marketplace app), then call `Pisano.boot(...)` for the new session:

```swift
Pisano.clear()
Pisano.boot(appId: newAppId, accessKey: newAccessKey, code: newCode,
            apiUrl: apiUrl, feedbackUrl: feedbackUrl) { status in /* … */ }
```

### What `clear()` removes

| Data | Where it is kept | Removed by `clear()` |
|---|---|---|
| Boot credentials (app id, access key, code, URLs) | Memory and Keychain (UserDefaults only if the Keychain is unavailable) | ✅ |
| SDK detail and trigger responses, last used code | Memory and UserDefaults | ✅ |
| "Display once" and display-rate state | UserDefaults | ✅ |
| Cookies set by the Pisano API (session, load balancer) | SDK's own in-memory cookie jar | ✅ |
| API responses | Never stored: requests use an ephemeral session with caching disabled | — |
| Survey web data: device id, "already answered" guard, incomplete surveys | iOS 17+: SDK's own web data store | ✅ everything in that store (cookies, local / session storage, IndexedDB, caches) |
| | iOS 12–16: the app's default web data store | ✅ the survey's localStorage entries on the feedback origin |

`clear()` also ends the session's work in progress:

- Calls still running are cancelled; their `completion` is called once with the cancel status (see [Cancellation](#cancellation)). Their responses are dropped, so they cannot write the previous session's data back.
- An open survey is closed; its `completion` is called once with `.none`.
- A survey shown right after `clear()` waits until the web data removal has finished.

`clear()` never touches the host app's own data: its UserDefaults keys, Keychain items, `HTTPCookieStorage.shared`, URL cache or its own web views.

### Notes

- **iOS 12–16:** the survey shares the app's default web data store. Only the survey's own localStorage entries are removed, never anything else in that store, because on on-premise installs it can hold the host app's data for the same domain.
- **Reinstall:** iOS keeps Keychain items when an app is deleted, so boot credentials can survive a reinstall. Call `clear()` (or `boot` with the current user's values) on first launch if that matters for your app.
- Call `clear()` from the main thread, like the other SDK calls.


## 💡 Usage Examples

### Swift Usage

#### UIKit Project

```swift
import UIKit
import PisanoFeedback

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func showFeedback(_ sender: Any) {
        Pisano.show(mode: .bottomSheet,
                   language: "en",
                   customer: ["externalId": "USER-123"],
                   completion: { status in
                       print("Feedback status: \(status.description)")
                   })
    }
}
```

#### SwiftUI Project

```swift
import SwiftUI
import PisanoFeedback

@main
struct MyApp: App {
    init() {
        #if DEBUG
        Pisano.debugMode(true)
        #endif
        
        Pisano.boot(appId: "YOUR_APP_ID",
                   accessKey: "YOUR_ACCESS_KEY",
                   code: "YOUR_CODE",
                   apiUrl: "https://api.pisano.co",
                   feedbackUrl: "https://web.pisano.co/web_feedback")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Button("Show Feedback") {
                Pisano.show(mode: .bottomSheet,
                           title: NSAttributedString(string: "Your Feedback"),
                           customer: ["email": "user@example.com"],
                           completion: { _ in })
            }
        }
    }
}
```

### Objective-C Usage

```objc
#import <PisanoFeedback/PisanoFeedback-Swift.h>

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)showFeedback:(id)sender {
    [Pisano showWithMode:ViewModeBottomSheet
                   title:nil
                language:@"en"
                customer:@{@"externalId": @"USER-123"}
                 payload:nil
                    code:nil
              completion:^(enum CloseStatus status) {
        NSLog(@"Feedback status: %@", @(status));
    }];
}

@end
```

### Widget events

Every outcome is reported through the `completion` of the call (`show`, `boot`, `healthCheck`, `track`). The SDK does not post `NotificationCenter` notifications; the `pisano-actions` notification of older versions was replaced by these callbacks.

## ⚙️ Configuration

### ViewMode

You can select the view mode:

```swift
// Full-screen overlay (default)
Pisano.show(mode: .default)

// Bottom sheet (iOS 13+)
Pisano.show(mode: .bottomSheet)
```

### Custom Title

You can customize the widget title:

```swift
let title = NSAttributedString(
    string: "WE VALUE YOUR FEEDBACK",
    attributes: [
        .font: UIFont.boldSystemFont(ofSize: 18),
        .foregroundColor: UIColor.systemBlue,
        .kern: 1.5
    ]
)

Pisano.show(title: title)
```

### User Information

You can provide a personalized experience by sending user information:

```swift
let customer: [String: Any] = [
    "name": "John Doe",
    "email": "john@example.com",
    "phoneNumber": "+1234567890",
    "externalId": "CRM-12345",
    "customAttrs": [
        "language": "en",
        "city": "New York",
        "gender": "male",
        "birthday": "1990-01-01"
    ]
]

Pisano.show(customer: customer)
```

**Valid user keys:**
- `name`: User name
- `email`: Email address
- `phoneNumber`: Phone number
- `externalId`: External system ID
- `customAttrs`: Custom attributes (Dictionary)

## ❓ Frequently Asked Questions

### When should I initialize the SDK?

You must initialize the SDK either at application startup (in `AppDelegate`) or before calling the `show()` method.

### Can I call the SDK at app launch?

Yes. Since 1.1.0 no SDK call blocks the calling thread; network requests run in the background and every `completion` arrives on the main thread. Call the SDK from the main thread.

### Should I use health check?

Health check allows you to check the SDK status before displaying the widget. It is recommended to use it before showing the widget on important screens.

### How can I display the widget in different languages?

You can display the widget in different languages using the `language` parameter:

```swift
Pisano.show(language: "en") // English
Pisano.show(language: "tr") // Turkish
```

### What is the display once feature?

This feature ensures that the widget is shown to the user only once. This control is managed by the backend.

## 🔧 Troubleshooting

### SDK won't initialize

1. Make sure `appId` and `accessKey` values are correct
2. Check that API URLs are accessible
3. Enable debug mode to review logs:

```swift
Pisano.debugMode(true)
```

### Widget won't display

1. Make sure `Pisano.boot()` method completed successfully
2. Check SDK status by performing a health check
3. Check internet connection

### Objective-C usage error

Make sure you added the `#import <PisanoFeedback/PisanoFeedback-Swift.h>` import in Objective-C projects.

### Bottom sheet not working

Bottom sheet feature requires iOS 13+. On versions below iOS 13, bottom sheet mode may not work properly, and it is recommended to use `.default` mode in this case.
