# 骰子 App 规划文档（DiceRoller for iOS）

> 一个功能完整的 iOS 掷骰子 App：支持多种骰子、自定义组合、历史记录，并带有掷骰动画、震动反馈、音效与摇一摇掷骰。

---

## 1. 产品定位

| 项目 | 选择 |
|------|------|
| 平台 | iOS（iPhone 优先，iPad 兼容） |
| 功能范围 | 完整版：多骰种 + 自定义组合 + 历史记录 + 本地持久化 |
| UI 框架 | SwiftUI |
| 体验增强 | 掷骰动画、Haptic 震动反馈、音效、摇一摇掷骰 |
| 最低系统 | iOS 17.0（为使用 SwiftData 持久化；如需兼容 iOS 16 可改用 Core Data / Codable+UserDefaults） |
| 架构 | MVVM + 轻量 Service 层 |
| 语言 | Swift 5.9+ |

### 核心用户故事
1. 我可以选择骰子类型（D4/D6/D8/D10/D12/D20/D100）和数量，点击或摇晃手机掷骰，看到每颗骰子的点数与总和。
2. 我可以加一个修正值（modifier，如 `2d6+3`），结果自动计入总和。
3. 我可以把常用组合（如「2d6+3」「3d20」）保存为预设，下次一键掷出。
4. 我可以查看历史掷骰记录，并能删除单条或清空。
5. 掷骰时有翻滚动画、震动和音效，体验真实。

---

## 2. 功能清单

### 2.1 掷骰主界面（Roll）
- 骰种选择器：D4、D6、D8、D10、D12、D20、D100。
- 每种骰子的数量增减（stepper，0–20 颗，可设上限）。
- 修正值（modifier）输入：`-20 ~ +20`。
- 「掷骰」主按钮 + 摇一摇触发。
- 结果展示：每颗骰子的点数、分组小计、总和（含修正值）。
- 「再掷一次」与「清空选择」。
- 保存当前组合为预设的入口。

### 2.2 预设组合（Presets）
- 保存命名的骰子组合（骰种 + 数量 + 修正值）。
- 列表展示，一键快速掷骰。
- 编辑、删除、重命名、排序。

### 2.3 历史记录（History）
- 按时间倒序列出每次掷骰：组合描述、各骰点数、总和、时间戳。
- 点击查看详情。
- 左滑删除单条 / 一键清空。
- 持久化到本地（SwiftData）。

### 2.4 设置（Settings，轻量）
- 开关：震动反馈、音效、摇一摇掷骰、动画。
- 主题：跟随系统 / 浅色 / 深色。
- 历史记录保留上限（如最近 200 条）。

---

## 3. 技术架构

### 3.1 分层（MVVM + Services）
```
DiceRollerApp (入口 @main)
└── RootTabView (TabView：掷骰 / 预设 / 历史 / 设置)
    ├── Views（SwiftUI 视图，无业务逻辑）
    ├── ViewModels（@Observable，持有状态与意图处理）
    ├── Models（Die / DieType / RollResult / 持久化模型）
    └── Services（单一职责、可注入、可测试）
        ├── DiceRoller        // 纯随机数掷骰逻辑（可测）
        ├── HapticManager     // 震动反馈
        ├── SoundManager      // 音效播放
        ├── MotionManager     // 摇一摇检测
        └── SettingsStore     // 用户偏好（@AppStorage 封装）
```

### 3.2 数据模型
```swift
enum DieType: Int, CaseIterable, Codable, Identifiable {
    case d4 = 4, d6 = 6, d8 = 8, d10 = 10, d12 = 12, d20 = 20, d100 = 100
    var sides: Int { rawValue }
    var label: String { "D\(rawValue)" }
    var id: Int { rawValue }
}

// 一次掷骰中的单颗结果
struct DieRoll: Identifiable, Codable {
    let id: UUID
    let type: DieType
    let value: Int          // 1...sides
}

// 用户当前选择的骰子组合
struct DiceSelection: Codable {
    var counts: [DieType: Int]   // 各骰种数量
    var modifier: Int
}

// 一次掷骰的完整结果
struct RollOutcome: Identifiable, Codable {
    let id: UUID
    let rolls: [DieRoll]
    let modifier: Int
    var total: Int { rolls.map(\.value).reduce(0, +) + modifier }
    let timestamp: Date
    var summary: String          // 例如 "2d6+3"
}
```

### 3.3 持久化（SwiftData，iOS 17+）
```swift
@Model final class RollRecord {        // 历史记录
    var id: UUID
    var summary: String
    var detailJSON: Data            // 序列化 [DieRoll]
    var modifier: Int
    var total: Int
    var timestamp: Date
}

@Model final class DicePreset {        // 自定义预设
    var id: UUID
    var name: String
    var selectionJSON: Data         // 序列化 DiceSelection
    var sortIndex: Int
}
```
> 若需兼容 iOS 16，将 SwiftData 替换为 Core Data；预设/历史数量不大时也可用 `Codable + FileManager`。

### 3.4 掷骰逻辑（核心，可单测）
```swift
struct DiceRoller {
    var rng: RandomNumberGenerator = SystemRandomNumberGenerator()
    mutating func roll(_ selection: DiceSelection) -> RollOutcome {
        var rolls: [DieRoll] = []
        for type in DieType.allCases {
            let n = selection.counts[type] ?? 0
            for _ in 0..<n {
                let v = Int.random(in: 1...type.sides, using: &rng)
                rolls.append(DieRoll(id: UUID(), type: type, value: v))
            }
        }
        return RollOutcome(id: UUID(), rolls: rolls,
                           modifier: selection.modifier,
                           timestamp: .now,
                           summary: Self.makeSummary(selection))
    }
}
```
- 用 `SystemRandomNumberGenerator`（高质量随机）。
- 单测时注入可控的伪随机数发生器，验证范围与分布。

### 3.5 体验增强实现要点
| 功能 | 实现方式 |
|------|----------|
| 掷骰动画 | SwiftUI `.rotation3DEffect` + 数字快速滚动（Timer/`withAnimation`），落定后显示最终点数；可用 `matchedGeometryEffect` / `phaseAnimator`（iOS 17）。 |
| 震动反馈 | `UIImpactFeedbackGenerator`（轻量）或 `CoreHaptics` 自定义掷骰震动曲线。 |
| 音效 | `AVAudioPlayer` 播放骰子碰撞音效（短音频资源），遵守静音键与设置开关。 |
| 摇一摇 | `CoreMotion` 的 `CMMotionManager` 监听加速度峰值，或重写 `motionEnded(_:with:)` 检测 shake 手势。 |

---

## 4. 工程结构

```
DiceRoller/
├── DiceRoller.xcodeproj
├── DiceRoller/
│   ├── App/
│   │   └── DiceRollerApp.swift
│   ├── Models/
│   │   ├── DieType.swift
│   │   ├── DiceModels.swift          // DieRoll / DiceSelection / RollOutcome
│   │   └── Persistence.swift         // RollRecord / DicePreset (@Model)
│   ├── Services/
│   │   ├── DiceRoller.swift
│   │   ├── HapticManager.swift
│   │   ├── SoundManager.swift
│   │   ├── MotionManager.swift
│   │   └── SettingsStore.swift
│   ├── ViewModels/
│   │   ├── RollViewModel.swift
│   │   ├── PresetsViewModel.swift
│   │   └── HistoryViewModel.swift
│   ├── Views/
│   │   ├── RootTabView.swift
│   │   ├── Roll/  (RollView, DiePickerView, DieResultView, RollAnimationView)
│   │   ├── Presets/ (PresetsView, PresetEditView)
│   │   ├── History/ (HistoryView, HistoryDetailView)
│   │   └── Settings/ (SettingsView)
│   ├── Resources/
│   │   ├── Assets.xcassets            // 图标、颜色、骰面图
│   │   └── Sounds/dice_roll.caf
│   └── Info.plist
└── DiceRollerTests/
    ├── DiceRollerTests.swift          // 掷骰范围/总和/分布
    └── PersistenceTests.swift
```

---

## 5. 实施阶段（里程碑）

| 阶段 | 内容 | 产出 |
|------|------|------|
| **P0 项目搭建** | 新建 Xcode 工程、目录结构、基础 TabView 骨架 | 可运行空壳 |
| **P1 核心掷骰** | DieType / DiceRoller / 选择器 / 结果展示 / 修正值 | 能掷出单/多骰并求和 |
| **P2 持久化** | SwiftData 接入、历史记录、自定义预设 | 历史与预设可保存/读取 |
| **P3 体验增强** | 掷骰动画 → 震动 → 音效 → 摇一摇 | 完整交互体验 |
| **P4 设置与打磨** | 设置开关、深色模式、无障碍、空状态、App 图标 | 接近上架质量 |
| **P5 测试与收尾** | 单元测试、边界处理、性能、README | 可交付 |

---

## 6. 测试计划
- **单元测试**：掷骰结果恒在 `1...sides`；总和 = 各骰之和 + 修正值；注入固定 RNG 验证确定性；大量样本验证分布均匀；持久化往返（save→fetch）一致。
- **手动/UI**：摇一摇触发、音效随静音/设置开关、动画落定数值正确、历史删除与清空。

---

## 7. 本环境的重要约束 ⚠️

当前会话运行在 **Linux 远程容器**中，**无法运行 Xcode、iOS 模拟器或构建/真机调试**（这些只能在装有 Xcode 的 macOS 上进行）。因此在此环境中我可以完成：

- ✅ 编写全部 Swift 源代码（Models / Services / ViewModels / Views / Tests）。
- ✅ 生成 Xcode 工程文件结构（`.xcodeproj` / `Info.plist` / `Assets` 占位）。
- ✅ 提交并推送到规划分支。

但**编译、运行、模拟器预览、真机测试、音效/震动/摇一摇的实机验证**需要你在本地 macOS + Xcode 中完成。

---

## 8. 待你确认的几点（实现前）
1. **App 名称** 与 Bundle Identifier（如 `com.yourname.diceroller`）。
2. 是否接受 **iOS 17+**（用 SwiftData）；若必须支持更老系统再调整持久化方案。
3. 骰子数量上限（默认每种 20 颗）。
4. 是否需要 **App 图标设计**（我可给出占位，最终美术由你提供）。
5. 音效资源：使用占位音频，还是你提供素材？

确认后我将按 P0→P5 逐阶段编写代码并推送到 `claude/dice-roller-ios-planning-70ggrb` 分支。
