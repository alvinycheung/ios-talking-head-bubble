@preconcurrency import AVFoundation
import AppKit

// MARK: - Comparable Extension

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - BubbleContentView

final class BubbleContentView: NSView {

    private let cameraManager: CameraManager
    private let cameraPreviewLayer: AVCaptureVideoPreviewLayer
    private let scrollSensitivity: CGFloat = 3.0

    init(cameraManager: CameraManager) {
        self.cameraManager = cameraManager
        self.cameraPreviewLayer = cameraManager.previewLayer
        super.init(frame: .zero)

        wantsLayer = true
        guard let layer else { return }
        layer.addSublayer(cameraPreviewLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layout() {
        super.layout()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        cameraPreviewLayer.frame = bounds
        cameraPreviewLayer.cornerRadius = bounds.width / 2
        cameraPreviewLayer.masksToBounds = true
        layer?.cornerRadius = bounds.width / 2
        layer?.masksToBounds = true
        CATransaction.commit()
    }

    // MARK: - Scroll Wheel (resize)

    override func scrollWheel(with event: NSEvent) {
        // Filter out momentum events
        if event.momentumPhase != [] { return }

        guard let panel = window as? BubblePanel else { return }
        let currentSize = panel.frame.width
        let delta = event.scrollingDeltaY * scrollSensitivity
        panel.resizeBubble(to: currentSize + delta)
    }

    // MARK: - Magnify / Pinch (resize)

    override func magnify(with event: NSEvent) {
        guard let panel = window as? BubblePanel else { return }
        let currentSize = panel.frame.width
        let newSize = currentSize * (1 + event.magnification)
        panel.resizeBubble(to: newSize)
    }

    // MARK: - Right-Click Context Menu

    override func menu(for event: NSEvent) -> NSMenu? {
        let menu = NSMenu()

        // Camera submenu
        let cameraMenu = NSMenu()
        for device in cameraManager.availableCameras() {
            let item = NSMenuItem(
                title: device.localizedName,
                action: #selector(selectCameraAction(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = device
            if device.uniqueID == cameraManager.currentDevice?.uniqueID {
                item.state = .on
            }
            cameraMenu.addItem(item)
        }
        let cameraItem = NSMenuItem(title: "Camera", action: nil, keyEquivalent: "")
        cameraItem.submenu = cameraMenu
        menu.addItem(cameraItem)

        // Mirror toggle
        let mirrorItem = NSMenuItem(
            title: "Mirror",
            action: #selector(toggleMirrorAction),
            keyEquivalent: ""
        )
        mirrorItem.target = self
        mirrorItem.state = cameraManager.isMirrored ? .on : .off
        menu.addItem(mirrorItem)

        menu.addItem(.separator())

        // Quit
        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quitAction),
            keyEquivalent: ""
        )
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    // MARK: - Menu Actions

    @objc private func selectCameraAction(_ sender: NSMenuItem) {
        guard let device = sender.representedObject as? AVCaptureDevice else { return }
        cameraManager.selectCamera(device)
    }

    @objc private func toggleMirrorAction() {
        cameraManager.toggleMirror()
    }

    @objc private func quitAction() {
        NSApp.terminate(nil)
    }
}
