# Pisano Feedback iOS SDK

Pisano Feedback iOS SDK is an SDK that allows you to easily integrate user feedback collection into your iOS applications. With this SDK, you can collect surveys and feedback from your users and improve the user experience.

## 📋 Table of Contents

- [Features](#-features)
- [Requirements](#-requirements)
  - [Migrating from 1.x](#migrating-from-1x)
- [Installation](#-installation)
  - [Installation with Swift Package Manager](#installation-with-swift-package-manager)
  - [Installation with CocoaPods](#installation-with-cocoapods)
- [Quick Start](#-quick-start)
- [API Reference](#-api-reference)
  - [CloseStatus](#closestatus)
  - [Events: `Pisano.subscribe()`](#pisanosubscribe--events)
  - [App Store review: `Pisano.automaticStoreReview`](#pisanoautomaticstorereview--app-store-review-prompt)
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
- ✅ **Events**: `Pisano.subscribe` reports when a survey opens, is submitted and closes (and why)
- ✅ **Typed customer**: `PisanoCustomer` with fixed fields, the same as Android

## 📱 Requirements

- iOS 15.0 or higher
- Xcode 16.0 or higher
- Swift 5.9 or higher. Apps in the **Swift 6 language mode** (complete strict concurrency) use the SDK without warnings: completions and event handlers are `@MainActor`, and `PisanoTask`, `PisanoSubscription`, `PisanoEvent` and the enums are `Sendable`.

> iOS 12–14 are no longer supported. Apps that still need to run on iOS 12–14 can stay on SDK `1.1.0`.

### Migrating from 1.x

- Minimum iOS is 15.0.
- `CloseStatus.initSucces` is now `.initSuccess` and `.surveyPassive` is now `.channelPassive`. The old Swift names still compile with a deprecation warning (a `switch` listing them without `default` does not); Objective-C names are unchanged.
- A submitted chat survey reports `.sendFeedback` (was `.closed`). Closing the thank-you screen early reports `.sendFeedback` once (was `.closed`, then `.sendFeedback`).
- Your app dismissing the widget now ends `show` with `.closed`; a survey page that cannot load ends it with `.none`.
- Customer: the `customer:` dictionary parameter of `show`, `healthCheck` and `track` is replaced by `pisanoCustomer:`, which takes a typed `PisanoCustomer`. A misspelled key used to be dropped without any sign; a misspelled field now does not compile. `track` now sends the customer in the same format as `show`.

  ```swift
  // 1.x
  Pisano.show(customer: ["name": "Ada", "phoneNumber": "+90555", "customAttrs": ["plan": "gold"]]) { _ in }
  // 2.0
  Pisano.show(pisanoCustomer: PisanoCustomer(name: "Ada", phoneNumber: "+90555",
                                             customAttributes: ["plan": "gold"])) { _ in }
  ```
- To know the moment feedback is submitted, or how the widget closed, use [`Pisano.subscribe()`](#pisanosubscribe--events).

See [RELEASE_NOTES_2.0.0.md](RELEASE_NOTES_2.0.0.md) for the full list.

## 📦 Installation

### Installation with Swift Package Manager

1. In Xcode, go to **File → Add Package Dependencies...**
2. Enter `https://github.com/Pisano/pisano-ios` and choose **Up to Next Major Version** from `2.0.0`.
3. Add the `PisanoFeedback` product to your app target.

### Installation with CocoaPods

1. Create or edit your `Podfile`:

```ruby
platform :ios, '15.0'
use_frameworks!

target 'YourApp' do
  pod 'Pisano', '~> 2.0'
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
           pisanoCustomer: PisanoCustomer(name: "John Doe",
                                          email: "john@example.com",
                                          phoneNumber: "+1234567890",
                                          externalId: "CRM-12345"),
           payload: ["source": "app", "screen": "home"],
           dismissOnDrag: true,
           completion: { status in
               print("Status: \(status.description)")
           })
```

## 📚 API Reference

`boot`, `healthCheck`, `show` and `track` return a `PisanoTask` that can cancel the call (see [Cancellation](#cancellation)); keeping it is optional. Their `completion` is always called asynchronously on the main thread.

### CloseStatus

The `CloseStatus` enum is the result of a call, reported once. For `show` it says how the call ended; what happened on the way (opened, submitted, how the widget closed) comes through [`Pisano.subscribe()`](#pisanosubscribe--events).

The survey was shown:
- `.sendFeedback`: The survey was submitted, however the widget closed afterwards. After a submit the thank-you screen closes itself after 3 seconds; closing it earlier (close button, drag, outside tap) or closing a chat survey later is still `.sendFeedback`
- `.closed`: Closed without submitting: close button, drag (`dismissOnDrag: true`), or your app dismissing the widget
- `.outside`: Closed without submitting by a tap outside the bottom sheet
- `.none`: No result: `clear()` ended the session, the survey page could not be loaded, or the call was cancelled

The survey was not shown:
- `.displayOnce`: Already shown before
- `.preventMultipleFeedback`: The customer already submitted feedback in the given time period
- `.channelQuotaExceeded`: The channel quota is exceeded
- `.channelPassive`: The survey is passive
- `.displayRateLimited`: Not shown due to `display_rate`

`boot` results: `.initSuccess`, `.initFailed`. `.opened` is never reported (use the `opened` event); `.healthCheckSuccessful` / `.healthCheckFailed` are internal (`healthCheck` reports a `Bool`).

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
  
  Returns `.initSuccess` or `.initFailed`. See [CloseStatus](#closestatus) for all possible values.

**Example:**

```swift
Pisano.boot(appId: "app-123",
           accessKey: "key-456",
           code: "code-789",
           apiUrl: "https://api.pisano.co",
           feedbackUrl: "https://web.pisano.co/web_feedback",
           eventUrl: "https://event.pisano.co") { status in
    switch status {
    case .initSuccess:
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
  - `.bottomSheet`: Bottom sheet
- `title: NSAttributedString?` - Custom title (optional)
- `language: String?` - Language code (e.g., "en", "tr") (optional)
- `pisanoCustomer: PisanoCustomer?` - User information (optional), see [User Information](#user-information)
- `payload: [String: String]?` - Extra data (optional)
- `code: String?` - Override code for this call (optional). If not provided, SDK uses the code passed in `Pisano.boot(...)`.
- `dismissOnDrag: Bool` - **Optional (default: `false`).** When `true` and `mode` is `.bottomSheet`, the sheet shows a grabber and the user can dismiss it by dragging down; `completion` is then called with `.closed` (or `.sendFeedback` after a submit). When `false`, swipe dismiss is disabled
- `completion: (CloseStatus) -> Void` - Called once with the result
  
  See [CloseStatus](#closestatus) for all possible return values.

**User Information Keys:** `name`, `email`, `phoneNumber`, `externalId`, `customAttributes` (Dictionary). See [User Information](#user-information) for accepted spellings.

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
           pisanoCustomer: PisanoCustomer(name: "John Doe",
                                          email: "john@example.com",
                                          externalId: "USER-123"),
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
- `pisanoCustomer: PisanoCustomer?` - User information (optional)
- `language: String?` - Language code (optional)
- `completion: (CloseStatus) -> Void` - Completion callback

**Example:**

```swift
Pisano.track(event: "purchase_completed",
            payload: ["order_id": "12345", "amount": "99.99"],
            pisanoCustomer: PisanoCustomer(email: "john@example.com"),
            language: "en") { status in
    print("Event tracked: \(status.description)")
}
```

### `Pisano.healthCheck()`

Checks the SDK status. It is recommended to use this before displaying the feedback widget.

**Parameters:**
- `language: String?` - Language code (optional)
- `pisanoCustomer: PisanoCustomer?` - User information (optional)
- `payload: [String: String]?` - Extra data (optional)
- `code: String?` - Override code for this call (optional). If not provided, SDK uses the code passed in `Pisano.boot(...)`.
- `completion: (Bool) -> Void` - Health check result (true: successful, false: failed)

**Example:**

```swift
Pisano.healthCheck(pisanoCustomer: PisanoCustomer(externalId: "USER-789"),
                   code: nil) { isHealthy in
    if isHealthy {
        Pisano.show()
    } else {
        print("SDK health check failed")
    }
}
```

### `Pisano.subscribe()` — Events

Subscribe to what happens while a survey is on screen. The `show()` completion still reports the result once; events add the steps on the way.

```swift
let subscription = Pisano.subscribe { event in
    switch event.type {
    case .opened:
        print("Survey \(event.code) is on screen")
    case .feedbackSubmitted:
        print("Feedback submitted (chat: \(event.hasChat))")
    case .redirectedToStore:
        print("Survey asked for the store review flow")
    case .closed:
        print("Widget closed, reason: \(event.closeReason)")
    @unknown default:
        break
    }
}

// Later, to stop receiving events:
subscription.cancel()
```

```objc
PisanoSubscription *subscription = [Pisano subscribe:^(PisanoEvent *event) {
    if (event.type == PisanoEventTypeFeedbackSubmitted) { /* … */ }
}];
```

| Event | When | Fields |
|---|---|---|
| `.opened` | The survey widget is on screen | `code` |
| `.feedbackSubmitted` | The user submitted the survey, the moment the survey reports it (also in chat surveys) | `code`, `hasChat` |
| `.redirectedToStore` | The survey asked for the store review flow | `code`, `handledBySDK` |
| `.closed` | The widget left the screen, right before the `show()` completion | `code`, `closeReason` |

`closeReason`: `.closeButton`, `.drag`, `.outside`, `.afterSubmit` (the thank-you screen closed itself), `.clear`, `.loadFailed`, `.hostDismissed` (your app dismissed the widget).

- For one survey, events arrive in this order, all before the `show()` completion: `opened`, `feedbackSubmitted`, `redirectedToStore`, `closed`.
- A survey that is not shown (display once, passive, …) sends no events, only the completion.
- A widget that closes before it finished appearing (`clear()`, a page that cannot load) may send `closed` without `opened`.
- Events are delivered on the main thread. A subscription stays active until `cancel()`, whether or not you keep the object.

### `Pisano.automaticStoreReview` — App Store review prompt

When a survey redirects to the store review flow, the SDK asks for the App Store review prompt by default. To run your own flow instead, turn it off and react to the `redirectedToStore` event:

```swift
import StoreKit

Pisano.automaticStoreReview = false   // default: true

Pisano.subscribe { event in
    guard event.type == .redirectedToStore, !event.handledBySDK,
          let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
    SKStoreReviewController.requestReview(in: scene)   // or your own flow
}
```

- The `redirectedToStore` event is sent either way; `handledBySDK` is `true` when the SDK asked for the prompt.
- The system does not tell whether the prompt was actually shown (Apple limits how often it appears), so `handledBySDK` means "asked", not "seen".
- The setting does not change the `show()` result, applies to the next review request, is safe to set from any thread, and is not stored: it is `true` again on the next app launch.

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
PisanoTask *task = [Pisano healthCheckWithLanguage:nil pisanoCustomer:nil payload:nil code:nil
                                        completion:^(BOOL isHealthy) { /* main thread */ }];
[task cancel];
```

### Known limitations

- `track`'s `completion` is not called when the event is sent or fails yet; it is only called on `cancel()`.
- When the survey is not shown (no boot data, no connection, a failed request, nothing to present on), `show` ends with `.none`. `clear()` ends a `show` at any stage with `.none`, including one about to be presented, which is then not shown.
- If the widget is presented but the survey page cannot load (for example no connection), the widget closes and `completion` is called once with `.none`.
- The survey shows its thank-you screen 2–3 seconds before it reports the submit. If the user closes it in that time, `show` ends with `.closed` and no `feedbackSubmitted` event is sent.

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
| | iOS 15–16: the app's default web data store | ✅ the survey's localStorage entries on the feedback origin |

`clear()` also ends the session's work in progress:

- Calls still running are cancelled; their `completion` is called once with the cancel status (see [Cancellation](#cancellation)). Their responses are dropped, so they cannot write the previous session's data back.
- An open survey is closed; its `completion` is called once with `.none`.
- A survey shown right after `clear()` waits until the web data removal has finished.

`clear()` never touches the host app's own data: its UserDefaults keys, Keychain items, `HTTPCookieStorage.shared`, URL cache or its own web views.

### Notes

- **iOS 15–16:** the survey shares the app's default web data store. Only the survey's own localStorage entries are removed, never anything else in that store, because on on-premise installs it can hold the host app's data for the same domain.
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
                   pisanoCustomer: PisanoCustomer(externalId: "USER-123"),
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
                           pisanoCustomer: PisanoCustomer(email: "user@example.com"),
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
          pisanoCustomer:[[PisanoCustomer alloc] initWithName:nil email:nil phoneNumber:nil
                                               externalId:@"USER-123" customAttributes:nil]
                 payload:nil
                    code:nil
           dismissOnDrag:NO
              completion:^(enum CloseStatus status) {
        NSLog(@"Feedback status: %@", @(status));
    }];
}

@end
```

### Widget events

The result of each call comes through its `completion`; what happens while a survey is on screen comes through [`Pisano.subscribe()`](#pisanosubscribe--events). The SDK does not post `NotificationCenter` notifications; the `pisano-actions` notification of older versions no longer exists.

## ⚙️ Configuration

### ViewMode

You can select the view mode:

```swift
// Full-screen overlay (default)
Pisano.show(mode: .default)

// Bottom sheet
Pisano.show(mode: .bottomSheet)

// Bottom sheet with drag-to-dismiss
Pisano.show(mode: .bottomSheet, dismissOnDrag: true) { _ in }
```

**Bottom sheet behaviour:** The sheet opens at half height (`.medium`) and can be expanded to full height (`.large`). By default swipe-down dismiss is disabled. Pass `dismissOnDrag: true` to show a grabber and let the user dismiss the sheet by dragging down; `completion` is called once.

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

You can provide a personalized experience by sending user information with `PisanoCustomer`. Its fields are fixed, so a misspelled field is a compile error instead of data that never arrives. Set only the fields you have; the others are not sent.

```swift
let customer = PisanoCustomer(
    name: "John Doe",
    email: "john@example.com",
    phoneNumber: "+1234567890",
    externalId: "CRM-12345",
    customAttributes: ["language": "en", "city": "New York"]
)

Pisano.show(mode: .bottomSheet, pisanoCustomer: customer) { status in }
Pisano.track(event: "purchase", pisanoCustomer: customer) { status in }
```

```objc
PisanoCustomer *customer = [[PisanoCustomer alloc] initWithName:@"John Doe" email:@"john@example.com"
                                                    phoneNumber:@"+1234567890" externalId:@"CRM-12345"
                                               customAttributes:@{@"city": @"New York"}];
[Pisano showWithMode:ViewModeBottomSheet title:nil language:nil pisanoCustomer:customer
             payload:nil code:nil dismissOnDrag:NO completion:^(enum CloseStatus status) {}];
```

**Customer fields** (same names as Android, React Native and Flutter): `name`, `email`, `phoneNumber`, `externalId`, `customAttributes` (any other attributes, e.g. `["plan": "gold"]`).

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

### Customer data does not show in the panel

Check that the fields are set on the `PisanoCustomer` you pass as `pisanoCustomer:`; fields left `nil` are not sent. Other attributes go in `customAttributes`.
