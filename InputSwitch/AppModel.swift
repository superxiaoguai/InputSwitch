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
    @Published private(set) var primarySource: InputSourceInfo?
    @Published private(set) var secondarySource: InputSourceInfo?
    @Published private(set) var launchAtLoginEnabled = false
    @Published private(set) var launchAtLoginStatusText = "Not checked"
    @Published private(set) var onboardingCompleted = false
    @Published private(set) var statusMessage = "Save your current input source once as Primary and once as Secondary."

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
        primarySource = inputSourceController.storedPrimarySource()
        secondarySource = inputSourceController.storedSecondarySource()
        refreshOnboardingState()
    }

    func rememberCurrentAsPrimary() {
        guard let source = inputSourceController.rememberCurrentAsPrimary() else {
            statusMessage = "Unable to read the current input source."
            return
        }

        primarySource = source
        currentSource = source
        statusMessage = "Saved “\(source.displayName)” as the Primary input source."
        refreshOnboardingState()
    }

    func rememberCurrentAsSecondary() {
        guard let source = inputSourceController.rememberCurrentAsSecondary() else {
            statusMessage = "Unable to read the current input source."
            return
        }

        secondarySource = source
        currentSource = source
        statusMessage = "Saved “\(source.displayName)” as the Secondary input source."
        refreshOnboardingState()
    }

    func toggleInputSourceFromButton() {
        toggleInputSource(source: "Manual test")
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
            statusMessage = enabled ? "Launch at login has been requested." : "Launch at login has been turned off."
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
        guard primarySource != nil, secondarySource != nil else {
            refreshAll()
            statusMessage = "Setup is incomplete. Save one Primary input source and one Secondary input source first."
            return
        }

        if let switchedTo = inputSourceController.toggleBetweenSavedSources() {
            currentSource = switchedTo
            primarySource = inputSourceController.storedPrimarySource()
            secondarySource = inputSourceController.storedSecondarySource()
            statusMessage = "\(source) switched to “\(switchedTo.displayName)”."
        } else {
            refreshAll()
            statusMessage = "\(source) could not switch input sources. Check Input Monitoring permission and confirm both saved sources still exist."
        }
    }

    private func configureMonitor() {
        if isEnabled {
            switch shiftMonitor.start() {
            case .started:
                if statusMessage.contains("global listener") || statusMessage.contains("Input Monitoring") {
                    statusMessage = "Single-tap Shift switching is enabled."
                }
            case .missingInputMonitoringPermission:
                statusMessage = "The global listener did not start because Input Monitoring permission is missing."
            case .failedToCreateTap:
                statusMessage = "The global listener could not start because the event tap failed to initialize. Remove the old Input Monitoring permission, add it again, and relaunch the app."
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
            launchAtLoginStatusText = "Enabled"
        case .requiresApproval:
            launchAtLoginEnabled = false
            launchAtLoginStatusText = "Needs approval in System Settings"
        case .notRegistered:
            launchAtLoginEnabled = false
            launchAtLoginStatusText = "Disabled"
        case .notFound:
            launchAtLoginEnabled = false
            launchAtLoginStatusText = "This app is not eligible as a login item"
        @unknown default:
            launchAtLoginEnabled = false
            launchAtLoginStatusText = "Unknown"
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

    private func launchAtLoginFailureMessage(for error: Error) -> String {
        let nsError = error as NSError

        if isSMAppServiceError(nsError) {
            return "Launch at login failed: \(nsError.localizedDescription)"
        }

        return "Launch at login failed. Make sure the app is installed in /Applications and allowed to run as a login item."
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
