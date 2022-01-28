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
import UIKit
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
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

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Pre-populate isFirstLaunch for users which already installed the app before we introduced this flag
        if WalletUserStorage.shared.hasCompletedOnboarding {
            isFirstLaunch = false
        }

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
        
        UIStateManager.shared.addObserver(self) { [weak self] s in
            self?.queueCertificateNotificationChecks()
        }
    
        return true
    }
    
    private var certificateNotificationCheckTimer: Timer? = nil
    
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
            guard let self = self else { return }
            
            guard let config = ConfigManager.currentConfig else { return }
            guard let time = VerifierManager.shared.currentTime else {
                self.queueCertificateNotificationChecks()
                return
            }
            
            let certLogicValueSets = CovidCertificateSDK.currentValueSets().mapValues { $0.valueSetValues.map { $0.key } }
            
            self.notificationHandler.startCertificateNotificationCheck(window: self.window, certificates: UIStateManager.shared.uiState.certificateState.certificates, valueSets: certLogicValueSets, validationClock: time, config: config)
        }
    }

    func application(_: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    {
        if let url = userActivity.webpageURL {
            return linkHandler.handle(url: url)
        }
        return false
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
        CovidCertificateSDK.restartTrustListUpdate(force: backgroundTime == 0, completionHandler: { [weak self] wasUpdated, failed in
            if wasUpdated {
                VerifierManager.shared.restartAllVerifiers()
            }
            self?.hasUpdatedValueSetData = true
            self?.queueCertificateNotificationChecks()
            UIStateManager.shared.stateChanged(forceRefresh: wasUpdated)                       
        })
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
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
