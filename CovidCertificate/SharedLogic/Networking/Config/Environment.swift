/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import CovidCertificateSDK
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
        #if WALLET
            return URL(string: UBLocalized.wallet_apple_app_store_url)!
        #elseif VERIFIER
            return URL(string: UBLocalized.verifier_apple_app_store_url)!
        #endif
    }

    var privacyURL: URL {
        #if WALLET
            return URL(string: UBLocalized.wallet_terms_privacy_link)!
        #elseif VERIFIER
            return URL(string: UBLocalized.verifier_terms_privacy_link)!
        #endif
    }

    var configService: Backend {
        switch self {
        case .dev:
            return Backend("https://gruenerpass.gesundheit.gv.at", version: nil)
        case .abnahme:
            return Backend("https://gruenerpass.gesundheit.gv.at", version: nil)
        case .prod:
            return Backend("https://gruenerpass.gesundheit.gv.at", version: nil)
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
        // If you intend to integrate the CovidCertificate-SDK into your app, please get in touch with BIT/BAG to get a token assigned.
        #if VERIFIER
            switch self {
            case .dev:
                return ""
            case .abnahme:
                return ""
            case .prod:
                return ""
            }
        #elseif WALLET
            switch self {
            case .dev:
                return ""
            case .abnahme:
                return "GixQfE3Oje1dGOWT6S5eVF9Iv4GHTJMm"
            case .prod:
                return "qAFg7d3kRdTN9A0IzoAComdd1lU8SwKf"
            }
        #endif
    }
}

extension Endpoint {
    /// Load Config
    /// let av = "ios-10"
    /// let os = "ios13"
    static func config(appversion _: String, osversion _: String, buildnr _: String) -> Endpoint {
        #if WALLET
            let path = "wallet-app/config"
        #elseif VERIFIER
            let path = "verifier/v1/config"
        #else
            let path = "" // Not supported
        #endif
        return Environment.current.configService.endpoint(path)
    }
}
