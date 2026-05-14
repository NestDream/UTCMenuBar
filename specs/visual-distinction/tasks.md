# 任务列表

## 任务 1：创建 StyleOptions 数据模型

- [x] 1.1 在 UTCMenuBarLib 中创建 StyleOptions.swift 文件，定义 FontFamily、FontWeight、FontSize、TextColorOption、Decorator 枚举（_需求 1.1, 2.1, 3.1, 4.1, 5.1_）
- [x] 1.2 实现 StyleOptions struct，包含所有样式属性和默认值（_需求 1.3, 2.3, 3.5, 4.4, 5.4_）
- [x] 1.3 实现 StyleOptions 的 save(to:) 和 load(from:) 方法，通过 UserDefaults 持久化（_需求 5.6, 7.1, 7.2_）
- [x] 1.4 为 StyleOptions 编写单元测试，验证默认值、持久化往返一致性和容错加载（_需求 7.1, 7.2, 7.3_）

## 任务 2：创建 StyledTextBuilder 组件

- [x] 2.1 在 UTCMenuBarLib 中创建 StyledTextBuilder.swift 文件
- [x] 2.2 实现 resolveFont(family:weight:size:) 方法，包含字体回退机制（_需求 1.4, 2.2, 3.2-3.4_）
- [x] 2.3 实现 resolveColor(option:) 方法，返回对应的 NSColor 或 nil（_需求 4.2, 4.3, 4.5_）
- [x] 2.4 实现 buildAttributedString(text:style:) 方法，组合字体、颜色和 `decorator.prefix`/`decorator.suffix` 生成 NSAttributedString（_需求 5.2, 5.3, 6.1, 6.3, 6.4_）
- [x] 2.5 为 StyledTextBuilder 编写单元测试，验证字体解析、颜色解析和富文本构建

## 任务 3：扩展 MenuBuilder 支持外观子菜单

- [x] 3.1 扩展 MenuBuilder.buildMenu 方法签名，接受 StyleOptions 与 setFontFamily / setFontWeight / setFontSize / setTextColor / setDecorator / showSettings selectors（_需求 8.1_）
- [x] 3.2 实现"外观"子菜单构建逻辑，包含字体、字重、字号、颜色、装饰五个 radio 子菜单（_需求 8.3_）
- [x] 3.3 实现 radio 子菜单中的互斥单选勾选标记逻辑，使用 `NSMenuItem.tag` 存放 `T.allCases` 索引（_需求 1.5, 2.4, 3.6, 4.6, 5.5, 8.4_）
- [x] 3.4 在主菜单中追加"设置… ⌘,"项（_需求 10.1_）
- [x] 3.5 为扩展后的 MenuBuilder 编写单元测试，验证 8 项菜单结构、外观子菜单 5 项 radio 状态、设置项快捷键

## 任务 4：集成到 AppDelegate

- [x] 4.1 在 AppDelegate 中持有 `StyleOptionsStore` 实例，启动时由 store 内部从 UserDefaults 加载（_需求 7.2_）
- [x] 4.2 修改 updateTime() 方法，从 statusItem.button?.title 迁移到 attributedTitle，并清空原 title（_需求 6.1_）
- [x] 4.3 实现样式切换的 @objc action（setFontFamily / setFontWeight / setFontSize / setTextColor / setDecorator），通过 `sender.tag` 反查枚举值并调用 `styleStore.update`（_需求 1.2, 2.2, 3.2-3.4, 4.2, 4.3, 5.2, 5.3_）
- [x] 4.4 更新 buildMenu() 调用，传入 `styleStore.current` 与所有样式 selectors + showSettings + quit（_需求 8.1, 8.3_）
- [x] 4.5 注册 `styleStore.addListener` 以在任意 store 变更后重建菜单并刷新 attributedTitle（_需求 6.2_）

## 任务 5：属性测试

- [x] 5.1 编写属性测试：富文本内容等于装饰后的纯文本（属性 1，使用 `style.decorator.prefix/suffix`）
- [x] 5.2 编写属性测试：字体解析始终返回有效字体且 pointSize 正确（属性 2）
- [x] 5.3 编写属性测试：StyleOptions 持久化往返一致性（属性 4）
- [x] 5.4 编写属性测试：StyleOptions 加载容错性（属性 5）
- [x] 5.5 编写属性测试：与现有 DisplayOptions 功能兼容（属性 8）
- [x] 5.6 编写属性测试：菜单选中状态与样式选项一致（属性 7，覆盖五个 radio 子菜单）

## 任务 6：StyleOptionsStore（样式单一事实源）

- [x] 6.1 在应用 target 创建 `Sources/StyleOptionsStore.swift`，定义 `@MainActor final class StyleOptionsStore`
- [x] 6.2 实现 `current`（私有 setter）、`init(defaults:)` 自 UserDefaults 加载（_需求 7.2, 7.3_）
- [x] 6.3 实现 `update(_ mutate:)`：原地修改 → `current.save(to: defaults)` → 同步广播给所有 listener（_需求 7.1_）
- [x] 6.4 实现 `addListener(_:)` 注册接口，AppDelegate 与 SettingsWindowController 各注册一个 listener
- [x] 6.5 替换 AppDelegate 中原本"在每个 @objc action 里手动 save + buildMenu + updateTime"的逻辑为 `styleStore.update`

## 任务 7：SettingsViewModel 与单元测试

- [x] 7.1 在 UTCMenuBarLib 创建 `SettingsViewModel.swift`，提供 `selectedIndex<T:CaseIterable&Equatable>(_:)`、`value<T:CaseIterable>(at:of:)`、`previewAttributedString(style:sample:)`
- [x] 7.2 编写 SettingsViewModelTests：每个 StyleOptions 字段枚举的 `selectedIndex` 与 `value(at:of:)` 双向往返；越界索引返回 nil；`previewAttributedString` 与 `StyledTextBuilder.buildAttributedString` 输出等价（同 string、同 .font、同 .foregroundColor）

## 任务 8：SettingsWindowController 与 main.swift 接线

- [x] 8.1 在应用 target 创建 `Sources/SettingsWindowController.swift`，使用程序化 AppKit 构建 380×260 的 `[.titled, .closable]` 窗口，标题 "UTCMenuBar 设置"，`isReleasedWhenClosed = false`（_需求 10.3, 10.8_）
- [x] 8.2 构建视图层级：5 行 row(label, control) + NSBox 分隔线 + 预览 NSStackView，控件分别为 4 个 NSPopUpButton + 1 个 NSSegmentedControl（字号，selectOne）（_需求 10.4_）
- [x] 8.3 实现 `refresh(from:)`：用 `SettingsViewModel.selectedIndex` 与 `previewAttributedString` 同步控件与预览（_需求 10.5, 10.7_）
- [x] 8.4 实现 `popupChanged(_:)` / `segmentedChanged(_:)`：用 `SettingsViewModel.value(at:of:)` 反查 → `store.update`（_需求 10.6_）
- [x] 8.5 在 AppDelegate 添加 `showSettings()`：懒加载 `SettingsWindowController` → `NSApp.activate(ignoringOtherApps:)` → `showWindow(nil)`，永远不切换 activationPolicy（_需求 10.2, 10.9_）
- [x] 8.6 main.swift 仅在启动时调用一次 `app.setActivationPolicy(.accessory)`（_需求 10.9_）

## 任务 9：规格文档同步

- [x] 9.1 更新 requirements.md：术语表加入 Decorator/StyleOptionsStore/SettingsWindowController；需求 5 改为基于 Decorator 枚举与单一 UserDefaults 键；新增需求 10（设置窗口）
- [x] 9.2 更新 design.md：StyleOptions 字段 `prefix`/`suffix` → `decorator: Decorator`；新增 StyleOptionsStore / SettingsViewModel / SettingsWindowController 组件章节；菜单结构图从 5 项更新为 8 项；属性 1 限定 prefix/suffix 来源于 Decorator 计算属性；新增属性 9（设置窗口控件 ↔ store 一致性）
- [x] 9.3 更新 tasks.md：将原任务 1.x–5.x 全部标记 `[x]`；新增任务 6（store）、7（SettingsViewModel + tests）、8（SettingsWindowController + 接线）、9（本任务）
