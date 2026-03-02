# InputSwitch

一个面向 Windows 转 Mac 用户的菜单栏工具。

核心行为：

- 单独按一次 `Shift` 切换中英文输入法
- `Caps Lock` 继续保留为 macOS 原生大小写
- `Shift + 字母`、`Shift + 1` 这类组合输入不会误触发切换

## 适用场景

适合这类用户：

- 长期使用 Windows，已经习惯 `Shift` 切换中英文
- 同时使用 Windows 和 macOS，希望两边输入习惯一致

## 系统要求

- macOS 15.0 或更高
- 需要开启“输入监控”权限

## 安装

1. 下载 `InputSwitch.app` 或发布包。
2. 将 `InputSwitch.app` 拖到 `/Applications`。
3. 启动应用后，点击菜单栏图标。
4. 按提示打开：
   - 系统设置 > 隐私与安全性 > 输入监控
5. 勾选 `InputSwitch`。
6. 完全退出应用，再重新打开。

## 首次使用

首次使用需要完成两项录入：

1. 切到英文输入法，点击“把当前输入法记为英文”
2. 切到中文输入法，点击“把当前输入法记为中文”

完成后即可单独按 `Shift` 在这两个输入法之间切换。

## 使用说明

- 只有“单独按下并释放 `Shift`”才会切换输入法
- `Shift + 字母`
- `Shift + 数字`
- `Shift + 鼠标点击`
- `Shift + 滚轮`

这些场景都不会触发误切换。

## 使用前说明

请先在：

- 系统设置 > 键盘 > 输入法

里关闭 macOS 自带的 `Caps Lock` 切换输入法选项。

## 开机自启

应用内提供“开机自动启动”开关。

如果状态显示异常，请确认：

- 应用已经放在 `/Applications`
- 系统允许它作为登录项运行

## 本地开发

工程使用 Xcode 构建。

本地调试：

```bash
xcodebuild \
  -project InputSwitch.xcodeproj \
  -scheme InputSwitch \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

构建 Release：

```bash
xcodebuild \
  -project InputSwitch.xcodeproj \
  -scheme InputSwitch \
  -configuration Release \
  -destination 'generic/platform=macOS' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## 说明

当前仓库主要面向本地开发和官网分发准备。

如果需要正式对外分发，建议后续补齐：

- Developer ID 签名
- Apple notarization
- 正式安装包
