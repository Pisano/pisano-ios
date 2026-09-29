# Release 1.0.20 – Bottom Sheet

## Improvements

- **`dismissOnDrag` on `Pisano.show()`** — Optional parameter (default `false`). When `true`, users can dismiss the bottom sheet by swiping down.
- **Default bottom sheet behaviour** — When `dismissOnDrag` is not set, the sheet uses `isModalInPresentation = true` so swipe-to-dismiss is disabled (aligned with Android default).

## Migration

No breaking changes. Existing `Pisano.show(...)` calls work unchanged; `dismissOnDrag` defaults to `false`.

```swift
Pisano.show(
    mode: .bottomSheet,
    title: "Title",
    code: nil,
    language: "tr",
    customer: customer,
    payload: payload,
    dismissOnDrag: true  // optional
) { status in
    // ...
}
```
