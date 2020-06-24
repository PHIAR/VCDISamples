import CVideoCaptureDriverInterface
import Dispatch
import Foundation

#if os(iOS) || os(macOS) || os(tvOS)

internal final class CameraInstance {
    private typealias MappedBuffer = (pointer: UnsafeMutableRawPointer,
                                      size: Int)

    public typealias PixelbufferCallback = (_ context: UnsafeMutableRawPointer,
                                            _ pointer: UnsafeMutableRawPointer,
                                            _ length: Int) -> Void

    private let executionQueue = DispatchQueue(label: "CameraInstance.executionQueue")
    private let receiveQueue = DispatchQueue(label: "CameraInstance.receiveQueue")
    private var stopped = false
    private var stopSynchronizer = DispatchGroup()
    private var callbacks: [(context: UnsafeMutableRawPointer,
                             callback: PixelbufferCallback)] = []

    private func receiveOnReceiveQueue() {
        dispatchPrecondition(condition: .onQueue(self.receiveQueue))

        while !self.executionQueue.sync(execute: {
            guard self.stopped else {
                return false
            }

            self.stopSynchronizer.leave()
            return true
        }) {
        }
    }

    internal init() {
    }

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
        return true
    }

    internal func startCapture() -> Bool {
        self.receiveQueue.async {
            self.executionQueue.sync { self.stopped = false }
            self.receiveOnReceiveQueue()
        }

        return true
    }

    internal func stopCapture() -> Bool {
        self.executionQueue.sync {
            self.stopSynchronizer.enter()
            self.stopped = true
        }

        self.stopSynchronizer.wait()
        return true
    }
}

#endif
