import AVFoundation

/// 音效播放。占位音频为 `Resources/Sounds/dice_roll.wav`，可自行替换为真实骰子音效。
@MainActor
final class SoundManager {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?

    private init() {}

    func playRoll() {
        guard let url = Bundle.main.url(forResource: "dice_roll", withExtension: "wav") else {
            return
        }
        do {
            // 使用 ambient 分类并允许混音，遵守静音键、不打断其它音频。
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            let player = try AVAudioPlayer(contentsOf: url)
            self.player = player
            player.prepareToPlay()
            player.play()
        } catch {
            // 占位音频缺失或解码失败时静默忽略。
        }
    }
}
