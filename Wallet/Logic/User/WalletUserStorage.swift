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
            ConfigManager().startConfigRequest(force: false, window: UIApplication.shared.keyWindow?.window, completionBlock: {
                (UIApplication.shared.delegate as? AppDelegate)?.didUpdateConfig()
            })
        }
    }

    @UBUserDefault(key: "wallet.user.selectedValidationRegion", defaultValue: nil)
    var selectedValidationRegion: String? {
        didSet { UIStateManager.shared.stateChanged(forceRefresh: true) }
    }

    @UBUserDefault(key: "lastInstalledAppVersion", defaultValue: ConfigManager.shortAppVersion)
    static var lastInstalledAppVersion: String

    @UBUserDefault(key: "hasAskedForStoreReview", defaultValue: false)
    static var hasAskedForStoreReview: Bool

    @UBUserDefault(key: "hasOptedOutOfNonImportantCampaigns", defaultValue: false)
    static var hasOptedOutOfNonImportantCampaigns: Bool
}

class CertificateStorage {
    static let shared = CertificateStorage()

    var hasModifiedCertificatesInSession = false

    @KeychainPersisted(key: "wallet.user.certificates", defaultValue: [])
    var userCertificates: [UserCertificate] {
        didSet { UIStateManager.shared.stateChanged() }
    }

    func insertCertificate(userCertificate: UserCertificate) {
        if !userCertificates.contains(userCertificate) {
            hasModifiedCertificatesInSession = true
            userCertificates.insert(userCertificate, at: 0)
        }
    }

    func removeCertificate(userCertificate: UserCertificate) {
        userCertificates = userCertificates.filter { $0 != userCertificate }
        hasModifiedCertificatesInSession = true
    }
}
