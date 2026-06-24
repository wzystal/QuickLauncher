# Release 签名（本地）

脚本统一放在 `~/tools/scripts/`，不在各项目中重复维护。

```bash
~/tools/scripts/generate-release-keystore.sh "/Users/zhaoyang.wzy/work/launcher3-aosp"
~/tools/scripts/setup-github-secrets.sh --project-dir "/Users/zhaoyang.wzy/work/launcher3-aosp" wzystal/launcher3-aosp
~/tools/scripts/setup-shared-secrets.sh --repos wzystal/launcher3-aosp
```

CI 运行时从 `wzystal/android-ci-scripts` 拉取共享脚本（蒲公英上传、钉钉通知）。
