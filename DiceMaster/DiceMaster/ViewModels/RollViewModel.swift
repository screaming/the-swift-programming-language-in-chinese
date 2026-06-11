import Foundation
import SwiftData

/// 掷骰主界面的状态与逻辑。
@MainActor
@Observable
final class RollViewModel {
    /// 当前选择的骰子组合。
    var selection = DiceSelection()
    /// 最近一次掷骰结果。
    var lastOutcome: RollOutcome?
    /// 是否正在播放掷骰动画。
    var isRolling = false
    /// 动画期间显示的临时跳动数字。
    var animatedTotal = 0

    // MARK: - 选择编辑

    func increment(_ type: DieType) {
        guard selection.canAddMore else { return }
        selection.setCount(selection.count(for: type) + 1, for: type)
    }

    func decrement(_ type: DieType) {
        selection.setCount(selection.count(for: type) - 1, for: type)
    }

    func clear() {
        selection = DiceSelection()
        lastOutcome = nil
    }

    func load(_ selection: DiceSelection) {
        self.selection = selection
    }

    // MARK: - 掷骰

    /// 执行掷骰：计算结果、触发反馈与动画，并写入历史记录。
    func roll(context: ModelContext, settings: RollSettings) async {
        guard !selection.isEmpty, !isRolling else { return }

        var roller = DiceRoller()
        let outcome = roller.roll(selection)

        if settings.haptics { HapticManager.roll() }
        if settings.sound { SoundManager.shared.playRoll() }

        if settings.animation {
            isRolling = true
            let lowerBound = max(1, outcome.rolls.count)
            let upperBound = max(lowerBound, outcome.total)
            for step in 0..<12 {
                animatedTotal = Int.random(in: lowerBound...upperBound)
                if settings.haptics, step.isMultiple(of: 3) { HapticManager.tick() }
                try? await Task.sleep(for: .milliseconds(40 + step * 12))
            }
            isRolling = false
        }

        lastOutcome = outcome
        HistoryService.record(outcome, in: context, limit: settings.historyLimit)
    }
}
