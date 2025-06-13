import Flutter
import UIKit
import NetworkExtension
import SystemConfiguration.CaptiveNetwork

public class SwiftPluginWifiConnectPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "plugin_wifi_connect", binaryMessenger: registrar.messenger())
    let instance = SwiftPluginWifiConnectPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    do {
      switch (call.method) {
        case "disconnect":
          disconnect(result: result)
          return

        case "getSSID":
          getSSID { ssid in
            result(ssid)
          }
          return

        case "connect":
          let args = try GetArgs(arguments: call.arguments)
          let hotspotConfig = NEHotspotConfiguration.init(ssid: args["ssid"] as! String)
          hotspotConfig.joinOnce = !(args["saveNetwork"] as! Bool);
          connect(hotspotConfig: hotspotConfig, result: result)
          return

        case "secureConnect":
          let args = try GetArgs(arguments: call.arguments)
          let hotspotConfig = NEHotspotConfiguration.init(ssid: args["ssid"] as! String, passphrase: args["password"] as! String, isWEP: args["isWep"] as! Bool)
          hotspotConfig.joinOnce = !(args["saveNetwork"] as! Bool);
          connect(hotspotConfig: hotspotConfig, result: result)
          return

        case "securePrefixConnect":
          guard #available(iOS 13.0, *) else {
            result(FlutterError(code: "iOS must be above 13", message: "Prefix connect doesn't work on iOS pre 13", details: nil))
            return
          }
          let args = try GetArgs(arguments: call.arguments)
          let hotspotConfig = NEHotspotConfiguration.init(ssidPrefix: args["ssid"] as! String, passphrase: args["password"] as! String, isWEP: args["isWep"] as! Bool)
          hotspotConfig.joinOnce = !(args["saveNetwork"] as! Bool);
          connect(hotspotConfig: hotspotConfig, result: result)
          return

        case "prefixConnect":
          guard #available(iOS 13.0, *) else {
            result(FlutterError(code: "iOS must be above 13", message: "Prefix connect doesn't work on iOS pre 13", details: nil))
            return
          }
          let args = try GetArgs(arguments: call.arguments)
          let hotspotConfig = NEHotspotConfiguration.init(ssidPrefix: args["ssid"] as! String)
          hotspotConfig.joinOnce = !(args["saveNetwork"] as! Bool);
          connect(hotspotConfig: hotspotConfig, result: result)
          return

        default:
          result(FlutterMethodNotImplemented)
          return
      }
    } catch ArgsError.MissingArgs {
        result(
          FlutterError( code: "missingArgs", 
            message: "Missing args",
            details: "Missing args."))
        return
    } catch {
        result(
          FlutterError( code: "unknownError", 
            message: "Unkown iOS error",
            details: error))
        return
    }
  }

  enum ArgsError: Error {
    case MissingArgs
  }

  func GetArgs(arguments: Any?) throws -> [String : Any]{
    guard let args = arguments as? [String : Any] else {
      throw ArgsError.MissingArgs
    }
    return args
  }

  @available(iOS 11, *)
  private func connect(hotspotConfig: NEHotspotConfiguration, result: @escaping FlutterResult) -> Void {
    NEHotspotConfigurationManager.shared.apply(hotspotConfig) { [weak self] (error) in

      if let error = error as NSError? {
        switch(error.code) {
        case NEHotspotConfigurationError.alreadyAssociated.rawValue:
            result(true)
            break
        case NEHotspotConfigurationError.userDenied.rawValue:
            result(false)
            break
        default:
            result(false)
            break
        }
        return
      }
      guard let this = self else {
        result(false)
        return
      }

      this.getSSID { ssid in
        if let ssid = ssid {
            result(ssid.hasPrefix(hotspotConfig.ssid))
        } else {
            result(false)
        }
      }
    }
  }

  @available(iOS 11.0, *)
  private func disconnect(result: @escaping FlutterResult) -> Void {
      getSSID { ssid in
          guard let ssid = ssid else {
              result(false)
              return
          }
          NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssid)
          result(true)
      }
  }

  private func getSSID(completion: @escaping (String?) -> Void) {
    if #available(iOS 14.0, *) {
        NEHotspotNetwork.fetchCurrent { currentNetwork in
            completion(currentNetwork?.ssid)
        }
    } else {
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary?,
                    let ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String {
                    completion(ssid)
                    return
                }
            }
        }
        completion(nil)
    }
  }
}
