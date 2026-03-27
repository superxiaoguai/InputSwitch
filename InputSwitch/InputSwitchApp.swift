//
//  InputSwitchApp.swift
//  InputSwitch
//
//  Created by wangyong on 2026/2/28.
//

import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}

@main
struct InputSwitchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppModel()

    var body: some Scene {
        MenuBarExtra("ShiftSwitch", systemImage: model.isEnabled ? "keyboard.fill" : "keyboard") {
            ContentView()
                .environmentObject(model)
                .environment(\.locale, model.locale)
        }
        .menuBarExtraStyle(.window)
    }
}
