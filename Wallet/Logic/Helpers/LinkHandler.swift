//
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

/* Different types of links which are handled in the app*/
enum WalletAppLinkType {
    case directLink(secret: String, secretSignature: String, clientId: String? = nil, clientIdSignature: String? = nil)
    case directLinkWithBpt(secret: String, secretSignature: String, clientId: String? = nil, clientIdSignature: String? = nil, bpt: String)
    case directQRCode(data: String)
    case none
}

class LinkHandler {
    @discardableResult
    func handle(url _: URL) -> Bool {
        false
    }

    func handle(urlComponents: URLComponents) -> WalletAppLinkType {
        let parts = urlComponents.path.split(separator: "/")

        if parts.count == 3, String(parts[0]) == "result" {
            if let bpt = urlComponents.queryItems?.first(where: { $0.name == "bpt" })?.value {
                return .directLinkWithBpt(secret: String(parts[1]), secretSignature: String(parts[2]), bpt: bpt)
            }
            return .directLink(secret: String(parts[1]), secretSignature: String(parts[2]))
        } else if parts.count == 5, String(parts[0]) == "result" {
            if let bpt = urlComponents.queryItems?.first(where: { $0.name == "bpt" })?.value {
                return .directLinkWithBpt(secret: String(parts[1]), secretSignature: String(parts[2]), clientId: String(parts[3]), clientIdSignature: String(parts[4]), bpt: bpt)
            }
            return .directLink(secret: String(parts[1]), secretSignature: String(parts[2]), clientId: String(parts[3]), clientIdSignature: String(parts[4]))
        } else if parts.count == 5, String(parts[0]) == "gruenerpass", String(parts[1]) == "download", String(parts[2]) == "qr-code", String(parts[3]) == "wallet" {
            // Feature temporarely deactivated
            return .none
            // guard let qrCodeData = Data(base64Encoded: String(parts[4])), let qrCode = String(data: qrCodeData, encoding: .utf8) else {
            //    return .none
            // }
            // return .directQRCode(data: qrCode)
        }

        // path does not fit anything we handle
        return .none
    }
}

private extension URL {
    init?(userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL
        else {
            return nil
        }
        self = url
    }
}
