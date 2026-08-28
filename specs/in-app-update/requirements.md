# 应用内更新 — 需求

## 背景

应用未经 Apple 公证,用户每次从 GitHub 下载新版本都要重新经历 Gatekeeper 的"Open Anyway"流程。应用自身通过 `URLSession` 下载的文件不带 quarantine 标记(应用未声明 `LSFileQuarantineEnabled`),因此应用内自更新可以一次安装、后续无阻力升级。

## 术语

- **最新发行版**: GitHub API `repos/NestDream/UTCMenuBar/releases/latest` 返回的非 draft、非 prerelease 的 Release
- **更新资产**: 发行版资产中名称匹配 `UTCMenuBar-*.zip` 的 zip 包(universal .app)
- **当前版本**: `CFBundleShortVersionString`,如 `1.1.0`;开发构建为 `0.0.0-dev`

## 需求 1：检查更新

**用户故事：** 作为用户，我希望应用能告诉我有没有新版本，而不用自己去 GitHub 看。

1. THE MenuBarApp SHALL 在右键菜单中提供"检查更新…"项（位于"时区转换…"之后、退出分隔线之前）
2. THE MenuBarApp SHALL 在设置窗口"关于"区提供"检查更新…"按钮
3. WHEN 用户触发检查, THE UpdateChecker SHALL 通过 HTTPS 请求 GitHub 最新发行版 API 并解析出版本号、更新资产下载地址与发行页地址
4. IF 最新版本号 > 当前版本号, THEN THE MenuBarApp SHALL 弹出提示，提供"立即更新"、"查看发行页"、"稍后"三个选项，以及"跳过此版本"勾选项
5. IF 最新版本号 <= 当前版本号 且为用户主动检查, THEN THE MenuBarApp SHALL 提示"已是最新版本"
6. IF 当前版本无法解析为 `major.minor.patch`（如 `0.0.0-dev` 开发构建）, THEN THE UpdateChecker SHALL 视为无可用更新（开发构建不参与升级）
7. IF 网络请求或解析失败, THEN THE MenuBarApp SHALL 仅在用户主动检查时弹出错误提示（含"打开发行页"按钮）；自动检查失败保持静默

## 需求 2：自动检查

**用户故事：** 作为用户，我希望不用记得手动检查也能获知新版本。

1. THE MenuBarApp SHALL 默认开启自动检查，并在设置窗口"通用"区提供"自动检查更新"开关（UserDefaults 键 `updates.autoCheck`）
2. WHEN 应用启动且开关开启且距上次检查 >= 24 小时, THE MenuBarApp SHALL 在启动数秒后静默发起检查（记录 `updates.lastCheckAt`）
3. IF 用户在提示中勾选"跳过此版本", THEN THE MenuBarApp SHALL 记录该 tag（`updates.skippedTag`），自动检查不再就同一 tag 提示；用户主动检查不受跳过影响

## 需求 3：下载与安装

**用户故事：** 作为用户，我点"立即更新"后应用应自己完成下载、替换、重启。

1. WHEN 用户选择"立即更新", THE UpdateController SHALL 显示下载进度窗口并经 HTTPS 下载更新资产
2. THE UpdateController SHALL 用 `ditto -x -k` 解压，并校验解出的 .app：bundle identifier 与当前一致，且 `CFBundleShortVersionString` 等于目标版本；校验失败视为更新失败
3. IF 当前 bundle 路径位于 App Translocation 只读挂载下，或其父目录不可写, THEN THE UpdateController SHALL 放弃替换并提示用户打开发行页手动下载
4. WHEN 校验通过, THE UpdateController SHALL 将当前 .app 移入废纸篓、把新 .app 移动到原路径、以新实例启动并退出当前实例
5. IF 下载、解压、校验或替换任一步失败, THEN THE UpdateController SHALL 弹出错误提示（含失败原因与"打开发行页"按钮），且不得让应用处于半替换状态（替换失败时原 bundle 仍在原路径或可从废纸篓恢复）

## 需求 4：本地化与发布配套

1. THE MenuBarApp SHALL 为上述所有用户可见文案提供中英双语（`Strings` 表）
2. THE ReleaseWorkflow SHALL 在发行说明中附带安装指引（macOS 15+ 的 Open Anyway 路径与 `xattr` 命令）与资产 SHA-256
3. THE README SHALL 更新首启指引（macOS 15 起右键打开不再绕过 Gatekeeper）并说明应用内更新
