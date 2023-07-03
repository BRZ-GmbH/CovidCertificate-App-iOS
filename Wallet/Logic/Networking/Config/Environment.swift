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

/// The backend environment under which the application runs.
enum Environment {
    case dev
    case abnahme
    case prod

    /// The current environment, as configured in build settings.
    static var current: Environment {
        #if DEBUG
            return .abnahme
        #elseif RELEASE_DEV
            return .abnahme
        #elseif RELEASE_ABNAHME
            return .abnahme
        #elseif RELEASE_PROD
            return .prod
        #elseif RELEASE_PROD_TEST
            return .prod
        #else
            fatalError("Missing build setting for environment")
        #endif
    }

    var appStoreURL: URL {
        return URL(string: UBLocalized.wallet_apple_app_store_url)!
    }

    var privacyURL: String {
        return UBLocalized.wallet_terms_privacy_link
    }

    var configService: Backend {
        switch self {
        case .dev:
            return Backend("https://dgc-trusttest.qr.gv.at", version: nil)
        case .abnahme:
            return Backend("https://dgc-trusttest.qr.gv.at", version: nil)
        case .prod:
            return Backend("https://dgc-trust.qr.gv.at", version: nil)
        }
    }

    var directLinkUrl: String {
        switch self {
        case .dev:
            return "https://nachweist.gesundheit.gv.at/result/wallet/v1/directLink"
        case .abnahme:
            return "https://nachweistest.gesundheit.gv.at/result/wallet/v1/directLink"
        case .prod:
            return "https://nachweis.gesundheit.gv.at/result/wallet/v1/directLink"
        }
    }

    var sdkEnvironment: SDKEnvironment {
        switch self {
        case .dev:
            return SDKEnvironment.dev
        case .abnahme:
            return SDKEnvironment.abn
        case .prod:
            return SDKEnvironment.prod
        }
    }

    var appToken: String {
        // These app tokens are reserved for the official COVID Certificate and COVID Certificate Check app.
        // If you intend to integrate the CovidCertificate-SDK into your app, please read
        // https://github.com/Federal-Ministry-of-Health-AT/green-pass-overview#getting-access-to-trust-list-business-rules-and-value-sets
        return Environment.stageAPIKey("WALLET_APP_SDK_API_TOKEN")!
    }

    fileprivate static func stageAPIKey(_ key: String) -> String? {
        let rVal: String? = (Bundle.main.infoDictionary?[key] as? String)?.replacingOccurrences(of: "\\", with: "")
        return rVal
    }
}

extension Endpoint {
    /// Load Config
    /// let av = "ios-10"
    /// let os = "ios13"
    static func config(appversion _: String, osversion _: String, buildnr _: String) -> Endpoint {
        let path = "config_wallet.json"
        return Environment.current.configService.endpoint(path)
    }
}
