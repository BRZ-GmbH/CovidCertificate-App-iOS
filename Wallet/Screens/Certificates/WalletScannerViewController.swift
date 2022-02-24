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

import CovidCertificateSDK
import Foundation

class WalletScannerViewController: ViewController {
    // MARK: - Subviews

    private let detailViewController = CertificateAddDetailViewController()

    private var qrView: QRScannerView?
    private var qrOverlay: WalletQRScannerFullOverlayView?

    private let backgroundView = RoundBackgroundView(backgroundColor: UIColor.cc_white, down: false)

    private let imageView = UIImageView(image: UIImage(named: "ic-scan-code"))
    private let explanationLabel = Label(.textBoldLarge, textAlignment: .center)
    private let moreInfoButton = SimpleTextButton(title: UBLocalized.wallet_scanner_info_button, color: .cc_green_dark)

    private var isLightOn: Bool = false
    private let lightButton = ScannerLightButton.walletButton()

    private var timer: Timer?

    private var cameraErrorView: CameraErrorView?
    private var shouldReadVisibleError = true

    // MARK: - Init

    override init() {
        super.init()
        title = UBLocalized.wallet_scanner_title.uppercased()
        navigationItem.accessibilityLabel = UBLocalized.wallet_scanner_title
        qrView = QRScannerView(delegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupInteraction()

        addDismissButton()

        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.startScanning()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopScanning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }

    private func setup() {
        if let qv = qrView {
            view.addSubview(qv)
            qv.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            let isSmall = UIScreen.main.bounds.width <= 320

            var additionalInset: CGFloat = 0.0
            if !isSmall {
                additionalInset = Padding.medium
            }

            qrOverlay = WalletQRScannerFullOverlayView(additionalInset: additionalInset)

            view.addSubview(qrOverlay!)
            qrOverlay?.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            cameraErrorView = CameraErrorView(backgroundColor: .cc_grey, center: false, isSmall: isSmall)
            view.addSubview(cameraErrorView!)
            cameraErrorView?.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            cameraErrorView?.alpha = 0.0
        }

        view.addSubview(backgroundView)

        backgroundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        backgroundView.addSubview(explanationLabel)
        backgroundView.addSubview(imageView)

        if qrView?.canEnableTorch ?? false {
            backgroundView.addSubview(lightButton)

            lightButton.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(Padding.medium)
                make.centerY.equalTo(self.backgroundView.snp.top)
            }
        }

        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Padding.small)
            make.centerX.equalToSuperview()
        }

        explanationLabel.text = UBLocalized.wallet_scanner_explanation
        
        explanationLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(2.0 * Padding.small)
            make.left.right.equalToSuperview().inset(Padding.large)
        }

        backgroundView.addSubview(moreInfoButton)

        moreInfoButton.snp.makeConstraints { make in
            make.top.equalTo(explanationLabel.snp.bottom).offset(Padding.small)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(Padding.medium)
            make.right.lessThanOrEqualToSuperview().offset(-Padding.medium)

            let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
            if bottomPadding > 0 {
                make.bottom.equalTo(self.view.snp.bottomMargin).inset(Padding.medium)
            } else {
                make.bottom.equalToSuperview().inset(Padding.medium)
            }
        }

        addSubviewController(detailViewController) { make in
            make.edges.equalToSuperview()
        }

        detailViewController.view.alpha = 0.0
        setupAccessibilityIdentifiers()
    }
    
    private func setupAccessibilityIdentifiers() {
        explanationLabel.accessibilityIdentifier = "qr_code_scanner_explanation"
        moreInfoButton.accessibilityIdentifier = "qr_code_scanner_button_how"
    }

    private func setupInteraction() {
        detailViewController.addOrOkCertificateTouchUpCallback = { [weak self] certificate in
            guard let strongSelf = self, let c = certificate else { return }

            CertificateStorage.shared.insertCertificate(userCertificate: c)
            strongSelf.dismiss(animated: true, completion: nil)
        }

        detailViewController.scanAgainTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.hideDetail()
        }

        moreInfoButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            let vc = BasicStaticContentViewController(models: [.howItWorks], title: UBLocalized.wallet_scanner_howitworks_header.uppercased(), contentViewType: .scannerHowTo)
            vc.presentInNavigationController(from: strongSelf)
        }

        lightButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.toggleLight()
        }
    }

    private func toggleLight() {
        isLightOn = !isLightOn
        qrView?.setCameraLight(on: isLightOn)
        lightButton.isOn = isLightOn
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundView.updatePath()
    }

    // MARK: - Show/hide

    private func startScanning() {
        /// We have to delay the announcement until VoiceOver starts to read the FirstResponder. Then we can queue our announcement.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            /// It takes about atleast 1.5 seconds to find the FirstResponder.
            UIAccessibility.post(notification: .announcement, argument: NSAttributedString(string: UBLocalized.accessibility_active_camera, attributes: [.accessibilitySpeechQueueAnnouncement: true]))
        }
        
        cameraErrorView?.alpha = 0.0
        qrView?.startScanning()
        qrView?.setCameraLight(on: isLightOn)

        showError(error: nil)
    }

    private func stopScanning() {
        timer?.invalidate()
        timer = nil
        qrView?.stopScanning()
        /// We have to delay the announcement until VoiceOver starts to read the FirstResponder. Then we can queue our announcement.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            /// It takes about atleast 1.5 seconds to find the FirstResponder.
            UIAccessibility.post(notification: .announcement, argument: NSAttributedString(string: UBLocalized.accessibility_in_active_camera, attributes: [.accessibilitySpeechQueueAnnouncement: true]))
        }
    }

    private func showDetail() {
        showError(error: nil)

        UIView.animate(withDuration: 0.25) {
            self.detailViewController.view.alpha = 1.0
        }

        detailViewController.view.accessibilityViewIsModal = true
        UIAccessibility.post(notification: .screenChanged, argument: detailViewController.view)
    }

    private func hideDetail() {
        UIView.animate(withDuration: 0.25) {
            self.detailViewController.view.alpha = 0.0
        } completion: { _ in
            self.detailViewController.certificate = nil
            self.startScanning()
        }

        detailViewController.view.accessibilityViewIsModal = false
        UIAccessibility.post(notification: .screenChanged, argument: view)
    }

    private func showError(error: CovidCertError?) {
        if error != nil {
            
            if shouldReadVisibleError, let errorText = qrOverlay?.errorView.errorLabel.text {
                shouldReadVisibleError.toggle()
                UIAccessibility.post(notification: .announcement, argument: errorText)
            }
            
            qrOverlay?.showErrorView(error: error, animated: true)

            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { [weak self] _ in
                guard let strongSelf = self else { return }
                UIView.animate(withDuration: 0.2) {
                    strongSelf.showError(error: nil)
                    strongSelf.shouldReadVisibleError.toggle()
                }
            })

        } else {
            qrOverlay?.showErrorView(error: error, animated: true)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension WalletScannerViewController: QRScannerViewDelegate {
    func qrScanningDidFail() {
        cameraErrorView?.alpha = 1.0
    }

    func qrScanningSucceededWithCode(_ str: String?) {
        if let s = str {
            let cert = UserCertificate(qrCode: s)
            
            switch cert.decodedCertificate {
            case .success:
                let feedback = UIImpactFeedbackGenerator(style: .heavy)
                feedback.impactOccurred()

                qrView?.stopScanning()

                detailViewController.certificate = cert
                showDetail()

            case let .failure(error):
                showError(error: error)
            }
        }
    }

    func qrScanningDidStop() {
        showError(error: nil)
    }
}
