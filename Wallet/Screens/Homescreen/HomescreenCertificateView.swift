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

class HomescreenCertificateView: UIView {
    public var touchUpCallback: (() -> Void)?

    // MARK: - Inset

    public static let inset: CGFloat = 6.0

    private let titleLabel = Label(.uppercaseBold, textColor: .cc_greyText, textAlignment: .center)

    private let nameView = QRCodeNameView(qrCodeInset: Padding.large)
    private let dashedView = DashedLineView(style: .thin)
    private let contentView = UIView()

    // private let stateLabel = HomescreenStateLabel()
    private let stateView = CertificateStateView()

    public let certificate: UserCertificate

    public var state: VerificationResultStatus = .loading {
        didSet {
            stateView.states = (state, .idle)
            update(animated: true)
        }
    }

    // MARK: - Subviews

    init(certificate: UserCertificate) {
        self.certificate = certificate
        super.init(frame: .zero)
        setup()

        isAccessibilityElement = true
        accessibilityTraits = [.button]
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let shadowRadius: CGFloat = 20.0
        let shadowOpacity: CGFloat = 0.17

        contentView.backgroundColor = .white
        contentView.ub_addShadow(radius: shadowRadius, opacity: shadowOpacity, xOffset: 0.0, yOffset: 2.0)
        contentView.layer.cornerRadius = 20.0
        addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(HomescreenCertificateView.inset)
        }

        contentView.addSubview(titleLabel)
        titleLabel.ub_setContentPriorityRequired()

        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(Padding.large)
        }

        contentView.addSubview(nameView)
        // contentView.addSubview(stateLabel)

        nameView.snp.makeConstraints { make in
            // make.top.equalTo(self.stateLabel.snp.bottom).offset(Padding.medium)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(Padding.medium)
            make.left.right.equalToSuperview().inset(Padding.large)
        }   

        titleLabel.text = UBLocalized.wallet_certificate
        nameView.certificate = certificate

        /* stateLabel.snp.makeConstraints { make in
             make.top.equalTo(self.titleLabel.snp.bottom).offset(Padding.medium)
             make.left.greaterThanOrEqualToSuperview().inset(2.0 * Padding.small)
             make.right.lessThanOrEqualToSuperview().inset(2.0 * Padding.small)
             make.centerX.equalToSuperview()
         }

         let c = CovidCertificateSDK.decode(encodedData: certificate.qrCode)
         switch c {
         case let .success(holder):
             stateLabel.certificate = holder.healthCert
         default: break
         } */
        
        contentView.addSubview(dashedView)
        dashedView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Padding.large)
            make.right.equalToSuperview().offset(-Padding.large)
            make.top.equalTo(nameView.snp.bottom).offset(2.0 * Padding.small)
            make.height.equalTo(1)
        }

        contentView.addSubview(stateView)
        stateView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(dashedView.snp.bottom).offset(2.0 * Padding.small)
            make.bottom.left.right.equalToSuperview().inset(2.0 * Padding.small)
        }

        // disable user interaction
        for v in contentView.subviews {
            v.isUserInteractionEnabled = false
        }

        // add button at bottom
        let v = UBButton()
        contentView.insertSubview(v, at: 0)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.layer.cornerRadius = contentView.layer.cornerRadius
        v.backgroundColor = .clear
        v.highlightedBackgroundColor = UIColor.cc_touchState

        v.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.touchUpCallback?()
        }

        update(animated: false)
    }

    private func update(animated _: Bool) {
        let isInvalid = state.isInvalid()
        nameView.enabled = !isInvalid

        accessibilityLabel = [titleLabel.text, nameView.accessibilityLabel, stateView.accessibilityLabel].compactMap { $0 }.joined(separator: ", ")

        // stateLabel.enabled = !isInvalid
    }
}

class HomescreenStateLabel: StateLabel {
    init() {
        super.init(labelType: .uppercaseBold)
    }
}

class HomescreenStateLabel: StateLabel {
    init() {
        super.init(labelType: .uppercaseBold)
    }
}
