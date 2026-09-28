# Release 1.1.0

Non-blocking API with timeout and cancellation, session isolation on `clear()`, and security / privacy hardening.

This is a **minor** release with behaviour changes (see [Behaviour changes](#behaviour-changes)). Existing Swift and Objective-C code compiles without changes.

## Highlights

### Non-blocking calls, main-thread callbacks (MT-79, MT-89)

- `boot`, `healthCheck`, `show` and `track` no longer block the calling thread. Before, each call waited for the whole network round-trip; called from the main thread (for example at app launch) this froze the UI.
- Every `completion` is called **asynchronously on the main thread**, including early failures (no network, not booted). Completions are typed `@MainActor`, so UI can be updated directly in them.
- Calling the SDK from the main thread is recommended.

### Timeout and cancellation (new API)

- `Pisano.requestTimeout` (seconds, default `60`) sets the network timeout of every SDK request.
- `boot`, `healthCheck`, `show` and `track` now return a `PisanoTask` (`@discardableResult`, so existing calls are unchanged). `cancel()` stops the call; its completion is called once with `.initFailed` (boot), `false` (healthCheck) or `.none` (show, track). After the call finished, or once `show` has presented the survey, `cancel()` does nothing.

```swift
Pisano.requestTimeout = 15
let task = Pisano.healthCheck { isHealthy in /* main thread */ }
task.cancel()
```

### Logout and user / tenant switch: `clear()` (MT-84, MT-82)

`Pisano.clear()` now ends the session completely, so nothing of one user or tenant (for example a seller) carries over to the next:

- cancels the session's calls still running (their response is dropped) and closes an open survey (completion `.none`);
- removes the boot credentials from memory and the Keychain, the cached SDK detail / trigger, the display-once and display-rate state, and the SDK's API cookies;
- removes the survey's web data (device id, "already answered" guard, incomplete surveys): on iOS 17+ everything in the SDK's own web data store, on iOS 12–16 the survey's localStorage entries on the feedback origin. A survey shown right after `clear()` waits until this has finished;
- never touches the host app's own data, cookies or web views.

The README section "Logout and User / Tenant Switch" lists every item.

### Security and privacy

- **MT-82:** boot credentials (including the access key) are stored in the Keychain instead of UserDefaults. Existing caches are moved on first launch.
- **MT-81:** API responses are never cached, and requests send `Cache-Control: no-store`. Request URLs carry credentials.
- **MT-84:** API requests use an ephemeral session with an in-memory cookie jar owned by the SDK; nothing is written to `HTTPCookieStorage.shared` or disk. On iOS 17+ the survey runs in a web data store of its own, isolated from the app's web views. Existing survey state is carried over once, on the first presentation after the update.
- **MT-80:** `PrivacyInfo.xcprivacy` privacy manifest is included in the framework.
- **MT-83:** widget URL query values are percent-encoded (a `+` in a payload is no longer read as a space).

### Presentation

- **MT-85:** the survey is presented from the active window scene (iPad multi-window, Stage Manager, split view) instead of the deprecated `keyWindow`.
- **MT-88:** `show()` settings (mode, title, dismiss on drag) belong to that call; overlapping `show()` calls no longer mix them.

### Swift 6 (MT-89)

`CloseStatus`, `ViewMode` and `PisanoTask` are `Sendable`, and completions are `@MainActor`, so the public API compiles cleanly in Swift 6 language mode with complete strict concurrency.

## Behaviour changes

- Completions are now always asynchronous. Code that expected a completion to have run before the call returned (possible for early failures before) must wait for the callback.
- `boot`, `healthCheck`, `show` and `track` return `PisanoTask`. Source compatible for Swift (`@discardableResult`) and Objective-C (same selectors).
- `clear()` now cancels running calls and closes an open survey.
- `URLSession.requestSynchronousData(request:)` was removed. It was public by mistake and is not part of the SDK API.

## Known limitations

- `track`'s completion is only called on `cancel()`, not when the event is sent or fails.
- Some `show` failures before the survey is presented (for example not booted, or a network error) do not call the completion; use the returned task's `cancel()` to end a call you no longer wait for.

## Compatibility

- Minimum iOS: **12.0** (unchanged)
- Built with Xcode 16.4 (iOS 18.5 SDK), module-stable (`.swiftinterface`)
- Swift 5 and Swift 6 language modes
- Tested on iOS 18.2, 18.6, 26.0–26.2 and 27.0 simulators (iPhone and iPad) against a live environment. The iOS 12 minimum was checked by compiling the SDK and a client against the iOS 12 target.

## Upgrade

| Method | How |
|--------|-----|
| **SPM** | `https://github.com/Pisano/pisano-ios`, tag `1.1.0` ("Up to Next Major" from 1.0.x picks it up) |
| **CocoaPods** | `pod 'Pisano', '~> 1.1'` |
| **Manual** | Replace `PisanoFeedback.xcframework` with this release |

The React Native and Flutter SDKs pin `Pisano ~> 1.0.21` and are not affected until they move to 1.1.

## Source

- Binary: `pisano-ios` tag `1.1.0`
- Source: `feedback-ios` tag `1.1.0` (`4623ee6`)
