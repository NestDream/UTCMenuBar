# 应用内更新 — 设计

## 架构

延续库/壳分层：可单测的纯逻辑进 `UTCMenuBarLib`，网络、文件替换、UI 留在 app target。

```
UTCMenuBarLib/
  UpdateChecker.swift      # AppVersion 解析比较、GitHub JSON 解析、可用性判定、自动检查节流（纯函数）
  UpdatePreferences.swift  # updates.* UserDefaults 模型（autoCheck / skippedTag / lastCheckAt）
Sources/
  UpdateController.swift   # @MainActor：URLSession 请求与下载、ditto 解压、校验、替换、重启、NSAlert/进度窗
```

## 数据模型

```swift
public struct AppVersion: Comparable, Sendable {
    public let major: Int; public let minor: Int; public let patch: Int
    // 接受 "1.2.0" 与 "v1.2.0"；含任何后缀（如 0.0.0-dev）或缺段返回 nil
    public static func parse(_ string: String) -> AppVersion?
}

public struct UpdateInfo: Equatable, Sendable {
    public let version: AppVersion   // 由 tag 解析
    public let tagName: String       // "v1.2.0"
    public let assetURL: URL         // browser_download_url
    public let assetName: String
    public let releasePageURL: URL   // html_url
}

public struct UpdatePreferences: Equatable, Sendable {
    public var autoCheck: Bool       // updates.autoCheck，默认 true
    public var skippedTag: String?   // updates.skippedTag
    public var lastCheckAt: Date?    // updates.lastCheckAt（epoch 秒）
    // save(to:) / load(from:) 与 DisplayOptions 同构
}
```

## 算法

### UpdateChecker.parseLatestRelease(json:) -> UpdateInfo?

1. Decodable 解析 GitHub Release JSON（`tag_name`、`html_url`、`draft`、`prerelease`、`assets[].name/browser_download_url`）
2. `draft || prerelease` → nil
3. `AppVersion.parse(tag_name)` 失败 → nil
4. 资产选择：优先名称前缀 `UTCMenuBar-` 且后缀 `.zip`；否则任一 `.zip`；无 → nil

### UpdateChecker.availableUpdate(currentVersion:latest:skippedTag:) -> UpdateInfo?

- `AppVersion.parse(currentVersion)` 失败（开发构建）→ nil（需求 1.6）
- `latest.version <= current` → nil
- `latest.tagName == skippedTag` → nil（调用方在用户主动检查时传 nil，实现需求 2.3）

### UpdateChecker.shouldAutoCheck(now:preferences:minimumInterval=86400) -> Bool

`preferences.autoCheck && (lastCheckAt == nil || now - lastCheckAt >= minimumInterval)`

### UpdateController.downloadAndInstall(update:)（app target）

1. `URLSession.download(from: assetURL)` → 临时 zip（应用未声明 `LSFileQuarantineEnabled`，产物无 quarantine）
2. `ditto -x -k` 解压到独立临时目录，取其中唯一 `.app`
3. 校验：`Bundle(url:)` 的 identifier == 当前 identifier 且 short version == `update.version`
4. 目标 = `Bundle.main.bundleURL`；路径含 `/AppTranslocation/` 或父目录不可写 → 抛 `.cannotReplace`（需求 3.3）
5. 替换：`trashItem(当前)` → `moveItem(新 → 原路径)`；任一步抛错即失败（原 bundle 可从废纸篓找回）
6. 重启：`/usr/bin/open -n <原路径>` 后 `NSApp.terminate`

## 正确性属性

- P1 版本解析：合法 `x.y.z` 与 `vx.y.z` 均可解析且逐段数值比较；任何非法输入（空、缺段、带后缀、非数字）返回 nil
- P2 版本比较全序：对随机三元组，比较结果与逐段字典序一致（属性测试）
- P3 发行版解析：draft/prerelease/无 zip 资产/非法 tag → nil；多资产时优先 `UTCMenuBar-*.zip`
- P4 可用性判定：latest <= current → nil；current 不可解析 → nil；skippedTag 命中 → nil；严格更大且未跳过 → 返回 latest
- P5 自动检查节流：关开关 → false；从未检查 → true；间隔 >= 24h → true，否则 false
- P6 偏好持久化：save 后 load 往返相等；缺省键 load 出默认值（autoCheck=true, 其余 nil）

## 菜单与设置

- `MenuBuilder` 新增 `checkForUpdates` selector 参数，菜单项插在"时区转换…"之后（菜单从 9 项变为 10 项，更新 MenuTests 的结构断言；在 visual-distinction 需求 8 的结构上追加一项）
- `SettingsViewModel2` 新增 `autoCheckUpdates: Bool`（didSet 持久化到 `UpdatePreferences`）；SettingsView 通用区加开关、关于区加"检查更新…"按钮（注入 `onCheckForUpdates` 闭包）

## 安全考量

- 仅访问固定的 GitHub HTTPS 端点；下载后强校验 bundle identifier 与版本号
- 不做任何 quarantine 剥离操作；依赖"应用自身下载不产生 quarantine"这一系统行为
- 替换失败不回滚半成品：先移废纸篓再搬入，任何一步失败都保持可恢复状态
