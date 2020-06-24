import AVFoundation
import CVideoCaptureDriverInterface
import Dispatch
import Foundation

#if os(iOS) || os(macOS) || os(tvOS)

internal final class CameraInstance: NSObject,
                                     AVCaptureVideoDataOutputSampleBufferDelegate {
    private typealias MappedBuffer = (pointer: UnsafeMutableRawPointer,
                                      size: Int)

    public typealias PixelbufferCallback = (_ context: UnsafeMutableRawPointer,
                                            _ pointer: UnsafeMutableRawPointer,
                                            _ length: Int) -> Void

    private let executionQueue = DispatchQueue(label: "CameraInstance.executionQueue")
    private let receiveQueue = DispatchQueue(label: "CameraInstance.receiveQueue")
    private let captureSession = AVCaptureSession()
    private var captureDevice: AVCaptureDevice? = nil
    private var callbacks: [(context: UnsafeMutableRawPointer,
                             callback: PixelbufferCallback)] = []

    deinit {
    }

    internal func registerPixelbufferCallback(context: UnsafeMutableRawPointer,
                                              callback: @escaping PixelbufferCallback) {
        self.executionQueue.sync {
            self.callbacks.append((context: context,
                                   callback: callback))
        }
    }

    internal func requestAuthorization() -> Bool {
        return self.executionQueue.sync {
            guard self.captureDevice == nil else {
                return true
            }

            var granted = false
            let group = DispatchGroup()

            group.enter()
            AVCaptureDevice.requestAccess(for: .video) { _granted in
                granted = _granted
                group.leave()
            }

            group.wait()

            guard granted else {
                return false
            }

            let captureDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [
                                                                      .builtInWideAngleCamera,
                                                                  ],
                                                                  mediaType: .video,
                                                                  position: .back).devices

            guard let captureDevice = captureDevices.first else {
                return false
            }

            let captureSession = self.captureSession

            captureSession.beginConfiguration()

            let captureInput = try! AVCaptureDeviceInput(device: captureDevice)
            let outputData = AVCaptureVideoDataOutput()

            outputData.videoSettings = [
                String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA,
            ]

            outputData.setSampleBufferDelegate(self,
                                               queue: self.executionQueue)

            guard captureSession.canAddInput(captureInput),
                  captureSession.canAddOutput(outputData) else {
                captureSession.commitConfiguration()
                return false
            }

            captureSession.addInput(captureInput)
            captureSession.addOutput(outputData)
            captureSession.commitConfiguration()
            self.captureDevice = captureDevice
            return true
        }
    }

    internal func startCapture() -> Bool {
        self.executionQueue.async {
            self.captureSession.startRunning()
        }

        return true
    }

    internal func stopCapture() -> Bool {
        self.executionQueue.sync {
            self.captureSession.stopRunning()
        }

        return true
    }

    public func captureOutput(_ output: AVCaptureOutput,
                              didOutput sampleBuffer: CMSampleBuffer,
                              from connection: AVCaptureConnection) {
        dispatchPrecondition(condition: .onQueue(self.executionQueue))

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {

            return
        }
    }
}

#endif
