package com.peakysoftware.plugin_wifi_connect

import android.annotation.SuppressLint
import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.*
import android.net.wifi.WifiConfiguration
import android.net.wifi.WifiManager
import android.net.wifi.WifiNetworkSpecifier
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PatternMatcher
import android.os.PatternMatcher.PATTERN_PREFIX
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.Error

/** PluginWifiConnectPlugin */
class PluginWifiConnectPlugin() : FlutterPlugin, MethodCallHandler {
  // / The MethodChannel that will the communication between Flutter and native Android
  // /
  // / This local reference serves to register the plugin with the Flutter Engine and unregister it
  // / when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  // holds the call while connected using ConnectivityManager.requestNetwork API
  private var networkCallback: ConnectivityManager.NetworkCallback? = null

  // holds the network id returned by WifiManager.addNetwork, required to disconnect (API < 29)
  private var networkId: Int? = null

  private val connectivityManager: ConnectivityManager by lazy(LazyThreadSafetyMode.NONE) {
    context?.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
  }

  private val wifiManager: WifiManager by lazy(LazyThreadSafetyMode.NONE) {
    context?.getSystemService(Context.WIFI_SERVICE) as WifiManager
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext()
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "plugin_wifi_connect")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "disconnect" -> {
        when {
          Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q -> {
            result.success(disconnect())
            return
          }
          else -> {
            disconnect(result)
            return
          }
        }
        return
      }
      "getSSID" -> {
        result.success(getSSID())
        return
      }
      "connect" -> {
        val ssid = call.argument<String>("ssid")
        ssid?.let {
          when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q -> {
              val specifier = WifiNetworkSpecifier.Builder()
                      .setSsid(it)
                      .build()
              connect(specifier, result)
              return
            }
            else -> {
              val wifiConfig = createWifiConfig(it)
              connect(wifiConfig, result)
              return
            }
          }
        }
        return
      }
      "prefixConnect" -> {
        val ssid = call.argument<String>("ssid")
        ssid?.let {
          when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q -> {
              val specifier = WifiNetworkSpecifier.Builder()
                      .setSsidPattern(PatternMatcher(it, PATTERN_PREFIX))
                      .build()
              connect(specifier, result)
              return
            }
            else -> {
              val wifiConfig = createWifiConfig(it)
              connectByPrefix(it, wifiConfig, result)
              return
            }
          }
        }
        return
      }
      "secureConnect" -> {
        val ssid = call.argument<String>("ssid")
        val password = call.argument<String>("password")
        val isWep = call.argument<Boolean>("isWep")
        val isWpa3 = call.argument<Boolean>("isWpa3")

        if (ssid == null || password == null || isWep == null) {
          return
        }

        if(isWep || Build.VERSION.SDK_INT < Build.VERSION_CODES.Q){
          val wifiConfig = isWep.let {
            if(it){
              createWEPConfig(ssid, password)
            }else{
              createWifiConfig(ssid, password)
            }
          }
          connect(wifiConfig, result)
          return
        }
        val specifier = WifiNetworkSpecifier.Builder()
                .setSsid(ssid)
                .apply {
                  if (isWpa3 != null && isWpa3) {
                    setWpa3Passphrase(password)
                  } else {
                    setWpa2Passphrase(password)
                  }
                }
                .build()
        connect(specifier, result)
        return
      }
      "securePrefixConnect" -> {
        val ssid = call.argument<String>("ssid")
        val password = call.argument<String>("password")
        val isWep = call.argument<Boolean>("isWep")
        val isWpa3 = call.argument<Boolean>("isWpa3")

        if (ssid == null || password == null || isWep == null) {
          return
        }

        if(isWep || Build.VERSION.SDK_INT < Build.VERSION_CODES.Q){
          val wifiConfig = when {
            isWep -> {
              createWEPConfig(ssid, password)
            }
            else -> {
              createWifiConfig(ssid, password)
            }
          }

          connectByPrefix(ssid, wifiConfig, result)
          return
        }
        val specifier = WifiNetworkSpecifier.Builder()
                .setSsidPattern(PatternMatcher(ssid, PATTERN_PREFIX))
                .apply {
                  if (isWpa3 != null && isWpa3) {
                    setWpa3Passphrase(password)
                  } else {
                    setWpa2Passphrase(password)
                  }
                }
                .build()
        connect(specifier, result)
        return
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  @SuppressLint("MissingPermission")
  @Suppress("DEPRECATION")
  fun connectByPrefix(@NonNull ssidPrefix: String, @NonNull config: WifiConfiguration, @NonNull result: Result){
    val wifiScanReceiver = object : BroadcastReceiver() {
      override fun onReceive(context: Context?, intent: Intent?) {
        val ssid = getNearbySsid(ssidPrefix)
        when {
          ssid != null -> {
            connect(config.apply {
              SSID = "\"" + ssid + "\""
            }, result)
          }
          else -> {
            result.success(false)
          }
        }
        context?.unregisterReceiver(this)
      }
    }

    val intentFilter = IntentFilter()
    intentFilter.addAction(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION)
    context?.registerReceiver(wifiScanReceiver, intentFilter)

    val scanStarted = wifiManager.startScan()
    if(!scanStarted){
      wifiScanReceiver.onReceive(null, null)
    }
  }

  @SuppressLint("MissingPermission")
  fun getNearbySsid(@NonNull ssidPrefix: String): String?{
    val results = wifiManager.scanResults
    return results.filter { scanResult -> scanResult.SSID.startsWith(ssidPrefix) }
            .maxByOrNull { scanResult -> scanResult.level }?.SSID
  }

  @Suppress("DEPRECATION")
  fun createWifiConfig(@NonNull ssid: String): WifiConfiguration{
    return WifiConfiguration().apply {
      SSID = "\"" + ssid + "\""
      allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE)

      allowedProtocols.set(WifiConfiguration.Protocol.RSN)
      allowedProtocols.set(WifiConfiguration.Protocol.WPA)

      allowedAuthAlgorithms.clear()

      allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.CCMP)
      allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.TKIP)

      allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP40)
      allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP104)
      allowedGroupCiphers.set(WifiConfiguration.GroupCipher.CCMP)
      allowedGroupCiphers.set(WifiConfiguration.GroupCipher.TKIP)
    }
  }

  @Suppress("DEPRECATION")
  fun createWifiConfig(@NonNull ssid: String, @NonNull password: String): WifiConfiguration{
    return createWifiConfig(ssid).apply {
      preSharedKey = "\"" + password + "\""
      status = WifiConfiguration.Status.ENABLED

      allowedKeyManagement.clear()
      allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK)
    }
  }

  @Suppress("DEPRECATION")
  fun createWEPConfig(@NonNull ssid: String, @NonNull password: String): WifiConfiguration{
    return createWifiConfig(ssid).apply {
      wepKeys[0] = "\"" + password + "\""
      wepTxKeyIndex = 0

      allowedGroupCiphers.clear()
      allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP40);
      allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP104);

      allowedAuthAlgorithms.set(WifiConfiguration.AuthAlgorithm.OPEN)
      allowedAuthAlgorithms.set(WifiConfiguration.AuthAlgorithm.SHARED)
    }
  }

  @SuppressLint("MissingPermission")
  fun connect(@NonNull wifiConfiguration: WifiConfiguration, @NonNull result: Result){
    val network = wifiManager.addNetwork(wifiConfiguration)
    if (network == -1) {
      result.success(false)
      return
    }
    wifiManager.saveConfiguration()

    val wifiChangeReceiver = object : BroadcastReceiver() {
      var count = 0
      override fun onReceive(context: Context, intent: Intent) {
        count++;
        val info = intent.getParcelableExtra<NetworkInfo>(WifiManager.EXTRA_NETWORK_INFO)
        if(info != null && info.isConnected) {
          if (info.extraInfo == wifiConfiguration.SSID || getSSID() == wifiConfiguration.SSID) {
            result.success(true)
            context?.unregisterReceiver(this)
          } else if (count > 1) {
            // Ignore first callback if not success. It may be for the already connected SSID
            result.success(false)
            context?.unregisterReceiver(this)
          }
        }
      }
    }

    val intentFilter = IntentFilter()
    intentFilter.addAction(WifiManager.NETWORK_STATE_CHANGED_ACTION)
    context?.registerReceiver(wifiChangeReceiver, intentFilter)

    // enable the new network and attempt to connect to it 
    wifiManager.enableNetwork(network, true)
    networkId = network
  }

  @RequiresApi(Build.VERSION_CODES.Q)
  fun connect(@NonNull specifier: WifiNetworkSpecifier, @NonNull result: Result){
    if (this.networkCallback != null) {
      // there was already a connection, unregister to disconnect before proceeding
      connectivityManager.unregisterNetworkCallback(this.networkCallback!!)
    }
    val request = NetworkRequest.Builder()
            .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
            .removeCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .setNetworkSpecifier(specifier)
            .build()

    this.networkCallback = object : ConnectivityManager.NetworkCallback() {
      override fun onAvailable(network: Network) {
        super.onAvailable(network)
        connectivityManager.bindProcessToNetwork(network)
        result.success(true)
        // cannot unregister callback here since it would disconnect form the network
      }

      override fun onUnavailable() {
        super.onUnavailable()
        result.success(false)
        //connectivityManager.unregisterNetworkCallback(this)
      }
    }

    val handler = Handler(Looper.getMainLooper())
    connectivityManager.requestNetwork(request, networkCallback!!, handler)
  }

  @RequiresApi(Build.VERSION_CODES.Q)
  fun disconnect(): Boolean{
    if (this.networkCallback == null){
      return false
    }
    
    connectivityManager.unregisterNetworkCallback(this.networkCallback!!)
    connectivityManager.bindProcessToNetwork(null)
    this.networkCallback = null

    return true
  }

  @SuppressLint("MissingPermission")
  @Suppress("DEPRECATION")
  fun disconnect(@NonNull result: Result){
    val network = networkId
    if (network == null) {
      result.success(false)
      return
    }
    val wifiChangeReceiver = object : BroadcastReceiver() {
      override fun onReceive(context: Context, intent: Intent) {
        val info = intent.getParcelableExtra<NetworkInfo>(WifiManager.EXTRA_NETWORK_INFO)
        if(info != null && !info.isConnected){
          result.success(true)
          context?.unregisterReceiver(this)
        }
      }
    }

    val intentFilter = IntentFilter()
    intentFilter.addAction(WifiManager.NETWORK_STATE_CHANGED_ACTION)
    context?.registerReceiver(wifiChangeReceiver, intentFilter)
    // remove network to emulate a behavior as close as possible to new Android API
    wifiManager.removeNetwork(network)
    wifiManager.reconnect()
    networkId = null
  }

  @SuppressLint("MissingPermission")
  fun getSSID(): String = wifiManager.connectionInfo.ssid
}
