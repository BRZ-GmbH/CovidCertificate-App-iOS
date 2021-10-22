/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

// simple user storage only for User Default values
class WalletUserStorage {
    static let shared = WalletUserStorage()

    @UBUserDefault(key: "wallet.user.hasCompletedOnboarding", defaultValue: false)
    var hasCompletedOnboarding: Bool {
        didSet {
            ConfigManager().startConfigRequest(force: false, window: UIApplication.shared.keyWindow?.window)
        }
    }
    
    @UBUserDefault(key: "wallet.user.selectedValidationRegion", defaultValue: "")
    var selectedValidationRegion: String {
        didSet { UIStateManager.shared.stateChanged(forceRefresh: true) }
    }
    
    @UBUserDefault(key: "lastInstalledAppVersion", defaultValue: ConfigManager.shortAppVersion)
    static var lastInstalledAppVersion: String
}

class CertificateStorage {
    static let shared = CertificateStorage()

    @KeychainPersisted(key: "wallet.user.certificates", defaultValue: [])
    var userCertificates: [UserCertificate] {
        didSet { UIStateManager.shared.stateChanged() }
    }

    func insertCertificate(userCertificate: UserCertificate) {
        if !userCertificates.contains(userCertificate) {
            userCertificates.insert(userCertificate, at: 0)
        }
    }
}
