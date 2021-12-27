//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 * Copyright (c) 2021 BRZ GmbH <https://www.brz.gv.at>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import CovidCertificateSDK
import Foundation
import UIKit
import ValidationCore

/**
 Handles notifications for Vaccination booster reminders
 */
class NotificationHandler: NSObject {
    
    private static var notificationAlert: UIAlertController?
    
    @KeychainPersisted(key: "wallet.user.notifications", defaultValue: [:])
    private var notifications: [String:Date]
    
    @KeychainPersisted(key: "wallet.user.notification.johnson.booster.shot.shown", defaultValue: false)
    private var hasNotifiedAboutJohnsonBoosterShot: Bool
    
    private var certificateCombinationHash = 0
    
    /**
        Checks if a vaccination booster notifications needs to be presented for any of the provided certificates and presents them on the rootViewController of the provided window
     */
    public func startCertificateNotificationCheck(window: UIWindow?, certificates: [UserCertificate]) {
        // EPIEMSCO-2173 Currently deactivate booster campaign
        /*certificateCombinationHash = certificates.map({ $0.qrCode }).joined(separator: "_").hash
        let certificateHolders: [DGCHolder] = certificates.compactMap({
            switch $0.decodedCertificate {
            case let .success(result): return result
            case .failure(_): return nil
            }
        })
        
        let eligibleCertificates = certificatesEligibleForNotification(certificateHolders: certificateHolders)
        let notifyableCertificates = certificatesToNotify(certificateHolders: eligibleCertificates)
        
        self.presentAlertForCertificateIfNeeded(certificates: notifyableCertificates, window: window, certificateHash:  certificateCombinationHash)*/
    }
    
    public func startCheckForJohnsonVaccinationBooster(window: UIWindow?, certificates: [UserCertificate], completion: @escaping (() -> ())) {
        completion()
        // EPIEMSCO-2173 Currently deactivate booster campaign
        /*guard !hasNotifiedAboutJohnsonBoosterShot else {
            completion()
            return
        }
        
        let certificateHolders: [DGCHolder] = certificates.compactMap({
            switch $0.decodedCertificate {
            case let .success(result): return result
            case .failure(_): return nil
            }
        })
        
        if certificateHolders.contains(where: {
            $0.healthCert.vaccinations?.first?.isJanssenVaccination == true
            && $0.healthCert.vaccinations?.first?.doseNumber == 1
        }) {
            hasNotifiedAboutJohnsonBoosterShot = true
            let alert = UIAlertController(title: nil, message: UBLocalized.wallet_notification_johnson_booster_message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: UBLocalized.wallet_notification_johnson_booster_ok_button, style: .cancel, handler: { _ in
                completion()
            }))
            alert.addAction(UIAlertAction(title: UBLocalized.wallet_notification_johnson_booster_info_button, style: .default, handler: { _ in
                guard let url = URL(string: UBLocalized.wallet_notification_johnson_booster_info_url) else { return }
                
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
            window?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            completion()
        }*/
    }
    
    /**
     Returns a filtered list of DGCHolder objects that represent certificates that are eligible for showing a notification about a vaccination booster
     */
    public func certificatesEligibleForNotification(certificateHolders: [DGCHolder]) -> [DGCHolder] {
        return certificateHolders.filter({
            // Only notify about vaccinations
            guard let vaccination = $0.healthCert.vaccinations?.first else { return false}
            
            // Only notify about certificates from Austria
            guard vaccination.country == "AT" else { return false }
            
            // Only notify for certificates that have not expired yet
            guard $0.expiresAt?.isAfter(Date()) ?? true else { return false }
            
            // Only notify fully vaccinated
            guard vaccination.doseNumber >= vaccination.totalDoses else {
                return false
            }
            
            guard vaccination.atLeastSixMonthsAgo else {
                return false
            }
            
            return (!vaccination.isJanssenVaccination && vaccination.doseNumber <= 2) || (vaccination.isJanssenVaccination && vaccination.doseNumber == 2)            
        })
    }
    
    /**
     Returns a filtered list of DGCHolder objects for which a notification should actually be presented (has either never been presented before or is already eligible for being shown again)
     */
    public func certificatesToNotify(certificateHolders: [DGCHolder]) -> [DGCHolder] {
        return certificateHolders.filter({ shouldNotifyForCertificate($0) })
    }
    
    /**
     Removes the notification display status for the provided certificate
     */
    public func removeCertificate(_ certificate: UserCertificate) {
        if case let .success(result) = certificate.decodedCertificate {
            if let identifier = result.healthCert.vaccinations?.first?.certificateIdentifier {
                notifications[identifier] = nil
            }
        }
    }
    
    private func shouldNotifyForCertificate(_ certificate: DGCHolder) -> Bool {
        guard let identifier = certificate.healthCert.vaccinations?.first?.certificateIdentifier else { return false }
        
        guard let nextNotificationWindow = notifications[identifier] else { return true }
        
        return nextNotificationWindow.isBefore(Date())
    }
    
    /**
        Presents an alert for the first certificate in the provided array and recursively calls itself again for the remaining certificates.
        certificateHash is compared again certificateCombinationHash to be able to cancel the recursive cycle in case the certificates change
     */
    private func presentAlertForCertificateIfNeeded(certificates: [DGCHolder], window: UIWindow?, certificateHash: Int) {
        if Self.notificationAlert != nil && certificateHash != certificateCombinationHash {
            dismissAlert()
        }
        if let certificate = certificates.first, let certificateIdentifier = certificate.healthCert.vaccinations?.first?.certificateIdentifier, certificateHash == certificateCombinationHash {
            let remainingCertificates = certificates.dropFirst()
            let title = UBLocalized.wallet_notification_booster_title
            let message = UBLocalized.wallet_notification_booster_message
            let readButton = UBLocalized.wallet_notification_booster_ok_button
            let remindAgainButton = UBLocalized.wallet_notification_booster_later_button
            let appointmentButton = UBLocalized.wallet_notification_booster_info_button
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            // Read
            alert.addAction(UIAlertAction(title: readButton, style: .default, handler: { _ in
                self.notifications[certificateIdentifier] = Calendar.current.date(byAdding: .year, value: 100, to: Date())
                DispatchQueue.main.async {
                    Self.notificationAlert = nil
                    self.presentAlertForCertificateIfNeeded(certificates: Array(remainingCertificates), window: window, certificateHash: certificateHash)
                }
            }))
            
            if (certificate.nextNotificationDate.isBefore(Date()) == false) {
                // Later
                alert.addAction(UIAlertAction(title: remindAgainButton, style: .default, handler: { _ in
                    self.notifications[certificateIdentifier] = certificate.nextNotificationDate
                    DispatchQueue.main.async {
                        Self.notificationAlert = nil
                        self.presentAlertForCertificateIfNeeded(certificates: Array(remainingCertificates), window: window, certificateHash: certificateHash)
                    }
                }))
            }
            
            alert.addAction(UIAlertAction(title: appointmentButton, style: .cancel, handler: { _ in
                self.notifications[certificateIdentifier] = Calendar.current.date(byAdding: .year, value: 100, to: Date())
                DispatchQueue.main.async {
                    Self.notificationAlert = nil
                    
                    guard let url = URL(string: UBLocalized.wallet_notification_booster_info_url) else { return }
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            
            window?.rootViewController?.present(alert, animated: true, completion: nil)
            Self.notificationAlert = alert
        }
    }
    
    /**
     Dismisses any potentially shown notification alert
     */
    public func dismissAlert() {
        certificateCombinationHash = 0
        Self.notificationAlert?.dismiss(animated: false, completion: nil)
        Self.notificationAlert = nil
    }
}

extension DGCHolder {
    /**
     Returns the next date for notifying about the vaccination booster for this certificate - either one week before expiration or one month from now
     */
    var nextNotificationDate: Date {
        let oneWeekBeforeExpiration = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: expiresAt ?? Date()) ?? Date()
        #if RELEASE_ABNAHME
            let tenMinutesFromNow = Calendar.current.date(byAdding: .minute, value: 10, to: Date()) ?? Date()
    
            return oneWeekBeforeExpiration.isBefore(tenMinutesFromNow) ? oneWeekBeforeExpiration : tenMinutesFromNow
        #endif
        
        let oneMonthFromNow = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
        return oneWeekBeforeExpiration.isBefore(oneMonthFromNow) ? oneWeekBeforeExpiration : oneMonthFromNow
    }
}

public extension Vaccination {
    func vaccinationIsOlderThan(months: Int) -> Bool {
        if let vaccinationDate = dateOfVaccination, let monthsAfterVaccination = Calendar.current.date(byAdding: .month, value: months, to:vaccinationDate) {
            return monthsAfterVaccination.isBefore(Date())
        }
        return false
    }
    
    /**
     Returns whether the vaccination date is at least 6 months ago
     */
    var atLeastSixMonthsAgo: Bool {
        return vaccinationIsOlderThan(months: 6)
    }
    
    /**
     Returns whether the vaccination date is at least 9 months ago
     */
    var atLeastNineMonthsAgo: Bool {
        return vaccinationIsOlderThan(months: 9)
    }
    
    /**
     Returns whether the vaccination was performed with a Janssen vaccine (by comparing the medicinalProduct (mp) field
     */
    var isJanssenVaccination: Bool {
        return medicinialProduct == "EU/1/20/1525"
    }
    
    /**
     Returns whether the vaccination was performed with a Vaxzevria (Astra Zeneca) vaccine (by comparing the medicinalProduct (mp) field
     */
    var isVaxzevriaVaccination: Bool {
        return medicinialProduct == "EU/1/21/1529"
    }
}

public extension EuHealthCert {
    
    private func ageIsOver(years: Int) -> Bool {
        if let birthDate = birthDate, let yearsAfterBirthDate = Calendar.current.date(byAdding: .year, value: years, to: birthDate) {
            return yearsAfterBirthDate.isBefore(Date())
        }
        return false
    }
    
    /**
     Returns whether the person is at least 65 years old
     */
    var isOver65: Bool {
        return ageIsOver(years: 65)
    }
    
    /**
     Returns whether the person is at least 18 years old
     */
    var isOver18: Bool {
        return ageIsOver(years: 18)
    }
}
