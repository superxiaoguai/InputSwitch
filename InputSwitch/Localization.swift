import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case simplifiedChinese = "zh-Hans"

    var id: String { rawValue }

    init(storedValue: String?) {
        self = Self(rawValue: storedValue ?? "") ?? .english
    }

    var localeIdentifier: String {
        rawValue
    }

    var pickerLabel: String {
        switch self {
        case .english:
            "English"
        case .simplifiedChinese:
            "中文"
        }
    }
}

enum LaunchAtLoginStatus {
    case notChecked
    case enabled
    case requiresApproval
    case disabled
    case notEligible
    case unknown
}

enum SwitchTrigger {
    case manualTest
    case shift
}

enum LaunchAtLoginFailureReason {
    case systemDescription(String)
    case installHint
}

enum StatusMessage {
    case savePrimaryAndSecondaryPrompt
    case unableToReadCurrentSource
    case savedPrimary(String)
    case savedSecondary(String)
    case launchAtLoginRequested
    case launchAtLoginTurnedOff
    case launchAtLoginFailed(LaunchAtLoginFailureReason)
    case setupIncomplete
    case switched(SwitchTrigger, String)
    case switchFailed(SwitchTrigger)
    case shiftEnabled
    case missingInputMonitoringPermission
    case eventTapInitializationFailed
}

struct AppStrings {
    let language: AppLanguage

    var languagePickerTitle: String {
        switch language {
        case .english:
            "Display Language"
        case .simplifiedChinese:
            "界面语言"
        }
    }

    var headerTitle: String {
        switch language {
        case .english:
            "Windows-Style Input Switching"
        case .simplifiedChinese:
            "Windows 风格输入法切换"
        }
    }

    var headerSubtitle: String {
        switch language {
        case .english:
            "Tap Shift by itself to switch between any two saved input sources while Caps Lock keeps its normal job."
        case .simplifiedChinese:
            "单独轻按一次 Shift，就能在两个已保存的输入法之间切换，同时保留 Caps Lock 原本的大写功能。"
        }
    }

    var beforeYouStartTitle: String {
        switch language {
        case .english:
            "Before You Start"
        case .simplifiedChinese:
            "开始之前"
        }
    }

    var beforeYouStartIntro: String {
        switch language {
        case .english:
            "Complete these steps once before using single-tap Shift switching."
        case .simplifiedChinese:
            "在使用单击 Shift 切换之前，请先完成下面这些步骤。"
        }
    }

    var moveAppTitle: String {
        switch language {
        case .english:
            "Move ShiftSwitch.app into /Applications."
        case .simplifiedChinese:
            "把 ShiftSwitch.app 移动到 /Applications。"
        }
    }

    var moveAppDetail: String {
        switch language {
        case .english:
            "Permissions and launch-at-login are more reliable when the app is installed there."
        case .simplifiedChinese:
            "应用安装在那里后，权限申请和开机启动通常会更稳定。"
        }
    }

    var enableInputMonitoringTitle: String {
        switch language {
        case .english:
            "Enable Input Monitoring for ShiftSwitch, then relaunch the app."
        case .simplifiedChinese:
            "给 ShiftSwitch 开启“输入监控”权限，然后重新打开应用。"
        }
    }

    func inputMonitoringStatus(granted: Bool) -> String {
        switch language {
        case .english:
            granted ? "Current status: Granted." : "Current status: Not granted."
        case .simplifiedChinese:
            granted ? "当前状态：已授权。" : "当前状态：未授权。"
        }
    }

    var openInputMonitoring: String {
        switch language {
        case .english:
            "Open Input Monitoring"
        case .simplifiedChinese:
            "打开输入监控设置"
        }
    }

    var inputMonitoringExplanation: String {
        switch language {
        case .english:
            "Required only to detect a single Shift tap. No typing content is recorded."
        case .simplifiedChinese:
            "这个权限只用于检测一次单独的 Shift 按键，不会记录你的输入内容。"
        }
    }

    var disableCapsLockSwitcherTitle: String {
        switch language {
        case .english:
            "Turn off the built-in Caps Lock language switcher in macOS."
        case .simplifiedChinese:
            "关闭 macOS 自带的 Caps Lock 切换输入法功能。"
        }
    }

    var disableCapsLockSwitcherDetail: String {
        switch language {
        case .english:
            "Open Keyboard settings, then go to Text Input > Edit and disable the Caps Lock language-switch option."
        case .simplifiedChinese:
            "打开键盘设置，然后进入“文本输入 > 编辑”，关闭使用 Caps Lock 切换语言或输入法的选项。"
        }
    }

    var openKeyboardSettings: String {
        switch language {
        case .english:
            "Open Keyboard Settings"
        case .simplifiedChinese:
            "打开键盘设置"
        }
    }

    var saveInputSourcesTitle: String {
        switch language {
        case .english:
            "Save one Primary input source and one Secondary input source."
        case .simplifiedChinese:
            "保存一个主输入法和一个副输入法。"
        }
    }

    func saveInputSourcesStatus(primarySaved: Bool, secondarySaved: Bool) -> String {
        switch language {
        case .english:
            "Current status: Primary \(savedWord(primarySaved)), Secondary \(savedWord(secondarySaved))."
        case .simplifiedChinese:
            "当前状态：主输入法\(savedWord(primarySaved))，副输入法\(savedWord(secondarySaved))。"
        }
    }

    var saveInputSourcesHint: String {
        switch language {
        case .english:
            "Switch to the input source you want in the macOS menu bar, then save it below."
        case .simplifiedChinese:
            "先在 macOS 菜单栏切换到你想要的输入法，然后在下面保存。"
        }
    }

    var saveCurrentAsPrimary: String {
        switch language {
        case .english:
            "Save Current as Primary"
        case .simplifiedChinese:
            "将当前输入法保存为主输入法"
        }
    }

    var saveCurrentAsSecondary: String {
        switch language {
        case .english:
            "Save Current as Secondary"
        case .simplifiedChinese:
            "将当前输入法保存为副输入法"
        }
    }

    var refresh: String {
        switch language {
        case .english:
            "Refresh"
        case .simplifiedChinese:
            "刷新"
        }
    }

    var testSwitch: String {
        switch language {
        case .english:
            "Test Switch"
        case .simplifiedChinese:
            "测试切换"
        }
    }

    var statusTitle: String {
        switch language {
        case .english:
            "Status"
        case .simplifiedChinese:
            "状态"
        }
    }

    var enableSingleTapShiftSwitching: String {
        switch language {
        case .english:
            "Enable single-tap Shift switching"
        case .simplifiedChinese:
            "启用单击 Shift 切换输入法"
        }
    }

    var currentInputSource: String {
        switch language {
        case .english:
            "Current input source"
        case .simplifiedChinese:
            "当前输入法"
        }
    }

    var primaryInputSource: String {
        switch language {
        case .english:
            "Primary input source"
        case .simplifiedChinese:
            "主输入法"
        }
    }

    var secondaryInputSource: String {
        switch language {
        case .english:
            "Secondary input source"
        case .simplifiedChinese:
            "副输入法"
        }
    }

    var launchAtLoginTitle: String {
        switch language {
        case .english:
            "Launch at Login"
        case .simplifiedChinese:
            "开机启动"
        }
    }

    var launchShiftSwitchAtLogin: String {
        switch language {
        case .english:
            "Launch ShiftSwitch at login"
        case .simplifiedChinese:
            "登录时启动 ShiftSwitch"
        }
    }

    var currentStatusLabel: String {
        switch language {
        case .english:
            "Current status"
        case .simplifiedChinese:
            "当前状态"
        }
    }

    var refreshLaunchStatus: String {
        switch language {
        case .english:
            "Refresh launch status"
        case .simplifiedChinese:
            "刷新启动状态"
        }
    }

    var launchAtLoginHint: String {
        switch language {
        case .english:
            "If the app is reported as ineligible, make sure it is installed in /Applications and allowed to run as a login item."
        case .simplifiedChinese:
            "如果应用显示为不可用于开机启动，请确认它已经安装到 /Applications，并且已被允许作为登录项运行。"
        }
    }

    var quit: String {
        switch language {
        case .english:
            "Quit"
        case .simplifiedChinese:
            "退出"
        }
    }

    var notSaved: String {
        switch language {
        case .english:
            "Not saved"
        case .simplifiedChinese:
            "未保存"
        }
    }

    var unknownLanguage: String {
        switch language {
        case .english:
            "Unknown"
        case .simplifiedChinese:
            "未知"
        }
    }

    func launchAtLoginStatus(_ status: LaunchAtLoginStatus) -> String {
        switch (language, status) {
        case (.english, .notChecked):
            "Not checked"
        case (.english, .enabled):
            "Enabled"
        case (.english, .requiresApproval):
            "Needs approval in System Settings"
        case (.english, .disabled):
            "Disabled"
        case (.english, .notEligible):
            "This app is not eligible as a login item"
        case (.english, .unknown):
            "Unknown"
        case (.simplifiedChinese, .notChecked):
            "未检查"
        case (.simplifiedChinese, .enabled):
            "已开启"
        case (.simplifiedChinese, .requiresApproval):
            "需要在系统设置中批准"
        case (.simplifiedChinese, .disabled):
            "已关闭"
        case (.simplifiedChinese, .notEligible):
            "当前应用不符合开机启动条件"
        case (.simplifiedChinese, .unknown):
            "未知"
        }
    }

    func statusMessage(_ message: StatusMessage) -> String {
        switch (language, message) {
        case (.english, .savePrimaryAndSecondaryPrompt):
            "Save your current input source once as Primary and once as Secondary."
        case (.english, .unableToReadCurrentSource):
            "Unable to read the current input source."
        case let (.english, .savedPrimary(name)):
            "Saved “\(name)” as the Primary input source."
        case let (.english, .savedSecondary(name)):
            "Saved “\(name)” as the Secondary input source."
        case (.english, .launchAtLoginRequested):
            "Launch at login has been requested."
        case (.english, .launchAtLoginTurnedOff):
            "Launch at login has been turned off."
        case let (.english, .launchAtLoginFailed(reason)):
            "Launch at login failed: \(launchAtLoginFailureReason(reason))"
        case (.english, .setupIncomplete):
            "Setup is incomplete. Save one Primary input source and one Secondary input source first."
        case let (.english, .switched(trigger, name)):
            "\(switchTriggerName(trigger)) switched to “\(name)”."
        case let (.english, .switchFailed(trigger)):
            "\(switchTriggerName(trigger)) could not switch input sources. Check Input Monitoring permission and confirm both saved sources still exist."
        case (.english, .shiftEnabled):
            "Single-tap Shift switching is enabled."
        case (.english, .missingInputMonitoringPermission):
            "The global listener did not start because Input Monitoring permission is missing."
        case (.english, .eventTapInitializationFailed):
            "The global listener could not start because the event tap failed to initialize. Remove the old Input Monitoring permission, add it again, and relaunch the app."
        case (.simplifiedChinese, .savePrimaryAndSecondaryPrompt):
            "请先把当前输入法分别保存为主输入法和副输入法。"
        case (.simplifiedChinese, .unableToReadCurrentSource):
            "无法读取当前输入法。"
        case let (.simplifiedChinese, .savedPrimary(name)):
            "已将“\(name)”保存为主输入法。"
        case let (.simplifiedChinese, .savedSecondary(name)):
            "已将“\(name)”保存为副输入法。"
        case (.simplifiedChinese, .launchAtLoginRequested):
            "已请求开启开机启动。"
        case (.simplifiedChinese, .launchAtLoginTurnedOff):
            "已关闭开机启动。"
        case let (.simplifiedChinese, .launchAtLoginFailed(reason)):
            "开机启动设置失败：\(launchAtLoginFailureReason(reason))"
        case (.simplifiedChinese, .setupIncomplete):
            "配置还没完成，请先保存一个主输入法和一个副输入法。"
        case let (.simplifiedChinese, .switched(trigger, name)):
            "\(switchTriggerName(trigger))已切换到“\(name)”。"
        case let (.simplifiedChinese, .switchFailed(trigger)):
            "\(switchTriggerName(trigger))无法切换输入法。请检查输入监控权限，并确认两个已保存的输入法仍然存在。"
        case (.simplifiedChinese, .shiftEnabled):
            "已启用单击 Shift 切换输入法。"
        case (.simplifiedChinese, .missingInputMonitoringPermission):
            "全局监听未启动，因为缺少输入监控权限。"
        case (.simplifiedChinese, .eventTapInitializationFailed):
            "全局监听启动失败，事件监听器初始化没有成功。请移除旧的输入监控授权，重新授权后再启动应用。"
        }
    }

    private func savedWord(_ saved: Bool) -> String {
        switch (language, saved) {
        case (.english, true):
            "saved"
        case (.english, false):
            "not saved"
        case (.simplifiedChinese, true):
            "已保存"
        case (.simplifiedChinese, false):
            "未保存"
        }
    }

    private func switchTriggerName(_ trigger: SwitchTrigger) -> String {
        switch (language, trigger) {
        case (.english, .manualTest):
            "Manual test"
        case (.english, .shift):
            "Shift"
        case (.simplifiedChinese, .manualTest):
            "手动测试"
        case (.simplifiedChinese, .shift):
            "Shift"
        }
    }

    private func launchAtLoginFailureReason(_ reason: LaunchAtLoginFailureReason) -> String {
        switch (language, reason) {
        case let (_, .systemDescription(description)):
            description
        case (.english, .installHint):
            "Make sure the app is installed in /Applications and allowed to run as a login item."
        case (.simplifiedChinese, .installHint):
            "请确认应用已经安装到 /Applications，并且已被允许作为登录项运行。"
        }
    }
}
