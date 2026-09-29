# Screenshot gallery

[← README](../README.md) · [简体中文](../README.zh-CN.md)

These images render UTCMenuBar's actual SwiftUI and AppKit views with a fixed sample time: **September 25, 2026, 14:30 UTC**. The converter shows the same instant in `America/Los_Angeles`, **07:30**. Settings uses Menlo Semibold, Blue, and brackets to demonstrate the live preview.

All images are rendered directly at **3× resolution**. Click any image below to open the full-size PNG. They are native view captures, not whole-desktop screenshots. Window chrome, wallpaper, and unrelated menu bar items are omitted. English and Chinese views use identical sample data. The style strip is an illustration rendered through the app's actual `TimeFormatter` and `StyledTextBuilder`.

| Surface | Native size (points) | Image size (pixels) |
| --- | --- | --- |
| UTC popover | 292 × 250 | 876 × 750 |
| Settings | 440 × 560 | 1320 × 1680 |
| Time Zone Converter | 460 × 332 | 1380 × 996 |
| Clock style examples | 900 × 208 | 2700 × 624 |

## English

### UTC popover

| Light | Dark |
| --- | --- |
| <a href="assets/screenshots/popover-en-light.png"><img src="assets/screenshots/popover-en-light.png" width="292" alt="English UTC popover in light appearance"></a> | <a href="assets/screenshots/popover-en-dark.png"><img src="assets/screenshots/popover-en-dark.png" width="292" alt="English UTC popover in dark appearance"></a> |

### Settings

Appearance settings, with General and About available through the native segmented control. The live clock preview stays above the appearance controls:

| Light | Dark |
| --- | --- |
| <a href="assets/screenshots/settings-en-light.png"><img src="assets/screenshots/settings-en-light.png" width="440" alt="English Settings with a blue bracketed clock preview, light appearance"></a> | <a href="assets/screenshots/settings-en-dark.png"><img src="assets/screenshots/settings-en-dark.png" width="440" alt="English Settings with a blue bracketed clock preview, dark appearance"></a> |

<details>
<summary>General, display, and language settings</summary>

| Light | Dark |
| --- | --- |
| <a href="assets/screenshots/settings-general-en-light.png"><img src="assets/screenshots/settings-general-en-light.png" width="440" alt="English general and display settings, light appearance"></a> | <a href="assets/screenshots/settings-general-en-dark.png"><img src="assets/screenshots/settings-general-en-dark.png" width="440" alt="English general and display settings, dark appearance"></a> |

</details>

### Time Zone Converter

<a href="assets/screenshots/converter-en-light.png"><img src="assets/screenshots/converter-en-light.png" width="460" alt="English converter in light appearance: 14:30 UTC becomes 07:30 in Los Angeles"></a>

<a href="assets/screenshots/converter-en-dark.png"><img src="assets/screenshots/converter-en-dark.png" width="460" alt="English converter in dark appearance: 14:30 UTC becomes 07:30 in Los Angeles"></a>

## 简体中文

### UTC 浮窗

| 浅色 | 深色 |
| --- | --- |
| <a href="assets/screenshots/popover-zh-light.png"><img src="assets/screenshots/popover-zh-light.png" width="292" alt="中文 UTC 浮窗，浅色外观"></a> | <a href="assets/screenshots/popover-zh-dark.png"><img src="assets/screenshots/popover-zh-dark.png" width="292" alt="中文 UTC 浮窗，深色外观"></a> |

### 设置

外观设置；顶部的原生分段控件可切换通用、外观与关于。调整样式时，时钟预览始终可见：

| 浅色 | 深色 |
| --- | --- |
| <a href="assets/screenshots/settings-zh-light.png"><img src="assets/screenshots/settings-zh-light.png" width="440" alt="中文设置与蓝色方括号时钟预览，浅色外观"></a> | <a href="assets/screenshots/settings-zh-dark.png"><img src="assets/screenshots/settings-zh-dark.png" width="440" alt="中文设置与蓝色方括号时钟预览，深色外观"></a> |

<details>
<summary>通用、显示与语言设置</summary>

| 浅色 | 深色 |
| --- | --- |
| <a href="assets/screenshots/settings-general-zh-light.png"><img src="assets/screenshots/settings-general-zh-light.png" width="440" alt="中文通用与显示设置，浅色外观"></a> | <a href="assets/screenshots/settings-general-zh-dark.png"><img src="assets/screenshots/settings-general-zh-dark.png" width="440" alt="中文通用与显示设置，深色外观"></a> |

</details>

### 时区转换

<a href="assets/screenshots/converter-zh-light.png"><img src="assets/screenshots/converter-zh-light.png" width="460" alt="中文时区转换，浅色外观：UTC 14:30 对应洛杉矶 07:30"></a>

<a href="assets/screenshots/converter-zh-dark.png"><img src="assets/screenshots/converter-zh-dark.png" width="460" alt="中文时区转换，深色外观：UTC 14:30 对应洛杉矶 07:30"></a>

## Clock styling

<a href="assets/styles-light.png"><img src="assets/styles-light.png" width="900" alt="Default, blue bracketed Menlo, and minimal UTC clock styles on a light background"></a>

<a href="assets/styles-dark.png"><img src="assets/styles-dark.png" width="900" alt="Default, blue bracketed Menlo, and minimal UTC clock styles on a dark background"></a>

## Regenerating the images

On a Mac with a logged-in graphical session and a Swift 6 toolchain:

```sh
./scripts/render-readme.sh
```

The script builds the library, compiles the existing views into a temporary documentation app, and exports **34 PNGs at 3× resolution** into `docs/assets/`. It uses isolated preferences, a fixed clock reading, and an inactive login-item adapter. It does not launch the regular app, change its settings, register a login item, or check for updates.

The capture matrix also includes all three settings panes, seconds, and empty/invalid conversion states. The converter sample is entered through its existing text-change handler and checked before capture. The Settings version comes from the most recent `v*` Git tag. The macOS version can affect native control rendering, and the converter's time-zone picker labels show offsets at capture time, just as they do in the app.

To inspect a fresh set before replacing the committed images:

```sh
./scripts/render-readme.sh /tmp/utcmenubar-readme
```

The original development preview command remains available in Debug builds through `--render-previews <directory>`.
