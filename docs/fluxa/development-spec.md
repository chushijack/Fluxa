# Fluxa 基于 FlClash 二开开发规范

## 1. 项目目标

当前阶段的目标是基于 FlClash 开源项目开发 Fluxa。

Fluxa 是一个独立品牌的跨平台代理客户端，当前阶段优先复用 FlClash 已有的成熟能力，在此基础上进行 UI、功能、架构和产品体验改造。

未来 Fluxa 可能会完全从零使用 Rust + Tauri 重写，因此当前代码必须尽量降低对 FlClash 原始实现的耦合，为未来迁移保留空间。

---

## 2. 核心原则

## 2.1 FlClash 是上游项目

FlClash 是 Fluxa 当前阶段的 upstream。

Git 仓库应该保持：

```text
origin
    ↓
Fluxa

upstream
    ↓
FlClash
```

典型配置：

```bash
git remote add upstream https://github.com/chen08209/FlClash.git
```

查看：

```bash
git remote -v
```

预期：

```text
origin    https://github.com/<your-account>/Fluxa.git
upstream  https://github.com/chen08209/FlClash.git
```

---

## 3. 上游同步策略

FlClash 更新后，Fluxa 需要能够同步上游代码。

禁止直接覆盖 Fluxa 自己的修改。

推荐流程：

```bash
git fetch upstream
```

创建同步分支：

```bash
git checkout -b sync/flclash-<version>
```

然后：

```bash
git merge upstream/main
```

解决冲突后进行：

- 编译检查
- 单元测试
- UI 检查
- Fluxa 功能检查
- 平台构建检查

确认无误后再合并到：

```text
main
```

---

## 4. Git 分支规范

建议：

```text
main
│
├── feature/*
├── fix/*
├── refactor/*
├── sync/flclash-*
└── release/*
```

例如：

```text
feature/single-node-import
feature/vless-parser
feature/fluxa-dashboard

sync/flclash-0.8.100
sync/flclash-0.8.101
```

不要直接在 `main` 分支执行 FlClash 上游同步。

---

## 5. 代码架构原则

最重要的原则：

> 不要把 Fluxa 自己的产品逻辑大量直接写进 FlClash 原有代码。

尽量保持：

```text
FlClash Base
      ↓
Fluxa Adapter
      ↓
Fluxa Core / Features
      ↓
Fluxa UI
```

而不是：

```text
FlClash
   ↓
到处直接修改
   ↓
Fluxa
```

这样可以降低未来同步 FlClash 时的冲突。

---

## 6. 推荐目录结构

当前项目基于 Flutter + FlClash。

推荐逐步整理成：

```text
lib/
├── app/
│   ├── app.dart
│   ├── router/
│   ├── theme/
│   └── localization/
│
├── core/
│   ├── config/
│   ├── models/
│   ├── services/
│   ├── storage/
│   ├── utils/
│   └── constants/
│
├── features/
│   ├── dashboard/
│   ├── profiles/
│   ├── nodes/
│   ├── proxies/
│   ├── proxy_groups/
│   ├── rules/
│   ├── connections/
│   ├── logs/
│   ├── dns/
│   ├── tun/
│   └── settings/
│
├── fluxa/
│   ├── adapters/
│   ├── models/
│   ├── services/
│   ├── parsers/
│   ├── providers/
│   └── utils/
│
└── legacy/
    └── flclash/
```

如果当前 FlClash 代码结构与上述结构存在较大差异，不要求一次性全部重构。

应该采用渐进式迁移。

---

## 7. Fluxa 自有代码隔离

Fluxa 新增功能优先放在：

```text
lib/fluxa/
```

或者：

```text
lib/features/
```

不要为了实现新功能随意修改 FlClash 底层代码。

例如：

```text
VLESS 单节点导入
```

应该尽量设计成：

```text
VLESS URL
    ↓
Fluxa VLESS Parser
    ↓
FluxaNode
    ↓
FlClash/Mihomo Adapter
    ↓
Mihomo Config
```

而不是：

```text
VLESS URL
    ↓
直接修改 FlClash 内部模型
```

---

## 8. Fluxa 自有数据模型

为了支持未来完全重写 Fluxa，需要逐步建立自己的领域模型。

例如：

```text
FluxaNode
FluxaProfile
FluxaProvider
FluxaProxyGroup
FluxaRule
FluxaConnection
```

不要让 UI 直接依赖 FlClash 内部的数据结构。

推荐：

```text
UI
 ↓
Fluxa Model
 ↓
Fluxa Service
 ↓
FlClash Adapter
 ↓
Mihomo
```

未来重写：

```text
UI
 ↓
Fluxa Model
 ↓
Fluxa Service
 ↓
Fluxa Core
 ↓
Mihomo / sing-box
```

这样未来可以替换底层实现，而不需要重写整个产品逻辑。

---

## 9. FluxaNode

需要建立统一的节点抽象。

示例：

```dart
class FluxaNode {
  final String id;
  final String name;
  final ProxyProtocol protocol;
  final String server;
  final int port;

  final Map<String, dynamic> credentials;
  final Map<String, dynamic> tls;
  final Map<String, dynamic> transport;

  final Map<String, dynamic> metadata;
}
```

具体实现可以根据当前项目语言和架构调整。

核心要求：

> Fluxa 的节点模型不能强依赖 FlClash 内部节点模型。

---

## 10. 节点导入设计

Fluxa 不能只支持机场订阅。

必须逐步支持：

```text
订阅
├── URL Subscription
├── Local YAML
├── Local JSON
└── Provider

单节点
├── VLESS
├── VMess
├── Trojan
├── Shadowsocks
├── Hysteria
├── Hysteria2
├── TUIC
└── 其他协议
```

统一流程：

```text
Input
  ↓
Parser
  ↓
FluxaNode
  ↓
Fluxa Storage
  ↓
Proxy Adapter
```

例如：

```text
vless://...
      ↓
VLESS Parser
      ↓
FluxaNode
      ↓
Mihomo Adapter
```

---

## 11. UI 架构原则

Fluxa 应该拥有自己的 UI，不应该长期保持 FlClash 原始 UI。

Fluxa UI 包括：

```text
Dashboard
Profiles
Nodes
Proxies
Proxy Groups
Rules
Connections
Logs
DNS
TUN
Settings
About
```

UI 文案、Logo、主题、图标、品牌元素都使用 Fluxa。

不要在新的 Fluxa UI 中继续出现 FlClash 品牌元素，除非属于开源致谢信息。

---

## 12. 品牌与项目名称

项目名称统一使用：

```text
Fluxa
```

不要使用：

```text
FlClash Plus
FlClash Pro
FlClash Next
```

Fluxa 是独立产品品牌。

可以在 README / About / License 页面注明：

```text
Fluxa is based on FlClash.
```

---

## 13. License 要求

FlClash 使用 GPL-3.0。

必须：

- 保留 GPL-3.0 License
- 保留原作者版权信息
- 保留必要的第三方 License
- 对 GPL 衍生代码遵守 GPL 要求
- 发布时提供对应源代码
- 不删除原项目版权与 License 信息

可以：

- 修改 UI
- 修改产品名称
- 修改 Logo
- 修改应用图标
- 增加 Fluxa 功能
- 发布 Fluxa
- 商业化 Fluxa

第三方依赖必须单独检查 License。

---

## 14. License 目录

建议建立：

```text
LICENSE
LICENSES/
├── FLCLASH.md
├── MIHOMO.md
└── THIRD_PARTY/
```

实际文件名和内容根据仓库实际 License 情况确定。

不要凭猜测添加 License。

必须检查实际依赖和上游仓库。

---

## 15. About 页面

Fluxa 应该拥有自己的 About 页面。

例如：

```text
Fluxa

A modern cross-platform proxy client.

Version: x.x.x

Open Source

Fluxa is based on FlClash.

FlClash
https://github.com/chen08209/FlClash

License
GNU General Public License v3.0
```

同时提供：

```text
Open Source Licenses
```

用于展示第三方依赖许可证。

---

## 16. 上游版本记录

建立：

```text
docs/upstream.md
```

记录：

```text
Current upstream:
FlClash v0.x.x

Upstream commit:
<commit>

Last synced:
YYYY-MM-DD
```

每次同步 FlClash 时更新。

例如：

```markdown
# FlClash Upstream

Current version: v0.8.100

Commit:
abcdef123456

Last synced:
2026-10-08
```

---

## 17. 上游同步原则

同步 FlClash 时：

### 第一优先级

保留 FlClash 的：

- Bug Fix
- 安全修复
- Core 更新
- 平台兼容性修复
- 性能优化
- 重要功能修复

### 第二优先级

评估：

- UI 更新
- 页面结构
- 状态管理
- 配置系统变化

这些可能与 Fluxa 自己的产品设计产生冲突。

### 第三优先级

Fluxa 自己的：

- Logo
- UI
- 产品功能
- 节点系统
- 单节点导入
- 品牌设计

不能被上游覆盖。

---

## 18. 禁止事项

不要：

1. 直接删除 FlClash License
2. 删除原作者版权信息
3. 把 FlClash GPL 代码改成闭源许可
4. 在没有检查 License 的情况下复制第三方代码
5. 将 Fluxa 新功能全部直接写进 FlClash 原始代码
6. 直接覆盖上游代码
7. 在 `main` 分支直接进行大规模 upstream merge
8. 为了同步上游而破坏 Fluxa 自己的数据模型
9. 让 UI 直接依赖 FlClash 内部实现
10. 在没有测试的情况下合并 FlClash 大版本更新

---

## 19. 未来 Fluxa Next

未来可能创建完全独立的：

```text
Fluxa Next
```

推荐独立仓库：

```text
github.com/<account>/fluxa
github.com/<account>/fluxa-next
```

Fluxa Next 可能使用：

```text
Rust
Tauri
Vue / React
Mihomo / sing-box
```

Fluxa Next 不应该直接复制当前 FlClash 项目的大量 UI 代码。

应该复用当前 Fluxa 已经沉淀的：

```text
FluxaNode
FluxaProfile
FluxaProvider
FluxaProxyGroup
FluxaRule
配置格式
节点解析规则
产品设计
交互设计
```

最终架构：

```text
Fluxa 1.x
    │
    ├── Flutter
    ├── FlClash
    └── Mihomo
         │
         │ 产品验证
         ▼
    Fluxa Next
         │
         ├── Rust
         ├── Tauri
         ├── Fluxa Core
         └── Mihomo / sing-box
```

---

## 20. 最终架构目标

当前：

```text
              FlClash
                 │
                 ▼
          Fluxa Adapter
                 │
                 ▼
          Fluxa Features
                 │
                 ▼
             Fluxa UI
```

未来：

```text
              Fluxa UI
                 │
                 ▼
           Fluxa Application
                 │
                 ▼
             Fluxa Core
                 │
        ┌────────┴────────┐
        ▼                 ▼
     Mihomo            sing-box
```

最终目标：

> Fluxa 的产品逻辑、数据模型和核心能力独立于 FlClash。

FlClash 只是当前阶段帮助 Fluxa 快速完成产品验证和功能实现的基础。

---

## 21. Cursor 开发行为要求

在修改代码之前：

1. 先阅读现有项目结构
2. 找到 FlClash 原有实现
3. 判断代码属于：
   - FlClash 原始代码
   - Fluxa 新代码
   - 第三方代码
4. 优先创建 Fluxa 自己的 abstraction / adapter
5. 尽量减少直接修改 FlClash 核心代码
6. 修改前考虑未来 upstream merge
7. 修改后检查是否会增加未来同步冲突
8. 不要为了完成一个小功能进行大规模重构
9. 不确定 License 时不要自行判断，先标记出来
10. 不要删除已有功能，除非明确要求

---

## 22. 每次开发前的判断标准

新增功能时优先问：

```text
这个功能是不是 Fluxa 独有？

是
 ↓
放到 Fluxa Features / Core

否
 ↓
是否可以直接使用 FlClash？
 ↓
可以 → 尽量复用
 ↓
不可以 → 增加 Adapter
```

修改 FlClash 原始代码之前必须考虑：

```text
以后 FlClash 更新怎么办？
```

如果可以通过：

```text
Adapter
Extension
Service
Wrapper
独立 Feature
```

解决，就不要直接修改 FlClash 核心代码。

---

## 23. 最重要的开发原则

Fluxa 当前阶段不是：

> “把 FlClash 改成另一个名字。”

而是：

> “利用 FlClash 快速构建 Fluxa，同时逐步建立 Fluxa 自己的产品层和领域模型。”

最终目标：

```text
FlClash
   ↓
帮助 Fluxa 快速起步
   ↓
Fluxa 产品层逐渐独立
   ↓
Fluxa Core 独立
   ↓
未来完全重写
   ↓
Fluxa Next
```

所有代码修改都应该尽量符合这个长期目标。
