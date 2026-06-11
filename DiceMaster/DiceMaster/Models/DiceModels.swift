import Foundation

/// 全局掷骰约束。
enum DiceConfig {
    /// 单次掷骰允许的骰子总数上限。
    static let maxTotalDice = 10
    /// 修正值允许范围。
    static let modifierRange = -20...20
}

/// 单颗骰子的掷出结果。
struct DieRoll: Identifiable, Codable, Hashable {
    var id = UUID()
    let type: DieType
    let value: Int
}

/// 用户当前选择的骰子组合（各骰种数量 + 修正值）。
struct DiceSelection: Codable, Equatable {
    var counts: [DieType: Int] = [:]
    var modifier: Int = 0

    /// 已选骰子总数。
    var totalDice: Int { counts.values.reduce(0, +) }

    var isEmpty: Bool { totalDice == 0 }

    /// 在不超过总数上限的前提下，是否还能再添加骰子。
    var canAddMore: Bool { totalDice < DiceConfig.maxTotalDice }

    func count(for type: DieType) -> Int { counts[type] ?? 0 }

    mutating func setCount(_ newValue: Int, for type: DieType) {
        if newValue <= 0 {
            counts[type] = nil
        } else {
            counts[type] = newValue
        }
    }

    /// 形如 "2D6 + 1D20 + 3" 的可读描述。
    var summary: String {
        let parts = DieType.allCases.compactMap { type -> String? in
            let n = count(for: type)
            return n > 0 ? "\(n)\(type.label)" : nil
        }
        var text = parts.joined(separator: " + ")
        if text.isEmpty { text = "—" }
        if modifier > 0 {
            text += " + \(modifier)"
        } else if modifier < 0 {
            text += " − \(abs(modifier))"
        }
        return text
    }
}

/// 一次完整掷骰的结果。
struct RollOutcome: Identifiable, Codable {
    var id = UUID()
    let rolls: [DieRoll]
    let modifier: Int
    let summary: String
    var timestamp = Date()

    /// 骰子点数之和（不含修正值）。
    var diceTotal: Int { rolls.reduce(0) { $0 + $1.value } }

    /// 最终总和（含修正值）。
    var total: Int { diceTotal + modifier }
}
