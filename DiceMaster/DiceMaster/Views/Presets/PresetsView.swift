import SwiftUI
import SwiftData

struct PresetsView: View {
    @Binding var selectedTab: RootView.Tab
    @Environment(RollViewModel.self) private var rollVM
    @Environment(\.modelContext) private var context
    @Query(sort: \DicePreset.sortIndex) private var presets: [DicePreset]

    var body: some View {
        NavigationStack {
            Group {
                if presets.isEmpty {
                    ContentUnavailableView(
                        "还没有预设",
                        systemImage: "star",
                        description: Text("在掷骰页选好骰子组合后，点击「存为预设」即可保存常用组合。")
                    )
                } else {
                    List {
                        ForEach(presets) { preset in
                            Button {
                                load(preset)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(preset.name).font(.headline)
                                    Text(preset.selection.summary)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .tint(.primary)
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("预设")
        }
    }

    private func load(_ preset: DicePreset) {
        rollVM.load(preset.selection)
        selectedTab = .roll
    }

    private func delete(_ offsets: IndexSet) {
        for index in offsets {
            context.delete(presets[index])
        }
    }
}
