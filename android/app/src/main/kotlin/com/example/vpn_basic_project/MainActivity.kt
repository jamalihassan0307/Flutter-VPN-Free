package com.example.vpn_basic_project

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.net.VpnService
import android.content.Intent
import android.util.Log
import android.os.Handler
import android.os.Looper
import de.blinkt.openvpn.core.OpenVPNService
import de.blinkt.openvpn.VpnProfile
import de.blinkt.openvpn.core.ConfigParser
import android.app.ActivityManager
import android.content.Context
import io.flutter.plugin.common.EventChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "vpn_channel"
    private val EVENT_CHANNEL = "vpn_status"
    private val TAG = "VPNEngine"
    private val REQUEST_VPN_PERMISSION = 1
    private var vpnService: OpenVPNService? = null

    companion object {
        private var methodChannel: MethodChannel? = null

        fun updateVpnStatus(status: String) {
            Handler(Looper.getMainLooper()).post {
                methodChannel?.invokeMethod("updateStatus", status)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startVpn" -> {
                    val config = call.argument<String>("config")
                    if (config != null) {
                        startVpnService(config)
                        result.success(null)
                    } else {
                        result.error("CONFIG_ERROR", "VPN config is null", null)
                    }
                }
                "stopVpn" -> {
                    stopVpnService()
                    result.success(null)
                }
                "prepare" -> {
                    try {
                        Log.d(TAG, "Preparing VPN")
                        val intent = VpnService.prepare(context)
                        if (intent != null) {
                            startActivityForResult(intent, REQUEST_VPN_PERMISSION)
                        }
                        result.success(null)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error preparing VPN: ${e.message}")
                        result.error("VPN_PREPARE_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    // Handle VPN status updates
                }

                override fun onCancel(arguments: Any?) {
                    // Cleanup
                }
            }
        )
    }

    private fun startVpnService(config: String) {
        val intent = Intent(this, OpenVPNService::class.java)
        intent.putExtra("config", config)
        startForegroundService(intent)
    }

    private fun stopVpnService() {
        val intent = Intent(this, OpenVPNService::class.java)
        stopService(intent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_VPN_PERMISSION) {
            if (resultCode == RESULT_OK) {
                Log.d(TAG, "VPN permission granted")
                // Notify Flutter about permission granted
                MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL)
                    .invokeMethod("onVpnPermissionGranted", null)
            } else {
                Log.d(TAG, "VPN permission denied")
                // Notify Flutter about permission denied
                MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL)
                    .invokeMethod("onVpnPermissionDenied", null)
            }
        }
        super.onActivityResult(requestCode, resultCode, data)
    }
} 