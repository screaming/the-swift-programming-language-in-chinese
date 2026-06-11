import Foundation

/// 用户偏好的快照。读取自 `UserDefaults`，键与 `SettingsView` 的 `@AppStorage` 一致。
struct RollSettings {
    var haptics: Bool
    var sound: Bool
    var shake: Bool
    var animation: Bool
    var historyLimit: Int

    enum Keys {
        static let haptics = "settings.haptics"
        static let sound = "settings.sound"
        static let shake = "settings.shake"
        static let animation = "settings.animation"
        static let historyLimit = "settings.historyLimit"
    }

    static let defaultHistoryLimit = 200

    /// 读取当前偏好（未设置过的项使用默认值）。
    static var current: RollSettings {
        let defaults = UserDefaults.standard
        func bool(_ key: String) -> Bool {
            defaults.object(forKey: key) == nil ? true : defaults.bool(forKey: key)
        }
        let limit = defaults.object(forKey: Keys.historyLimit) == nil
            ? defaultHistoryLimit
            : defaults.integer(forKey: Keys.historyLimit)
        return RollSettings(
            haptics: bool(Keys.haptics),
            sound: bool(Keys.sound),
            shake: bool(Keys.shake),
            animation: bool(Keys.animation),
            historyLimit: limit
        )
    }
}
