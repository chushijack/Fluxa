# Fluxa development environment (phase 0)

Align tooling with FlClash release CI before building or running tests.

## Remotes

| Remote | URL |
|--------|-----|
| `origin` | https://github.com/chushijack/Fluxa |
| `upstream` | https://github.com/chen08209/FlClash |

```bash
git remote -v
git fetch upstream
git fetch origin
```

## Toolchain (from FlClash README / CI)

| Tool | Version |
|------|---------|
| Flutter | **3.47.4** (`.github/workflows/build.yaml` `FLUTTER_VERSION`) |
| Dart | Bundled with Flutter (SDK lower bound in `pubspec.yaml`: `>=3.10.0`) |
| Go | **1.26** (core build) |
| Rust | via rustup (`plugins/rust_api`) |

This machine may have an older global Flutter; use [FVM](https://fvm.app/) or install 3.47.4 before `flutter pub get` / `flutter test`.

## Submodule (mihomo / Clash.Meta)

```bash
git submodule update --init --recursive core/Clash.Meta
```

Required for Go core builds and DNS override tests that read `core/Clash.Meta/config/config.go`.

## Baseline checks (after SDK alignment)

```bash
flutter pub get
flutter test
```

Full platform builds: `dart setup.dart <android|windows|macos|linux>` (see root `README.md`).

## Third-party licenses

Generate the dependency license bundle (after `flutter pub get`):

```bash
flutter pub licenses > LICENSES/third_party_pub_licenses.txt
```

Review and split into `LICENSES/` as needed; do not commit secrets.
