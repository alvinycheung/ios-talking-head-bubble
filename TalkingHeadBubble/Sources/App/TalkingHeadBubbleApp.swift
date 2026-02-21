import SwiftUI
@preconcurrency import AVFoundation

@main
struct TalkingHeadBubbleApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

// MARK: - AppDelegate

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {

    private var cameraManager: CameraManager!
    private var panel: BubblePanel!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let manager = CameraManager()
        self.cameraManager = manager

        let contentView = BubbleContentView(cameraManager: manager)
        let bubblePanel = BubblePanel(size: 200)
        bubblePanel.contentView = contentView
        self.panel = bubblePanel

        // Show bubble immediately (blank until camera authorized)
        bubblePanel.orderFront(nil)

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            manager.selectDefaultCamera()
            manager.start()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        manager.selectDefaultCamera()
                        manager.start()
                    } else {
                        self.showPermissionDeniedAlert()
                    }
                }
            }
        case .denied, .restricted:
            showPermissionDeniedAlert()
        @unknown default:
            break
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    private func showPermissionDeniedAlert() {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = "Camera Access Required"
        alert.informativeText = "TalkingHeadBubble needs camera access. Please grant permission in System Settings > Privacy & Security > Camera."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Quit")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") {
                NSWorkspace.shared.open(url)
            }
        }
        NSApp.terminate(nil)
    }
}
