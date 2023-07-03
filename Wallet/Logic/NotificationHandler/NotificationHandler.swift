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
import JSON
import BusinessRulesValidationCore

/**
 Extensions for Vaccination Campaigns
 */
extension Campaign {
    
    /**
     Returns a unique key for fetching/storing the last display timestamp for a given campaign. If the campaign applies/is displayed for individual certificates, the certificate identifier is also added to this key.
     */
    func lastDisplayTimestampKeyForCertificate(_ certificate: HealthCert?) -> String? {
        switch campaignType {
            case .singleForEachCertificate, .repeatingForEachCertificate:
                guard let certificateIdentifier = certificate?.vaccinations?.first?.certificateIdentifier else { return nil }
                
                return "\(id)_\(certificateIdentifier)"
            default:
                return "\(id)_*"
        }
    }
    
    /**
     Returns whether the conditions for this campaign are fulfilled for the given certificate
     */
    func appliesToCertificate(_ certificate: DGCHolder,
                              condititions: [String:CertificateCondition],
                              externalParameterString: String,
                              otherCertificates: [DGCHolder],
                              otherCertificatesForSamePerson: [DGCHolder],
                              validationTime: Date?
    ) -> Bool {
        if campaignType == .single || campaignType == .repeating {
            return true
        }
        
        guard let conditionGroups = conditionGroups, !conditionGroups.isEmpty else { return true }
        
        let certificatePayload = try! JSONEncoder().encode(certificate.healthCert)
        let payloadString = String(data: certificatePayload, encoding: .utf8)!
        
        let jsonObjectForValidation = BusinessRulesCoreHelper.jsonObjectForValidation(forCertificatePayload: payloadString, externalParameter: externalParameterString)
        
        for group in conditionGroups {
            var isMatchingAllConditions = true
            for condition in group {
                if condition.isExternalCondition {
                    if let conditionNameAndArguments = condition.externalConditionNameAndArguments {
                        let evaluator = ExternalConditionVerifier(originalCertificate: certificate, otherCertificates: otherCertificates, otherCertificatesForSamePerson: otherCertificatesForSamePerson, condition: conditionNameAndArguments.condition, parameters: conditionNameAndArguments.parameters, region: "", profile: "", validationTime: validationTime ?? Date(), validationCore: nil)
                        if let result = evaluator.evaluateCondition() as? Bool, result == true {
                            // The rule was successfully validated and matches
                        } else {
                            isMatchingAllConditions = false
                        }
                    }
                } else {
                    if let validationResult = BusinessRulesCoreHelper.evaluateBooleanRule(try? condititions[condition]?.parsedJsonLogic(), forValidationObject: jsonObjectForValidation), validationResult == true {
                        // The rule was successfully validated and matches
                    } else {
                        isMatchingAllConditions = false
                    }
                }
            }
            if isMatchingAllConditions {
                return true
            }
        }
        
        return false
    }
    
    /**
     Returns whether the conditions for this campaign are fulfilled for the given certificate
     */
    func appliesToConditionsWithCertificates(certificates: [DGCHolder],
                                             validationTime: Date?
    ) -> Bool {
        guard let conditionGroups = conditionGroups, !conditionGroups.isEmpty else { return true }
        
        for group in conditionGroups {
            var isMatchingAllConditions = true
            for condition in group {
                if condition.isExternalCondition {
                    if let conditionNameAndArguments = condition.externalConditionNameAndArguments {
                        let evaluator = ExternalConditionVerifier(originalCertificate: nil, otherCertificates: certificates, otherCertificatesForSamePerson: [], condition: conditionNameAndArguments.condition, parameters: conditionNameAndArguments.parameters, region: "", profile: "", validationTime: validationTime ?? Date(), validationCore: nil)
                        if let result = evaluator.evaluateCondition() as? Bool, result == true {
                            // The rule was successfully validated and matches
                        } else {
                            isMatchingAllConditions = false
                        }
                    }
                } else {
                    // Campaign unspecific to a certificate can only match verify against external conditions
                    isMatchingAllConditions = false
                }
            }
            if isMatchingAllConditions {
                return true
            }
        }
        
        return false
    }
    
    /**
     Returns whether the campaign should be displayed given the provided last display timestamps and repeat interval. If the campaign applies to individual certificates, this method always returns false and the other variant of this method including a EuHealthCert should be used.
     */
    func shouldBeDisplayed(lastDisplayTimestamps: [String:Date]) -> Bool {
        guard let key = lastDisplayTimestampKeyForCertificate(nil) else { return false }
        
        switch campaignType {
            case .single:
                return lastDisplayTimestamps[key] == nil
            case .repeating:
                guard let repeatInterval = repeatInterval else {
                    return false
                }
                guard let lastDisplayTime = lastDisplayTimestamps[key] else { return true }
                
                return repeatInterval.dateByAddingRepeatIntervalTo(date: lastDisplayTime).isBefore(Date())
            default:
                return false
        }
    }
    
    /**
     Returns whether the campaign should be displayed given the provided last display timestamps, repeat interval and the given certificate. If the campaign does not apply to individual certificates, this method always returns false and the other variant of this method without the EuHealthCert should be used.
     */
    func shouldBeDisplayedForCertificate(_ certificate: HealthCert, lastDisplayTimestamps: [String:Date]) -> Bool {
        guard let key = lastDisplayTimestampKeyForCertificate(certificate) else { return false }
        
        switch campaignType {
            case .singleForEachCertificate, .singleForAnyCertificate:
                return lastDisplayTimestamps[key] == nil
            case .repeatingForEachCertificate, .repeatingForAnyCertificate:
                guard let repeatInterval = repeatInterval else {
                    return false
                }
                
                guard let lastDisplayTime = lastDisplayTimestamps[key] else { return true }
                
                return repeatInterval.dateByAddingRepeatIntervalTo(date: lastDisplayTime).isBefore(Date())
            default: return false
        }
    }
    
    var hasCompatibleCampaignVersion: Bool {
        return version <= NotificationHandler.maximumSupportedCampaignVersion
    }
    
    func localizedTitleWithPlaceholders(forValidationObject validationObject: JSON?) -> String? {
        guard let title = title?.value else { return nil }
        
        return BusinessRulesCoreHelper.evaluatePlaceholdersInString(title, onValidationObject: validationObject)
    }
    
    func localizedMessageWithPlaceholders(forValidationObject validationObject: JSON?) -> String? {
        guard let message = message?.value else { return nil }
               
        return BusinessRulesCoreHelper.evaluatePlaceholdersInString(message, onValidationObject: validationObject)
    }
}

/**
 Helper class for queueing campaign notifications
 */
struct QueuedCampaignNotification {
    let certificate: HealthCert?
    let campaign: Campaign
    let title: String?
    let message: String?
}

/**
 Handles notifications for Vaccination booster reminders
 */
class NotificationHandler: NSObject {
    
    static let maximumSupportedCampaignVersion: Int = 2
    
    private static var notificationAlert: UIAlertController?
    
    private var certificateCombinationHash = 0
    private var queuedCampaignNotifications: [QueuedCampaignNotification] = []
    
    @KeychainPersisted(key: "wallet.user.campaign_last_display_timestamps", defaultValue: [:])
    private var certificateCampaignLastDisplayTimestamps: [String:Date]

    @KeychainPersisted(key: "wallet.user.notification.last_expired_test_certificate_reminder", defaultValue: nil)
    private var lastExpiredTestCertificateReminderDate: Date?
    
    @KeychainPersisted(key: "wallet.user.notification.expired_test_certificate_reminder_count", defaultValue: 0)
    private var expiredTestCertificateReminderCount: Int
    
    @KeychainPersisted(key: "wallet.user.notification.ignore_expired_test_certificate", defaultValue: false)
    private var shouldIgnoreExpiredTestCertificates: Bool
    
    static let testCertificateExpirationPeriod: TimeInterval = 60 * 60 * 48
    #if RELEASE_ABNAHME
    static let recurringExpiredTestCertificateNotificationPeriod: TimeInterval = 60 * 60 * 24 * 7
    #else
    static let recurringExpiredTestCertificateNotificationPeriod: TimeInterval = 60 * 10
    #endif
    
    /**
        Checks if a vaccination booster notifications needs to be presented for any of the provided certificates and presents them on the rootViewController of the provided window
     */
    public func startCertificateNotificationCheck(window: UIWindow?, certificates: [UserCertificate], valueSets: [String:[String]], validationClock: Date, config: ConfigResponseBody) {
        guard window?.rootViewController?.presentedViewController == nil else { return }
        
        certificateCombinationHash = certificates.map({ $0.qrCode }).joined(separator: "_").appending("_\(Date.timeIntervalSinceReferenceDate)").hash
        queuedCampaignNotifications.removeAll()
        dismissAlert()
        
        let certificateHolders: [DGCHolder] = certificates.compactMap({
            switch $0.decodedCertificate {
            case let .success(result): return result
            case .failure(_): return nil
            }
        }).sorted(by: { ($0.issuedAt ?? Date()).isAfter($1.issuedAt ?? Date())})
        
        let groupedCertificateHolders = Dictionary(grouping: certificateHolders, by: {
            $0.healthCert.comparableIdentifier
        })
        
        var campaignsToDisplay: [QueuedCampaignNotification] = []
        config.campaigns?.forEach({ campaign in
            guard campaign.hasCompatibleCampaignVersion else { return }
            
            guard campaign.isActive else { return }
            
            guard (campaign.important || WalletUserStorage.hasOptedOutOfNonImportantCampaigns == false) else { return }
            
            if campaign.campaignType == .single || campaign.campaignType == .repeating {
                if campaign.shouldBeDisplayed(lastDisplayTimestamps: certificateCampaignLastDisplayTimestamps) {
                    if campaign.appliesToConditionsWithCertificates(certificates: certificateHolders, validationTime: validationClock) {
                        campaignsToDisplay.append(QueuedCampaignNotification(certificate: nil, campaign: campaign, title: campaign.title?.value, message: campaign.message?.value))
                    }
                }
            } else {
                var hasAddedCampaign = false
                
                var certificatesToCheck = certificateHolders.filter { holder in
                    campaign.certificateType == nil || holder.healthCert.businessRuleCertificationType == campaign.certificateType
                }
                if campaign.appliesTo == .newestCertificatePerPerson {
                    certificatesToCheck = []
                    groupedCertificateHolders.forEach { key, holders in
                        if let first = holders.first(where: { campaign.certificateType == nil || $0.healthCert.businessRuleCertificationType == campaign.certificateType }) {
                            certificatesToCheck.append(first)
                        }
                    }
                }
                
                for certificateHolder in certificatesToCheck {
                    let externalParameter = BusinessRulesCoreHelper.getExternalParameterStringForValidation(certificateIssueDate: certificateHolder.issuedAt ?? Date(), certificateExpiresDate: certificateHolder.expiresAt ?? Date(), countryCode: "AT", valueSets: valueSets, validationClock: validationClock)
                    
                    if !hasAddedCampaign {
                        let otherCertificates = certificateHolders.filter({ $0.encodedData != certificateHolder.encodedData })
                        let otherCertificatesForSamePerson = otherCertificates.filter({
                            return certificateHolder.healthCert.comparableIdentifier == $0.healthCert.comparableIdentifier
                        })
                        
                        if campaign.appliesToCertificate(certificateHolder, condititions: config.conditions ?? [:], externalParameterString: externalParameter, otherCertificates: otherCertificates, otherCertificatesForSamePerson: otherCertificatesForSamePerson, validationTime: validationClock) {
                            if campaign.shouldBeDisplayedForCertificate(certificateHolder.healthCert, lastDisplayTimestamps: certificateCampaignLastDisplayTimestamps) {
                                if campaign.campaignType == .singleForAnyCertificate || campaign.campaignType == .repeatingForAnyCertificate {
                                    hasAddedCampaign = true
                                }
                                
                                let certificatePayload = try! JSONEncoder().encode(certificateHolder.healthCert)
                                let payloadString = String(data: certificatePayload, encoding: .utf8)!
                                
                                let jsonObject = BusinessRulesCoreHelper.jsonObjectForValidation(forCertificatePayload: payloadString, externalParameter: externalParameter)
                                
                                campaignsToDisplay.append(QueuedCampaignNotification(certificate: certificateHolder.healthCert, campaign: campaign, title: campaign.localizedTitleWithPlaceholders(forValidationObject: jsonObject), message: campaign.localizedMessageWithPlaceholders(forValidationObject: jsonObject)))
                            }
                        }
                    }
                }
            }
        })
        
        queuedCampaignNotifications = campaignsToDisplay
        presentAlertForNextQueuedCampaignNotification(window: window, certificateHash: certificateCombinationHash)
    }
    
    /**
     Removes the notification display status for the provided certificate
     */
    public func removeCertificate(_ certificate: UserCertificate) {
        if case let .success(result) = certificate.decodedCertificate {
            if let identifier = result.healthCert.vaccinations?.first?.certificateIdentifier {
                let campaignKeys = certificateCampaignLastDisplayTimestamps.keys.filter( { $0.hasSuffix("_\(identifier)")})
                campaignKeys.forEach {
                    certificateCampaignLastDisplayTimestamps[$0] = nil
                }
            }
        }
    }
    
    /**
        Presents an alert for the first certificate in the provided array and recursively calls itself again for the remaining certificates.
        certificateHash is compared again certificateCombinationHash to be able to cancel the recursive cycle in case the certificates change
     */
    private func presentAlertForNextQueuedCampaignNotification(window: UIWindow?, certificateHash: Int) {
        if Self.notificationAlert != nil {
            dismissAlert()
        }
        
        if let campaignNotification = queuedCampaignNotifications.first, certificateHash == certificateCombinationHash {
            queuedCampaignNotifications.removeFirst()
            let alert = UIAlertController(title: campaignNotification.title, message: campaignNotification.message, preferredStyle: .alert)
            
            var hasAddedCancelButton = false
            campaignNotification.campaign.buttons.forEach { button in
                switch button.type {
                case .dismiss, .dismissWithAction:
                    alert.addAction(UIAlertAction(title: button.title.value, style: hasAddedCancelButton ? .default : .cancel, handler: { _ in
                        if let timestampKey = campaignNotification.campaign.lastDisplayTimestampKeyForCertificate(campaignNotification.certificate) {
                            self.certificateCampaignLastDisplayTimestamps[timestampKey] = Date().addingTimeInterval(60 * 60 * 24 * 365 * 100)
                        }
                        if let url = button.url, button.type == .dismissWithAction {
                            Self.notificationAlert = nil
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            DispatchQueue.main.async {
                                Self.notificationAlert = nil
                                self.presentAlertForNextQueuedCampaignNotification(window: window, certificateHash: certificateHash)
                            }
                        }
                    }))
                    hasAddedCancelButton = true
                case .later, .laterWithAction:
                    if campaignNotification.campaign.campaignType == .repeating || campaignNotification.campaign.campaignType == .repeatingForAnyCertificate || campaignNotification.campaign.campaignType == .repeatingForEachCertificate {
                        alert.addAction(UIAlertAction(title: button.title.value, style: .default, handler: { _ in
                            if let timestampKey = campaignNotification.campaign.lastDisplayTimestampKeyForCertificate(campaignNotification.certificate) {
                                self.certificateCampaignLastDisplayTimestamps[timestampKey] = Date()
                            }
                            if let url = button.url, button.type == .laterWithAction {
                                Self.notificationAlert = nil
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            } else {
                                DispatchQueue.main.async {
                                    Self.notificationAlert = nil
                                    self.presentAlertForNextQueuedCampaignNotification(window: window, certificateHash: certificateHash)
                                }
                            }
                        }))
                    }
                }
            }
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
    
    private func shouldCheckForExpiredTestCertificates() -> Bool {
        if shouldIgnoreExpiredTestCertificates {
            return false
        }
        
        if let lastReminder = lastExpiredTestCertificateReminderDate,
           lastReminder.timeIntervalSinceNow < NotificationHandler.recurringExpiredTestCertificateNotificationPeriod {
            return false
        }
        return true
    }
    
    /**
        Checks if 10 or more expired test certificates are added and if yes, shows a reminder dialog to automatically remove them
     */
    func checkForExpiredTestCertificates(window: UIWindow?, _ certificates: [UserCertificate], completionBlock: @escaping (_ hasRemovedCertificates: Bool) -> ()) {
        if window?.rootViewController?.presentedViewController != nil
            || shouldCheckForExpiredTestCertificates() == false {
            completionBlock(false)
            return
        }
        
        let expiredTestCertificates = certificates.expiredTestCertificates()
        
        if expiredTestCertificates.count >= 10 {
            let alert = UIAlertController(title: nil, message:
                                            String(format: NSLocalizedString("wallet_test_certificate_cleanup_message", comment: ""), "\(expiredTestCertificates.count)"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: UBLocalized.wallet_test_certificate_cleanup_no_button, style: .cancel, handler: { _ in
                self.lastExpiredTestCertificateReminderDate = Date()
                self.expiredTestCertificateReminderCount = self.expiredTestCertificateReminderCount + 1
                completionBlock(false)
            }))
            if expiredTestCertificateReminderCount >= 3 {
                alert.addAction(UIAlertAction(title: UBLocalized.wallet_test_certificate_cleanup_never_button, style: .cancel, handler: { _ in
                    self.shouldIgnoreExpiredTestCertificates = true
                    self.lastExpiredTestCertificateReminderDate = nil
                    self.expiredTestCertificateReminderCount = 0
                    completionBlock(false)
                }))
            }
            alert.addAction(UIAlertAction(title: UBLocalized.wallet_test_certificate_cleanup_cleanup_button, style: .default, handler: { _ in
                self.lastExpiredTestCertificateReminderDate = nil
                self.expiredTestCertificateReminderCount = 0
                self.shouldIgnoreExpiredTestCertificates = false
                
                CertificateStorage.shared.userCertificates = CertificateStorage.shared.userCertificates.filter { expiredTestCertificates.contains($0) == false }
                
                completionBlock(true)
            }))
            window?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            completionBlock(false)
        }
    }
}

extension Sequence where Iterator.Element : UserCertificate {
    func expiredTestCertificates() -> [Iterator.Element] {
        return self.filter({ $0.isExpiredTestCertificate() })
    }
}

extension UserCertificate {
    func isExpiredTestCertificate() -> Bool {
        switch decodedCertificate {
        case let .success(result):
            return result.healthCert.businessRuleCertificationType == .test
                && abs((result.expiresAt ?? Date()).timeIntervalSinceNow) > NotificationHandler.testCertificateExpirationPeriod
        case .failure(_): return false
        }
    }
}
