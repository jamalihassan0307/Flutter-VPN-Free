package com.example.vpn_basic_project

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "vpn_engine"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startVpn" -> {
                    // Implement VPN start logic
                    result.success(null)
                }
                "stopVpn" -> {
                    // Implement VPN stop logic
                    result.success(null)
                }
                "prepare" -> {
                    // Implement VPN preparation
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
} 