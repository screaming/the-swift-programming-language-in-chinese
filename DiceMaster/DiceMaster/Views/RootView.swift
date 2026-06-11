import SwiftUI

struct RootView: View {
    /// 在各标签页之间共享的掷骰状态（让预设可以载入到掷骰页）。
    @State private var rollVM = RollViewModel()
    @State private var selectedTab: Tab = .roll

    enum Tab: Hashable {
        case roll, presets, history, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            RollView(selectedTab: $selectedTab)
                .tabItem { Label("掷骰", systemImage: "dice.fill") }
                .tag(Tab.roll)

            PresetsView(selectedTab: $selectedTab)
                .tabItem { Label("预设", systemImage: "star.fill") }
                .tag(Tab.presets)

            HistoryView()
                .tabItem { Label("历史", systemImage: "clock.fill") }
                .tag(Tab.history)

            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape.fill") }
                .tag(Tab.settings)
        }
        .environment(rollVM)
    }
}

#Preview {
    RootView()
        .modelContainer(for: [RollRecord.self, DicePreset.self], inMemory: true)
}
