# Release 签名

```bash
~/tools/scripts/generate-release-keystore.sh "/Users/zhaoyang.wzy/work/QuickLauncher"
~/tools/scripts/setup-github-secrets.sh --project-dir "/Users/zhaoyang.wzy/work/QuickLauncher" wzystal/QuickLauncher
~/tools/scripts/setup-shared-secrets.sh --repos wzystal/QuickLauncher
```

本地 `keystore.properties` 与 `*.jks` 已加入 `.gitignore`，勿提交。
