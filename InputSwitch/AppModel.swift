import AppKit
import ApplicationServices
import Combine
import ServiceManagement
import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: Self.enabledKey)
            configureMonitor()
        }
    }

    @Published private(set) var inputMonitoringGranted = false
    @Published private(set) var currentSource: InputSourceInfo?
    @Published private(set) var englishSource: InputSourceInfo?
    @Published private(set) var chineseSource: InputSourceInfo?
    @Published private(set) var launchAtLoginEnabled = false
    @Published private(set) var launchAtLoginStatusText = "未检查"
    @Published private(set) var onboardingCompleted = false
    @Published private(set) var statusMessage = "请先把当前英文输入法和中文输入法各记录一次。"

    private let inputSourceController = InputSourceController()
    private lazy var shiftMonitor = GlobalShiftMonitor { [weak self] in
        self?.toggleInputSourceFromShift()
    }

    private static let enabledKey = "feature.isEnabled"
    private static let onboardingCompletedKey = "ui.onboardingCompleted"

    init() {
        isEnabled = UserDefaults.standard.object(forKey: Self.enabledKey) as? Bool ?? true
        refreshAll()
        configureMonitor()
    }

    func refreshAll() {
        inputMonitoringGranted = CGPreflightListenEventAccess()
        currentSource = inputSourceController.currentSource()
        englishSource = inputSourceController.storedEnglishSource()
        chineseSource = inputSourceController.storedChineseSource()
        refreshOnboardingState()
    }

    func rememberCurrentAsEnglish() {
        guard let source = inputSourceController.rememberCurrentAsEnglish() else {
            statusMessage = "没有读取到当前输入法。"
            return
        }

        englishSource = source
        currentSource = source
        statusMessage = "已将“\(source.displayName)”记为英文输入法。"
        refreshOnboardingState()
    }

    func rememberCurrentAsChinese() {
        guard let source = inputSourceController.rememberCurrentAsChinese() else {
            statusMessage = "没有读取到当前输入法。"
            return
        }

        chineseSource = source
        currentSource = source
        statusMessage = "已将“\(source.displayName)”记为中文输入法。"
        refreshOnboardingState()
    }

    func toggleInputSourceFromButton() {
        toggleInputSource(source: "按钮测试")
    }

    func requestInputMonitoringPermission() {
        inputMonitoringGranted = CGRequestListenEventAccess()
    }

    func openInputMonitoringSettings() {
        openSystemSettingsPane("x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")
    }

    func setLaunchAtLoginEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }

            refreshLaunchAtLoginState()
            statusMessage = enabled ? "已请求开机自动启动。" : "已关闭开机自动启动。"
        } catch {
            refreshLaunchAtLoginState()
            statusMessage = launchAtLoginFailureMessage(for: error)
        }
    }

    func refreshLaunchAtLoginStatus() {
        refreshLaunchAtLoginState()
    }

    func dismissOnboarding() {
        onboardingCompleted = true
        UserDefaults.standard.set(true, forKey: Self.onboardingCompletedKey)
    }

    func quit() {
        NSApp.terminate(nil)
    }

    private func toggleInputSourceFromShift() {
        toggleInputSource(source: "Shift")
    }

    private func toggleInputSource(source: String) {
        guard englishSource != nil, chineseSource != nil else {
            refreshAll()
            statusMessage = "未完成配置：请先分别记录英文输入法和中文输入法。"
            return
        }

        if let switchedTo = inputSourceController.toggleBetweenStoredSources() {
            currentSource = switchedTo
            englishSource = inputSourceController.storedEnglishSource()
            chineseSource = inputSourceController.storedChineseSource()
            statusMessage = "\(source) 已切换到“\(switchedTo.displayName)”。"
        } else {
            refreshAll()
            statusMessage = "\(source) 切换失败。请检查输入监控权限，以及已保存的输入法是否仍然存在。"
        }
    }

    private func configureMonitor() {
        if isEnabled {
            switch shiftMonitor.start() {
            case .started:
                if statusMessage.contains("全局监听") || statusMessage.contains("输入监控") {
                    statusMessage = "Shift 单键切换已启用。"
                }
            case .missingInputMonitoringPermission:
                statusMessage = "全局监听未启动：缺少输入监控权限。请重新授予后再试。"
            case .failedToCreateTap:
                statusMessage = "全局监听未启动：事件 tap 创建失败。请删除旧的输入监控授权后重新添加，并完全重启应用。"
            }
        } else {
            shiftMonitor.stop()
        }
    }

    private func refreshLaunchAtLoginState() {
        let status = SMAppService.mainApp.status

        switch status {
        case .enabled:
            launchAtLoginEnabled = true
            launchAtLoginStatusText = "已启用"
        case .requiresApproval:
            launchAtLoginEnabled = false
            launchAtLoginStatusText = "需要在系统设置里批准"
        case .notRegistered:
            launchAtLoginEnabled = false
            launchAtLoginStatusText = "未启用"
        case .notFound:
            launchAtLoginEnabled = false
            launchAtLoginStatusText = "当前 App 不符合登录项要求"
        @unknown default:
            launchAtLoginEnabled = false
            launchAtLoginStatusText = "未知状态"
        }
    }

    private func refreshOnboardingState() {
        let completedBySetup = inputMonitoringGranted && englishSource != nil && chineseSource != nil
        let dismissed = UserDefaults.standard.bool(forKey: Self.onboardingCompletedKey)

        onboardingCompleted = completedBySetup || dismissed

        if completedBySetup && !dismissed {
            UserDefaults.standard.set(true, forKey: Self.onboardingCompletedKey)
            onboardingCompleted = true
        }
    }

    private func launchAtLoginFailureMessage(for error: Error) -> String {
        let nsError = error as NSError

        if nsError.domain == SMAppServiceErrorDomain {
            return "设置开机自启失败：\(nsError.localizedDescription)"
        }

        return "设置开机自启失败。请确认应用已安装到 /Applications，并且系统允许它作为登录项启动。"
    }

    private func openSystemSettingsPane(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }
}
