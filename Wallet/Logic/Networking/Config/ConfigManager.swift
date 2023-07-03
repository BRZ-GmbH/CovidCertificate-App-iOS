/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation
import UIKit

/// Config request allows to disable old versions of the app if
class ConfigManager: NSObject {
    // MARK: - Data Task

    private let session = URLSession(configuration: .default,
                                     delegate: nil,
                                     delegateQueue: nil)
    private var dataTask: URLSessionDataTask?

    // MARK: - Last Loaded Config

    @UBUserDefault(key: "config", defaultValue: fallbackConfig)
    static var currentConfig: ConfigResponseBody? {
        didSet {
            UIStateManager.shared.stateChanged()
        }
    }

    @UBUserDefault(key: "lastConfigLoad", defaultValue: nil)
    static var lastConfigLoad: Date?

    #if RELEASE_PROD || RELEASE_PROD_TEST
        static let configForegroundValidityInterval: TimeInterval = 60 * 60 * 1 // 1h
    #else
        static let configForegroundValidityInterval: TimeInterval = 60 * 60 * 8 // 8h
    #endif

    // MARK: - Version Numbers

    static var shortAppVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }

    static var appVersion: String {
        return "ios-\(shortAppVersion)"
    }

    static var osVersion: String {
        let systemVersion = UIDevice.current.systemVersion
        return "ios\(systemVersion)"
    }

    static var buildNumber: String {
        let shortVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        return "ios-\(shortVersion)"
    }

    // MARK: - Start config request

    static func shouldLoadConfig(lastConfigLoad: Date?) -> Bool {
        return lastConfigLoad == nil || Date().timeIntervalSince(lastConfigLoad!) > Self.configForegroundValidityInterval
    }

    public func loadConfig(force: Bool, completion: @escaping (ConfigResponseBody?) -> Void) {
        let request = Endpoint.config(appversion: ConfigManager.appVersion, osversion: ConfigManager.osVersion, buildnr: ConfigManager.buildNumber).request()

        guard force || Self.shouldLoadConfig(lastConfigLoad: Self.lastConfigLoad)
        else {
            completion(Self.currentConfig)
            return
        }

        dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let _ = response as? HTTPURLResponse,
                  let data = data
            else {
                Logger.log("Failed to load config, error: \(error?.localizedDescription ?? "?")")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            DispatchQueue.main.async {
                do {
                    let config = try JSONDecoder().decode(ConfigResponseBody.self, from: data)
                    // Do not store configuration as it is only used for mandatory update for now
                    ConfigManager.currentConfig = config
                    Self.lastConfigLoad = Date()

                    completion(config)
                } catch {
                    Logger.log("Failed to load config, error: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        })

        dataTask?.resume()
    }

    public func startConfigRequest(force: Bool, window: UIWindow?, showForceUpdateDialogIfNecessary: Bool = true, completionBlock: @escaping (() -> Void)) {
        loadConfig(force: force) { config in
            // self must be strong
            if let config = config {
                if showForceUpdateDialogIfNecessary {
                    self.presentAlertIfNeeded(config: config, window: window, completionBlock: completionBlock)
                } else {
                    completionBlock()
                }
            }
        }
    }

    private static var configAlert: UIAlertController?

    private func presentAlertIfNeeded(config: ConfigResponseBody, window: UIWindow?, completionBlock: (() -> Void)?) {
        if let minVersion = config.ios, Bundle.appVersion.versionCompare(minVersion) == .orderedAscending {
            if Self.configAlert != nil {
                Self.configAlert?.dismiss(animated: false, completion: nil)
                Self.configAlert = nil
            }
            let alert = UIAlertController(title: config.forceUpdate ? UBLocalized.force_update_title : UBLocalized.force_update_grace_period_title,
                                          message: config.forceUpdate ? UBLocalized.force_update_text : String(format: NSLocalizedString("force_update_grace_period_text", comment: ""), config.formattedForceUpdateDate),
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: config.forceUpdate ? UBLocalized.force_update_button : UBLocalized.force_update_grace_period_update_button, style: .default, handler: { _ in
                // Schedule tasks to next run loop
                DispatchQueue.main.async {
                    // show alert again -> app should always be blocked
                    Self.configAlert = nil
                    self.presentAlertIfNeeded(config: config, window: window, completionBlock: nil)

                    // jump to app store
                    UIApplication.shared.open(Environment.current.appStoreURL, options: [:], completionHandler: nil)
                }

            }))

            if config.forceUpdate == false {
                alert.addAction(UIAlertAction(title: UBLocalized.force_update_grace_period_skip_button, style: .default, handler: { _ in
                    completionBlock?()
                }))
            }

            window?.rootViewController?.topViewController.present(alert, animated: false, completion: nil)
            Self.configAlert = alert
        } else {
            if Self.configAlert != nil {
                Self.configAlert?.dismiss(animated: true, completion: nil)
                Self.configAlert = nil
            }
            completionBlock?()
        }
    }

    // In case the config has not yet been loaded at least once from the request, we use the bundled config as fallback
    public static var fallbackConfig: ConfigResponseBody? {
        let path = "config_wallet"
        guard let resource = Bundle.main.path(forResource: path, ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: resource), options: .mappedIfSafe),
              let config = try? JSONDecoder().decode(ConfigResponseBody.self, from: data)
        else {
            return nil
        }

        return config
    }
}

private extension UIViewController {
    var topViewController: UIViewController {
        if let p = presentedViewController {
            return p.topViewController
        } else {
            return self
        }
    }
}
