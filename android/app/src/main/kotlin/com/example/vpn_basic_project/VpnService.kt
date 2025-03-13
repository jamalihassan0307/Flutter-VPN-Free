package com.example.vpn_basic_project

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.net.VpnService
import android.os.IBinder
import android.os.ParcelFileDescriptor
import android.util.Log
import androidx.core.app.NotificationCompat

class OpenVpnService : VpnService() {
    private val TAG = "OpenVpnService"
    private var vpnInterface: ParcelFileDescriptor? = null
    private var configString: String? = null
    private var isRunning = false

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "VPN Service Created")
        startForeground()
    }

    private fun startForeground() {
        val channelId = "vpn_service_channel"
        val channelName = "VPN Service"
        
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                channelName,
                NotificationManager.IMPORTANCE_LOW
            )
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("VPN Service")
            .setContentText("VPN is running")
            .setSmallIcon(R.drawable.notification_icon)
            .build()

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(1, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
        } else {
            startForeground(1, notification)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        configString = intent?.getStringExtra("config")
        if (configString != null && !isRunning) {
            isRunning = true
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
                .allowBypass()

            vpnInterface = builder.establish()
            
            if (vpnInterface != null) {
                Log.d(TAG, "VPN interface established")
                MainActivity.updateVpnStatus("CONNECTED")
                
                // Keep service alive
                while (isRunning && vpnInterface != null) {
                    Thread.sleep(1000)
                }
            } else {
                Log.e(TAG, "Failed to establish VPN interface")
                MainActivity.updateVpnStatus("FAILED")
            }

        } catch (e: Exception) {
            Log.e(TAG, "Error starting VPN: ${e.message}")
            MainActivity.updateVpnStatus("FAILED")
        } finally {
            isRunning = false
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        stopVpn()
    }

    private fun stopVpn() {
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