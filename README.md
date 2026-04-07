# Textual-NG

A modernized fork of [Textual](https://github.com/Codeux-Software/Textual), the IRC client for macOS.

Textual-NG picks up where the original left off — bringing Swift, SwiftUI, async/await, and modern macOS support to a battle-tested IRC client.

## What's Changed

- **Swift IRC parser** — core message parsing rewritten in Swift
- **async/await networking** — Network.framework with modern concurrency
- **SwiftUI preferences** — 12 of 15 preference panes converted to SwiftUI
- **macOS 14+ (Sonoma)** — deployment target raised for modern APIs
- **Removed legacy code** — WebKit 1, GCDAsyncSocket, DCC file transfers, license manager (~23,000 lines removed)
- **Unit tests** — 67 tests for IRC protocol parsing

## Building

```
git clone --recursive https://github.com/buggerman/Textual.git Textual-NG
cd Textual-NG
```

Open `Textual.xcworkspace` in Xcode and build the **Textual (Standard Release)** or **Textual (Debug)** scheme.

### Requirements

- macOS 14.0 or later
- Xcode 15 or later

## Original Project

Textual was created by [Codeux Software, LLC](https://codeux.com) and is no longer actively maintained. This fork preserves the original BSD license and acknowledges the contributions of all original developers.

## License

Textual-NG is licensed under the [BSD 3-Clause License](LICENSE.md), same as the original.

## IRC

Find us on `#textual-ng` on irc.libera.chat
