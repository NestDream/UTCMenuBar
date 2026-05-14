# 需求文档

## 简介

为 UTCMenuBar macOS 菜单栏应用添加时区转换器功能。当前应用仅在菜单栏显示 UTC 时间。本功能提供一个独立的"时区转换"窗口，支持 UTC ↔ 任意目标时区的**双向**转换：用户既可以输入 UTC 时间得到目标时区时间，也可以输入目标时区时间得到 UTC 时间。同时提供"现在"按钮快速填入当前时刻，以及"复制"按钮复制结果。

本功能解决的痛点：与全球团队协作的开发者经常需要把"我现在所在的时间"翻译成 UTC 给他人，或者把对方给的 UTC 时间转成本地，目前需要打开浏览器或者动手算时差，体验割裂。

## 术语表

- **TimezoneConverter（时区转换器）**: 本功能新增的窗口，支持 UTC 与目标时区之间的双向时间转换
- **TargetTimezone（目标时区）**: 用户选择用来与 UTC 互转的时区，用 IANA 时区标识符（如 `Asia/Shanghai`、`America/Los_Angeles`）持久化
- **DirectionField（活跃字段）**: 当前正在被用户编辑的输入字段（UTC 端 或 目标端），决定哪一边是"输入"哪一边是"输出"
- **ConversionFormat（转换格式）**: 时间字符串的接受/输出格式，统一为 `yyyy-MM-dd HH:mm:ss`（24 小时制）
- **NowButton（"现在"按钮）**: 一键将当前时刻填入活跃字段，并自动计算另一边
- **CopyButton（"复制"按钮）**: 把对应字段的值写入系统剪贴板（NSPasteboard）
- **TimezoneConverterStore**: 转换器窗口状态的持久化层（仅持久化 `targetTimezone`，输入框内容不持久化）

## 需求

### 需求 1：双向时区转换核心

**用户故事：** 作为跨时区协作的开发者，我希望能够在 UTC 与任意指定时区之间双向转换时间，以便快速沟通会议时间或日志事件时间。

#### 验收标准

1. THE TimezoneConverter SHALL 提供两个文本输入字段：UTC 时间字段、目标时区时间字段
2. WHEN 用户在 UTC 字段输入或修改有效时间字符串, THE TimezoneConverter SHALL 立即（≤100ms）在目标时区字段更新对应的本地时间
3. WHEN 用户在目标时区字段输入或修改有效时间字符串, THE TimezoneConverter SHALL 立即（≤100ms）在 UTC 字段更新对应的 UTC 时间
4. THE TimezoneConverter SHALL 使用 `yyyy-MM-dd HH:mm:ss` 作为统一的输入与输出格式
5. THE TimezoneConverter SHALL 不在用户输入半成品（解析失败）时清空另一字段，仅在有合法可解析的输入时才更新另一边
6. IF 用户输入的字符串无法解析为有效时间, THEN THE TimezoneConverter SHALL 在该字段下方显示一行错误提示（如"无法解析时间，请使用 YYYY-MM-DD HH:MM:SS 格式"）

### 需求 2：目标时区选择

**用户故事：** 作为用户，我希望能够选择并切换目标时区，以便在不同协作对象的时区之间快速转换。

#### 验收标准

1. THE TimezoneConverter SHALL 在窗口中提供时区选择控件（NSPopUpButton 或可搜索下拉），列出 IANA 时区数据库中所有时区（来自 `TimeZone.knownTimeZoneIdentifiers`）
2. WHEN 用户选择新的目标时区, THE TimezoneConverter SHALL 立即基于当前 UTC 字段值重新计算并更新目标时区字段
3. THE TimezoneConverter SHALL 在标签中显示目标时区的标识符以及当前 UTC 偏移（如 `Asia/Shanghai (UTC+08:00)`）
4. THE TimezoneConverter SHALL 默认使用系统当前时区（`TimeZone.current`）作为目标时区
5. THE TimezoneConverter SHALL 持久化用户选择的目标时区到 UserDefaults，键为 `timezoneConverter.targetTimezone`，值为 IANA 标识符字符串
6. WHEN 应用重启后再次打开 TimezoneConverter, THE TimezoneConverter SHALL 恢复上次保存的目标时区
7. IF UserDefaults 中存储的时区标识符无效（不在 `TimeZone.knownTimeZoneIdentifiers` 中）, THEN THE TimezoneConverter SHALL 回退到系统当前时区

### 需求 3："现在"快捷按钮

**用户故事：** 作为用户，我希望能够一键填入当前时刻，以便快速基于"现在"做转换。

#### 验收标准

1. THE TimezoneConverter SHALL 提供一个"现在"按钮
2. WHEN 用户点击"现在"按钮, THE TimezoneConverter SHALL 把当前时间（`Date()`）写入两个字段：UTC 字段填入当前 UTC 时间，目标时区字段填入当前目标时区本地时间
3. THE "现在"按钮 SHALL 在窗口任何状态下都可用（即使有错误提示）

### 需求 4："复制"按钮

**用户故事：** 作为用户，我希望能够复制任一字段的值，以便粘贴到聊天工具或文档中。

#### 验收标准

1. THE TimezoneConverter SHALL 在每个字段（UTC、目标时区）旁边各提供一个"复制"按钮
2. WHEN 用户点击某个字段的"复制"按钮, THE TimezoneConverter SHALL 把该字段当前显示的字符串写入系统剪贴板（`NSPasteboard.general`）
3. WHEN 用户点击"复制"按钮且字段为空或无效, THE TimezoneConverter SHALL 不写入剪贴板，并通过短暂的视觉反馈（如临时禁用按钮）告知用户

### 需求 5：窗口入口与生命周期

**用户故事：** 作为用户，我希望能够方便地打开和关闭时区转换器窗口，且不影响菜单栏主功能。

#### 验收标准

1. THE MenuBarApp SHALL 在菜单中"设置…"项之后、Quit 之前增加"时区转换…"菜单项
2. THE "时区转换…"菜单项 SHALL 使用快捷键 `⌘T`
3. WHEN 用户选择"时区转换…"或按 ⌘T, THE MenuBarApp SHALL 显示 TimezoneConverter 窗口；若窗口已存在则将其前置并获得焦点
4. THE TimezoneConverter 窗口 SHALL 使用 `NSWindow.styleMask = [.titled, .closable]`，可关闭、可拖动，但不可改变大小
5. THE TimezoneConverter 窗口 SHALL 在关闭后保留实例（`isReleasedWhenClosed = false`），下次打开恢复时区设置（输入框内容不恢复）
6. THE MenuBarApp SHALL 在打开窗口时保持 `setActivationPolicy(.accessory)` 不变，仅通过 `NSApp.activate(ignoringOtherApps: true)` 把窗口提到前台，避免 Dock 图标闪现

### 需求 6：与现有功能兼容

**用户故事：** 作为用户，我希望新功能不影响菜单栏 UTC 显示与现有视觉区分功能。

#### 验收标准

1. THE TimezoneConverter SHALL 不修改菜单栏 StatusItem 的显示逻辑（仍由 TimeFormatter + StyledTextBuilder 控制）
2. THE TimezoneConverter SHALL 与 SettingsWindowController 共存：可同时打开两个窗口，互不阻塞
3. THE TimezoneConverter SHALL 使用与现有窗口（SettingsWindowController）一致的视觉风格：程序化 AppKit、`NSStackView` 排版、Chinese 标签
4. THE TimezoneConverter SHALL 不读写 `styleOptions.*` 或 `displayOptions.*` 任一 UserDefaults 键

### 需求 7：边界与正确性

**用户故事：** 作为用户，我希望转换结果在所有合理场景下都是正确的，特别是夏令时切换日。

#### 验收标准

1. THE TimezoneConverter SHALL 正确处理 DST 切换：在目标时区有夏令时切换的当天，转换结果与 macOS Calendar 应用一致
2. THE TimezoneConverter SHALL 支持 1900-01-01 至 2100-12-31 范围内的任意日期时间
3. IF 用户输入年份越界（如 0000、9999）, THEN THE TimezoneConverter SHALL 显示错误提示
4. THE TimezoneConverter SHALL 在 24 小时制下解析时间（拒绝 `13:00 PM` 等带 AM/PM 后缀的输入）
5. THE TimezoneConverter SHALL 不依赖 `Locale.current`：解析与格式化都使用 `Locale(identifier: "en_US_POSIX")`，避免阿拉伯数字以外的本地化数字

## 非功能需求

- **性能**：输入字段防抖不超过 100ms；窗口首次打开 ≤ 200ms
- **本地化**：UI 中文（与现有窗口一致），错误提示中文，时区标识符保持英文 IANA 形式
- **可访问性**：所有控件支持 VoiceOver 标签；Tab 键可循环输入字段、按钮、popup
- **测试**：核心转换函数 100% 纯函数，单元 + 属性测试覆盖
