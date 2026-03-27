import AppKit
import ApplicationServices
import Combine
import ServiceManagement
import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var appLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(appLanguage.rawValue, forKey: Self.appLanguageKey)
        }
    }

    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: Self.enabledKey)
            configureMonitor()
        }
    }

    @Published private(set) var inputMonitoringGranted = false
    @Published private(set) var currentSource: InputSourceInfo?
    @Published private(set) var primarySource: InputSourceInfo?
    @Published private(set) var secondarySource: InputSourceInfo?
    @Published private(set) var launchAtLoginEnabled = false
    @Published private(set) var launchAtLoginStatus: LaunchAtLoginStatus = .notChecked
    @Published private(set) var onboardingCompleted = false
    @Published private(set) var statusMessageState: StatusMessage = .savePrimaryAndSecondaryPrompt

    private let inputSourceController = InputSourceController()
    private lazy var shiftMonitor = GlobalShiftMonitor { [weak self] in
        self?.toggleInputSourceFromShift()
    }

    private static let appLanguageKey = "ui.appLanguage"
    private static let enabledKey = "feature.isEnabled"
    private static let onboardingCompletedKey = "ui.onboardingCompleted"

    init() {
        appLanguage = AppLanguage(storedValue: UserDefaults.standard.string(forKey: Self.appLanguageKey))
        isEnabled = UserDefaults.standard.object(forKey: Self.enabledKey) as? Bool ?? true
        refreshAll()
        configureMonitor()
    }

    var strings: AppStrings {
        AppStrings(language: appLanguage)
    }

    var locale: Locale {
        Locale(identifier: appLanguage.localeIdentifier)
    }

    var launchAtLoginStatusText: String {
        strings.launchAtLoginStatus(launchAtLoginStatus)
    }

    var statusMessage: String {
        strings.statusMessage(statusMessageState)
    }

    func refreshAll() {
        inputMonitoringGranted = CGPreflightListenEventAccess()
        currentSource = inputSourceController.currentSource()
        primarySource = inputSourceController.storedPrimarySource()
        secondarySource = inputSourceController.storedSecondarySource()
        refreshOnboardingState()
    }

    func rememberCurrentAsPrimary() {
        guard let source = inputSourceController.rememberCurrentAsPrimary() else {
            statusMessageState = .unableToReadCurrentSource
            return
        }

        primarySource = source
        currentSource = source
        statusMessageState = .savedPrimary(source.displayName)
        refreshOnboardingState()
    }

    func rememberCurrentAsSecondary() {
        guard let source = inputSourceController.rememberCurrentAsSecondary() else {
            statusMessageState = .unableToReadCurrentSource
            return
        }

        secondarySource = source
        currentSource = source
        statusMessageState = .savedSecondary(source.displayName)
        refreshOnboardingState()
    }

    func toggleInputSourceFromButton() {
        toggleInputSource(trigger: .manualTest)
    }

    func requestInputMonitoringPermission() {
        inputMonitoringGranted = CGRequestListenEventAccess()
    }

    func openInputMonitoringSettings() {
        openSystemSettingsPane("x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")
    }

    func openKeyboardSettings() {
        openSystemSettingsPane("x-apple.systempreferences:com.apple.Keyboard-Settings.extension")
    }

    func setLaunchAtLoginEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }

            refreshLaunchAtLoginState()
            statusMessageState = enabled ? .launchAtLoginRequested : .launchAtLoginTurnedOff
        } catch {
            refreshLaunchAtLoginState()
            statusMessageState = launchAtLoginFailureMessage(for: error)
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
        toggleInputSource(trigger: .shift)
    }

    private func toggleInputSource(trigger: SwitchTrigger) {
        guard primarySource != nil, secondarySource != nil else {
            refreshAll()
            statusMessageState = .setupIncomplete
            return
        }

        if let switchedTo = inputSourceController.toggleBetweenSavedSources() {
            currentSource = switchedTo
            primarySource = inputSourceController.storedPrimarySource()
            secondarySource = inputSourceController.storedSecondarySource()
            statusMessageState = .switched(trigger, switchedTo.displayName)
        } else {
            refreshAll()
            statusMessageState = .switchFailed(trigger)
        }
    }

    private func configureMonitor() {
        if isEnabled {
            switch shiftMonitor.start() {
            case .started:
                switch statusMessageState {
                case .missingInputMonitoringPermission, .eventTapInitializationFailed:
                    statusMessageState = .shiftEnabled
                default:
                    break
                }
            case .missingInputMonitoringPermission:
                statusMessageState = .missingInputMonitoringPermission
            case .failedToCreateTap:
                statusMessageState = .eventTapInitializationFailed
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
            launchAtLoginStatus = .enabled
        case .requiresApproval:
            launchAtLoginEnabled = false
            launchAtLoginStatus = .requiresApproval
        case .notRegistered:
            launchAtLoginEnabled = false
            launchAtLoginStatus = .disabled
        case .notFound:
            launchAtLoginEnabled = false
            launchAtLoginStatus = .notEligible
        @unknown default:
            launchAtLoginEnabled = false
            launchAtLoginStatus = .unknown
        }
    }

    private func refreshOnboardingState() {
        let completedBySetup = inputMonitoringGranted && primarySource != nil && secondarySource != nil
        let dismissed = UserDefaults.standard.bool(forKey: Self.onboardingCompletedKey)

        onboardingCompleted = completedBySetup || dismissed

        if completedBySetup && !dismissed {
            UserDefaults.standard.set(true, forKey: Self.onboardingCompletedKey)
            onboardingCompleted = true
        }
    }

    private func launchAtLoginFailureMessage(for error: Error) -> StatusMessage {
        let nsError = error as NSError

        if isSMAppServiceError(nsError) {
            return .launchAtLoginFailed(.systemDescription(nsError.localizedDescription))
        }

        return .launchAtLoginFailed(.installHint)
    }

    private func isSMAppServiceError(_ error: NSError) -> Bool {
        if #available(macOS 15.0, *) {
            return error.domain == SMAppServiceErrorDomain
        }

        return error.domain == "SMAppServiceErrorDomain"
    }

    private func openSystemSettingsPane(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }
}
