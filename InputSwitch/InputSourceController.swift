import Carbon
import Foundation

struct InputSourceInfo: Equatable {
    let id: String
    let localizedName: String
    let languages: [String]

    var displayName: String {
        localizedName.isEmpty ? id : localizedName
    }

    var languageDescription: String {
        languages.first ?? "Unknown"
    }
}

@MainActor
final class InputSourceController {
    private enum Keys {
        static let primarySourceID = "inputSource.primary"
        static let secondarySourceID = "inputSource.secondary"
        static let legacyEnglishSourceID = "inputSource.english"
        static let legacyChineseSourceID = "inputSource.chinese"
    }

    private let defaults = UserDefaults.standard

    func currentSource() -> InputSourceInfo? {
        guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else {
            return nil
        }

        return info(for: source)
    }

    func storedPrimarySource() -> InputSourceInfo? {
        guard let id = storedSourceID(forKey: Keys.primarySourceID, legacyKey: Keys.legacyEnglishSourceID) else {
            return nil
        }

        return source(withID: id)
    }

    func storedSecondarySource() -> InputSourceInfo? {
        guard let id = storedSourceID(forKey: Keys.secondarySourceID, legacyKey: Keys.legacyChineseSourceID) else {
            return nil
        }

        return source(withID: id)
    }

    func rememberCurrentAsPrimary() -> InputSourceInfo? {
        guard let source = currentSource() else {
            return nil
        }

        defaults.set(source.id, forKey: Keys.primarySourceID)
        return source
    }

    func rememberCurrentAsSecondary() -> InputSourceInfo? {
        guard let source = currentSource() else {
            return nil
        }

        defaults.set(source.id, forKey: Keys.secondarySourceID)
        return source
    }

    func toggleBetweenSavedSources() -> InputSourceInfo? {
        guard
            let primaryID = storedSourceID(forKey: Keys.primarySourceID, legacyKey: Keys.legacyEnglishSourceID),
            let secondaryID = storedSourceID(forKey: Keys.secondarySourceID, legacyKey: Keys.legacyChineseSourceID),
            let current = currentSource()
        else {
            return nil
        }

        let targetID = current.id == primaryID ? secondaryID : primaryID

        guard selectSource(withID: targetID) else {
            return nil
        }

        return source(withID: targetID) ?? currentSource()
    }

    private func storedSourceID(forKey key: String, legacyKey: String) -> String? {
        if let id = defaults.string(forKey: key) {
            return id
        }

        guard let legacyID = defaults.string(forKey: legacyKey) else {
            return nil
        }

        defaults.set(legacyID, forKey: key)
        return legacyID
    }

    private func source(withID id: String) -> InputSourceInfo? {
        availableSources().first { $0.id == id }
    }

    private func availableSources() -> [InputSourceInfo] {
        let sourceList = TISCreateInputSourceList(nil, false).takeRetainedValue() as NSArray

        return sourceList.compactMap { rawValue in
            let source = rawValue as! TISInputSource

            let info = info(for: source)
            guard let info, isSelectable(source) else {
                return nil
            }

            return info
        }
    }

    private func selectSource(withID id: String) -> Bool {
        guard let sourceList = TISCreateInputSourceList(
            [kTISPropertyInputSourceID as String: id] as CFDictionary,
            false
        )?.takeRetainedValue() as? [TISInputSource], let source = sourceList.first else {
            return false
        }

        return TISSelectInputSource(source) == noErr
    }

    private func isSelectable(_ source: TISInputSource) -> Bool {
        boolProperty(for: source, key: kTISPropertyInputSourceIsSelectCapable)
    }

    private func info(for source: TISInputSource) -> InputSourceInfo? {
        guard let id = stringProperty(for: source, key: kTISPropertyInputSourceID) else {
            return nil
        }

        return InputSourceInfo(
            id: id,
            localizedName: stringProperty(for: source, key: kTISPropertyLocalizedName) ?? id,
            languages: arrayProperty(for: source, key: kTISPropertyInputSourceLanguages)
        )
    }

    private func stringProperty(for source: TISInputSource, key: CFString) -> String? {
        guard let rawValue = TISGetInputSourceProperty(source, key) else {
            return nil
        }

        return Unmanaged<CFString>.fromOpaque(rawValue).takeUnretainedValue() as String
    }

    private func boolProperty(for source: TISInputSource, key: CFString) -> Bool {
        guard let rawValue = TISGetInputSourceProperty(source, key) else {
            return false
        }

        let value = Unmanaged<CFBoolean>.fromOpaque(rawValue).takeUnretainedValue()
        return CFBooleanGetValue(value)
    }

    private func arrayProperty(for source: TISInputSource, key: CFString) -> [String] {
        guard let rawValue = TISGetInputSourceProperty(source, key) else {
            return []
        }

        let value = Unmanaged<CFArray>.fromOpaque(rawValue).takeUnretainedValue() as NSArray
        return value.compactMap { $0 as? String }
    }
}
