import XCTest
@testable import DiceMaster

/// 可复现的伪随机数发生器，用于确定性测试。
private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

final class DiceRollerTests: XCTestCase {

    func testRollCountMatchesSelection() {
        var selection = DiceSelection()
        selection.setCount(2, for: .d6)
        selection.setCount(1, for: .d20)

        var roller = DiceRoller(rng: SeededGenerator(seed: 42))
        let outcome = roller.roll(selection)

        XCTAssertEqual(outcome.rolls.count, 3)
        XCTAssertEqual(outcome.rolls.filter { $0.type == .d6 }.count, 2)
        XCTAssertEqual(outcome.rolls.filter { $0.type == .d20 }.count, 1)
    }

    func testValuesWithinRange() {
        var selection = DiceSelection()
        for type in DieType.allCases {
            selection.setCount(3, for: type)
        }

        var roller = DiceRoller(rng: SeededGenerator(seed: 7))
        let outcome = roller.roll(selection)

        for roll in outcome.rolls {
            XCTAssertGreaterThanOrEqual(roll.value, 1)
            XCTAssertLessThanOrEqual(roll.value, roll.type.sides)
        }
    }

    func testTotalIncludesModifier() {
        var selection = DiceSelection()
        selection.setCount(3, for: .d6)
        selection.modifier = 5

        var roller = DiceRoller(rng: SeededGenerator(seed: 1))
        let outcome = roller.roll(selection)

        XCTAssertEqual(outcome.total, outcome.diceTotal + 5)
    }

    func testDeterministicWithSameSeed() {
        var selection = DiceSelection()
        selection.setCount(5, for: .d20)

        var a = DiceRoller(rng: SeededGenerator(seed: 99))
        var b = DiceRoller(rng: SeededGenerator(seed: 99))

        XCTAssertEqual(a.roll(selection).rolls.map(\.value),
                       b.roll(selection).rolls.map(\.value))
    }

    func testSelectionCapHelper() {
        var selection = DiceSelection()
        selection.setCount(DiceConfig.maxTotalDice, for: .d6)
        XCTAssertFalse(selection.canAddMore)
        XCTAssertEqual(selection.totalDice, DiceConfig.maxTotalDice)

        selection.setCount(DiceConfig.maxTotalDice - 1, for: .d6)
        XCTAssertTrue(selection.canAddMore)
    }

    func testSummaryFormat() {
        var selection = DiceSelection()
        selection.setCount(2, for: .d6)
        selection.modifier = 3
        XCTAssertEqual(selection.summary, "2D6 + 3")
    }

    func testSelectionCodableRoundTrip() throws {
        var selection = DiceSelection()
        selection.setCount(2, for: .d6)
        selection.setCount(1, for: .d20)
        selection.modifier = -2

        let data = try JSONEncoder().encode(selection)
        let decoded = try JSONDecoder().decode(DiceSelection.self, from: data)

        XCTAssertEqual(decoded, selection)
    }
}
