import AppKit
import ApplicationServices

final class GlobalShiftMonitor {
    enum StartResult {
        case started
        case missingInputMonitoringPermission
        case failedToCreateTap
    }

    private static let relevantModifierFlags: CGEventFlags = [
        .maskShift,
        .maskControl,
        .maskAlternate,
        .maskCommand,
        .maskAlphaShift,
        .maskHelp,
        .maskSecondaryFn
    ]

    private struct ShiftCandidate {
        let keyCode: UInt16
        let startedAt: TimeInterval
        var cancelled = false
    }

    private static let shiftKeyCodes: Set<UInt16> = [56, 60]
    private static let maxStandalonePressDuration: TimeInterval = 0.30

    private let onShiftOnly: () -> Void
    private var candidate: ShiftCandidate?
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    init(onShiftOnly: @escaping () -> Void) {
        self.onShiftOnly = onShiftOnly
    }

    func start() -> StartResult {
        guard eventTap == nil, runLoopSource == nil else { return .started }

        let mask = (
            (1 << CGEventType.flagsChanged.rawValue) |
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.leftMouseDown.rawValue) |
            (1 << CGEventType.rightMouseDown.rawValue) |
            (1 << CGEventType.otherMouseDown.rawValue) |
            (1 << CGEventType.scrollWheel.rawValue)
        )

        let callback: CGEventTapCallBack = { _, type, event, userInfo in
            guard let userInfo else {
                return Unmanaged.passUnretained(event)
            }

            let monitor = Unmanaged<GlobalShiftMonitor>.fromOpaque(userInfo).takeUnretainedValue()
            return monitor.handleEvent(type: type, event: event)
        }

        let userInfo = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: CGEventMask(mask),
            callback: callback,
            userInfo: userInfo
        ) else {
            if !CGPreflightListenEventAccess() {
                return .missingInputMonitoringPermission
            }

            return .failedToCreateTap
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        eventTap = tap
        runLoopSource = source
        return .started
    }

    func stop() {
        candidate = nil

        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
            runLoopSource = nil
        }

        if let tap = eventTap {
            CFMachPortInvalidate(tap)
            eventTap = nil
        }
    }

    private func handleEvent(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        switch type {
        case .tapDisabledByTimeout, .tapDisabledByUserInput:
            if let eventTap {
                CGEvent.tapEnable(tap: eventTap, enable: true)
            }
            return Unmanaged.passUnretained(event)

        case .flagsChanged:
            handleFlagsChanged(event)
            return Unmanaged.passUnretained(event)

        case .keyDown, .leftMouseDown, .rightMouseDown, .otherMouseDown, .scrollWheel:
            handleInterferingEvent(type: type, event: event)
            return Unmanaged.passUnretained(event)

        default:
            return Unmanaged.passUnretained(event)
        }
    }

    private func handleFlagsChanged(_ event: CGEvent) {
        let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))

        if Self.shiftKeyCodes.contains(keyCode) {
            handleShiftFlagsChanged(event, keyCode: keyCode)
            return
        }

        if candidate != nil {
            candidate?.cancelled = true
        }
    }

    private func handleShiftFlagsChanged(_ event: CGEvent, keyCode: UInt16) {
        let flags = event.flags.intersection(Self.relevantModifierFlags)
        let shiftPressed = flags.contains(.maskShift)

        if shiftPressed {
            if flags != CGEventFlags.maskShift {
                candidate?.cancelled = true
                return
            }

            if candidate == nil {
                candidate = ShiftCandidate(keyCode: keyCode, startedAt: ProcessInfo.processInfo.systemUptime)
            } else if candidate?.keyCode != keyCode {
                candidate?.cancelled = true
            }
            return
        }

        guard let candidate, candidate.keyCode == keyCode else {
            return
        }

        self.candidate = nil

        if candidate.cancelled {
            return
        }

        if ProcessInfo.processInfo.systemUptime - candidate.startedAt > Self.maxStandalonePressDuration {
            return
        }

        onShiftOnly()
    }

    private func handleInterferingEvent(type: CGEventType, event: CGEvent) {
        guard candidate != nil else { return }

        if type == .keyDown {
            let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
            if Self.shiftKeyCodes.contains(keyCode) {
                return
            }
        }

        candidate?.cancelled = true
    }
}
