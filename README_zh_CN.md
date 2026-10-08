<div align="center">

<img src="assets/images/icon.png" alt="Fluxa" width="88">

# Fluxa

**基于 [FlClash](https://github.com/chen08209/FlClash) 二开**的跨平台代理客户端，采用 Clash Meta（mihomo）内核。开源、无广告。

[English](README.md) · **简体中文**

[![License](https://img.shields.io/github/license/chushijack/Fluxa?style=flat-square)](LICENSE)
[![Upstream](https://img.shields.io/badge/upstream-FlClash-6666FB?style=flat-square)](https://github.com/chen08209/FlClash)

[下载](#下载) · [更新日志](CHANGELOG.md) · [从源码构建](#从源码构建) · [上游同步](docs/fluxa/upstream.md)

</div>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="snapshots/preview-dark.png">
    <img alt="Fluxa 在 MacBook 与手机上的界面" src="snapshots/preview.png" width="92%">
  </picture>
</p>

## 简介

**Fluxa** 是在 FlClash 代码基础上独立演进的产品：品牌、界面与 Fluxa 专属能力主要在 `lib/fluxa/` 中维护，开发约定见 [docs/fluxa/development-spec.md](docs/fluxa/development-spec.md)。

Fluxa 以 **[GPL-3.0](LICENSE)** 发布。FlClash 为上游项目；同步或再分发时请保留上游版权与许可证信息。

## 功能

在 FlClash / mihomo 能力之上，使用 Fluxa 品牌并持续迭代：

- **覆盖 Android、Windows、macOS、Linux**，桌面端提供 x64 与 ARM64。
- **mihomo 内核**：规则分流、代理组、延迟测试、系统代理、TUN 模式。
- **配置管理**：订阅或文件导入、编辑器、覆写脚本、自定义规则与代理组。
- **实时查看**连接、请求、DNS 与日志。
- **Material You** 界面与自适应布局。
- **备份与恢复**：WebDAV 或本地文件。
- **平台能力**：Android 快捷设置、分应用代理、Android TV；桌面托盘与全局快捷键。

## 下载

安装包在 **[GitHub Releases](https://github.com/chushijack/Fluxa/releases)** 发布（如有）。文件名前缀为 `Fluxa-<版本>-…`（例如 `Fluxa-…-windows-amd64-setup.exe`）。

| 平台 | 安装包 | 说明 |
| --- | --- | --- |
| Android | APK（`arm64-v8a`、`armeabi-v7a`、`x86_64`） | 多数手机选 `arm64-v8a`。 |
| Windows 10 及以上 | 安装版或便携版，x64 / ARM64 | 桌面主程序为 **Fluxa.exe**。 |
| macOS 12 及以上 | Apple Silicon / Intel DMG | |
| Linux | `.deb`、`.rpm`、AppImage，x64 / ARM64 | AppImage / `.rpm` 可能需要 Ayatana 托盘依赖。 |

启用 Pages 后，[项目站点](https://chushijack.github.io/Fluxa/) 会展示下载与更新说明。

## 与 FlClash 的关系

| | FlClash | Fluxa |
| --- | --- | --- |
| 定位 | 上游 | 二开 / 衍生产品 |
| 仓库 | [chen08209/FlClash](https://github.com/chen08209/FlClash) | [chushijack/Fluxa](https://github.com/chushijack/Fluxa) |
| 协议 | GPL-3.0 | GPL-3.0（衍生代码同样适用） |

同步流程：`sync/flclash-<version>` → `dev` → `main`。详见 [docs/fluxa/upstream.md](docs/fluxa/upstream.md) 与 [LICENSES/FLCLASH.md](LICENSES/FLCLASH.md)。

## 使用

**订阅导入** 与 FlClash 相同，支持 `clash://`、`clashmeta://`、`flclash://` 等链接形式。

**Android 自动化**（当前包名仍为 `com.follow.clash`）：

```text
com.follow.clash.action.START
com.follow.clash.action.STOP
com.follow.clash.action.TOGGLE
```

## 从源码构建

工具链与 FlClash 一致： [Flutter](https://docs.flutter.dev/get-started/install) 3.47（正式版 3.47.4）、[Go](https://go.dev/dl/) 1.26、[Rust](https://rustup.rs/)。日常命令见 [.agents/commands.md](.agents/commands.md)。

```bash
git clone --recursive https://github.com/chushijack/Fluxa.git
cd Fluxa
flutter pub get
dart setup.dart android   # 或 windows、macos、linux
```

产物在 `dist/`。图标与托盘资源可用 `dart tool/generate_status_icons.dart` 重新生成（见 `.agents/commands.md`）。

## 支持

- **Fluxa**：[本仓库 Issues](https://github.com/chushijack/Fluxa/issues)。
- **上游 FlClash**：[chen08209/FlClash](https://github.com/chen08209/FlClash)。

## 许可证

Fluxa 为 FlClash 的衍生作品，以 [GNU GPL v3.0](LICENSE) 发布。第三方说明见 [LICENSES/](LICENSES/)。
