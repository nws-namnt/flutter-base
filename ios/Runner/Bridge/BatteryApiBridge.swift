import Flutter
import UIKit

/// Native implementation of [BatteryApi] for iOS.
///
/// Registered in `AppDelegate.swift`:
/// ```swift
/// BatteryApiSetup.setUp(binaryMessenger: controller.binaryMessenger, api: BatteryApiBridge())
/// ```
class BatteryApiBridge: BatteryApi {

    /// Returns the current battery charge level as a percentage (0–100).
    ///
    /// On Simulator, always returns `100` because `UIDevice.batteryLevel`
    /// is not available in the simulated environment.
    ///
    /// Throws a `PigeonError` with code `"UNAVAILABLE"` if battery monitoring
    /// cannot be activated on a real device (state is `.unknown`).
    func getBatteryLevel() throws -> Int64 {
        #if targetEnvironment(simulator)
        // Simulator has no real battery — return mock value.
        return 100
        #else
        UIDevice.current.isBatteryMonitoringEnabled = true
        guard UIDevice.current.batteryState != .unknown else {
            throw PigeonError(code: "UNAVAILABLE", message: "Battery level not available.", details: nil)
        }
        return Int64(UIDevice.current.batteryLevel * 100)
        #endif
    }
}
