import Foundation
import SwiftData

/// 历史掷骰记录（持久化）。
@Model
final class RollRecord {
    var id: UUID
    var summary: String
    var total: Int
    var modifier: Int
    var timestamp: Date
    /// 序列化后的 `[DieRoll]`，用于详情展示。
    var detailData: Data

    init(outcome: RollOutcome) {
        self.id = outcome.id
        self.summary = outcome.summary
        self.total = outcome.total
        self.modifier = outcome.modifier
        self.timestamp = outcome.timestamp
        self.detailData = (try? JSONEncoder().encode(outcome.rolls)) ?? Data()
    }

    var rolls: [DieRoll] {
        (try? JSONDecoder().decode([DieRoll].self, from: detailData)) ?? []
    }
}

/// 用户保存的骰子组合预设（持久化）。
@Model
final class DicePreset {
    var id: UUID
    var name: String
    var sortIndex: Int
    /// 序列化后的 `DiceSelection`。
    var selectionData: Data

    init(name: String, selection: DiceSelection, sortIndex: Int) {
        self.id = UUID()
        self.name = name
        self.sortIndex = sortIndex
        self.selectionData = (try? JSONEncoder().encode(selection)) ?? Data()
    }

    var selection: DiceSelection {
        (try? JSONDecoder().decode(DiceSelection.self, from: selectionData)) ?? DiceSelection()
    }
}
