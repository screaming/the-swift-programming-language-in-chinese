import SwiftUI
import SwiftData

struct RollView: View {
    @Binding var selectedTab: RootView.Tab
    @Environment(RollViewModel.self) private var vm
    @Environment(\.modelContext) private var context

    @State private var showSavePreset = false
    @State private var presetName = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    resultCard
                    DiePickerView()
                    modifierControl
                    actionButtons
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("骰子大师")
            .onShake {
                guard RollSettings.current.shake else { return }
                triggerRoll()
            }
            .alert("保存为预设", isPresented: $showSavePreset) {
                TextField("名称（可留空）", text: $presetName)
                Button("取消", role: .cancel) {}
                Button("保存") { savePreset() }
            } message: {
                Text(vm.selection.summary)
            }
        }
    }

    // MARK: - 结果展示

    private var resultCard: some View {
        VStack(spacing: 12) {
            Text(displayTotal)
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.snappy, value: animationValue)
                .foregroundStyle(.tint)

            if let outcome = vm.lastOutcome, !vm.isRolling {
                Text(outcome.summary)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                DieResultView(rolls: outcome.rolls)
                if outcome.modifier != 0 {
                    Text("骰子 \(outcome.diceTotal) "
                         + (outcome.modifier > 0 ? "+ \(outcome.modifier)" : "− \(abs(outcome.modifier))"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else if vm.lastOutcome == nil && !vm.isRolling {
                Text("选择骰子后点击下方按钮，或摇一摇手机")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
    }

    private var displayTotal: String {
        if vm.isRolling { return "\(vm.animatedTotal)" }
        if let outcome = vm.lastOutcome { return "\(outcome.total)" }
        return "—"
    }

    /// 用于驱动数字动画的值。
    private var animationValue: Int {
        vm.isRolling ? vm.animatedTotal : (vm.lastOutcome?.total ?? 0)
    }

    // MARK: - 修正值

    private var modifierControl: some View {
        @Bindable var vm = vm
        return HStack {
            Label("修正值", systemImage: "plusminus")
            Spacer()
            Stepper(
                value: $vm.selection.modifier,
                in: DiceConfig.modifierRange
            ) {
                Text(vm.selection.modifier >= 0 ? "+\(vm.selection.modifier)" : "\(vm.selection.modifier)")
                    .font(.headline)
                    .monospacedDigit()
            }
            .fixedSize()
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 操作按钮

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: triggerRoll) {
                Label("掷骰", systemImage: "dice.fill")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(vm.selection.isEmpty || vm.isRolling)

            HStack(spacing: 12) {
                Button(role: .destructive) {
                    vm.clear()
                } label: {
                    Label("清空", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(vm.selection.isEmpty)

                Button {
                    presetName = ""
                    showSavePreset = true
                } label: {
                    Label("存为预设", systemImage: "star")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(vm.selection.isEmpty)
            }
        }
    }

    // MARK: - 动作

    private func triggerRoll() {
        Task { await vm.roll(context: context, settings: .current) }
    }

    private func savePreset() {
        let trimmed = presetName.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = trimmed.isEmpty ? vm.selection.summary : trimmed
        let nextIndex = (try? context.fetchCount(FetchDescriptor<DicePreset>())) ?? 0
        context.insert(DicePreset(name: title, selection: vm.selection, sortIndex: nextIndex))
    }
}
