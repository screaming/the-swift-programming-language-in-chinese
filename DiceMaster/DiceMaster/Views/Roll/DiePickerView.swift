import SwiftUI

struct DiePickerView: View {
    @Environment(RollViewModel.self) private var vm

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("选择骰子").font(.headline)
                Spacer()
                Text("\(vm.selection.totalDice)/\(DiceConfig.maxTotalDice)")
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(vm.selection.canAddMore ? .secondary : .orange)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(DieType.allCases) { type in
                    dieCell(type)
                }
            }
        }
    }

    private func dieCell(_ type: DieType) -> some View {
        let count = vm.selection.count(for: type)
        let isActive = count > 0
        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(type.label).font(.headline)
                Text("1–\(type.sides)").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            stepper(for: type, count: count)
        }
        .padding(12)
        .background(
            isActive ? AnyShapeStyle(.tint.opacity(0.12))
                     : AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
            in: RoundedRectangle(cornerRadius: 14)
        )
    }

    private func stepper(for type: DieType, count: Int) -> some View {
        HStack(spacing: 12) {
            Button {
                vm.decrement(type)
                if RollSettings.current.haptics { HapticManager.tick() }
            } label: {
                Image(systemName: "minus.circle.fill")
            }
            .disabled(count == 0)

            Text("\(count)")
                .font(.headline)
                .monospacedDigit()
                .frame(minWidth: 18)

            Button {
                vm.increment(type)
                if RollSettings.current.haptics { HapticManager.tick() }
            } label: {
                Image(systemName: "plus.circle.fill")
            }
            .disabled(!vm.selection.canAddMore)
        }
        .buttonStyle(.plain)
        .font(.title3)
        .foregroundStyle(.tint)
    }
}
