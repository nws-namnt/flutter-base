import Flutter
import UIKit

class DeviceApiBridge: DeviceApi {
    func getDeviceId() throws -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }

    func getModel() throws -> String {
        return UIDevice.current.model
    }
}
