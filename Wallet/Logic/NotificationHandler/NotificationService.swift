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

import Foundation
import UIKit
import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    private var notificationAuthorizationStatus: UNAuthorizationStatus?
    private var isRequestingNotificationAuthorization = false

    var hasDeterminedNotificationPermission: Bool {
        return notificationAuthorizationStatus != nil && notificationAuthorizationStatus != .notDetermined
    }

    var canDisplayLocalNotifications: Bool {
        return notificationAuthorizationStatus == .authorized
    }

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        DispatchQueue.main.async { [weak self] in
            self?.checkNotificationSettings()
        }
    }

    @objc private func willEnterForeground() {
        checkNotificationSettings()
    }

    private func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            self?.notificationAuthorizationStatus = settings.authorizationStatus
        }
    }

    func requestPermissionForLocalNotificationsIfNecessary() {
        if notificationAuthorizationStatus == nil || notificationAuthorizationStatus == .notDetermined, !isRequestingNotificationAuthorization {
            isRequestingNotificationAuthorization = true
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { [weak self] _, _ in
                self?.isRequestingNotificationAuthorization = false
                DispatchQueue.main.async {
                    self?.checkNotificationSettings()
                }
            })
        }
    }

    private func triggerIntervalForNotifications() -> TimeInterval {
        guard let currentHour = Calendar.autoupdatingCurrent.dateComponents([.hour], from: Date()).hour else {
            return 60 * 5
        }

        if currentHour >= 8, currentHour <= 20 {
            return 60 * 5
        } else if currentHour < 8 {
            return Double(8 - currentHour) * 60 * 60
        } else if currentHour > 20 {
            return Double(24 - currentHour + 8) * 60 * 60
        } else {
            return 60 * 5
        }
    }

    func updateLocalNotificationsForCampaignCheckResult(_ checkResult: CampaignCheckResult, excludingVisibleCampaignTimestampKey: String?) {
        let triggerInterval = triggerIntervalForNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        UNUserNotificationCenter.current().getDeliveredNotifications { [weak self] visibleNotifications in
            let visibleCampaignTimestampKeys: [String] = visibleNotifications.compactMap { $0.request.content.userInfo["campaignTimestampKey"] as? String }

            let timestampKeysToShow = checkResult.campaignsToDisplay.compactMap { $0.campaign.lastDisplayTimestampKeyForCertificate($0.certificate) }

            let campaignsToAdd = checkResult.campaignsToDisplay.filter { campaignToDisplay in
                if let timestampKey = campaignToDisplay.campaign.lastDisplayTimestampKeyForCertificate(campaignToDisplay.certificate) {
                    return visibleCampaignTimestampKeys.contains(timestampKey) == false && timestampKey != excludingVisibleCampaignTimestampKey
                }
                return false
            }

            let notificationRequests: [UNNotificationRequest] = campaignsToAdd.compactMap { campaignNotification in
                guard let timestampKey = campaignNotification.campaign.lastDisplayTimestampKeyForCertificate(campaignNotification.certificate) else { return nil }
                let content = UNMutableNotificationContent()
                content.sound = UNNotificationSound.default
                content.title = campaignNotification.title ?? ""
                content.body = campaignNotification.message ?? ""
                content.userInfo = ["campaignId": campaignNotification.campaign.id, "campaignTimestampKey": timestampKey]
                return UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: triggerInterval, repeats: false))
            }

            let notificationIdentifersToRemove = visibleNotifications.filter { visibleNotification in
                guard let campaignTimestampKey = visibleNotification.request.content.userInfo["campaignTimestampKey"] as? String else { return false }
                return timestampKeysToShow.contains(campaignTimestampKey) == false
            }.map { $0.request.identifier }
            if !notificationIdentifersToRemove.isEmpty {
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: notificationIdentifersToRemove)
            }
            self?.queueNotificationRequests(notificationRequests)
        }
    }

    func getCampaignTimestampKeysFromDeliveredLocalNotifications(_ completion: @escaping (([String]) -> Void)) {
        UNUserNotificationCenter.current().getDeliveredNotifications { visibleNotifications in
            DispatchQueue.main.async {
                let visibleCampaignTimestampKeys: [String] = visibleNotifications.compactMap { $0.request.content.userInfo["campaignTimestampKey"] as? String }
                completion(visibleCampaignTimestampKeys)
            }
        }
    }

    private func queueNotificationRequests(_ requests: [UNNotificationRequest]) {
        guard let firstRequest = requests.first else { return }

        UNUserNotificationCenter.current().add(firstRequest) { [weak self] _ in
            self?.queueNotificationRequests(Array(requests.dropFirst()))
        }
    }
}
