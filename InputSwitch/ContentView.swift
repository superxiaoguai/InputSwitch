import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                if !model.onboardingCompleted {
                    onboardingSection
                }
                statusSection
                launchSection
                mappingSection
                permissionSection
                notesSection
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

    private var onboardingSection: some View {
        GroupBox("首次使用向导") {
            VStack(alignment: .leading, spacing: 14) {
                Text("第一次使用只要完成 3 步，后面就可以直接单按 Shift 切换中英文。")
                    .foregroundStyle(.secondary)

                onboardingStep(
                    title: "第 1 步：打开输入监控权限",
                    done: model.inputMonitoringGranted,
                    actionTitle: model.inputMonitoringGranted ? "已完成" : "去授权",
                    action: {
                        if !model.inputMonitoringGranted {
                            model.requestInputMonitoringPermission()
                        }
                    }
                )

                onboardingStep(
                    title: "第 2 步：切到英文输入法后录入",
                    done: model.englishSource != nil,
                    actionTitle: model.englishSource == nil ? "记为英文" : "已录入",
                    action: {
                        if model.englishSource == nil {
                            model.rememberCurrentAsEnglish()
                        }
                    }
                )

                onboardingStep(
                    title: "第 3 步：切到中文输入法后录入",
                    done: model.chineseSource != nil,
                    actionTitle: model.chineseSource == nil ? "记为中文" : "已录入",
                    action: {
                        if model.chineseSource == nil {
                            model.rememberCurrentAsChinese()
                        }
                    }
                )

                HStack {
                    Button("打开输入监控设置") {
                        model.openInputMonitoringSettings()
                    }

                    Spacer()

                    Button("稍后再说") {
                        model.dismissOnboarding()
                    }
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

    private var permissionSection: some View {
        GroupBox("权限与系统设置") {
            VStack(alignment: .leading, spacing: 12) {
                LabeledContent("输入监控权限", value: model.inputMonitoringGranted ? "已授予" : "未授予")

                Button("打开输入监控设置") {
                    model.openInputMonitoringSettings()
                }

                Text("如果 Shift 没有响应，通常是因为“输入监控”没有勾选本应用。")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("手动开启方式：系统设置 > 隐私与安全性 > 输入监控，然后打开 InputSwitch 的开关；如果列表里还没有本应用，先把应用放到 /Applications 后重新打开。")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var notesSection: some View {
        GroupBox("使用前说明") {
            VStack(alignment: .leading, spacing: 10) {
                Text("1. 在“系统设置 > 键盘 > 输入法”里关闭 macOS 自带的 Caps Lock 切换输入法选项。")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
    private func onboardingStep(title: String, done: Bool, actionTitle: String, action: @escaping () -> Void) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(done ? .green : .secondary)

            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(actionTitle, action: action)
                .disabled(done)
        }
    }
}
