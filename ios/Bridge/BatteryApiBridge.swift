import Flutter
import UIKit

class BatteryApiBridge: BatteryApi {
    func getBatteryLevel() throws -> Int64 {
        UIDevice.current.isBatteryMonitoringEnabled = true
        guard UIDevice.current.batteryState != .unknown else {
            throw PigeonError(code: "UNAVAILABLE", message: "Battery level not available.", details: nil)
        }
        return Int64(UIDevice.current.batteryLevel * 100)
    }
}
