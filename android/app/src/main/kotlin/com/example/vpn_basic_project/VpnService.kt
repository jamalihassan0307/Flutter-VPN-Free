package com.example.vpn_basic_project

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.VpnService
import android.os.IBinder
import android.os.ParcelFileDescriptor
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import java.io.FileInputStream
import java.io.FileOutputStream
import java.net.InetSocketAddress
import java.nio.channels.DatagramChannel

class OpenVpnService : VpnService() {
    private val TAG = "OpenVpnService"
    private var vpnInterface: ParcelFileDescriptor? = null
    private var configString: String? = null
    private var isRunning = false
    private var connectionThread: Thread? = null

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
            connectionThread = Thread {
                startVpn(configString!!)
            }.apply { start() }
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun startVpn(config: String) {
        try {
            updateStatus("CONNECTING")
            Log.d(TAG, "Starting VPN with config: ${config.take(50)}...")

            // Parse config
            val serverAddress = config.lines()
                .find { it.startsWith("remote ") }
                ?.split(" ")
                ?.get(1) ?: throw Exception("Server address not found in config")
            
            val port = config.lines()
                .find { it.startsWith("remote ") }
                ?.split(" ")
                ?.get(2)?.toIntOrNull() ?: 1194

            // Create VPN interface
            val builder = Builder()
                .setSession("OpenVPN")
                .addAddress("10.8.0.2", 24)
                .addDnsServer("8.8.8.8")
                .addRoute("0.0.0.0", 0)
                .setMtu(1500)
                .allowFamily(android.system.OsConstants.AF_INET)
                .allowBypass()

            vpnInterface = builder.establish() ?: throw Exception("Failed to establish VPN interface")

            // Create UDP channel
            val tunnel = DatagramChannel.open()
            tunnel.connect(InetSocketAddress(serverAddress, port))
            protect(tunnel.socket())

            // Start tunnel
            val vpnInput = FileInputStream(vpnInterface!!.fileDescriptor)
            val vpnOutput = FileOutputStream(vpnInterface!!.fileDescriptor)
            
            updateStatus("CONNECTED")
            
            // Keep connection alive
            val buffer = ByteArray(32767)
            while (isRunning) {
                val length = vpnInput.read(buffer)
                if (length > 0) {
                    // Process incoming packets
                    tunnel.write(java.nio.ByteBuffer.wrap(buffer, 0, length))
                }
                
                // Process outgoing packets
                val packet = java.nio.ByteBuffer.allocate(32767)
                if (tunnel.read(packet) > 0) {
                    packet.flip()
                    vpnOutput.write(packet.array(), 0, packet.limit())
                }
            }

        } catch (e: Exception) {
            Log.e(TAG, "VPN Error: ${e.message}")
            updateStatus("FAILED")
        } finally {
            isRunning = false
            cleanup()
        }
    }

    private fun cleanup() {
        try {
            vpnInterface?.close()
            vpnInterface = null
        } catch (e: Exception) {
            Log.e(TAG, "Error cleaning up: ${e.message}")
        }
    }

    private fun updateStatus(status: String) {
        Handler(Looper.getMainLooper()).post {
            MainActivity.updateVpnStatus(status)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        connectionThread?.interrupt()
        cleanup()
        updateStatus("DISCONNECTED")
    }
} 