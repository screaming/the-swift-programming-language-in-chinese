import Foundation

/// 支持的骰子种类，`rawValue` 即骰子面数。
enum DieType: Int, CaseIterable, Codable, Identifiable, Comparable {
    case d4 = 4
    case d6 = 6
    case d8 = 8
    case d10 = 10
    case d12 = 12
    case d20 = 20
    case d100 = 100

    /// 面数（1...sides）。
    var sides: Int { rawValue }

    /// 展示用标签，例如 "D20"。
    var label: String { "D\(rawValue)" }

    var id: Int { rawValue }

    static func < (lhs: DieType, rhs: DieType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
