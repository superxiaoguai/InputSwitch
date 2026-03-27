# ShiftSwitch for Mac

## 中文说明

ShiftSwitch 是一个 macOS 菜单栏小工具，可以通过单独轻按一次 `Shift`，在两个已保存的输入法之间切换，尽量还原很多多语言用户熟悉的 Windows 输入习惯。

### 系统要求

1. `macOS 14` 或更高版本
2. 支持 `Intel` 和 `Apple Silicon`
3. 首次使用需要授予 `输入监控` 权限
4. 如果你使用的是未签名版本，macOS 第一次打开时可能会要求你手动确认

### 功能说明

- 单独轻按一次 `Shift`，在两个已保存的输入法之间切换
- `Shift + 字母` 不会触发切换
- `Shift + 数字` 不会触发切换
- `Shift + 鼠标点击` 不会触发切换
- 关闭 macOS 自带的语言切换后，`Caps Lock` 仍保持正常的大写功能

### 安装步骤

#### 1. 把应用移动到 Applications

1. 解压你下载的应用
2. 将 `ShiftSwitch.app` 拖到 `/Applications`

如果直接从 Downloads 目录运行，可能会导致权限和开机启动相关问题。

#### 2. 首次打开应用

如果 macOS 第一次打开时拦截了应用，可以使用下面任一方式。

方式 A：在“隐私与安全性”中批准

1. 双击 `ShiftSwitch.app`
2. 如果 macOS 弹出警告，先关闭弹窗
3. 打开 `系统设置 > 隐私与安全性`
4. 向下滚动，找到被拦截的 `ShiftSwitch`
5. 点击 `仍要打开`
6. 如果系统再次询问，再确认一次

方式 B：通过右键菜单打开

1. 在 `/Applications` 中找到 `ShiftSwitch.app`
2. 右键点击应用并选择 `打开`
3. 确认弹窗

ShiftSwitch 是菜单栏应用。启动后，点击右上角菜单栏里的键盘图标即可打开控制面板。

#### 3. 授予输入监控权限

1. 打开 `ShiftSwitch`
2. 按照应用内按钮跳转，或者手动进入：
   `系统设置 > 隐私与安全性 > 输入监控`
3. 为 `ShiftSwitch` 打开权限
4. 完全退出应用
5. 重新打开应用

如果列表里还没有 `ShiftSwitch`，请先确认应用已经放进 `/Applications`，然后再次启动一次。

#### 4. 关闭系统自带的 Caps Lock 切换输入法功能

1. 打开 `系统设置 > 键盘`
2. 进入 `文本输入 > 编辑`
3. 关闭使用 `Caps Lock` 切换语言或输入法的选项

这样可以避免 macOS 自带切换逻辑和 ShiftSwitch 冲突。

#### 5. 保存两个输入法

1. 先切换到你想使用的第一个输入法
2. 在 `ShiftSwitch` 中点击 `将当前输入法保存为主输入法`
3. 再切换到第二个输入法
4. 点击 `将当前输入法保存为副输入法`

完成后，单独轻按一次 `Shift` 就会在这两个已保存输入法之间切换。

### 常见使用场景

- 英文 和 日文
- 英文 和 韩文
- 英文 和 拼音
- 英文 和 自定义键盘布局
- 任何一对可被 macOS 选择的输入法

### 隐私说明

ShiftSwitch 完全在本机运行。它申请输入监控权限，只是为了检测一次单独的 `Shift` 按键并触发输入法切换，不会上传你的按键内容，也不是为了记录输入内容而设计。

### 故障排查

#### 为什么应用打不开？

如果你使用的是未签名版本，macOS 可能会在第一次启动时拦截它。请打开 `系统设置 > 隐私与安全性` 并选择 `仍要打开`，或者通过右键菜单选择 `打开`。

#### 为什么按 Shift 没有反应？

最常见的原因是：

- 没有授予 `输入监控` 权限
- 还没有同时保存 `主输入法` 和 `副输入法`

#### 我已经给了权限，但还是不工作

建议按下面顺序重新操作：

1. 确认 `ShiftSwitch.app` 已经在 `/Applications`
2. 在 `输入监控` 中先关闭再重新开启 `ShiftSwitch`
3. 完全退出 `ShiftSwitch`
4. 重新打开 `ShiftSwitch`

#### 支持 Intel Mac 吗？

支持，同时兼容 `Intel` 和 `Apple Silicon`。

#### 支持哪些 macOS 版本？

当前最低支持版本：`macOS 14`。

---

## English

ShiftSwitch is a macOS menu bar utility that lets you switch between any two saved input sources with a single tap of `Shift`, similar to the Windows typing workflow many multilingual users are already used to.

### Requirements

1. `macOS 14` or later
2. `Intel` or `Apple Silicon`
3. `Input Monitoring` permission must be granted on first use
4. If you are using an unsigned build, macOS may ask you to approve the app manually the first time you open it

### What It Does

- Tap `Shift` by itself to switch between two saved input sources
- `Shift + letter` does not trigger a switch
- `Shift + number` does not trigger a switch
- `Shift + mouse click` does not trigger a switch
- `Caps Lock` keeps its normal capitalization behavior when the macOS language-switch shortcut is disabled

### Installation

#### 1. Move the app to Applications

1. Unzip the app bundle you downloaded
2. Drag `ShiftSwitch.app` into `/Applications`

Running the app from Downloads can cause permission and launch-at-login issues.

#### 2. Open the app for the first time

If macOS blocks the app on first launch, use one of these methods.

Method A: approve it in Privacy & Security

1. Double-click `ShiftSwitch.app`
2. If macOS shows a warning, close the dialog
3. Open `System Settings > Privacy & Security`
4. Scroll down until you find the blocked `ShiftSwitch` entry
5. Click `Open Anyway`
6. Confirm the next dialog if macOS asks again

Method B: open it from the context menu

1. Find `ShiftSwitch.app` in `/Applications`
2. Right-click the app and choose `Open`
3. Confirm the dialog

ShiftSwitch runs as a menu bar app. After launch, click the keyboard icon in the top-right menu bar to open its controls.

#### 3. Grant Input Monitoring

1. Open `ShiftSwitch`
2. Follow the in-app button, or open:
   `System Settings > Privacy & Security > Input Monitoring`
3. Enable `ShiftSwitch`
4. Quit the app completely
5. Open it again

If `ShiftSwitch` does not appear in the list yet, confirm that the app is already in `/Applications`, then launch it once more.

#### 4. Turn off the built-in Caps Lock language switcher

1. Open `System Settings > Keyboard`
2. Go to `Text Input > Edit`
3. Disable the option that uses `Caps Lock` to switch languages or input sources

This prevents macOS from conflicting with ShiftSwitch.

#### 5. Save your two input sources

1. Switch to the first input source you want to use
2. In `ShiftSwitch`, click `Save Current as Primary`
3. Switch to the second input source you want to use
4. Click `Save Current as Secondary`

After that, a single tap of `Shift` will switch between those two saved input sources.

### Typical Use Cases

- English and Japanese
- English and Korean
- English and Pinyin
- English and a custom keyboard layout
- Any other pair of selectable macOS input sources

### Privacy

ShiftSwitch works locally on your Mac. It uses Input Monitoring permission only to detect a standalone `Shift` key tap and trigger an input-source switch. It is not designed to upload your keystrokes or typing content.

### Troubleshooting

#### Why won't the app open?

If you are using an unsigned build, macOS may block it the first time. Open `System Settings > Privacy & Security` and choose `Open Anyway`, or right-click the app and open it from the context menu.

#### Why does tapping Shift do nothing?

The most common causes are:

- `Input Monitoring` permission has not been granted
- You have not saved both a `Primary` and `Secondary` input source yet

#### I already granted permission, but it still does not work

Try this order:

1. Confirm `ShiftSwitch.app` is in `/Applications`
2. Turn `ShiftSwitch` off and on again in `Input Monitoring`
3. Quit `ShiftSwitch`
4. Reopen `ShiftSwitch`

#### Does it work on Intel Macs?

Yes. It supports both `Intel` and `Apple Silicon`.

#### Which macOS versions are supported?

Current minimum version: `macOS 14`.
