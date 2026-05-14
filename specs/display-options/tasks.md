# 实现计划：显示选项（Display Options）

## 概述

在 `AppDelegate.swift` 中增量实现显示选项功能。先添加数据模型和格式化逻辑，再集成菜单交互和持久化，最后连接所有组件。所有实现代码保持在单文件中，测试文件放在 `UTCMenuBarTests/` 目录。

## 任务

- [x] 1. 实现 DisplayOptions 数据模型
  - [x] 1.1 在 AppDelegate.swift 中添加 DisplayOptions 结构体
    - 定义 `showDate`、`compactTime`、`compactDate` 三个 Bool 属性，默认值均为 `false`
    - 定义 UserDefaults 键名常量（`displayOptions.showDate` 等）
    - 实现 `static let default` 默认实例
    - 实现 `save()` 方法，将三个属性写入 UserDefaults
    - 实现 `static func load() -> DisplayOptions`，从 UserDefaults 读取
    - _需求：4.1, 4.2, 4.3, 1.4, 2.4, 3.4_

  - [x] 1.2 编写属性测试：DisplayOptions 持久化往返一致性
    - **属性 4：DisplayOptions 持久化往返一致性**
    - 生成随机 DisplayOptions，保存后加载，验证与原始值相等
    - **验证需求：4.1, 4.2**

  - [x] 1.3 编写单元测试：DisplayOptions 默认值和 UserDefaults 空值
    - 验证 `DisplayOptions.default` 所有属性为 `false`
    - 验证从空 UserDefaults 加载返回默认值
    - _需求：1.4, 2.4, 3.4, 4.3_

- [x] 2. 实现 TimeFormatter 格式化逻辑
  - [x] 2.1 在 AppDelegate.swift 中添加 TimeFormatter 枚举
    - 实现 `static func formatTime(date: Date, compact: Bool) -> String`
      - `compact=false` → `"HH:mm:ss"` 格式
      - `compact=true` → `"HH:mm"` 格式
    - 实现 `static func formatDate(date: Date, compact: Bool) -> String`
      - `compact=false` → `"yyyy-MM-dd"` 格式
      - `compact=true` → `"MM/dd"` 格式
    - 实现 `static func formatDisplay(date: Date, options: DisplayOptions) -> String`
      - 始终以 `"🌐 "` 开头、`" UTC"` 结尾
      - `showDate=true` 时在时间前插入日期部分
    - _需求：1.2, 1.3, 2.2, 2.3, 3.2, 3.3, 5.2, 5.3_

  - [x] 2.2 编写属性测试：showDate 控制日期可见性
    - **属性 1：showDate 控制日期可见性**
    - 生成随机 Date 和 DisplayOptions，验证输出中日期部分的存在性与 showDate 一致
    - **验证需求：1.2, 1.3**

  - [x] 2.3 编写属性测试：compactTime 控制秒数可见性
    - **属性 2：compactTime 控制秒数可见性**
    - 生成随机 Date 和 DisplayOptions，验证时间格式与 compactTime 设置一致
    - **验证需求：2.2, 2.3**

  - [x] 2.4 编写属性测试：compactDate 控制日期格式
    - **属性 3：compactDate 控制日期格式**
    - 生成随机 Date（showDate=true），验证日期格式与 compactDate 设置一致
    - **验证需求：3.2, 3.3**

  - [x] 2.5 编写属性测试：输出格式结构不变量
    - **属性 5：输出格式结构不变量**
    - 生成随机 Date 和 DisplayOptions，验证前缀 `"🌐 "`、后缀 `" UTC"` 以及日期在时间之前
    - **验证需求：5.2, 5.3**

  - [x] 2.6 编写单元测试：具体格式示例验证
    - 验证设计文档中显示格式矩阵的全部 6 种组合的精确输出字符串
    - _需求：1.2, 1.3, 2.2, 2.3, 3.2, 3.3_

- [x] 3. 检查点 - 确保模型和格式化逻辑正确
  - 确保所有测试通过，如有疑问请询问用户。

- [x] 4. 集成菜单交互和实时更新
  - [x] 4.1 在 AppDelegate 中添加 displayOptions 属性和菜单构建方法
    - 添加 `private var displayOptions: DisplayOptions` 属性
    - 实现 `buildMenu()` 方法，构建包含"显示日期"、"紧凑时间"、"紧凑日期"选项的菜单
    - 已启用选项显示勾选标记（`.on` state）
    - 当 `showDate=false` 时，"紧凑日期"菜单项设为 `isEnabled = false`（灰显）
    - 在选项和 Quit 之间添加分隔线
    - _需求：1.1, 2.1, 3.1, 6.1, 6.2, 6.3, 6.4_

  - [x] 4.2 实现选项切换方法和实时更新
    - 实现 `toggleShowDate()`：切换 `showDate`，保存，重建菜单，更新显示
    - 实现 `toggleCompactTime()`：切换 `compactTime`，保存，重建菜单，更新显示
    - 实现 `toggleCompactDate()`：切换 `compactDate`，保存，重建菜单，更新显示
    - _需求：5.1_

  - [x] 4.3 修改 applicationDidFinishLaunching 和 updateTime
    - 在 `applicationDidFinishLaunching` 中调用 `DisplayOptions.load()` 初始化选项
    - 调用 `buildMenu()` 替代原有的手动菜单构建
    - 修改 `updateTime()` 使用 `TimeFormatter.formatDisplay()` 生成显示字符串
    - _需求：4.2, 5.1, 5.2_

  - [x] 4.4 编写属性测试：菜单勾选状态与选项值一致
    - **属性 6：菜单勾选状态与选项值一致**
    - 生成随机 DisplayOptions，构建菜单，验证勾选状态与选项布尔值一致
    - **验证需求：6.2, 6.3**

  - [x] 4.5 编写属性测试：紧凑日期可用性取决于 showDate
    - **属性 7：紧凑日期可用性取决于 showDate**
    - 生成随机 DisplayOptions，构建菜单，验证紧凑日期菜单项的 enabled 状态等于 showDate
    - **验证需求：3.1, 6.4**

  - [x] 4.6 编写单元测试：菜单结构验证
    - 验证菜单包含 3 个选项项、1 个分隔线和 1 个 Quit 项
    - _需求：1.1, 2.1, 6.1_

- [x] 5. 最终检查点 - 确保所有测试通过
  - 确保所有测试通过，如有疑问请询问用户。

## 备注

- 标记 `*` 的任务为可选任务，可跳过以加快 MVP 进度
- 每个任务引用了具体的需求编号以确保可追溯性
- 属性测试验证通用正确性属性，单元测试验证具体示例和边界情况
- 所有代码实现在 `AppDelegate.swift` 中，测试文件在 `UTCMenuBarTests/` 目录
