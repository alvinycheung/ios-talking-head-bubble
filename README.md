# Talking Head Bubble

A tiny macOS app that floats your camera feed on screen as a draggable circle. That's it. No fluff, no bloat, no menus you'll never use.

Pick your camera, drag the bubble wherever you want, scroll to resize. Right-click for options. Done.

## Download

Grab the latest release: [**TalkingHeadBubble.app.zip**](https://github.com/alvinycheung/osx-talking-head-bubble/releases/latest)

> **Note:** The app is not notarized with an Apple Developer ID. After unzipping, right-click the app and select **Open** to bypass Gatekeeper on first launch.

## What It Does

- **Floating camera bubble** — a circular preview of your face that stays on top of everything
- **Drag anywhere** — click and drag, put it wherever works for you
- **Resize on the fly** — scroll or pinch to go from 100px to 400px
- **Switch cameras** — right-click to pick from any connected camera
- **Mirror toggle** — because sometimes you want to read text behind you
- **Zero clutter** — no Dock icon, no menu bar, no Cmd-Tab entry. Just the bubble.
- **All Spaces** — follows you across virtual desktops and full-screen apps

## Getting Started

Requires macOS 15.0+ and Xcode with Swift 6.

```bash
# Clone it
git clone https://github.com/alvinycheung/ios-talking-head-bubble.git
cd ios-talking-head-bubble/TalkingHeadBubble

# Generate the Xcode project (requires xcodegen)
xcodegen generate

# Build and run
open TalkingHeadBubble.xcodeproj
```

Or build from the command line:

```bash
xcodebuild build -scheme TalkingHeadBubble -destination 'platform=macOS'
```

## Usage

- **Drag** the bubble to move it
- **Scroll** or **pinch** to resize (100px–400px)
- **Right-click** for the menu: camera selection, mirror, quit

That's the whole manual.

## Built By

Made by [Alvin Cheung](https://alvincheung.com). Part of the [dotfun](https://dotfun.co) family — where we skip the buzzwords and get straight to building things that work.

## License

MIT License

Copyright (c) 2026 Alvin Cheung

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
