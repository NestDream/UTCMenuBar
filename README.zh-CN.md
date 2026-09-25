<p align="center">
  <img src="icon.png" width="160" height="160" alt="UTCMenuBar 图标：青色本初子午线穿过钟面">
</p>

<h1 align="center">UTCMenuBar</h1>

<p align="center">
  在 Mac 菜单栏显示 UTC 时间。
</p>

<p align="center">
  <a href="https://github.com/NestDream/UTCMenuBar/releases/latest"><img src="https://img.shields.io/github/v/release/NestDream/UTCMenuBar?style=flat-square&amp;color=086F98" alt="最新版本"></a>
  <img src="https://img.shields.io/badge/macOS-13%2B-086F98?style=flat-square" alt="macOS 13 及以上">
  <img src="https://img.shields.io/badge/Apple%20Silicon%20%2B%20Intel-333333?style=flat-square" alt="支持 Apple Silicon 与 Intel">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-086F98?style=flat-square" alt="MIT 许可证"></a>
</p>

<p align="center">
  <a href="#安装">下载</a> ·
  <a href="#截图">截图</a> ·
  <a href="#从源码构建">从源码构建</a> ·
  <a href="README.md">English</a>
</p>

UTCMenuBar 在菜单栏显示 UTC，系统时钟仍然显示本地时间。你可以调整字体、颜色和样式，方便区分两个时钟。应用内也提供时区转换，可以查询同一时刻在其他时区的时间。

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/assets/styles-dark.png">
    <img src="docs/assets/styles-light.png" width="900" alt="三种 UTC 时钟样式：默认地球仪与日期、蓝色 Menlo 字体与方括号、只保留时间的极简样式">
  </picture>
</p>

<p align="center"><sub>菜单栏样式示例，使用应用的格式化代码渲染。</sub></p>

## 安装

**[下载最新版本](https://github.com/NestDream/UTCMenuBar/releases/latest)**，需要 macOS 13 Ventura 或更新版本。Apple Silicon 和 Intel 使用同一个安装包。

1. 解压 `UTCMenuBar-vX.Y.Z.zip`，将 **UTCMenuBar.app** 拖入**应用程序**。
2. 打开应用，时钟会出现在菜单栏中，Dock 中没有图标。
3. 如需随 Mac 启动，在**设置 → 开机启动**中开启。

> [!NOTE]
> 发行版使用临时签名，尚未经过 Apple 公证。如果 macOS 拦截首次启动，请确认应用下载自本仓库，再前往**系统设置 → 隐私与安全性 → 仍要打开**。也可以[从源码构建](#从源码构建)。

版本说明附有 SHA-256 校验值，可用以下命令核对下载文件：

```sh
shasum -a 256 ~/Downloads/UTCMenuBar-vX.Y.Z.zip
```

后续升级可右键点击时钟，选择**检查更新…**。应用会在你确认后下载并安装更新。

## 截图

以下图片使用应用界面和示例数据渲染。[完整图集](docs/SCREENSHOTS.md)包含中英文界面的浅色和深色版本。

<table>
  <tr><th>时钟浮窗</th><th>时区转换</th></tr>
  <tr>
    <td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/assets/screenshots/popover-zh-dark.png"><img src="docs/assets/screenshots/popover-zh-light.png" width="280" alt="UTC 浮窗显示 14:30、完整日期，以及设置、时区转换和退出快捷操作"></picture></td>
    <td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/assets/screenshots/converter-zh-dark.png"><img src="docs/assets/screenshots/converter-zh-light.png" width="520" alt="时区转换窗口：2026-09-25 14:30 UTC 对应洛杉矶 07:30，两个时间字段均有复制按钮"></picture></td>
  </tr>
</table>

## 使用

| 操作 | 作用 |
| --- | --- |
| 点击时钟 | 查看 UTC 时间、完整日期，以及设置和时区转换入口 |
| 右键点击或 Control + 点击 | 打开显示选项、外观、语言和更新菜单 |
| ⌘, | 打开设置 |
| ⌘T | 打开时区转换 |
| Esc | 关闭浮窗 |
| ⌘Q | 退出 |

键盘快捷键在时钟浮窗打开时可用。

默认显示为 `🌐 09/25 14:30 UTC`。关闭**紧凑时间**可显示秒；关闭**紧凑日期**可显示 `2026-09-25`；关闭**显示日期**可隐藏日期。时钟使用 24 小时制，日期也按 UTC 计算。

## 外观

在**设置 → 外观**中，可以调整字体、字重、字号、颜色和图标，也可以在时钟两侧加上括号或竖线。字体可选系统字体、Menlo、SF Mono，或其他已安装的字体。修改时可以直接查看预览。

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/assets/screenshots/settings-zh-dark.png">
    <img src="docs/assets/screenshots/settings-zh-light.png" width="380" alt="UTCMenuBar 中文设置滚动至外观、语言与关于部分，顶部固定预览蓝色方括号 Menlo 时钟">
  </picture>
</p>

设置中也可以切换 English 和简体中文，无需重启。各项设置会在下次启动时保留。

## 时区转换

打开**时区转换…**，选择目标时区，在任意一侧输入时间，另一侧会显示转换结果：

```text
UTC                    2026-09-25 14:30:00
America/Los_Angeles     2026-09-25 07:30:00
```

输入格式为 `YYYY-MM-DD HH:MM:SS`。点击**现在**可填入当前时间，字段旁的按钮可复制对应时间。应用会记住所选时区，并使用 macOS 的时区规则处理转换，包括夏令时。

转换器每次处理一个目标时区，菜单栏时钟始终显示 UTC。

## 隐私与更新

时钟和转换器使用 Mac 的系统时间与时区数据，可以离线使用。设置保存在本机。应用无需账号，没有广告，也不收集使用数据。

检查更新会连接 GitHub。自动检查默认开启，在启动时执行，距离上次成功检查至少间隔 24 小时。可以在**设置 → 自动检查更新**中关闭。

## 从源码构建

需要 macOS 13+，以及包含 macOS SDK 的 Swift 6 工具链。项目使用 Swift Package Manager，没有外部依赖。

```sh
git clone https://github.com/NestDream/UTCMenuBar.git
cd UTCMenuBar
./scripts/build-app.sh
open UTCMenuBar.app
```

默认构建适用于当前 Mac 架构的 Release 应用。如需同时支持 Apple Silicon 和 Intel：

```sh
./scripts/build-app.sh release --universal
```

开发时可用：

```sh
swift build                     # Debug 构建
./scripts/test.sh               # 运行自定义测试程序
./scripts/build-app.sh debug    # 打包 Debug 应用
```

项目使用自定义测试程序，运行测试请用 `scripts/test.sh`，而非 `swift test`。

项目结构和贡献方式见 [CONTRIBUTING.md](CONTRIBUTING.md)，版本变化见 [CHANGELOG.md](CHANGELOG.md)，计划中的功能见[路线图](docs/ROADMAP.md)。

## 许可证

[MIT](LICENSE)
