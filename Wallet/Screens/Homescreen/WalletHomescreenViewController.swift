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
import MobileCoreServices

enum HomescreenState {
    case onboarding
    case certificates
}

class WalletHomescreenViewController: HomescreenBaseViewController {
    // MARK: - Screens

    private var state: HomescreenState = .onboarding {
        didSet {
            updateState(true)
        }
    }

    let onboardingViewController = HomescreenOnboardingViewController()
    let certificatesViewController = HomescreenCertificatesViewController()

    let bottomView = HomescreenBottomView()

    let addCertificateButton = Button(image: UIImage(named: "ic-add-certificate"), accessibilityName: UBLocalized.accessibility_add_button)
    private var actionViewIsShown = false

    let actionPopupView = WalletHomescreenActionPopupView()

    let documentPickerDelegate = DocumentPickerDelegate()
    var accessibilityViews = [UIView]()

    init() {
        super.init(color: .cc_green_dark)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        UIStateManager.shared.addObserver(self) { [weak self] s in
            guard let strongSelf = self else { return }
            strongSelf.state = s.certificateState.certificates.count == 0 ? .onboarding : .certificates
            
            strongSelf.regionSelectionButton.region = Region.regionFromString(WalletUserStorage.shared.selectedValidationRegion)
        }
        
        addCertificateButton.accessibilityIdentifier = "homescreen_scan_button_small"

        setupViews()
        setupInteraction()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Region.regionFromString(WalletUserStorage.shared.selectedValidationRegion) == nil {
            let vc = RegionSelectionViewController()
            vc.presentInNavigationController(from: self)
        }
    }

    // MARK: - Update

    private func updateState(_ animated: Bool) {
        let actions = {
            self.addCertificateButton.alpha = self.state == .onboarding ? 0.0 : 1.0

            self.certificatesViewController.view.alpha = self.state == .certificates ? 1.0 : 0.0
            self.onboardingViewController.view.alpha = self.state == .onboarding ? 1.0 : 0.0

            self.backgroundViewOffset = self.state == .certificates ? CGPoint(x: -Padding.large, y: 120.0) : .zero

            self.bottomView.state = self.state
        }

        if animated {
            UIView.animate(withDuration: 0.3) {
                actions()
            } completion: { _ in }
        } else {
            actions()
        }
    }

    // MARK: - Setup

    private func setupInteraction() {
        onboardingViewController.addQRCertificateTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            let vc = WalletScannerViewController()
            vc.presentInNavigationController(from: strongSelf)
        }

        onboardingViewController.addPDFCertificateTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.openDocumentFromPDF()
        }

        actionPopupView.addQRCertificateTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.changeAccessibilityStatus(isEnabled: true)
            strongSelf.actionPopupView.dismiss()
            strongSelf.addCertificateButton.changeAccessibilityTitle(title: UBLocalized.accessibility_add_button)

            let vc = WalletScannerViewController()
            vc.presentInNavigationController(from: strongSelf, preferFullscreenOnSmallDevice: true)
        }

        actionPopupView.addPDFCertificateTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.changeAccessibilityStatus(isEnabled: true)
            strongSelf.actionPopupView.dismiss()
            strongSelf.addCertificateButton.changeAccessibilityTitle(title: UBLocalized.accessibility_add_button)

            strongSelf.openDocumentFromPDF()
        }

        bottomView.faqButtonCallback = { [weak self] in
            guard let strongSelf = self else { return }

            let vc = BasicStaticContentViewController(models: ConfigManager.currentConfig?.viewModels ?? [], title: UBLocalized.wallet_faq_header.uppercased(), contentViewType: .faq)
            vc.presentInNavigationController(from: strongSelf)
        }

        bottomView.listButtonCallback = { [weak self] in
            guard let strongSelf = self else { return }
            let vc = CertificateListViewController()
            vc.presentInNavigationController(from: strongSelf)
        }

        addCertificateButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.actionViewIsShown {
                strongSelf.changeAccessibilityStatus(isEnabled: true)
                strongSelf.actionPopupView.dismiss()
                strongSelf.addCertificateButton.changeAccessibilityTitle(title: UBLocalized.accessibility_add_button)

            } else {
                strongSelf.setAccessibilityView(forView: strongSelf.view)

                strongSelf.addCertificateButton.changeAccessibilityTitle(title: UBLocalized.accessibility_close_button)
                strongSelf.changeAccessibilityStatus(isEnabled: false)
                strongSelf.actionPopupView.presentFrom(view: strongSelf.addCertificateButton)
            }
        }

        actionPopupView.showCallback = { [weak self] show in
            guard let strongSelf = self else { return }
            strongSelf.actionViewIsShown = show

            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseInOut]) {
                strongSelf.addCertificateButton.transform = CGAffineTransform(rotationAngle: show ? CGFloat.pi * 0.25 : 0.0)
            } completion: { _ in }

            UIAccessibility.post(notification: .layoutChanged, argument: show ? strongSelf.actionPopupView : nil)
        }

        settingsButtonCallback = { [weak self] in
            guard let strongSelf = self else { return }
            let vc = WalletSettingsViewController()
            vc.presentInNavigationController(from: strongSelf)
        }
        
        regionSelectionButtonCallback = { [weak self] in
            guard let strongSelf = self else { return }
            let vc = RegionSelectionViewController()
            vc.presentInNavigationController(from: strongSelf)
        }
        
        regionSelectionButtonCallback = { [weak self] in
            guard let strongSelf = self else { return }
            let vc = RegionSelectionViewController()
            vc.presentInNavigationController(from: strongSelf)
        }

        certificatesViewController.touchedCertificateCallback = { [weak self] cert in
            guard let strongSelf = self else { return }
            let vc = CertificateDetailViewController(certificate: cert)
            vc.presentInNavigationController(from: strongSelf)
        }
        
        /**
         In test builds (for Q as well as P environment) we support a double tap on the country flag to change the device time setting.
         This setting allows the app to either use the real time fetched from a time server (behaviour in the published app) or to use the current device time for validating the business rules.
         */
        #if RELEASE_ABNAHME || RELEASE_PROD_TEST
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleDeviceTimeSettings))
            tapGestureRecognizer.numberOfTapsRequired = 2
            logoView.isUserInteractionEnabled = true
            logoView.addGestureRecognizer(tapGestureRecognizer)
        #endif
    }
    
    private func changeAccessibilityStatus(isEnabled: Bool) {
        accessibilityViews.forEach({
            $0.isAccessibilityElement = isEnabled
        })
    }
    
    private func setAccessibilityView(forView: UIView) {
        guard accessibilityViews.isEmpty else { return }
        
        forView.recursiveSubviews.forEach({
            if $0.isAccessibilityElement {
                if let superView = $0.superview, !superView.isKind(of: AddCertificateView.self)
                    && $0 != addCertificateButton {
                    accessibilityViews.append($0)
                }
            }
        })
    }

    #if RELEASE_ABNAHME || RELEASE_PROD_TEST
    @objc private func toggleDeviceTimeSettings() {
        VerifierManager.shared.useDeviceTime = !VerifierManager.shared.useDeviceTime
        
        let alert = UIAlertController(title: VerifierManager.shared.useDeviceTime ? "Using Device Time" : "Using Real Time", message: VerifierManager.shared.useDeviceTime ? "The app now uses the current device time for Business Rule Validation" : "The app now uses the real time (fetched from NTP-Server) for Business Rule Validation", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    #endif
    
    private func setupViews() {
        addCertificateButton.ub_addShadow(radius: 4.0, opacity: 0.2, xOffset: 0.0, yOffset: 0.0)

        addSubviewController(onboardingViewController) { make in
            make.top.equalTo(self.logoView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }

        view.addSubview(bottomView)

        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }

        let isSmall = UIScreen.main.bounds.width <= 375
        
        addSubviewController(certificatesViewController) { make in
            make.top.equalTo(self.logoView.snp.bottom).offset(isSmall ? Padding.large : Padding.large + Padding.medium)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.bottomView.snp.top)
        }

        view.addSubview(actionPopupView)
        actionPopupView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(addCertificateButton)
        addCertificateButton.snp.makeConstraints { make in
            make.center.equalTo(self.bottomView.addButtonGuide.snp.center)
        }

        updateState(false)
    }

    private func openDocumentFromPDF() {
        let types: [String] = [kUTTypePDF as String]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentPicker.allowsMultipleSelection = false
        documentPicker.delegate = documentPickerDelegate
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true, completion: nil)
    }
}

class DocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {
    func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt url: [URL]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let firstURL = url.first else {
            return
        }
        appDelegate.importHandler?.handle(url: firstURL)
    }
}
