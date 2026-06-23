import Flutter
import UIKit

/// Native implementation of [DeviceApi] for iOS.
///
/// Registered in `AppDelegate.swift`:
/// ```swift
/// DeviceApiSetup.setUp(binaryMessenger: controller.binaryMessenger, api: DeviceApiBridge())
/// ```
class DeviceApiBridge: DeviceApi {

    /// Returns the vendor UUID string, or `"unknown"` if the system returns nil.
    func getDeviceId() throws -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }

    /// Returns the device model string (e.g. `"iPhone"`, `"iPad"`).
    func getModel() throws -> String {
        return UIDevice.current.model
    }
}