import CVideoCaptureDriverInterface

#if os(iOS) || os(macOS) || os(tvOS)

import AVFoundation

@_cdecl("vcdi_main")
public func vcdi_main(_ instance: UnsafeMutablePointer <vcdi_instance_t>) {
    let registerInstance = instance.pointee.register_instance
    let instanceHandle = instance.pointee.instance_handle
    let _instance = VCDIInstance(instanceHandle: instanceHandle)
    let context = _instance.toUnsafeMutableRawPointer(retained: true)
    var instanceRegistrationData = vcdi_instance_registration_data_t(context: context,
                                                                     vendor_name: _instance.vendorName,
                                                                     instance_type: vcdi_instance_type_hardware_color_camera,
                                                                     request_authorization: _instance.requestAuthorization,
                                                                     open_session: _instance.openSession)
    let registeredInstance = registerInstance(instanceHandle, &instanceRegistrationData)

    precondition(registeredInstance, "Failed to register driver instance.")
}

#endif
