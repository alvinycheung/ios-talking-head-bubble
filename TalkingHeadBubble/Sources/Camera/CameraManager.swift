@preconcurrency import AVFoundation
import AppKit

final class CameraManager: NSObject, @unchecked Sendable {

    private let session = AVCaptureSession()
    let previewLayer: AVCaptureVideoPreviewLayer

    private(set) var currentDevice: AVCaptureDevice?
    private(set) var isMirrored: Bool = true

    private let sessionQueue = DispatchQueue(label: "com.talkingheadbubble.session")

    override init() {
        session.sessionPreset = .medium
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        super.init()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceWasConnected),
            name: AVCaptureDevice.wasConnectedNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceWasDisconnected),
            name: AVCaptureDevice.wasDisconnectedNotification,
            object: nil
        )
    }

    // MARK: - Camera Discovery

    func availableCameras() -> [AVCaptureDevice] {
        let types: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera,
            .external,
            .continuityCamera
        ]
        return AVCaptureDevice.DiscoverySession(
            deviceTypes: types,
            mediaType: .video,
            position: .unspecified
        ).devices
    }

    // MARK: - Camera Selection

    func selectDefaultCamera() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        selectCamera(device)
    }

    /// Session config runs on main thread (fast graph operations).
    /// Only startRunning/stopRunning are dispatched to sessionQueue.
    func selectCamera(_ device: AVCaptureDevice) {
        session.beginConfiguration()

        // Remove existing input
        for input in session.inputs {
            session.removeInput(input)
        }

        // Add new input
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            session.commitConfiguration()
            return
        }
        guard session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)
        session.commitConfiguration()

        // Connection exists now — configure mirror immediately
        currentDevice = device
        applyMirror()
    }

    // MARK: - Mirror

    func toggleMirror() {
        isMirrored.toggle()
        applyMirror()
    }

    private func applyMirror() {
        guard let connection = previewLayer.connection,
              connection.isVideoMirroringSupported else { return }
        connection.automaticallyAdjustsVideoMirroring = false
        connection.isVideoMirrored = isMirrored
    }

    // MARK: - Session Lifecycle

    func start() {
        sessionQueue.async { [weak self] in
            self?.session.startRunning()
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
        }
    }

    // MARK: - Device Notifications

    @objc private func deviceWasConnected(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let self, self.currentDevice == nil else { return }
            self.selectDefaultCamera()
        }
    }

    @objc private func deviceWasDisconnected(_ notification: Notification) {
        let disconnectedID = (notification.object as? AVCaptureDevice)?.uniqueID
        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let disconnectedID,
                  disconnectedID == self.currentDevice?.uniqueID else { return }
            self.currentDevice = nil
            self.selectDefaultCamera()
        }
    }
}
