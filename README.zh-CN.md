<p align="center">
  <img src="icon.png" width="160" height="160" alt="UTCMenuBar 图标：青色本初子午线穿过钟面">
</p>

<h1 align="center">UTCMenuBar</h1>

<p align="center">
  <i>抬眼看 UTC，本地时间照旧。</i>
  <br>
  <b>为跨时区工作准备的一枚 Mac 菜单栏时钟。</b>
</p>

<p align="center">
  <a href="https://github.com/NestDream/UTCMenuBar/releases/latest"><img src="https://img.shields.io/github/v/release/NestDream/UTCMenuBar?style=flat-square&amp;color=086F98" alt="最新版本"></a>
  <img src="https://img.shields.io/badge/macOS-13%2B-086F98?style=flat-square" alt="macOS 13 及以上">
  <img src="https://img.shields.io/badge/Apple%20Silicon%20%2B%20Intel-333333?style=flat-square" alt="支持 Apple Silicon 与 Intel">
  <img src="https://img.shields.io/badge/Swift-6-F05138?style=flat-square&amp;logo=swift&amp;logoColor=white" alt="Swift 6">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-086F98?style=flat-square" alt="MIT 许可证"></a>
</p>

<p align="center">
  <a href="#-安装">下载</a> ·
  <a href="#-界面一览">截图</a> ·
  <a href="#-让-utc-一眼可辨">外观</a> ·
  <a href="#-双向时区转换">时区转换</a> ·
  <a href="#-隐私">隐私</a> ·
  <a href="README.md">English</a>
</p>

---

日志里写着 `14:30 UTC`，Mac 上显示 `7:30`。让两个时间同时出现在眼前。

UTCMenuBar 在系统时钟旁边添上一枚 UTC 时钟。换一种字体、一种颜色，或者加上一对方括号，还没读清数字，就知道哪个是 UTC。值班排障、安排发布、与异地同事沟通时，少一次心算。

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/assets/styles-dark.png">
    <img src="docs/assets/styles-light.png" width="900" alt="三种 UTC 时钟样式：默认地球仪与日期、蓝色 Menlo 字体与方括号、只保留时间的极简样式">
  </picture>
</p>

<p align="center"><sub>同一枚时钟，按你的习惯呈现。示例由应用实际使用的时间格式化与样式代码绘制。</sub></p>

## 📦 安装

**[下载最新版本](https://github.com/NestDream/UTCMenuBar/releases/latest)** — 支持 macOS 13 Ventura 及以上，**Apple Silicon 与 Intel** 均可使用同一个通用安装包。

1. 下载 `UTCMenuBar-vX.Y.Z.zip`，解压后将 **UTCMenuBar.app** 拖入**应用程序**。
2. 打开应用，时钟会出现在菜单栏中，不占用 Dock。
3. 如果希望随 Mac 启动，在**设置 → 开机启动**中开启即可。

> [!NOTE]
> 发行版使用临时签名，**尚未经过 Apple 公证**。如果 macOS 拦截首次启动，请先确认下载来源可信，再于尝试打开后前往**系统设置 → 隐私与安全性 → 仍要打开**。也可以选择[从源码构建](#-开发)。

每个发行版的说明都附有 SHA-256 校验值，可与本地下载文件比较：

```sh
shasum -a 256 ~/Downloads/UTCMenuBar-vX.Y.Z.zip
```

之后右键点击时钟，选择**检查更新…**即可升级。应用会先征求同意，再下载并安装更新。自动检查默认开启，可在设置中关闭。

## 📸 界面一览

以下图片由应用的原生 SwiftUI 和 AppKit 视图渲染，使用示例数据。图片会随页面切换浅色或深色；[完整图集](docs/SCREENSHOTS.md)包含中英文界面的两种外观。

<table>
  <tr><th>点击即可展开</th><th>UTC ↔ 所选时区</th></tr>
  <tr>
    <td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/assets/screenshots/popover-zh-dark.png"><img src="docs/assets/screenshots/popover-zh-light.png" width="280" alt="UTC 浮窗显示 14:30、完整日期，以及设置、时区转换和退出快捷操作"></picture></td>
    <td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/assets/screenshots/converter-zh-dark.png"><img src="docs/assets/screenshots/converter-zh-light.png" width="520" alt="时区转换窗口：2026-09-25 14:30 UTC 对应洛杉矶 07:30，两个时间字段均有复制按钮"></picture></td>
  </tr>
</table>

## ⚡ 日常使用

| 操作 | 作用 |
| --- | --- |
| **点击**时钟 | 展开实时 UTC 浮窗，查看完整日期和快捷操作 |
| **右键点击**或 **Control + 点击** | 打开显示选项、外观、语言和更新菜单 |
| **⌘,** | 打开设置，实时预览菜单栏时钟的样式 |
| **⌘T** | 打开时区转换 |
| **Esc** | 关闭浮窗 |
| **⌘Q** | 退出 UTCMenuBar |

键盘快捷键在浮窗打开时可用，并非系统级全局快捷键。

默认显示为 `🌐 09/25 14:30 UTC`，使用紧凑日期和 24 小时制。关闭**紧凑时间**可显示秒；关闭**紧凑日期**可显示 `2026-09-25`；关闭**显示日期**则只保留时间。日期始终按 **UTC** 计算。

## 🎨 让 UTC 一眼可辨

打开**设置 → 外观**，边调整边查看固定在顶部的预览。

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/assets/screenshots/settings-zh-dark.png">
    <img src="docs/assets/screenshots/settings-zh-light.png" width="380" alt="UTCMenuBar 中文设置滚动至外观、语言与关于部分，顶部固定预览蓝色方括号 Menlo 时钟">
  </picture>
</p>

| 设置 | 可选项 |
| --- | --- |
| **字体** | 系统字体、Menlo、SF Mono，或通过 macOS 字体面板选用已安装的字体 |
| **字重与字号** | 四种字重；小、标准、大三种字号 |
| **颜色** | 默认、蓝、绿、橙、紫、红；系统动态颜色适配浅色与深色外观 |
| **图标** | 🌐 地球仪、🕐 时钟、🧭 指南针、🌍 地球，或不显示图标 |
| **装饰** | 无装饰、`[方括号]`、`(圆括号)` 或 `│竖线│` |
| **语言** | English 与简体中文，即时切换，无需重启 |

自定义样式用于菜单栏和设置预览；浮窗保留独立的大号时钟布局。偏好保存在本机，下次启动时自动恢复。

## 🌐 双向时区转换

打开**时区转换…**，选择目标时区，然后编辑任意一侧：

```text
UTC                    2026-09-25 14:30:00
America/Los_Angeles     2026-09-25 07:30:00
```

**UTC → 当地时间：**粘贴日志中的 UTC 时间，查看当地几点。**当地时间 → UTC：**修改目标时间，为发布计划或交接记录生成 UTC 时间。

输入格式为 `YYYY-MM-DD HH:MM:SS`。点击**现在**可填入当前时刻；字段旁的复制按钮可复制对应时间。应用会记住所选时区，并根据输入日期使用 macOS 的时区规则转换，包括夏令时。

转换器每次处理一个目标时区，菜单栏时钟始终显示 UTC。

## 🔒 隐私

无账号、订阅、广告或遥测。时钟显示和时区转换均在本机完成，使用 Mac 的系统时间与时区数据。

**检查更新会联网。** 应用会向 GitHub 查询发行信息，并在你选择**立即更新**后下载安装包。自动检查在符合条件的启动时执行，成功检查后的 24 小时内不会再次自动查询。如果偏好手动检查，可在设置中关闭**自动检查更新**。

外观、语言、显示选项、所选时区及更新偏好均保存在本地 `UserDefaults` 中。应用不需要辅助功能或屏幕录制权限。

## ❓ 常见问题

#### 会改变 Mac 的系统时区吗？

不会。系统时钟保持原样，UTCMenuBar 只是将同一时刻按 UTC 显示。

#### 必须联网校时吗？

时钟和转换器可以离线使用。UTCMenuBar 读取 Mac 的系统时间，不会自行连接时间服务器校时。

#### 能显示多个时钟、使用 12 小时制，或复制 ISO 时间戳吗？

目前菜单栏仅显示一个 24 小时制 UTC 时钟。转换器可以复制 `YYYY-MM-DD HH:MM:SS` 格式的时间；点击菜单栏时钟会打开浮窗。多个常驻时区、12 小时制，以及直接复制 ISO / Unix 时间戳尚未实现，见[路线图](docs/ROADMAP.md)。

#### 为什么 Dock 中没有图标？

UTCMenuBar 是菜单栏工具，可以从时钟菜单打开设置或退出。开机启动按需开启。

## 🛠 开发

需要 **macOS 13+**，以及包含 **macOS SDK 的 Swift 6 工具链**。构建前可用 `swift --version` 确认版本。项目采用 Swift Package Manager，**没有外部包依赖**。

```sh
git clone https://github.com/NestDream/UTCMenuBar.git
cd UTCMenuBar
./scripts/build-app.sh
open UTCMenuBar.app
```

脚本默认构建适用于当前 Mac 架构的 Release 应用。日常使用可将生成的 `UTCMenuBar.app` 移至应用程序。构建同时支持两种架构的通用版本：

```sh
./scripts/build-app.sh release --universal
```

开发与验证：

```sh
swift build                     # Debug 构建
./scripts/test.sh               # 运行自定义测试程序
./scripts/build-app.sh debug    # 打包 Debug 应用
```

测试覆盖时间格式、偏好保存、样式、时区转换、菜单操作、视图模型、浮窗定位、计时调度和更新判断。项目使用自定义可执行测试程序，请运行 `scripts/test.sh`，而非 `swift test`。

| 路径 | 内容 |
| --- | --- |
| [`Sources/`](Sources/) | AppKit 菜单栏与窗口、SwiftUI 视图、登录项及更新流程 |
| [`Sources/UTCMenuBarLib/`](Sources/UTCMenuBarLib/) | 数据模型、格式化、状态存储、视图模型及可测试的辅助逻辑 |
| [`Tests/UTCMenuBarTests/`](Tests/UTCMenuBarTests/) | 单元测试与随机属性测试 |
| [`specs/`](specs/) | 功能需求、设计与实现任务 |
| [`scripts/`](scripts/) | 应用打包、测试、图标渲染及文档配图生成 |

欢迎贡献。参与方式见 [CONTRIBUTING.md](CONTRIBUTING.md)，版本变化见 [CHANGELOG.md](CHANGELOG.md)，配图生成方法见[截图文档](docs/SCREENSHOTS.md#regenerating-the-images)。`_archive/` 中的旧 Xcode 工程仅供参考。

## 许可证

[MIT](LICENSE)。可自由使用、研究与修改。
