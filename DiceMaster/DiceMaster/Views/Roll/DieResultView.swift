import SwiftUI

/// 以小方块网格展示每颗骰子的点数；最大/最小值高亮。
struct DieResultView: View {
    let rolls: [DieRoll]

    private let columns = [GridItem(.adaptive(minimum: 56), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(rolls) { roll in
                VStack(spacing: 2) {
                    Text("\(roll.value)")
                        .font(.title3.bold())
                        .monospacedDigit()
                    Text(roll.type.label)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 56, height: 56)
                .background(background(for: roll), in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private func background(for roll: DieRoll) -> AnyShapeStyle {
        if roll.value == roll.type.sides {
            return AnyShapeStyle(.green.opacity(0.22))   // 最大值
        }
        if roll.value == 1 {
            return AnyShapeStyle(.red.opacity(0.16))     // 最小值
        }
        return AnyShapeStyle(Color(.tertiarySystemGroupedBackground))
    }
}
