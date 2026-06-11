import Foundation

/// 纯掷骰逻辑。随机数发生器可注入，便于编写确定性单元测试。
struct DiceRoller {
    private var rng: RandomNumberGenerator

    init(rng: RandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.rng = rng
    }

    /// 根据选择掷出所有骰子。注意：本方法不强制总数上限，上限是 UI 层的约束。
    mutating func roll(_ selection: DiceSelection) -> RollOutcome {
        var rolls: [DieRoll] = []
        for type in DieType.allCases {
            for _ in 0..<selection.count(for: type) {
                let value = Int.random(in: 1...type.sides, using: &rng)
                rolls.append(DieRoll(type: type, value: value))
            }
        }
        return RollOutcome(
            rolls: rolls,
            modifier: selection.modifier,
            summary: selection.summary
        )
    }
}
