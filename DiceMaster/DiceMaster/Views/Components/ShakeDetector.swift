import SwiftUI

// 摇一摇检测：重写 UIWindow 的 motionEnded，将系统的 shake 手势转成通知，
// 再由 SwiftUI 的 onShake 修饰符接收。此方式无需任何隐私权限。

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name("DiceMaster.deviceDidShake")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

private struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content.onReceive(
            NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)
        ) { _ in
            action()
        }
    }
}

extension View {
    /// 设备被摇动时执行 `action`。
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(DeviceShakeViewModifier(action: action))
    }
}
