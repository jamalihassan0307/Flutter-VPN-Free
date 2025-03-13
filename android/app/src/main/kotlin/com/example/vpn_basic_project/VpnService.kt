package com.example.vpn_basic_project

import android.app.Service
import android.content.Intent
import android.net.VpnService
import android.os.IBinder
import android.os.ParcelFileDescriptor
import android.util.Log

class OpenVpnService : VpnService() {
    private val TAG = "OpenVpnService"
    private var vpnInterface: ParcelFileDescriptor? = null
    private var configString: String? = null

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "VPN Service Created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        configString = intent?.getStringExtra("config")
        if (configString != null) {
            Thread {
                startVpn(configString!!)
            }.start()
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    fun startVpn(config: String) {
        try {
            Log.d(TAG, "Starting VPN connection with config: ${config.take(20)}...")
            MainActivity.updateVpnStatus("CONNECTING")
            
            // Create VPN interface
            val builder = Builder()
                .setSession("OpenVPN")
                .addAddress("10.0.0.2", 24)
                .addDnsServer("8.8.8.8")
                .addRoute("0.0.0.0", 0)
                .setMtu(1500)
                .allowFamily(android.system.OsConstants.AF_INET)
                .allowFamily(android.system.OsConstants.AF_INET6)
                .allowBypass() // Allow apps to bypass VPN

            vpnInterface = builder.establish()
            
            if (vpnInterface != null) {
                Log.d(TAG, "VPN interface established")
                MainActivity.updateVpnStatus("CONNECTED")
                
                // Start a background thread to monitor connection
                Thread {
                    try {
                        // Keep the service alive
                        while (vpnInterface != null) {
                            Thread.sleep(1000)
                        }
                    } catch (e: InterruptedException) {
                        Log.e(TAG, "VPN monitoring interrupted", e)
                    }
                }.start()
                
            } else {
                Log.e(TAG, "Failed to establish VPN interface")
                MainActivity.updateVpnStatus("FAILED")
            }

        } catch (e: Exception) {
            Log.e(TAG, "Error starting VPN: ${e.message}")
            MainActivity.updateVpnStatus("FAILED")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        stopVpn()
    }

    fun stopVpn() {
        try {
            vpnInterface?.close()
            vpnInterface = null
            Log.d(TAG, "VPN stopped")
            MainActivity.updateVpnStatus("DISCONNECTED")
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping VPN: ${e.message}")
        }
    }
} 