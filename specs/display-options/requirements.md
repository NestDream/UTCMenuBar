# 需求文档

## 简介

为 UTCMenuBar macOS 菜单栏应用添加可配置的显示选项。当前应用仅以固定格式 "🌐 HH:mm:ss UTC" 显示 UTC 时间，无任何用户可配置项。本功能将允许用户自定义显示内容，包括是否显示日期、以及日期和时间的紧凑模式，以适应不同屏幕尺寸的需求。

## 术语表

- **MenuBarApp**: UTCMenuBar macOS 菜单栏应用程序，在系统菜单栏中显示 UTC 时间
- **StatusItem**: macOS 系统菜单栏中的显示项，用于展示时间文本
- **DisplayOptions（显示选项）**: 用户可配置的一组设置，控制菜单栏中时间和日期的显示方式
- **CompactMode（紧凑模式）**: 一种缩短显示格式的模式，减少菜单栏占用空间，适合小屏幕用户
- **SettingsMenu（设置菜单）**: 菜单栏应用的下拉菜单，包含所有显示选项的开关
- **UserDefaults**: macOS 系统提供的持久化存储机制，用于保存用户偏好设置

## 需求

### 需求 1：显示日期选项

**用户故事：** 作为用户，我希望能够选择是否在菜单栏中显示 UTC 日期，以便在需要时快速查看当前日期。

#### 验收标准

1. THE MenuBarApp SHALL 在 SettingsMenu 中提供"显示日期"开关选项
2. WHEN 用户启用"显示日期"选项, THE MenuBarApp SHALL 在 StatusItem 中同时显示日期和时间
3. WHEN 用户禁用"显示日期"选项, THE MenuBarApp SHALL 在 StatusItem 中仅显示时间
4. THE MenuBarApp SHALL 默认禁用"显示日期"选项，保持与当前行为一致

### 需求 2：时间紧凑模式

**用户故事：** 作为屏幕空间有限的用户，我希望能够切换到紧凑的时间显示格式，以减少菜单栏占用的空间。

#### 验收标准

1. THE MenuBarApp SHALL 在 SettingsMenu 中提供"紧凑时间"开关选项
2. WHEN 用户启用"紧凑时间"选项, THE MenuBarApp SHALL 以 "HH:mm" 格式显示时间（省略秒数）
3. WHEN 用户禁用"紧凑时间"选项, THE MenuBarApp SHALL 以 "HH:mm:ss" 格式显示时间
4. THE MenuBarApp SHALL 默认禁用"紧凑时间"选项，保持完整时间显示

### 需求 3：日期紧凑模式

**用户故事：** 作为屏幕空间有限的用户，我希望在显示日期时能够选择紧凑的日期格式，以减少菜单栏占用的空间。

#### 验收标准

1. WHILE "显示日期"选项已启用, THE MenuBarApp SHALL 在 SettingsMenu 中提供"紧凑日期"开关选项
2. WHEN 用户启用"紧凑日期"选项, THE MenuBarApp SHALL 以 "MM/dd" 格式显示日期（省略年份）
3. WHEN 用户禁用"紧凑日期"选项, THE MenuBarApp SHALL 以 "yyyy-MM-dd" 格式显示日期
4. THE MenuBarApp SHALL 默认禁用"紧凑日期"选项，保持完整日期显示

### 需求 4：设置持久化

**用户故事：** 作为用户，我希望我的显示偏好设置在应用重启后仍然保留，以免每次启动都需要重新配置。

#### 验收标准

1. WHEN 用户更改任何 DisplayOptions 设置, THE MenuBarApp SHALL 立即将设置保存到 UserDefaults
2. WHEN MenuBarApp 启动时, THE MenuBarApp SHALL 从 UserDefaults 读取已保存的 DisplayOptions 设置并应用
3. IF UserDefaults 中不存在已保存的设置, THEN THE MenuBarApp SHALL 使用默认值（仅显示完整时间，不显示日期）

### 需求 5：实时更新显示

**用户故事：** 作为用户，我希望更改显示选项后菜单栏立即反映变化，以便确认设置是否符合预期。

#### 验收标准

1. WHEN 用户切换任何 DisplayOptions 开关, THE MenuBarApp SHALL 在 1 秒内更新 StatusItem 的显示内容
2. THE MenuBarApp SHALL 在更新显示时保持 "🌐" 前缀和 "UTC" 后缀不变
3. WHEN "显示日期"选项已启用, THE MenuBarApp SHALL 按照 "🌐 {日期} {时间} UTC" 的顺序排列显示内容

### 需求 6：菜单结构

**用户故事：** 作为用户，我希望显示选项在菜单中清晰分组，以便快速找到和调整设置。

#### 验收标准

1. THE MenuBarApp SHALL 在 SettingsMenu 中使用分隔线将 DisplayOptions 与"Quit"菜单项分开
2. THE MenuBarApp SHALL 对已启用的选项在菜单项旁显示勾选标记（checkmark）
3. THE MenuBarApp SHALL 对已禁用的选项不显示勾选标记
4. WHILE "显示日期"选项已禁用, THE MenuBarApp SHALL 将"紧凑日期"菜单项显示为不可用（grayed out）状态
