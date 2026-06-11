# 骰子大师 DiceMaster

一个功能完整的 iOS 掷骰子 App，使用 **SwiftUI + SwiftData** 构建。

## 功能
- 🎲 多种骰子：D4 / D6 / D8 / D10 / D12 / D20 / D100，单次最多 **10** 颗
- ➕ 修正值（modifier）：`-20 ~ +20`，例如 `2D6 + 3`
- ⭐ 自定义预设：保存常用组合，一键载入掷骰
- 📜 历史记录：自动保存、查看详情、删除/清空（SwiftData 本地持久化）
- ✨ 体验增强：掷骰数字跳动动画、震动反馈、音效、**摇一摇掷骰**
- ⚙️ 设置：各项体验开关、历史保留条数

## 运行要求
- **Xcode 16+**（工程使用文件系统同步分组，objectVersion 77）
- **iOS 17.0+**（使用 SwiftData 与 Observation 框架）

## 如何打开
```bash
open DiceMaster.xcodeproj
```
选择 iPhone 模拟器或真机，直接 ⌘R 运行；⌘U 运行单元测试。

> 注意：摇一摇、震动、音效需在**真机**上体验；模拟器可用 `Device > Shake` 模拟摇晃。

## 工程结构
```
DiceMaster/
├── App/            应用入口与 ModelContainer
├── Models/         DieType / DiceSelection / RollOutcome / SwiftData 模型
├── Services/       掷骰逻辑、震动、音效、设置、历史服务
├── ViewModels/     RollViewModel
├── Views/          掷骰 / 预设 / 历史 / 设置 各界面
└── Resources/      占位音效（dice_roll.wav，可自行替换）
```

## 测试
`DiceMasterTests` 覆盖掷骰核心逻辑：点数范围、数量、修正值求和、
确定性（注入种子随机数）、数量上限与序列化往返。

## 占位资源
- **App 图标**：`Assets.xcassets/AppIcon.appiconset/icon-1024.png`（程序化生成的占位图，可替换）
- **音效**：`Resources/Sounds/dice_roll.wav`（0.25s 静音占位，替换为真实骰子音效即可，无需改代码）
