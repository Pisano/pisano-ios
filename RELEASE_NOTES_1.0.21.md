# Release 1.0.21

Includes the bottom sheet changes from 1.0.20.

## WebView zoom (`disable_zoom`)

Channel config from SDK detail API field `disable_zoom`:

- `true` → pinch zoom disabled
- `false` / omitted → pinch zoom enabled (up to 5x)
- Input focus auto-zoom → always disabled (16px font injection)

No app-side API change; controlled from Pisano panel per channel.

## Keyboard + viewport

- Keyboard open: viewport layout sync in web widget
- Bottom sheet: `prefersScrollingExpandsWhenScrolledToEdge = false` — scroll stays in survey content

## Bottom sheet (from 1.0.20, included)

- Optional `dismissOnDrag` on `Pisano.show()` (default `false`)
- When `true`: swipe-down dismiss enabled, grabber visible on iOS 15+

## Upgrade

| Method | How |
|--------|-----|
| **SPM** | Pin tag `1.0.21` on `https://github.com/Pisano/pisano-ios` |
| **CocoaPods** | `pod 'Pisano', '~> 1.0.21'` |
| **Manual** | Replace `PisanoFeedback.xcframework` with this release |

**Breaking changes:** None

## Source

- Binary: `pisano-ios` tag `1.0.21`
- Source: `feedback-ios` tag `1.0.21`
