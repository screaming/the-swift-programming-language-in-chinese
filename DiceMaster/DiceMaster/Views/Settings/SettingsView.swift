import SwiftUI

struct SettingsView: View {
    @AppStorage(RollSettings.Keys.haptics) private var haptics = true
    @AppStorage(RollSettings.Keys.sound) private var sound = true
    @AppStorage(RollSettings.Keys.shake) private var shake = true
    @AppStorage(RollSettings.Keys.animation) private var animation = true
    @AppStorage(RollSettings.Keys.historyLimit) private var historyLimit = RollSettings.defaultHistoryLimit

    var body: some View {
        NavigationStack {
            Form {
                Section("掷骰体验") {
                    Toggle("震动反馈", isOn: $haptics)
                    Toggle("音效", isOn: $sound)
                    Toggle("摇一摇掷骰", isOn: $shake)
                    Toggle("掷骰动画", isOn: $animation)
                }

                Section("历史记录") {
                    Picker("保留条数", selection: $historyLimit) {
                        ForEach([50, 100, 200, 500], id: \.self) { count in
                            Text("\(count)").tag(count)
                        }
                    }
                }

                Section {
                    LabeledContent("版本", value: "1.0")
                } header: {
                    Text("关于")
                } footer: {
                    Text("骰子大师 · 支持 D4–D100，单次最多 \(DiceConfig.maxTotalDice) 颗骰子。")
                }
            }
            .navigationTitle("设置")
        }
    }
}
