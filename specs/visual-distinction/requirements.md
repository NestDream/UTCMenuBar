# 需求文档

## 简介

为 UTCMenuBar macOS 菜单栏应用添加视觉区分功能，解决 UTC 时间在菜单栏中容易与系统时间混淆的问题。本功能允许用户自定义菜单栏中 UTC 时间的字体样式、字重、字号、文字颜色和装饰符，通过视觉差异使 UTC 时间一目了然地区别于系统时钟。

## 术语表

- **StyleOptions（样式选项）**: 用户可配置的一组视觉样式设置，控制菜单栏中时间文本的外观
- **FontFamily（字体族）**: 字体的家族分类，如系统字体、Menlo 等宽字体、SF Mono 等宽字体
- **FontWeight（字重）**: 字体的粗细程度，如常规、中等、半粗、粗体
- **FontSize（字号）**: 字体的大小，相对于系统菜单栏默认字号的偏移
- **TextColorOption（文字颜色）**: 菜单栏文字的前景色选项
- **Decorator（装饰符）**: 包裹时间文本的装饰枚举（`.none / .brackets / .parentheses / .bars`），其 `prefix`/`suffix` 计算属性提供具体的前后字符
- **StyleOptionsStore**: 应用层的 StyleOptions 单一事实源（single source of truth），向 AppDelegate 与 SettingsWindowController 广播变更
- **SettingsWindowController**: 独立的"设置"窗口控制器，提供与外观子菜单等价的 GUI 编辑入口
- **NSAttributedString**: macOS 富文本对象，支持字体、颜色等属性
- **attributedTitle**: NSStatusItem.button 的富文本标题属性，替代纯文本 title

## 需求

### 需求 1：字体族选择

**用户故事：** 作为用户，我希望能够选择菜单栏中 UTC 时间的字体族，以便通过不同的字体风格（如等宽字体）将其与系统时间区分开来。

#### 验收标准

1. THE MenuBarApp SHALL 在外观子菜单中提供字体族选择，包含以下选项：系统字体、Menlo（等宽）、SF Mono（等宽）
2. WHEN 用户选择某个字体族, THE MenuBarApp SHALL 立即使用该字体渲染菜单栏时间文本
3. THE MenuBarApp SHALL 默认使用系统字体
4. IF 用户选择的字体在系统中不可用, THEN THE MenuBarApp SHALL 回退到系统等宽字体
5. THE MenuBarApp SHALL 在字体族选项中对当前选中的字体显示勾选标记

### 需求 2：字重选择

**用户故事：** 作为用户，我希望能够调整菜单栏中 UTC 时间的字重，以便通过粗细差异增强视觉区分度。

#### 验收标准

1. THE MenuBarApp SHALL 在外观子菜单中提供字重选择，包含以下选项：常规、中等、半粗、粗体
2. WHEN 用户选择某个字重, THE MenuBarApp SHALL 立即使用该字重渲染菜单栏时间文本
3. THE MenuBarApp SHALL 默认使用常规字重
4. THE MenuBarApp SHALL 在字重选项中对当前选中的字重显示勾选标记

### 需求 3：字号选择

**用户故事：** 作为用户，我希望能够调整菜单栏中 UTC 时间的字号大小，以便通过大小差异增强视觉区分度。

#### 验收标准

1. THE MenuBarApp SHALL 在外观子菜单中提供字号选择，包含以下选项：小、标准、大
2. WHEN 用户选择"小"字号, THE MenuBarApp SHALL 使用系统菜单栏默认字号减 2pt 渲染文本
3. WHEN 用户选择"标准"字号, THE MenuBarApp SHALL 使用系统菜单栏默认字号渲染文本
4. WHEN 用户选择"大"字号, THE MenuBarApp SHALL 使用系统菜单栏默认字号加 2pt 渲染文本
5. THE MenuBarApp SHALL 默认使用标准字号
6. THE MenuBarApp SHALL 在字号选项中对当前选中的字号显示勾选标记

### 需求 4：文字颜色选择

**用户故事：** 作为用户，我希望能够设置菜单栏中 UTC 时间的文字颜色，以便通过颜色差异快速识别 UTC 时间。

#### 验收标准

1. THE MenuBarApp SHALL 在外观子菜单中提供颜色选择，包含以下选项：默认、蓝色、绿色、橙色、紫色、红色
2. WHEN 用户选择"默认"颜色, THE MenuBarApp SHALL 使用系统默认文字颜色（跟随 dark/light mode）
3. WHEN 用户选择非默认颜色, THE MenuBarApp SHALL 使用对应的 NSColor.system* 颜色渲染文本
4. THE MenuBarApp SHALL 默认使用"默认"颜色选项
5. THE MenuBarApp SHALL 使用系统动态颜色（NSColor.system*）以确保在 dark/light mode 下均有良好可见性
6. THE MenuBarApp SHALL 在颜色选项中对当前选中的颜色显示勾选标记

### 需求 5：装饰符选择

**用户故事：** 作为用户，我希望能够为菜单栏中的 UTC 时间添加装饰符（如方括号），以便通过视觉包裹效果将其与系统时间区分。

#### 验收标准

1. THE MenuBarApp SHALL 在外观子菜单中提供装饰符选择，对应 `Decorator` 枚举的全部 case：`.none`（无装饰）、`.brackets`（[方括号]）、`.parentheses`（(圆括号)）、`.bars`（│竖线│）
2. WHEN 用户选择 `.none`, THE MenuBarApp SHALL 不在文本前后添加任何字符（`prefix == "" && suffix == ""`）
3. WHEN 用户选择 `.brackets`/`.parentheses`/`.bars`, THE MenuBarApp SHALL 使用对应 case 的 `prefix` 与 `suffix` 计算属性包裹时间文本
4. THE MenuBarApp SHALL 默认使用 `.none`
5. THE MenuBarApp SHALL 在装饰符选项中对当前选中的装饰显示勾选标记
6. THE MenuBarApp SHALL 仅使用单一 UserDefaults 键 `styleOptions.decorator` 持久化所选 case 的 rawValue（不再使用独立的 prefix/suffix 字符串键）

### 需求 6：富文本渲染

**用户故事：** 作为用户，我希望所有视觉样式设置能正确应用到菜单栏显示中，以便看到一致的视觉效果。

#### 验收标准

1. THE MenuBarApp SHALL 使用 NSStatusItem.button 的 attributedTitle 属性（替代纯文本 title）来渲染时间文本
2. WHEN 任何样式选项变更时, THE MenuBarApp SHALL 在 1 秒内更新菜单栏显示
3. THE MenuBarApp SHALL 确保富文本在整个字符串范围内使用一致的样式属性
4. THE MenuBarApp SHALL 确保视觉样式不影响时间文本的内容（仅影响渲染外观）

### 需求 7：样式设置持久化

**用户故事：** 作为用户，我希望我的视觉样式设置在应用重启后仍然保留，以免每次启动都需要重新配置。

#### 验收标准

1. WHEN 用户更改任何 StyleOptions 设置, THE MenuBarApp SHALL 立即将设置保存到 UserDefaults
2. WHEN MenuBarApp 启动时, THE MenuBarApp SHALL 从 UserDefaults 读取已保存的 StyleOptions 设置并应用
3. IF UserDefaults 中存储的值无效或不存在, THEN THE MenuBarApp SHALL 使用默认值（系统字体、常规字重、标准字号、默认颜色、无装饰）

### 需求 8：菜单结构

**用户故事：** 作为用户，我希望视觉样式选项在菜单中组织清晰，易于找到和操作。

#### 验收标准

1. THE MenuBarApp SHALL 在现有显示选项和 Quit 之间添加"外观"子菜单项
2. THE MenuBarApp SHALL 使用分隔线将"外观"子菜单与其他菜单项分开
3. THE "外观"子菜单 SHALL 包含以下子菜单：字体、字重、字号、颜色、装饰
4. THE MenuBarApp SHALL 在每个子菜单中使用互斥单选样式（当前选中项显示勾选标记，其他项不显示）

### 需求 9：与现有功能兼容

**用户故事：** 作为用户，我希望新的视觉区分功能不影响现有的显示选项功能（显示日期、紧凑模式等）。

#### 验收标准

1. THE MenuBarApp SHALL 保持现有 DisplayOptions（显示日期、紧凑时间、紧凑日期）功能不变
2. THE MenuBarApp SHALL 确保 StyleOptions 和 DisplayOptions 可以独立配置，互不干扰
3. THE MenuBarApp SHALL 保持 "🌐" 前缀和 "UTC" 后缀在所有样式配置下不变
4. THE MenuBarApp SHALL 确保装饰符包裹的是完整的显示文本（包含 🌐 前缀和 UTC 后缀）

### 需求 10：设置窗口

**用户故事：** 作为用户，除了菜单栏中的外观子菜单外，我希望有一个独立的设置窗口，可以集中查看与调整所有视觉样式选项，并通过实时预览看到样式效果。

#### 验收标准

1. THE MenuBarApp SHALL 在主菜单中提供"设置…"项，键盘快捷键为 `⌘,`
2. WHEN 用户点击"设置…"或按下 `⌘,`, THE MenuBarApp SHALL 调用 `NSApp.activate(ignoringOtherApps: true)` 后显示设置窗口
3. THE 设置窗口 SHALL 标题为 "UTCMenuBar 设置"，初始尺寸 380×260，styleMask 为 `[.titled, .closable]`
4. THE 设置窗口 SHALL 包含以下五个控件，覆盖全部 StyleOptions 字段：字体（NSPopUpButton）、字重（NSPopUpButton）、字号（NSSegmentedControl，selectOne）、颜色（NSPopUpButton）、装饰（NSPopUpButton）
5. THE 设置窗口 SHALL 包含一个预览区域，使用 `SettingsViewModel.previewAttributedString` 渲染 `🌐 14:30:25 UTC` 的当前样式
6. WHEN 用户在设置窗口中改变任意控件的选中值, THE MenuBarApp SHALL 通过 `StyleOptionsStore.update` 写回，并立即更新菜单栏 attributedTitle、外观子菜单的勾选状态以及预览
7. WHEN 用户通过外观子菜单改变样式, THE 设置窗口（若已打开）SHALL 自动同步控件选中状态与预览
8. THE 设置窗口 SHALL 设置 `isReleasedWhenClosed = false`，关闭后再次触发"设置…"时复用同一控制器实例
9. THE MenuBarApp SHALL 始终保持 `NSApplication.activationPolicy == .accessory`（即不在 Dock 中出现），打开/关闭设置窗口不改变此策略

### 需求 11：图标前缀

**用户故事：** 作为用户，我希望能够更换或移除菜单栏文本起始的图标，以便在视觉上更进一步区分 UTC 时间，或在菜单栏空间紧张时隐藏图标。

#### 验收标准

1. THE MenuBarApp SHALL 在外观子菜单中提供"图标"子菜单，包含 `IconPrefix` 枚举的全部 case：`.globe`（地球仪）、`.clock`（时钟）、`.compass`（指南针）、`.earth`（地球）、`.none`（无图标）
2. WHEN 用户选择 `.globe`, THE MenuBarApp SHALL 使用 "🌐 " 作为前缀（即原默认值，保持向后兼容）
3. WHEN 用户选择 `.clock`/`.compass`/`.earth`, THE MenuBarApp SHALL 分别使用 "🕐 "/"🧭 "/"🌍 " 作为前缀
4. WHEN 用户选择 `.none`, THE MenuBarApp SHALL 不在文本前添加任何字符（前缀为空字符串）
5. THE MenuBarApp SHALL 默认使用 `.globe`
6. THE MenuBarApp SHALL 通过单一 UserDefaults 键 `styleOptions.iconPrefix` 持久化所选 case 的 rawValue
7. THE 设置窗口 SHALL 包含与"图标"子菜单等价的 NSPopUpButton，与 store 双向同步
8. THE MenuBarApp SHALL 在图标子菜单中对当前选中的 case 显示勾选标记
9. THE MenuBarApp SHALL 保持 " UTC" 后缀不变；图标前缀仅替换文本起始部分

### 需求 12：自定义字体

**用户故事：** 作为用户，除了系统预设的字体族外，我希望能够选择系统中已安装的任意字体来渲染菜单栏 UTC 时间，以便最大程度地与系统时钟视觉区分。

#### 验收标准

1. THE MenuBarApp SHALL 在 `FontFamily` 枚举中新增 `.custom` case（rawValue `"custom"`），与既有的 `.system / .menlo / .sfMono` 并列
2. THE StyleOptions SHALL 新增 `customFontName: String` 字段，默认 `""`，通过 UserDefaults 键 `styleOptions.customFontName` 持久化
3. WHEN `fontFamily == .custom` 且 `customFontName` 非空且系统存在该字体, THE StyledTextBuilder SHALL 使用该字体渲染（保留当前 `FontWeight`/`FontSize`）
4. IF `fontFamily == .custom` 且 `customFontName` 为空或字体在系统中不存在, THEN THE StyledTextBuilder SHALL 回退到系统字体（`NSFont.systemFont`）
5. THE MenuBarApp SHALL 在字体子菜单和设置窗口的字体下拉框最末位置显示 "自定义…" 项；当 `fontFamily == .custom` 且 `customFontName` 非空时，标签显示为 "自定义：<fontName>"
6. WHEN 用户在字体子菜单或设置窗口选择 "自定义…" 项, THE MenuBarApp SHALL 调用 `NSFontPanel.shared.makeKeyAndOrderFront(nil)` 弹出系统字体面板（同时通过 `NSFontManager` 设置当前选中字体）
7. WHEN 用户在字体面板中选定一个字体, THE MenuBarApp SHALL 通过 `StyleOptionsStore.update` 同时写入 `fontFamily = .custom` 与 `customFontName = picked.fontName`
8. THE MenuBarApp SHALL 保持既有 `styleOptions.fontFamily` 持久化向后兼容：旧用户存储的 `.menlo` 等 rawValue 在升级后仍能正确加载
9. WHEN `fontFamily == .custom` 时, THE 字体子菜单 SHALL 把勾选标记显示在 "自定义…" 项上
