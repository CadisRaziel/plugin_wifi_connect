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

        case "  ":
          guard #available(iOS 13.0, *) else {
            result(FlutterError(code: "iOS must be above 13", message: "Prefix connect doesn't work on iOS pre 13", details: nil))
            return
          }
          let args = try GetArgs(arguments: call.arguments)
          let hotspotConfig = NEHotspotConfiguration.init(ssidPrefix: args["ssid"] as! String)
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
            if let error = error as? NSError,
               let hotspotError = NEHotspotConfigurationError(rawValue: error.code) {
                switch (hotspotError) {
                case .alreadyAssociated:
                    result(true)
                case .userDenied:
                    // user cancelled, no success or failure so return nil
                    result(nil)
                case .invalid:
                    result(FlutterError(code: "invalid", message: error.localizedDescription, details: nil))
                case .invalidSSID:
                    result(FlutterError(code: "invalidSSID", message: error.localizedDescription, details: nil))
                case .invalidWPAPassphrase:
                    result(FlutterError(code: "invalidWPAPassphrase", message: error.localizedDescription, details: nil))
                case .invalidWEPPassphrase:
                    result(FlutterError(code: "invalidWEPPassphrase", message: error.localizedDescription, details: nil))
                case .invalidEAPSettings:
                    result(FlutterError(code: "invalidEAPSettings", message: error.localizedDescription, details: nil))
                case .invalidHS20Settings:
                    result(FlutterError(code: "invalidHS20Settings", message: error.localizedDescription, details: nil))
                case .invalidHS20DomainName:
                    result(FlutterError(code: "invalidHS20DomainName", message: error.localizedDescription, details: nil))
                case .internal:
                    result(FlutterError(code: "internal", message: error.localizedDescription, details: nil))
                case .pending:
                    result(FlutterError(code: "pending", message: error.localizedDescription, details: nil))
                case .systemConfiguration:
                    result(FlutterError(code: "systemConfiguration", message: error.localizedDescription, details: nil))
                case .unknown:
                    result(FlutterError(code: "unknown", message: error.localizedDescription, details: nil))
                case .joinOnceNotSupported:
                    result(FlutterError(code: "joinOnceNotSupported", message: error.localizedDescription, details: nil))
                case .applicationIsNotInForeground:
                    result(FlutterError(code: "applicationIsNotInForeground", message: error.localizedDescription, details: nil))
                case .invalidSSIDPrefix:
                    result(FlutterError(code: "invalidSSIDPrefix", message: error.localizedDescription, details: nil))
                case .userUnauthorized:
                    result(FlutterError(code: "userUnauthorized", message: error.localizedDescription, details: nil))
                case .systemDenied:
                    result(FlutterError(code: "systemDenied", message: error.localizedDescription, details: nil))
                @unknown default:
                    result(FlutterError(code: "unknownError", message: error.localizedDescription, details: nil))
                }
                return
            } else if let error = error {
                result(FlutterError(code: "unknownError", message: error.localizedDescription, details: nil))
                return
            }
            
            guard let this = self else {
                result(false)
                return
            }
            this.getSSID { (ssid) in
                if let currentSsid = ssid {
                    result(currentSsid.hasPrefix(hotspotConfig.ssid))
                } else {
                    result(false)
                }
            }
        }
    }
    
  @available(iOS 11, *)
  private func disconnect(result: @escaping FlutterResult) {
      getSSID { (ssid) in
          if let ssid {
              NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssid)
              result(true)
          } else {
              result(false)
          }
      }
  }
    
  private func getSSID(result: @escaping (String?) -> ()) {
      if #available(iOS 14.0, *) {
          NEHotspotNetwork.fetchCurrent(completionHandler: { currentNetwork in
              result(currentNetwork?.ssid) // was broken before, because this happens async
          })
      } else {
          if let interfaces = CNCopySupportedInterfaces() as NSArray? {
              for interface in interfaces {
                  if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                      result(interfaceInfo[kCNNetworkInfoKeySSID as String] as? String)
                      return
                  }
              }
          }
          result(nil)
      }
  }
}
