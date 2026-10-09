<div align="center">

<img src="assets/images/icon.png" alt="Fluxa" width="88">

# Fluxa

A cross-platform proxy client **forked from [FlClash](https://github.com/chen08209/FlClash)**. Built on Clash Meta (mihomo). Open source and ad-free.

**English** · [简体中文](README_zh_CN.md)

[![License](https://img.shields.io/github/license/chushijack/Fluxa?style=flat-square)](LICENSE)
[![Upstream](https://img.shields.io/badge/upstream-FlClash-6666FB?style=flat-square)](https://github.com/chen08209/FlClash)

[Download](#download) · [Changelog](CHANGELOG.md) · [Build from source](#build-from-source) · [Upstream sync](docs/fluxa/upstream.md)

</div>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="snapshots/preview-dark.png">
    <img alt="Fluxa dashboard on a MacBook and a phone" src="snapshots/preview.png" width="92%">
  </picture>
</p>

## About

**Fluxa** is an independent product that reuses the FlClash codebase as upstream. UI, branding, packaging names, and Fluxa-only features live in the `lib/fluxa/` layer; see [docs/fluxa/development-spec.md](docs/fluxa/development-spec.md).

Fluxa is distributed under **[GPL-3.0](LICENSE)**. FlClash remains the upstream project; please keep upstream copyright and license notices intact when you sync or redistribute.

## Features

Inherited from the FlClash / mihomo stack, with Fluxa branding and ongoing product work:

- **Android, Windows, macOS, and Linux** (x64 and ARM64 on desktop).
- **mihomo (Clash.Meta) core** — rule routing, proxy groups, latency tests, system proxy, TUN mode.
- **Profiles** from subscription links or files, editor, overrides, custom rules and proxy groups.
- **Live views** of connections, requests, DNS, and logs.
- **Material You** UI with dynamic color and adaptive layouts.
- **Backup and restore** via WebDAV or local files.
- **Platform extras** — Quick Settings tile, per-app proxy, Android TV; desktop tray and hotkeys.

## Download

Pre-built packages are published on **[GitHub Releases](https://github.com/chushijack/Fluxa/releases)** when available. Artifact names use the `Fluxa-<version>-…` prefix (for example `Fluxa-…-windows-amd64-setup.exe`).

| Platform | Packages | Notes |
| --- | --- | --- |
| Android | APK (`arm64-v8a`, `armeabi-v7a`, `x86_64`) | Most phones use `arm64-v8a`. |
| Windows 10+ | Installer (`.exe`) or portable `.zip`, x64 / ARM64 | Desktop binary is **Fluxa.exe**. |
| macOS 12+ | DMG for Apple Silicon and Intel | |
| Linux | `.deb`, `.rpm`, AppImage, x64 / ARM64 | Tray may need Ayatana AppIndicator on AppImage / `.rpm`. |

The [project site](https://chushijack.github.io/Fluxa/) (when enabled) lists the same downloads and changelog.

## Relationship to FlClash

| | FlClash | Fluxa |
| --- | --- | --- |
| Role | Upstream | Fork / derivative product |
| Repository | [chen08209/FlClash](https://github.com/chen08209/FlClash) | [chushijack/Fluxa](https://github.com/chushijack/Fluxa) |
| License | GPL-3.0 | GPL-3.0 (same for derived code) |

Sync workflow: `sync/flclash-<version>` → `dev` → `main`. Details in [docs/fluxa/upstream.md](docs/fluxa/upstream.md) and [LICENSES/FLCLASH.md](LICENSES/FLCLASH.md).

## Usage

**Subscription import** uses the same link schemes as FlClash (`clash://`, `clashmeta://`, `flclash://`, and related forms).

**Android automation** (package `com.follow.fluxa`):

```text
com.follow.fluxa.action.START
com.follow.fluxa.action.STOP
com.follow.fluxa.action.TOGGLE
```

## Build from source

Toolchain matches FlClash: [Flutter](https://docs.flutter.dev/get-started/install) 3.47 (release builds use 3.47.4), [Go](https://go.dev/dl/) 1.26, and [Rust](https://rustup.rs/) via rustup. See [.agents/commands.md](.agents/commands.md) for day-to-day commands.

```bash
git clone --recursive https://github.com/chushijack/Fluxa.git
cd Fluxa
flutter pub get
dart setup.dart android   # or windows, macos, linux
```

Outputs go to `dist/`. Icon and tray assets can be regenerated with `dart tool/generate_status_icons.dart` (see `.agents/commands.md`).

## Support

- **Fluxa**: [GitHub Issues](https://github.com/chushijack/Fluxa/issues) on this repository.
- **Upstream FlClash**: [chen08209/FlClash](https://github.com/chen08209/FlClash) for the base client and core integration.

## License

Fluxa is a derivative work of FlClash and is released under the [GNU GPL v3.0](LICENSE). Third-party notices: [LICENSES/](LICENSES/).
