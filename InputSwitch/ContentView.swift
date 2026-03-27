import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: AppModel

    private var strings: AppStrings {
        model.strings
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                languageSection
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

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(strings.languagePickerTitle)
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker("", selection: $model.appLanguage) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.pickerLabel).tag(language)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(strings.headerTitle)
                .font(.title3)
                .fontWeight(.semibold)

            Text(strings.headerSubtitle)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private var setupSection: some View {
        GroupBox(strings.beforeYouStartTitle) {
            VStack(alignment: .leading, spacing: 14) {
                Text(strings.beforeYouStartIntro)
                    .foregroundStyle(.secondary)

                setupStep(
                    number: 1,
                    title: strings.moveAppTitle,
                    detail: strings.moveAppDetail
                )

                setupStep(
                    number: 2,
                    title: strings.enableInputMonitoringTitle,
                    detail: strings.inputMonitoringStatus(granted: model.inputMonitoringGranted),
                    actionTitle: strings.openInputMonitoring,
                    action: {
                        model.openInputMonitoringSettings()
                    },
                    content: {
                        Text(strings.inputMonitoringExplanation)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.leading, 22)
                    }
                )

                setupStep(
                    number: 3,
                    title: strings.disableCapsLockSwitcherTitle,
                    detail: strings.disableCapsLockSwitcherDetail,
                    actionTitle: strings.openKeyboardSettings,
                    action: {
                        model.openKeyboardSettings()
                    }
                )

                setupStep(
                    number: 4,
                    title: strings.saveInputSourcesTitle,
                    detail: strings.saveInputSourcesStatus(
                        primarySaved: model.primarySource != nil,
                        secondarySaved: model.secondarySource != nil
                    ),
                    content: {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(strings.saveInputSourcesHint)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack {
                                Button(strings.saveCurrentAsPrimary) {
                                    model.rememberCurrentAsPrimary()
                                }

                                Button(strings.saveCurrentAsSecondary) {
                                    model.rememberCurrentAsSecondary()
                                }
                            }

                            HStack {
                                Button(strings.refresh) {
                                    model.refreshAll()
                                }

                                Button(strings.testSwitch) {
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
        GroupBox(strings.statusTitle) {
            VStack(alignment: .leading, spacing: 12) {
                Toggle(strings.enableSingleTapShiftSwitching, isOn: $model.isEnabled)

                LabeledContent(strings.currentInputSource, value: sourceLabel(for: model.currentSource))
                LabeledContent(strings.primaryInputSource, value: sourceLabel(for: model.primarySource))
                LabeledContent(strings.secondaryInputSource, value: sourceLabel(for: model.secondarySource))

                Text(model.statusMessage)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var launchSection: some View {
        GroupBox(strings.launchAtLoginTitle) {
            VStack(alignment: .leading, spacing: 12) {
                Toggle(
                    strings.launchShiftSwitchAtLogin,
                    isOn: Binding(
                        get: { model.launchAtLoginEnabled },
                        set: { model.setLaunchAtLoginEnabled($0) }
                    )
                )

                LabeledContent(strings.currentStatusLabel, value: model.launchAtLoginStatusText)

                Button(strings.refreshLaunchStatus) {
                    model.refreshLaunchAtLoginStatus()
                }

                Text(strings.launchAtLoginHint)
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

            Button(strings.quit) {
                model.quit()
            }
        }
    }

    private func sourceLabel(for source: InputSourceInfo?) -> String {
        guard let source else {
            return strings.notSaved
        }

        let languageName = localizedLanguageName(for: source)

        guard !languageName.isEmpty else {
            return source.displayName
        }

        return "\(source.displayName) (\(languageName))"
    }

    private func localizedLanguageName(for source: InputSourceInfo) -> String {
        guard let identifier = source.languages.first else {
            return strings.unknownLanguage
        }

        return model.locale.localizedString(forIdentifier: identifier) ?? identifier
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
