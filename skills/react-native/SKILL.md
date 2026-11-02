---
name: react-native
description: Verify and debug React Native apps on the iOS Simulator and Android emulator — screenshots, deep links, Maestro, reading runtime values, and native build gotchas (pods, Metro, Watchman). Use when testing or debugging an RN/Expo app on a simulator or emulator, or when an RN native build fails.
---

# React Native: verify and debug

## Drive the simulator

- **Tap with Maestro**, never screen-coordinate clickers: it drives the device by UDID through the
  accessibility tree, so window position, Spaces and monitors don't matter.
  Maestro picks the Android emulator by default — always pass `--device <ios-udid>`.
  `maestro hierarchy` dumps tappable text and bounds; `tapOn: "Label"` beats coordinates.
- **Screenshots**: `xcrun simctl io booted screenshot <path>` (iOS) or
  `adb exec-out screencap -p > shot.png` (Android). Both read the framebuffer.
- **Open screens directly** with `__DEV__`-only deep links:
  `xcrun simctl openurl booted "<scheme>://<route>"`. Fast Refresh resets navigation, so wait ~10s
  after an edit before re-opening the link.
- **Force UI states** with a temporary `__DEV__` fixture flag rather than shaping real data. Revert
  before committing, and grep for the marker.

## Read runtime values

Hermes `console.log` only reaches Metro's stdout, not the iOS unified log. To read a value:
- render it as temporary magenta `<Text>` and screenshot it, or
- POST it to a tiny localhost listener (the simulator shares the host's localhost).

Revert either afterwards.

## Native build gotchas

- **RN version bump** = `pod install` + full native rebuild (`yarn ios`), not a Metro restart. A
  "JavaScript X / Native Y" redbox means the installed binary predates the bump.
- **Watchman "Recrawled this watch"** → Metro serves stale bundles. Fix: `watchman watch-del-all`,
  then restart Metro with `--reset-cache`.
- **`Podfile.lock` checksum drift** on this machine: run `pod install`, build, and revert
  `Podfile.lock` only at commit time. Reverting before the build breaks it again.
- **Launch with `yarn ios`**, not `simctl launch`: cold launches can hit a TurboModule redbox.

## Rendering gotcha

A style `transform` on a `react-native-svg` `<Svg>` root (e.g. a lucide icon) renders nothing. Wrap
the icon in a `View` and transform the `View`.
