# QuickLauncher

基于 [amirzaidi/Launcher3](https://github.com/amirzaidi/Launcher3) `o-mr1` 分支（Android 8.1 Oreo 时代 AOSP Launcher3 + Rootless 改造），**无 Quickstep**，可作为**独立 APK** 安装。应用显示名：**Quick Launcher**。

## 特性

| 能力 | 状态 |
|------|------|
| 真 Launcher3 UI（Workspace / Hotseat / 文件夹 / Widget / 拖拽） | ✅ |
| SQLite 布局持久化（`LauncherProvider`） | ✅ |
| 独立 APK，非系统应用 | ✅ |
| minSdk 23（Android 6.0+） | ✅ |
| Quickstep / 手势 Recents 一体 | ❌ 需系统 priv-app |
| 隐藏应用（HideFilterPipeline） | 阶段二 |

## 配置

| 项 | 值 |
|----|-----|
| 项目名 | `QuickLauncher` |
| 应用名 | `Quick Launcher` |
| `applicationId` | `com.wzystal.launcher` |
| 入口 Activity | `com.google.android.apps.nexuslauncher.NexusLauncherActivity` |
| 编译变体 | `aospDebug` / `aospRelease` |
| 版本 | `1.0.0` |

## 构建与安装

```bash
./build-and-install.sh
```

仅编译：

```bash
./gradlew assembleAospDebug
```

APK 路径：`build/outputs/apk/aosp/debug/QuickLauncher-aosp-debug.apk`

## 设默桌面

安装后：系统设置 → 应用 → 默认应用 → 桌面 → 选择 **Quick Launcher**。

## CI / Release（GitHub + 蒲公英 + 钉钉）

push 到 `main` 后自动：

1. `assembleAospRelease` 签名打包
2. 创建 GitHub Release 并附 APK
3. 上传蒲公英（可选）
4. 钉钉群 Markdown 通知

| Workflow | 触发 |
|----------|------|
| `pr-ci.yml` | PR / push main，编译 Debug |
| `release-notify.yml` | push main，Release + 通知 |

配置 Secrets（首次）：

```bash
~/tools/scripts/generate-release-keystore.sh "$(pwd)"
~/tools/scripts/setup-github-secrets.sh --project-dir "$(pwd)" wzystal/QuickLauncher
~/tools/scripts/setup-shared-secrets.sh --repos wzystal/QuickLauncher
```

CI 参数见 `ci/release.env`。

## 路径

`/Users/zhaoyang.wzy/work/QuickLauncher`
