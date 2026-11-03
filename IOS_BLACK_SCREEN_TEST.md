# iOS 黑屏对照构建

此分支以原版 2.1.6 的提交 `4ed5968f3` 为基线，生成两份可以自行重签的 IPA。

| 包 | 桌面名称 | 播放逻辑 |
| --- | --- | --- |
| baseline | PiliPlus Test A | 原版 2.1.6 |
| no-pip | PiliPlus Test B | 移除 iOS PiP 原生插件注册，包括它安装的视频纹理 hook |

B 是诊断用的对照版本，尚未证明可以修复黑屏。它不提供 iOS 系统画中画。
两个包使用相同版本的 Flutter、Dart 应用代码和依赖锁文件；A/B 应保持相同网络、账号、画质、编码和播放器设置。
两个包保留上游 Bundle ID；如需同时安装，应在自行签名时使用不同 Bundle ID。

推送此分支会触发 `iOS Black Screen Test`，使用 GitHub 的标准 `macos-26` runner。
新 fork 可能需要先在 Actions 页面启用工作流。两个任务相互独立，一个失败不会取消另一个。
流程沿用上游 Flutter 和依赖补丁脚本，使用 `flutter build ios --release --no-codesign`，
按标准 `Payload/Runner.app` 结构打包，校验 ZIP 结构并提供 SHA-256。
Framework 的临时 ad-hoc 签名用于兼容重签工具，不是可直接安装的苹果开发者签名。

成功后从运行结果下载 `iOS-2.1.6-baseline` 与 `iOS-2.1.6-no-pip`，解压 artifact 获取 IPA 后自行签名安装。
源码版本、解析后的依赖锁文件、工具链和构建日志保存在对应 diagnostics artifact 中。
此工作流只上传构建产物，不发布 Release，也不需要上传证书或密码。

## 真机测试

1. 在 A 中反复打开容易黑屏的视频，并从下方推荐进入其他视频，记录失败次数。
2. 在 B 中以相同设置重复相同操作；一次未复现不能证明修复。
3. 黑屏且声音仍播放时，可以使用播放器内置视频截图，检查能否取得当前视频的正常画面。
4. 如 B 仍然出现黑屏，继续检查播放器事件循环、视频取流和解码日志。

此分支在 Windows 上准备，iOS 编译结果必须以云端 macOS 任务及真机测试为准。
