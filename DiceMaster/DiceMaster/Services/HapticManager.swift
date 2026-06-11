import UIKit

/// 轻量震动反馈封装。
enum HapticManager {
    /// 掷骰落定时的较强反馈。
    static func roll() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    /// 加减骰子、动画跳动等轻微反馈。
    static func tick() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
