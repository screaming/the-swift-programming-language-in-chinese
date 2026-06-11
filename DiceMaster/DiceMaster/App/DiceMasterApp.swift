import SwiftUI
import SwiftData

@main
struct DiceMasterApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [RollRecord.self, DicePreset.self])
    }
}
