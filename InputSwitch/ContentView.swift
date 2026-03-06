import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                setupSection
                statusSection
                mappingSection
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
            Text("Windows 风格输入切换")
                .font(.title3)
                .fontWeight(.semibold)

            Text("单独按下 Shift 切换中英文，Caps Lock 继续负责大小写。")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private var setupSection: some View {
        GroupBox("使用前请先完成这 4 项") {
            VStack(alignment: .leading, spacing: 14) {
                Text("先完成下面 4 项，再开始用 Shift 切换。")
                    .foregroundStyle(.secondary)

                setupStep(
                    number: 1,
                    title: "把 InputSwitch.app 放到 /Applications。",
                    detail: "否则权限和开机启动可能不稳定。"
                )

                setupStep(
                    number: 2,
                    title: "打开“输入监控”，勾选 InputSwitch，然后重开应用。",
                    detail: model.inputMonitoringGranted ? "当前状态：已授予。" : "当前状态：未授予。",
                    actionTitle: "打开输入监控",
                    action: {
                        model.openInputMonitoringSettings()
                    }
                )

                setupStep(
                    number: 3,
                    title: "关闭系统自带的 Caps Lock 切换输入法。",
                    detail: "打开后进“文本输入 > 编辑”，关闭“使用 Caps Lock 键切换输入法”。",
                    actionTitle: "打开键盘设置",
                    action: {
                        model.openKeyboardSettings()
                    }
                )

                setupStep(
                    number: 4,
                    title: "录入英文和中文输入法各一次。",
                    detail: "当前状态：英文\(model.englishSource == nil ? "未设置" : "已设置")，中文\(model.chineseSource == nil ? "未设置" : "已设置")。"
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var statusSection: some View {
        GroupBox("运行状态") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle("启用 Shift 单键切换", isOn: $model.isEnabled)

                LabeledContent("当前输入法", value: sourceLabel(for: model.currentSource))
                LabeledContent("英文输入法", value: sourceLabel(for: model.englishSource))
                LabeledContent("中文输入法", value: sourceLabel(for: model.chineseSource))

                Text(model.statusMessage)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var mappingSection: some View {
        GroupBox("录入输入法映射") {
            VStack(alignment: .leading, spacing: 12) {
                Text("先在系统菜单里切到目标输入法，再点下面按钮记录。")
                    .foregroundStyle(.secondary)

                HStack {
                    Button("把当前输入法记为英文") {
                        model.rememberCurrentAsEnglish()
                    }

                    Button("把当前输入法记为中文") {
                        model.rememberCurrentAsChinese()
                    }
                }

                HStack {
                    Button("刷新状态") {
                        model.refreshAll()
                    }

                    Button("测试切换") {
                        model.toggleInputSourceFromButton()
                    }
                    .disabled(model.englishSource == nil || model.chineseSource == nil)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var launchSection: some View {
        GroupBox("启动项") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle(
                    "开机自动启动",
                    isOn: Binding(
                        get: { model.launchAtLoginEnabled },
                        set: { model.setLaunchAtLoginEnabled($0) }
                    )
                )

                LabeledContent("当前状态", value: model.launchAtLoginStatusText)

                Button("刷新启动项状态") {
                    model.refreshLaunchAtLoginStatus()
                }

                Text("如果状态显示“当前 App 不符合登录项要求”，请确认应用已安装在 /Applications，并允许它作为登录项启动。")
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
                Button("退出") {
                    model.quit()
                }
        }
    }

    private func sourceLabel(for source: InputSourceInfo?) -> String {
        guard let source else {
            return "未设置"
        }

        return "\(source.displayName) (\(source.primaryLanguageDescription))"
    }

    @ViewBuilder
    private func setupStep(
        number: Int,
        title: String,
        detail: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
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
        }
    }
}
