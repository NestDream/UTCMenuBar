# 任务列表

## 任务 1：TimezoneConverterOptions 数据模型

- [ ] 1.1 在 UTCMenuBarLib 中创建 `TimezoneConverterOptions.swift`，含 `targetTimezone: String` 字段（_需求 2.5_）
- [ ] 1.2 实现 `save(to:)` / `load(from:)`，无效值回退到 `TimeZone.current.identifier`（_需求 2.4, 2.7_）
- [ ] 1.3 编写 `TimezoneConverterOptionsTests`：默认值、持久化往返、非法值容错（_属性 TC5, TC6_）

## 任务 2：TimezoneConverter 核心纯函数

- [ ] 2.1 创建 `Sources/UTCMenuBarLib/TimezoneConverter.swift`，定义 `ConversionError` 枚举（_需求 1.6, 7.3_）
- [ ] 2.2 实现 `parseUTC(_:)` 与 `parseInTimezone(_:timezone:)`，使用 `Locale(identifier: "en_US_POSIX")`（_需求 1.4, 7.4, 7.5_）
- [ ] 2.3 实现 `format(date:in:)`（_需求 1.4_）
- [ ] 2.4 实现 `convertUTCToTarget` 与 `convertTargetToUTC`，串联 parse + format（_需求 1.2, 1.3_）
- [ ] 2.5 实现 `now(targetTimezoneId:)`（_需求 3.2_）
- [ ] 2.6 实现年份越界检测（_需求 7.2, 7.3_）
- [ ] 2.7 编写 `TimezoneConverterTests`：成功路径、错误路径、DST 切换日（LA 2025-03-09 / 2025-11-02）（_需求 1.2, 1.3, 7.1_）
- [ ] 2.8 编写 `TimezoneConverterPropertyTests`：TC1, TC2, TC4（每条 100 次）

## 任务 3：TimezoneConverterStore

- [ ] 3.1 创建 `Sources/TimezoneConverterStore.swift`，与 `StyleOptionsStore` 同形（_需求 2.5, 2.6_）
- [ ] 3.2 注入 `UserDefaults.standard`，在 init 时 load
- [ ] 3.3 `update`/`addListener` 同 `StyleOptionsStore`

## 任务 4：菜单扩展

- [ ] 4.1 修改 `Sources/UTCMenuBarLib/MenuBuilder.swift`：增加 `showTimezoneConverter: Selector?` 参数（_需求 5.1_）
- [ ] 4.2 在"设置…"项之后插入"时区转换… ⌘T"项（_需求 5.1, 5.2_）
- [ ] 4.3 更新 `MenuTests.testMenuStructure`：现在 9 个顶层项（_需求 5.1, 5.2_）
- [ ] 4.4 增加 `testTimezoneConverterItemKeyEquivalent`：⌘T

## 任务 5：AppDelegate 接入（stub 阶段）

- [ ] 5.1 在 `main.swift` 增加 `converterStore: TimezoneConverterStore` 与 `converterWindowController: TimezoneConverterWindowController?` 字段
- [ ] 5.2 增加 stub `@objc func showTimezoneConverter()`：先 NSLog 占位
- [ ] 5.3 `buildMenu()` 调用更新，传入新 selector
- [ ] 5.4 `swift run` 验证菜单项可见、⌘T 触发 NSLog

## 任务 6：TimezoneConverterWindowController

- [ ] 6.1 创建 `Sources/TimezoneConverterWindowController.swift`，沿用 `SettingsWindowController` 的程序化 AppKit 风格（_需求 5.4, 6.3_）
- [ ] 6.2 构建视图：popup + 两个 NSTextField + 两个复制按钮 + errorLabel + nowButton（_需求 1.1, 2.1, 3.1, 4.1_）
- [ ] 6.3 popup 数据源：`TimeZone.knownTimeZoneIdentifiers.sorted()`，title 含 UTC 偏移（_需求 2.1, 2.3_）
- [ ] 6.4 实现 NSTextDelegate.controlTextDidChange + isProgrammaticUpdate 标志，避免回响（_需求 1.2, 1.3_）
- [ ] 6.5 实现 `nowClicked()`：调用 `TimezoneConverter.now(...)` 填两边（_需求 3.2_）
- [ ] 6.6 实现 `copyClicked(_:)`：写入 NSPasteboard.general（_需求 4.2, 4.3_）
- [ ] 6.7 实现 `timezoneChanged(_:)`：popup 切换后基于当前 UTC 字段重算 target（_需求 2.2_）
- [ ] 6.8 实现 errorLabel 显示/隐藏逻辑（_需求 1.6, 7.3_）

## 任务 7：AppDelegate 接入真实 window controller

- [ ] 7.1 替换 `showTimezoneConverter` stub 为真实实例化逻辑（与 `showSettings` 同形）（_需求 5.3, 5.5, 5.6_）
- [ ] 7.2 验证：⌘T 弹窗、关闭再打开保留时区设置、与 Settings 共存

## 任务 8：手动验证

- [ ] 8.1 完整跑通"验证"清单（design.md 末节）
- [ ] 8.2 验证 DST 切换日转换与 macOS Calendar 一致

## 任务 9：spec 同步

- [ ] 9.1 实现完成后回填 tasks.md 的勾选状态
- [ ] 9.2 如有偏离 design.md 的实际实现，更新 design.md
