import CVideoCaptureDriverInterface
import Foundation

#if os(iOS) || os(macOS) || os(tvOS)

import AVFoundation

private extension UnsafeMutableRawPointer {
    func toInstance(retained: Bool = false) -> VCDIInstance {
        guard retained else {
            return Unmanaged <VCDIInstance>.fromOpaque(UnsafeRawPointer(self)!).takeUnretainedValue()
        }

        return Unmanaged <VCDIInstance>.fromOpaque(UnsafeRawPointer(self)!).takeRetainedValue()
    }
}

internal extension VCDIInstance {
    func toUnsafeMutableRawPointer(retained: Bool = false) -> UnsafeMutableRawPointer {
        guard retained else {
            return UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        }

        return UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
    }
}


internal final class VCDIInstance {
    private let instanceHandle: UnsafeMutableRawPointer
    private let cameraInstance: CameraInstance
    private let _vendorName = "AVFoundation for Darwin".withCString { strdup($0)! }

    internal var closeSession: @convention(c) (UnsafeMutablePointer <vcdi_instance_session_t>) -> Void = { instanceSession in
        let _ = instanceSession.pointee.context.toInstance(retained: true)
    }

    internal var openSession: @convention(c) (UnsafeMutableRawPointer,
                                              UnsafeMutablePointer <vcdi_instance_session_t>) -> Bool = { context, instanceSession in
        let instance = context.toInstance()

        instanceSession.pointee.context = context
        instanceSession.pointee.close_session = instance.closeSession
        instanceSession.pointee.register_camera_callback = instance.registerPixelbufferCallback
        instanceSession.pointee.start_capture = instance.startCapture
        instanceSession.pointee.stop_capture = instance.stopCapture
        return true
    }

    internal var requestAuthorization: @convention(c) (UnsafeMutableRawPointer) -> Bool = { context in
        return context.toInstance().cameraInstance.requestAuthorization()
    }

    internal var registerPixelbufferCallback: @convention(c) (UnsafeMutablePointer <vcdi_instance_session_t>,
                                                              UnsafeMutableRawPointer,
                                                              @convention (c) @escaping (_ context: UnsafeMutableRawPointer,
                                                                                         _ pointer: UnsafeMutableRawPointer,
                                                                                         _ size: Int) -> Void) -> Void = { instanceSession, context, callback in
        return instanceSession.pointee.context.toInstance().cameraInstance.registerPixelbufferCallback(context: context,
                                                                                                       callback: callback)
    }

    internal var startCapture: @convention(c) (UnsafeMutablePointer <vcdi_instance_session_t>) -> Bool = { instanceSession in
        return instanceSession.pointee.context.toInstance().cameraInstance.startCapture()
    }

    internal var stopCapture: @convention(c) (UnsafeMutablePointer <vcdi_instance_session_t>) -> Bool = { instanceSession in
        return instanceSession.pointee.context.toInstance().cameraInstance.stopCapture()
    }

    internal var vendorName: UnsafeMutablePointer <CChar> {
        return self._vendorName
    }

    internal init(instanceHandle: UnsafeMutableRawPointer) {
        self.instanceHandle = instanceHandle
        self.cameraInstance = CameraInstance()
    }

    deinit {
        free(self._vendorName)
    }
}

#endif
