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
import android.app.Activity

class MainActivity: FlutterActivity() {
    private val CHANNEL = "vpn_engine"
    private val EVENT_CHANNEL = "vpn_status"
    private val TAG = "VPNEngine"
    private val REQUEST_CODE = 1
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
                "prepare" -> {
                    val intent = VpnService.prepare(context)
                    if (intent != null) {
                        startActivityForResult(intent, REQUEST_CODE)
                        result.success(false)
                    } else {
                        result.success(true)
                    }
                }
                "start" -> {
                    startVpnService()
                    result.success(null)
                }
                "stop" -> {
                    stopVpnService()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
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

    private fun startVpnService() {
        val serviceIntent = Intent(this, VpnService::class.java)
        startService(serviceIntent)
    }

    private fun stopVpnService() {
        val serviceIntent = Intent(this, VpnService::class.java)
        stopService(serviceIntent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            startVpnService()
        }
        super.onActivityResult(requestCode, resultCode, data)
    }
} 