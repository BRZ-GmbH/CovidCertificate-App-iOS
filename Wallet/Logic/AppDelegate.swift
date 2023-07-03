/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import BackgroundTasks
import StoreKit
import UIKit
import StoreKit
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    #if RELEASE_PROD || RELEASE_PROD_TEST
        static let backgroundTaskInterval: TimeInterval = 60 * 60 * 8
    #else
        static let backgroundTaskInterval: TimeInterval = 60 * 60 * 1
    #endif

    internal var window: UIWindow?
    private var lastForegroundActivity: Date?
    private var blurView: UIVisualEffectView?
    private(set) var importHandler: ImportHandler?

    private let screenProtecter = ScreenProtector()

    @UBUserDefault(key: "isFirstLaunch", defaultValue: true)
    var isFirstLaunch: Bool

    private var isHandlingImport = false

    private let linkHandler = LinkHandler()

    var notificationHandler: NotificationHandler!

    lazy var navigationController = NavigationController(rootViewController: WalletHomescreenViewController())

    private var hasUpdatedConfig = false
    private var hasUpdatedValueSetData = false

    private var campaignIdToOpenFromNotification: String?
    private var campaignTimestampKeyFromNotification: String?

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Pre-populate isFirstLaunch for users which already installed the app before we introduced this flag
        if WalletUserStorage.shared.hasCompletedOnboarding {
            isFirstLaunch = false
        }
        UNUserNotificationCenter.current().delegate = self

        // Reset keychain on first launch
        if isFirstLaunch {
            Keychain().deleteAll()
            isFirstLaunch = false
        }

        notificationHandler = NotificationHandler()

        VerifierManager.shared.resetTime()

        CovidCertificateSDK.initialize(environment: Environment.current.sdkEnvironment, apiKey: Environment.current.appToken)

        // defer window initialization if app was launched in
        // background because of location change
        if shouldSetupWindow(application: application, launchOptions: launchOptions) {
            setupWindow()
            willAppearAfterColdstart(application, coldStart: true, backgroundTime: 0)
        }

        if let launchOptions = launchOptions,
           let activityType = launchOptions[UIApplication.LaunchOptionsKey.userActivityType] as? String,
           activityType == NSUserActivityTypeBrowsingWeb,
           let url = launchOptions[UIApplication.LaunchOptionsKey.url] as? URL {
            linkHandler.handle(url: url)
        }

        #if RELEASE_ABNAHME || RELEASE_PROD_TEST
        #else
            screenProtecter.startPreventingRecording()
        #endif

        UIStateManager.shared.addObserver(self) { [weak self] _ in
            self?.queueCertificateNotificationChecks()
            VerifierManager.shared.restartAllVerifiers()
        }

        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            if #available(iOS 13.0, *) {
                BGTaskScheduler.shared.register(forTaskWithIdentifier: "\(bundleIdentifier).refresh", using: nil) { task in
                    self.handleAppRefresh(task: task as! BGAppRefreshTask)
                }
            } else {}
        }

        return true
    }

    @available(iOS 13.0, *)
    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()

        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        CovidCertificateSDK.restartTrustListUpdate(force: false, completionHandler: { wasUpdated, failed in
            if failed {
                Logger.log("Background Data Update - Failed", appState: false)
            } else {
                if wasUpdated {
                    Logger.log("Background Data Update - New Data", appState: false)
                } else {
                    Logger.log("Background Data Update - Unchanged", appState: false)
                }
            }
            ConfigManager().startConfigRequest(force: false, window: nil, showForceUpdateDialogIfNecessary: false) { [weak self] in
                self?.checkForCertificateCampaignsToQueueAndDisplay()
                task.setTaskCompleted(success: failed == false)
            }
        })
    }

    func scheduleAppRefresh() {
        if #available(iOS 13.0, *) {
            if let bundleIdentifier = Bundle.main.bundleIdentifier {
                let request = BGAppRefreshTaskRequest(identifier: "\(bundleIdentifier).refresh")
                request.earliestBeginDate = Date(timeIntervalSinceNow: AppDelegate.backgroundTaskInterval)
                do {
                    BGTaskScheduler.shared.cancelAllTaskRequests()
                    try BGTaskScheduler.shared.submit(request)
                } catch {}
            }
        }
    }

    private var certificateNotificationCheckTimer: Timer?

    func didCompleteOnboarding() {
        queueCertificateNotificationChecks()
    }

    private func queueCertificateNotificationChecks() {
        certificateNotificationCheckTimer?.invalidate()
        certificateNotificationCheckTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.certificateNotificationCheckTimer = nil
            self?.checkForCertificateCampaigns()
        }
    }

    private func checkForCertificateCampaigns() {
        guard hasUpdatedConfig else { return }
        guard hasUpdatedValueSetData else { return }
        guard !isHandlingImport else { return }
        guard WalletUserStorage.shared.hasCompletedOnboarding else { return }

        notificationHandler.checkForExpiredTestCertificates(window: window, UIStateManager.shared.uiState.certificateState.certificates) { [weak self] hasRemovedCertificates in
            guard !hasRemovedCertificates else { return }

            self?.checkForCertificateCampaignsToQueueAndDisplay()
        }
    }

    private func checkForCertificateCampaignsToQueueAndDisplay() {
        guard let config = ConfigManager.currentConfig else { return }
        guard let time = VerifierManager.shared.currentTime else {
            if UIApplication.shared.applicationState != .background {
                queueCertificateNotificationChecks()
            }
            return
        }

        let certLogicValueSets = CovidCertificateSDK.currentValueSets().mapValues { $0.valueSetValues.map { $0.key } }

        let campaignCheckResult = notificationHandler.startCertificateNotificationCheck(window: window, certificates: UIStateManager.shared.uiState.certificateState.certificates, valueSets: certLogicValueSets, validationClock: time, config: config)

        if NotificationService.shared.hasDeterminedNotificationPermission, campaignIdToOpenFromNotification == nil {
            if UIApplication.shared.applicationState == .background && NotificationService.shared.canDisplayLocalNotifications {
                NotificationService.shared.updateLocalNotificationsForCampaignCheckResult(campaignCheckResult, excludingVisibleCampaignTimestampKey: campaignTimestampKeyFromNotification)
            } else if UIApplication.shared.applicationState == .active {
                if NotificationService.shared.canDisplayLocalNotifications {
                    if CertificateStorage.shared.hasModifiedCertificatesInSession {
                        NotificationService.shared.getCampaignTimestampKeysFromDeliveredLocalNotifications { [weak self] deliveredCampaignTimestampKeys in
                            guard let self = self else { return }
                            self.notificationHandler.displayCampaignsForCheckResult(campaignCheckResult, window: self.window, excludingCampaignsWithTimestampKeys: deliveredCampaignTimestampKeys)
                        }
                    } else {
                        NotificationService.shared.updateLocalNotificationsForCampaignCheckResult(campaignCheckResult, excludingVisibleCampaignTimestampKey: campaignTimestampKeyFromNotification)
                    }
                } else {
                    notificationHandler.displayCampaignsForCheckResult(campaignCheckResult, window: window)
                }
            }
        }
    }

    func application(_: UIApplication, continue userActivity: NSUserActivity, restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }

        let linkType = linkHandler.handle(urlComponents: components)
        return handleLinkType(url: url, urlComponents: components, linkType: linkType)
    }

    func handleLinkType(url: URL, urlComponents _: URLComponents, linkType: WalletAppLinkType) -> Bool {
        guard let viewController = navigationController.viewControllers.first as? WalletHomescreenViewController else {
            return false
        }

        switch linkType {
        case let .directLink(secret: secret, signature: signature):
            viewController.addCertificateDirectly(url: url, secret: secret, signature: signature)
            return true
        case let .directLinkWithBpt(secret: secret, signature: signature, bpt: bpt):
            viewController.addCertificateDirectlyWithBpt(url: url, secret: secret, secretSignature: signature, bpt: bpt)
            return true
        case let .directQRCode(data: qrCode):
            viewController.addCertificate(qrCode: qrCode)
            return true
        case .none:
            viewController.invalidLinkError()
            return false
        }
    }

    private func shouldSetupWindow(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if application.applicationState == .background {
            return false
        }

        guard let launchOptions = launchOptions else {
            return true
        }

        let backgroundOnlyKeys: [UIApplication.LaunchOptionsKey] = [.location]

        for k in backgroundOnlyKeys {
            if launchOptions.keys.contains(k) {
                return false
            }
        }

        return true
    }

    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKey()
        window?.rootViewController = navigationController

        setupAppearance()

        window?.makeKeyAndVisible()

        if !WalletUserStorage.shared.hasCompletedOnboarding {
            // show onboarding
            let onboardingViewController = OnboardingViewController()
            onboardingViewController.modalPresentationStyle = .fullScreen
            window?.rootViewController?.present(onboardingViewController, animated: false)
        } else if ConfigManager.shortAppVersion != WalletUserStorage.lastInstalledAppVersion, Intro.hasAvailableIntro {
            // show Intro
            let introViewController = IntroViewController()
            introViewController.modalPresentationStyle = .fullScreen
            window?.rootViewController?.present(introViewController, animated: false)
        } else {
            if ConfigManager.shortAppVersion != WalletUserStorage.lastInstalledAppVersion {
                if WalletUserStorage.hasAskedForStoreReview == false {
                    WalletUserStorage.hasAskedForStoreReview = true

                    DispatchQueue.main.async {
                        if #available(iOS 14.0, *) {
                            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene {
                                SKStoreReviewController.requestReview(in: windowScene)
                            } else {
                                SKStoreReviewController.requestReview()
                            }
                        } else {
                            SKStoreReviewController.requestReview()
                        }
                    }
                }
            }
            WalletUserStorage.lastInstalledAppVersion = ConfigManager.shortAppVersion
        }

        setupImportHandler()
    }

    private func willAppearAfterColdstart(_: UIApplication, coldStart: Bool, backgroundTime: TimeInterval) {
        VerifierManager.shared.updateTime()

        if !coldStart {
            UIStateManager.shared.stateChanged(forceRefresh: true)
        }

        // Refresh trust list (public keys, revocation list, business rules,...)
        VerifierManager.shared.isSyncingData = true
        CovidCertificateSDK.restartTrustListUpdate(force: backgroundTime == 0, completionHandler: { [weak self] wasUpdated, failed in
            if failed {
                Logger.log("\(backgroundTime == 0 ? "Forced " : "")Data Update - Failed", appState: false)
            } else {
                if wasUpdated {
                    Logger.log("\(backgroundTime == 0 ? "Forced " : "")Data Update - New Data", appState: false)
                } else {
                    Logger.log("\(backgroundTime == 0 ? "Forced " : "")Data Update - Unchanged", appState: false)
                }
            }

            VerifierManager.shared.isSyncingData = false
            self?.hasUpdatedValueSetData = true
            self?.queueCertificateNotificationChecks()
            UIStateManager.shared.stateChanged(forceRefresh: wasUpdated)
        })
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        campaignIdToOpenFromNotification = nil
        campaignTimestampKeyFromNotification = nil

        CertificateStorage.shared.hasModifiedCertificatesInSession = false
        lastForegroundActivity = Date()

        // App should not have badges
        // Reset to 0 to ensure a unexpected badge doesn't stay forever
        application.applicationIconBadgeNumber = 0

        addBlurView()
        VerifierManager.shared.resetTime()

        notificationHandler.dismissAlert()

        isHandlingImport = false

        hasUpdatedConfig = false
        hasUpdatedValueSetData = false

        scheduleAppRefresh()
    }

    func applicationDidBecomeActive(_: UIApplication) {
        removeBlurView()

        // Refresh config
        let backgroundTime = -(lastForegroundActivity?.timeIntervalSinceNow ?? 0)
        ConfigManager().startConfigRequest(force: backgroundTime == 0, window: window, showForceUpdateDialogIfNecessary: isHandlingImport == false) { [weak self] in
            self?.didUpdateConfig()
        }
    }

    func didUpdateConfig() {
        hasUpdatedConfig = true
        queueCertificateNotificationChecks()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // If window was not initialized (e.g. app was started cause
        // by a location change), we need to do that
        if window == nil {
            setupWindow()
            willAppearAfterColdstart(application, coldStart: true, backgroundTime: 0)
        } else {
            let backgroundTime = -(lastForegroundActivity?.timeIntervalSinceNow ?? 0)
            willAppearAfterColdstart(application, coldStart: false, backgroundTime: backgroundTime)
            application.applicationIconBadgeNumber = 0
        }
    }

    // MARK: - Appearance

    private func setupAppearance() {
        UIBarButtonItem.appearance().tintColor = .cc_text

        UINavigationBar.appearance().titleTextAttributes = [
            .font: LabelType.textBold.font,
            .foregroundColor: UIColor.cc_greyText,
            .kern: LabelType.button.letterSpacing ?? 0.0,
        ]

        UIPageControl.appearance().pageIndicatorTintColor = .cc_black
        UIPageControl.appearance().currentPageIndicatorTintColor = .cc_white
    }

    // MARK: - Hide information on app switcher

    private func removeBlurView() {
        UIView.animate(withDuration: 0.15) {
            self.blurView?.effect = nil
            self.blurView?.alpha = 0.0
        } completion: { _ in
            self.blurView?.removeFromSuperview()
            self.blurView = nil
        }
    }

    private func addBlurView() {
        blurView?.removeFromSuperview()

        let bv = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        bv.frame = window?.frame ?? .zero
        bv.isUserInteractionEnabled = false
        window?.addSubview(bv)

        blurView = bv
    }

    func didFinishImport() {
        isHandlingImport = false
    }

    private func handleTapOnCampaignNotification(_ campaignId: String, title: String, message: String, timestampKey: String) {
        guard let campaign = ConfigManager.currentConfig?.campaigns?.first(where: { $0.id == campaignId }) else { return }

        campaignIdToOpenFromNotification = campaignId
        campaignTimestampKeyFromNotification = timestampKey

        DispatchQueue.main.asyncAfter(deadline: .now() + (UIApplication.shared.applicationState == .active ? 0 : 1)) { [weak self] in
            self?.notificationHandler.presentAlertForCampaign(campaign, title: title, message: message, window: self?.window, timestampKey: timestampKey, certificateHash: nil, autoCloseOnUpdates: false) { [weak self] in
                self?.campaignIdToOpenFromNotification = nil
                self?.campaignTimestampKeyFromNotification = nil
                self?.queueCertificateNotificationChecks()
            }
        }
    }
}

extension AppDelegate {
    private func setupImportHandler() {
        guard let delegate = window?.rootViewController as? NavigationController else {
            return
        }

        importHandler = ImportHandler(delegate: delegate)
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        guard WalletUserStorage.shared.hasCompletedOnboarding else {
            return false
        }

        isHandlingImport = true
        importHandler?.handle(url: url)

        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            if let campaignId = response.notification.request.content.userInfo["campaignId"] as? String,
               let timestampKey = response.notification.request.content.userInfo["campaignTimestampKey"] as? String {
                handleTapOnCampaignNotification(campaignId, title: response.notification.request.content.title, message: response.notification.request.content.body, timestampKey: timestampKey)
            }
        } else if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            if let campaignId = response.notification.request.content.userInfo["campaignId"] as? String,
               let timestampKey = response.notification.request.content.userInfo["campaignTimestampKey"] as? String,
               let campaign = ConfigManager.currentConfig?.campaigns?.first(where: { $0.id == campaignId }) {
                notificationHandler.dismissCampaignNotificationForCampaign(campaign, timestampKey: timestampKey)
            }
        }
        completionHandler()
    }
}
