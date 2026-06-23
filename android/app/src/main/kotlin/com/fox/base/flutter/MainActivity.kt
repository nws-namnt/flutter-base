package com.fox.base.flutter

import com.fox.base.flutter.bridge.BatteryApiBridge
import com.fox.base.flutter.bridge.DeviceApiBridge
import com.fox.base.flutter.generated.BatteryApi
import com.fox.base.flutter.generated.DeviceApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        BatteryApi.setUp(messenger, BatteryApiBridge(applicationContext))
        DeviceApi.setUp(messenger, DeviceApiBridge())
    }
}
