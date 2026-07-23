# SwKeyboard

Keyboard handling patterns for SwiftUI: reliable tap-outside-to-dismiss, a growing
multiline text editor with correct caret tracking, and app-wide scroll-to-dismiss
defaults.

## Requirements

- iOS 17+ / macOS 14+
- Swift 5.9+

## Installation

```swift
.package(url: "https://github.com/sphericalwave/SwKeyboard.git", branch: "main")
```

## Overview

- `KeyboardDismissal` — app-wide tap-outside-to-dismiss. Install once: `.onAppear { KeyboardDismissal.installTapOutsideDismissal() }`. Unlike a naive tap recognizer, this ignores touches on text inputs, the edit menu/callout bar, and the keyboard itself, avoiding flicker and broken paste
- `GrowingTextEditor` — multiline input that grows with content, built on `TextField(axis: .vertical)` so the containing Form/ScrollView scrolls to follow the caret natively (replaces the `TextEditor(...).scrollDisabled(true)` + hidden mirror-`Text` hack, which broke caret tracking after a long paste)
- `StandardKeyboardBehavior` — app-root `View` extension for scroll-to-dismiss defaults (a container setting that cascades to every descendant ScrollView/List/Form, unlike the per-field `plainKeyboard()` opt-in)
- `PlainKeyboard`, `DoneKeyboardToolbar` — per-field keyboard opt-ins

## Dependencies

None.
