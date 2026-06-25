# QuickLauncher

基于 AOSP Launcher3（Android 8.1）+ Pixel Nexus Launcher 改造的第三方桌面应用，以独立 APK 形式安装，提供完整的 Workspace / Hotseat / 文件夹 / Widget / 拖拽等桌面能力，不含 Quickstep 手势导航。核心技术是经典的 MVC 式 Launcher 架构：SQLite 持久化布局、LauncherModel 后台加载 + 主线程绑定 UI、自定义 View 体系处理拖拽与状态切换。

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
