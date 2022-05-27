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

    private let nameView = QRCodeNameView(qrCodeInset: Padding.large, shrinkCodeIfNecessary: true, reversed: true)
    private let dashedView = DashedLineView(style: .thin)
    private let contentView = UIView()
    private let informationContentView = UIView()
    private let stackScrollView = StackScrollView(axis: .vertical, spacing: 15)


    // private let stateLabel = HomescreenStateLabel()
    private lazy var stateView = {
        return CertificateStateView(certificate: certificate, isHomescreen: true)
    }()

    public let certificate: UserCertificate

    public var state: VerificationResultStatus = .loading {
        didSet {
            stateView.state = state
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
        accessibilityHint = UBLocalized.accessibility_detail_certificate
        setupAccessibilityIdentifiers()
    }
    
    private func setupAccessibilityIdentifiers() {
        accessibilityIdentifier = "certificate_page_main_group"
        titleLabel.accessibilityIdentifier = "certificate_page_title"
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
        
        contentView.addSubview(informationContentView)
        contentView.addSubview(stackScrollView)

        stackScrollView.addArrangedView(titleLabel)
        stackScrollView.addArrangedView(nameView)

        let isSmall = UIScreen.main.bounds.width <= 375
        
        stackScrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(isSmall ? Padding.medium - HomescreenCertificateView.inset : Padding.large - HomescreenCertificateView.inset)
            make.top.equalToSuperview().offset(Padding.medium)
        }

        stackScrollView.clipsToBounds = true
        stackScrollView.scrollView.clipsToBounds = true
        stackScrollView.stackView.clipsToBounds = true
        stackScrollView.scrollView.bounces = true
        stackScrollView.scrollView.alwaysBounceVertical = false
        stackScrollView.scrollView.showsVerticalScrollIndicator = true
        stackScrollView.scrollView.flashScrollIndicators()
        
        contentView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(HomescreenCertificateView.inset)
        }
        
        informationContentView.snp.makeConstraints { make in
            make.top.equalTo(stackScrollView.snp.bottom).offset(Padding.small)
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(HomescreenCertificateView.inset)
        }
       
        if case let .success(result) = certificate.decodedCertificate, result.healthCert.type == .vaccinationExemption {
            titleLabel.text = UBLocalized.wallet_certificate_vaccination_exemption
        } else {
            titleLabel.text = UBLocalized.wallet_certificate
        }
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingMiddle
        nameView.certificate = certificate

        informationContentView.addSubview(dashedView)
        dashedView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(isSmall ? Padding.medium : Padding.large)
            make.right.equalToSuperview().offset(isSmall ? -Padding.medium : -Padding.large)
            make.top.equalToSuperview().offset(2.0 * Padding.small)
            make.height.equalTo(1)
        }

        informationContentView.addSubview(stateView)
        stateView.snp.makeConstraints { make in
            make.top.equalTo(dashedView.snp.bottom).offset(2.0 * Padding.small)
            make.bottom.equalToSuperview().inset(isSmall ? HomescreenCertificateView.inset : 2.0 * Padding.small)
            make.left.right.equalToSuperview().inset(isSmall ? 0 : 2.0 * Padding.small)
        }

        // disable user interaction except for the stackScrollView
        for v in contentView.subviews.filter({ $0 != stackScrollView }) {
            v.isUserInteractionEnabled = false
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(performTap))
        addGestureRecognizer(tap)
        
        update(animated: false)
    }
    
    @objc private func performTap() {
        touchUpCallback?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameView.updateLayout()
    }
    
    private func update(animated _: Bool) {
        let isInvalid = state.isInvalid()
        nameView.enabled = !isInvalid
        nameView.updateLayout()

        accessibilityLabel = [titleLabel.text, nameView.accessibilityLabel, stateView.accessibilityLabel].compactMap { $0 }.joined(separator: ", ")

        // stateLabel.enabled = !isInvalid
    }
}

class HomescreenStateLabel: StateLabel {
    init() {
        super.init(labelType: .uppercaseBold)
    }
}
