# 应用内更新 — 任务

- [x] 1. 库：`AppVersion` 解析与比较（需求 1.6；属性 P1、P2）
- [x] 2. 库：`UpdateInfo` + `UpdateChecker.parseLatestRelease`（需求 1.3；属性 P3）
- [x] 3. 库：`UpdateChecker.availableUpdate`（需求 1.4-1.6、2.3；属性 P4）
- [x] 4. 库：`UpdatePreferences` save/load + `shouldAutoCheck`（需求 2.1、2.2；属性 P5、P6）
- [x] 5. 测试：`UpdateCheckerTests`（含 GitHub JSON 夹具、版本比较属性测试、节流与持久化）注册进 TestRunner
- [x] 6. 字符串：新增更新相关中英文案（需求 4.1）
- [x] 7. 菜单："检查更新…"项 + MenuBuilder 参数 + MenuTests 结构断言更新（需求 1.1）
- [x] 8. 设置：通用区"自动检查更新"开关、关于区"检查更新…"按钮（需求 1.2、2.1）
- [x] 9. app：`UpdateController`（检查、提示、下载进度窗、解压校验、替换、重启；需求 1.3-1.7、3.1-3.5）
- [x] 10. app：启动后延迟自动检查 + lastCheckAt 记录（需求 2.2）
- [x] 11. 发布：release workflow 附安装指引与 SHA-256；README 更新 macOS 15+ 指引与应用内更新说明（需求 4.2、4.3）
