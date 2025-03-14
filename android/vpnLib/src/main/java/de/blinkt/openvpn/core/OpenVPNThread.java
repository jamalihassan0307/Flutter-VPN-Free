/*
 * Copyright (c) 2012-2016 Arne Schwabe
 * Distributed under the GNU GPL v2 with additional terms. For full terms see the file doc/LICENSE.txt
 */

package de.blinkt.openvpn.core;

import android.annotation.SuppressLint;
import android.util.Log;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;
import java.util.LinkedList;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.concurrent.atomic.AtomicBoolean;

import de.blinkt.openvpn.R;

public class OpenVPNThread implements Runnable {
    private static final String DUMP_PATH_STRING = "Dump path: ";
    @SuppressLint("SdCardPath")
    private static final String BROKEN_PIE_SUPPORT = "/data/data/de.blinkt.openvpn/cache/pievpn";
    private final static String BROKEN_PIE_SUPPORT2 = "syntax error";
    private static final String TAG = "OpenVPNThread";
    // 1380308330.240114 18000002 Send to HTTP proxy: 'X-Online-Host: bla.blabla.com'
    private static final Pattern LOG_PATTERN = Pattern.compile("(\\d+).(\\d+) ([0-9a-f])+ (.*)");
    public static final int M_FATAL = (1 << 4);
    public static final int M_NONFATAL = (1 << 5);
    public static final int M_WARN = (1 << 6);
    public static final int M_DEBUG = (1 << 7);
    private String[] mArgv;
    private static Process mProcess;
    private String mNativeDir;
    private String mTmpDir;
    private static OpenVPNService mService;
    private String mDumpPath;
    private boolean mBrokenPie = false;
    private boolean mNoProcessExitStatus = false;
    private final AtomicBoolean mProcessLock = new AtomicBoolean(false);
    private final AtomicBoolean isProcessAlive = new AtomicBoolean(false);
    private int exitValue = 0;

    public OpenVPNThread(OpenVPNService service, String[] argv, String nativelibdir, String tmpdir) {
        mArgv = argv;
        mNativeDir = nativelibdir;
        mTmpDir = tmpdir;
        mService = service;
    }

    public OpenVPNThread() {
    }

    public void stopProcess() {
        if (mProcess != null) {
            try {
                isProcessAlive.set(false);
                mProcess.destroy();
                mProcess = null;
            } catch (Exception e) {
                Log.e(TAG, "Error stopping OpenVPN process", e);
            }
        }
    }

    void setReplaceConnection() {
        mNoProcessExitStatus = true;
    }

    @Override
    public void run() {
        try {
            if (!mProcessLock.compareAndSet(false, true)) {
                Log.w(TAG, "Process is already running");
                return;
            }
            
            Log.i(TAG, "Starting OpenVPN process");
            startVPNProcess();
            
        } catch (Exception e) {
            Log.e(TAG, "OpenVPN process failed", e);
        } finally {
            mProcessLock.set(false);
        }
    }

    private void startVPNProcess() {
        try {
            ProcessBuilder pb = new ProcessBuilder(mArgv);
            pb.environment().put("LD_LIBRARY_PATH", mNativeDir);
            
            mProcess = pb.start();
            isProcessAlive.set(true);

            // Start monitoring process output
            new Thread(() -> monitorProcessOutput(), "OpenVPNOutput").start();
            
            // Wait for process completion
            exitValue = mProcess.waitFor();
            isProcessAlive.set(false);
            
            Log.i(TAG, "OpenVPN process exited with value: " + exitValue);
            
        } catch (InterruptedException e) {
            Log.e(TAG, "OpenVPN process interrupted", e);
            stopProcess();
        } catch (Exception e) {
            Log.e(TAG, "Error starting OpenVPN process", e);
            stopProcess();
        }
    }

    private void monitorProcessOutput() {
        try (BufferedReader br = new BufferedReader(new InputStreamReader(mProcess.getInputStream()))) {
            String line;
            while (isProcessAlive.get() && (line = br.readLine()) != null) {
                Log.d(TAG, "OpenVPN: " + line);
            }
        } catch (Exception e) {
            if (!Thread.interrupted()) {
                Log.e(TAG, "Error reading OpenVPN output", e);
            }
        }
    }

    public static boolean stop() {
        if (mProcess != null)
            mProcess.destroy();
        return true;
    }

    public boolean isAlive() {
        return isProcessAlive.get();
    }

    public int getExitValue() {
        return exitValue;
    }

    private void startOpenVPNThreadArgs(String[] argv) {
        LinkedList<String> argvlist = new LinkedList<>();

        Collections.addAll(argvlist, argv);

        ProcessBuilder pb = new ProcessBuilder(argvlist);
        // Hack O rama

        String lbpath = genLibraryPath(argv, pb);
        Log.i(TAG, lbpath);

        pb.environment().put("LD_LIBRARY_PATH", lbpath);
        pb.environment().put("TMPDIR", mTmpDir);

        pb.redirectErrorStream(true);
        try {
            mProcess = pb.start();
            // Close the output, since we don't need it
            mProcess.getOutputStream().close();
            InputStream in = mProcess.getInputStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(in));
            String line;
            while ((line = br.readLine()) != null) {
                if (line.startsWith(DUMP_PATH_STRING))
                    mDumpPath = line.substring(DUMP_PATH_STRING.length());

                if (line.startsWith(BROKEN_PIE_SUPPORT) || line.contains(BROKEN_PIE_SUPPORT2))
                    mBrokenPie = true;

                Matcher m = LOG_PATTERN.matcher(line);
                int logerror = 0;
                if (m.matches()) {
                    int flags = Integer.parseInt(m.group(3), 16);
                    String msg = m.group(4);
                    int logLevel = flags & 0x0F;

                    VpnStatus.LogLevel logStatus = VpnStatus.LogLevel.INFO;

                    if ((flags & M_FATAL) != 0)
                        logStatus = VpnStatus.LogLevel.ERROR;
                    else if ((flags & M_NONFATAL) != 0)
                        logStatus = VpnStatus.LogLevel.WARNING;
                    else if ((flags & M_WARN) != 0)
                        logStatus = VpnStatus.LogLevel.WARNING;
                    else if ((flags & M_DEBUG) != 0)
                        logStatus = VpnStatus.LogLevel.VERBOSE;

                    if (msg.startsWith("MANAGEMENT: CMD"))
                        logLevel = Math.max(4, logLevel);

                    if ((msg.endsWith("md too weak") && msg.startsWith("OpenSSL: error")) || msg.contains("error:140AB18E"))
                        logerror = 1;

                    VpnStatus.logMessageOpenVPN(logStatus, logLevel, msg);
                    if (logerror == 1)
                        VpnStatus.logError("OpenSSL reported a certificate with a weak hash, please the in app FAQ about weak hashes");

                } else {
                    VpnStatus.logInfo("P:" + line);
                }

                if (Thread.interrupted()) {
                    throw new InterruptedException("OpenVpn process was killed form java code");
                }
            }
        } catch (InterruptedException | IOException e) {
            e.printStackTrace();
            VpnStatus.logException("Error reading from output of OpenVPN process", e);
            stopProcess();
        }


    }

    private String genLibraryPath(String[] argv, ProcessBuilder pb) {
        // Hack until I find a good way to get the real library path
        String applibpath = argv[0].replaceFirst("/cache/.*$", "/lib");

        String lbpath = pb.environment().get("LD_LIBRARY_PATH");
        if (lbpath == null)
            lbpath = applibpath;
        else
            lbpath = applibpath + ":" + lbpath;

        if (!applibpath.equals(mNativeDir)) {
            lbpath = mNativeDir + ":" + lbpath;
        }
        return lbpath;
    }
}
