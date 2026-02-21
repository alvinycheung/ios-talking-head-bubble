import AppKit

final class BubblePanel: NSPanel {

    static let minSize: CGFloat = 100
    static let maxSize: CGFloat = 400

    init(size: CGFloat = 200) {
        let rect = NSRect(x: 0, y: 0, width: size, height: size)
        super.init(
            contentRect: rect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        level = .floating
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        isMovableByWindowBackground = true
        hidesOnDeactivate = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Center on main screen
        if let screen = NSScreen.main {
            let origin = NSPoint(
                x: screen.visibleFrame.midX - size / 2,
                y: screen.visibleFrame.midY - size / 2
            )
            setFrameOrigin(origin)
        }
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    func resizeBubble(to newSize: CGFloat) {
        let clamped = newSize.clamped(to: Self.minSize...Self.maxSize)
        let center = NSPoint(
            x: frame.midX,
            y: frame.midY
        )
        let newOrigin = NSPoint(
            x: center.x - clamped / 2,
            y: center.y - clamped / 2
        )
        setFrame(NSRect(origin: newOrigin, size: NSSize(width: clamped, height: clamped)), display: true)
        invalidateShadow()
    }
}
