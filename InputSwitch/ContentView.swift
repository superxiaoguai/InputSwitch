import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                setupSection
                statusSection
                launchSection
                footerSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .frame(width: 420, height: 500)
        .onAppear {
            model.refreshAll()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Windows-Style Input Switching")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Tap Shift by itself to switch between any two saved input sources while Caps Lock keeps its normal job.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private var setupSection: some View {
        GroupBox("Before You Start") {
            VStack(alignment: .leading, spacing: 14) {
                Text("Complete these steps once before using single-tap Shift switching.")
                    .foregroundStyle(.secondary)

                setupStep(
                    number: 1,
                    title: "Move ShiftSwitch.app into /Applications.",
                    detail: "Permissions and launch-at-login are more reliable when the app is installed there."
                )

                setupStep(
                    number: 2,
                    title: "Enable Input Monitoring for ShiftSwitch, then relaunch the app.",
                    detail: model.inputMonitoringGranted ? "Current status: Granted." : "Current status: Not granted.",
                    actionTitle: "Open Input Monitoring",
                    action: {
                        model.openInputMonitoringSettings()
                    },
                    content: {
                        Text("Required only to detect a single Shift tap. No typing content is recorded.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.leading, 22)
                    }
                )

                setupStep(
                    number: 3,
                    title: "Turn off the built-in Caps Lock language switcher in macOS.",
                    detail: "Open Keyboard settings, then go to Text Input > Edit and disable the Caps Lock language-switch option.",
                    actionTitle: "Open Keyboard Settings",
                    action: {
                        model.openKeyboardSettings()
                    }
                )

                setupStep(
                    number: 4,
                    title: "Save one Primary input source and one Secondary input source.",
                    detail: "Current status: Primary \(model.primarySource == nil ? "not saved" : "saved"), Secondary \(model.secondarySource == nil ? "not saved" : "saved").",
                    content: {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Switch to the input source you want in the macOS menu bar, then save it below.")
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack {
                            Button("Save Current as Primary") {
                                model.rememberCurrentAsPrimary()
                            }

                            Button("Save Current as Secondary") {
                                model.rememberCurrentAsSecondary()
                            }
                        }

                        HStack {
                            Button("Refresh") {
                                model.refreshAll()
                            }

                            Button("Test Switch") {
                                model.toggleInputSourceFromButton()
                            }
                            .disabled(model.primarySource == nil || model.secondarySource == nil)
                        }
                    }
                    .padding(.leading, 22)
                    }
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var statusSection: some View {
        GroupBox("Status") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Enable single-tap Shift switching", isOn: $model.isEnabled)

                LabeledContent("Current input source", value: sourceLabel(for: model.currentSource))
                LabeledContent("Primary input source", value: sourceLabel(for: model.primarySource))
                LabeledContent("Secondary input source", value: sourceLabel(for: model.secondarySource))

                Text(model.statusMessage)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var launchSection: some View {
        GroupBox("Launch at Login") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle(
                    "Launch ShiftSwitch at login",
                    isOn: Binding(
                        get: { model.launchAtLoginEnabled },
                        set: { model.setLaunchAtLoginEnabled($0) }
                    )
                )

                LabeledContent("Current status", value: model.launchAtLoginStatusText)

                Button("Refresh launch status") {
                    model.refreshLaunchAtLoginStatus()
                }

                Text("If the app is reported as ineligible, make sure it is installed in /Applications and allowed to run as a login item.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear {
            model.refreshLaunchAtLoginStatus()
        }
    }

    private var footerSection: some View {
        HStack {
            Spacer()

            Button("Quit") {
                model.quit()
            }
        }
    }

    private func sourceLabel(for source: InputSourceInfo?) -> String {
        guard let source else {
            return "Not saved"
        }

        return "\(source.displayName) (\(source.languageDescription))"
    }

    @ViewBuilder
    private func setupStep(
        number: Int,
        title: String,
        detail: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> some View = { EmptyView() }
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 10) {
                Text("\(number).")
                    .fontWeight(.semibold)

                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text(detail)
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(.leading, 22)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .padding(.leading, 22)
            }

            content()
        }
    }
}
