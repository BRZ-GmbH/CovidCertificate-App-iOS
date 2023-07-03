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
import UIKit

class CertificateDetailViewController: ViewController {
    private let certificate: UserCertificate

    private let stackScrollView = StackScrollView()
    private let qrCodeNameView = QRCodeNameView(shrinkCodeIfNecessary: false, reversed: false)
    private let dashedView = DashedLineView(style: .thin)

    private lazy var stateView = CertificateStateView(certificate: certificate, isHomescreen: false)
    private lazy var detailView = CertificateDetailView(certificate: certificate, showEnglishLabelsIfNeeded: true)

    private let removeButton = Button(title: UBLocalized.delete_button, style: .normal(.cc_red))

    private let brightnessQRScanning = BrightnessQRScanning()

    public var deinitCallback: (() -> Void)?

    private var state: VerificationResultStatus = .loading {
        didSet {
            update()
        }
    }

    init(certificate: UserCertificate) {
        self.certificate = certificate
        super.init()

        if case let .success(result) = certificate.decodedCertificate, result.healthCert.type == .vaccinationExemption {
            title = UBLocalized.wallet_certificate_vaccination_exemption.uppercased()
        } else {
            title = UBLocalized.wallet_certificate.uppercased()
        }
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupInteraction()

        addDismissButton()

        removeButton.accessibilityIdentifier = "certificate_detail_button_delete"

        // start check of certificate
        // also starts again when lists are updated
        UIStateManager.shared.addObserver(self) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.startCheck()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        brightnessQRScanning.isEnabled = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        brightnessQRScanning.isEnabled = false
    }

    // MARK: - Setup

    private func setup() {
        let isSmall = UIScreen.main.bounds.width <= 375

        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        let p = isSmall ? Padding.medium : Padding.large + Padding.medium
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0.0, left: p, bottom: 0.0, right: p)

        view.addSubview(stackScrollView)

        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackScrollView.addSpacerView(Padding.large)
        stackScrollView.addArrangedView(qrCodeNameView)

        stackScrollView.addSpacerView(Padding.small * 2.0)
        stackScrollView.addArrangedView(dashedView)

        qrCodeNameView.certificate = certificate

        stackScrollView.addSpacerView(Padding.small * 2.0)
        stackScrollView.addArrangedView(stateView)

        stackScrollView.addSpacerView(2.0 * Padding.large)
        stackScrollView.addArrangedView(detailView)

        stackScrollView.addSpacerView(2.0 * Padding.large + 2.0 * Padding.small)

        if case let .success(result) = certificate.decodedCertificate {
            stackScrollView.addArrangedView(CertificateNoteView(type: result.healthCert.type))
        } else {
            stackScrollView.addArrangedView(CertificateNoteView(type: nil))
        }

        stackScrollView.addSpacerView(3.0 * Padding.large + Padding.medium)
        stackScrollView.addArrangedViewCentered(removeButton)

        stackScrollView.addSpacerView(5.0 * Padding.large)

        update()
    }

    private func setupInteraction() {
        removeButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.removeCertificate()
        }
    }

    // MARK: - Check

    private func startCheck() {
        state = .loading
        VerifierManager.shared.addObserver(self, for: certificate, region: WalletUserStorage.shared.selectedValidationRegion ?? "W", important: true) { [weak self] state in
            guard let strongSelf = self else { return }
            strongSelf.state = state
        }
    }

    private func removeCertificate() {
        let alert = UIAlertController(title: nil, message: UBLocalized.wallet_certificate_delete_confirm_text, preferredStyle: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet)
        alert.addAction(UIAlertAction(title: UBLocalized.delete_button, style: .destructive, handler: { _ in
            CertificateStorage.shared.removeCertificate(userCertificate: self.certificate)
            (UIApplication.shared.delegate as? AppDelegate)?.notificationHandler.removeCertificate(self.certificate)
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: UBLocalized.cancel_button, style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    private func update() {
        stateView.state = state
        detailView.state = state
        qrCodeNameView.enabled = !state.isInvalid()
    }

    deinit {
        self.deinitCallback?()
        NotificationCenter.default.removeObserver(self)
    }
}
