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

class WalletHomescreenActionView: UIView {
    // MARK: - API

    public var addQRCertificateTouchUpCallback: (() -> Void)?
    public var addPDFCertificateTouchUpCallback: (() -> Void)?

    // MARK: - Subviews

    private let stackView = UIStackView()

    private let addCertificateView = AddCertificateView()

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        setup()
        setupInteraction()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.axis = .vertical
        stackView.spacing = 2.0 * Padding.small

        stackView.addArrangedView(addCertificateView)
    }

    private func setupInteraction() {
        addCertificateView.addQRCertificateTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.addQRCertificateTouchUpCallback?()
        }

        addCertificateView.addPDFCertificateTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.addPDFCertificateTouchUpCallback?()
        }
    }
}

class AddCertificateView: UIView {
    // MARK: - API

    public var addQRCertificateTouchUpCallback: (() -> Void)?
    public var addPDFCertificateTouchUpCallback: (() -> Void)?

    // MARK: - Subviews

    private let topLabel = Label(.textBoldLarge)
    private let textLabel = Label(.text)

    private let qrButton = IconButton(text: UBLocalized.wallet_homescreen_qr_code_scannen, iconName: "ic-qrcode-scan")
    private let pdfButton = IconButton(text: UBLocalized.wallet_homescreen_pdf_import, iconName: "ic-pdf")

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        setup()
        setupInteraction()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = UIColor.cc_white
        layer.cornerRadius = 20
        ub_addShadow(radius: 10.0, opacity: 0.2, xOffset: 0.0, yOffset: 0.0)

        topLabel.text = UBLocalized.wallet_homescreen_add_title
        textLabel.text = UBLocalized.wallet_homescreen_add_certificate_description
        
        
        
        let lr = Padding.small + Padding.medium
        let tb = Padding.medium

        addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(UIEdgeInsets(top: tb, left: lr, bottom: tb, right: lr))
        }

        let lineView = UIView()
        lineView.backgroundColor = UIColor.cc_blueish

        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.top.equalTo(self.topLabel.snp.bottom).offset(tb)
            make.left.right.equalToSuperview()
            make.height.equalTo(1.0)
        }

        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(Padding.medium + 2.0)
            make.left.right.equalToSuperview().inset(lr)
        }

        addSubview(qrButton)
        qrButton.snp.makeConstraints { make in
            make.top.equalTo(textLabel.snp.bottom).offset(Padding.large)
            make.left.right.equalToSuperview().inset(lr / 2)
        }

        addSubview(pdfButton)
        pdfButton.snp.makeConstraints { make in
            make.top.equalTo(qrButton.snp.bottom).offset(Padding.medium + 2.0)
            make.left.right.equalToSuperview().inset(lr / 2)
            make.bottom.lessThanOrEqualToSuperview().inset(2.0 * Padding.medium)
        }

        accessibilityLabel = [topLabel.text, textLabel.text].compactMap { $0 }.joined(separator: ", ")
        setupAccessibilityIdentifiers()
    }
    
    private func setupAccessibilityIdentifiers() {
        topLabel.accessibilityIdentifier = "homescreen_options_overlay_add_certificate_options_title"
        textLabel.accessibilityIdentifier = "homescreen_options_overlay_add_certificate_options_text"
        qrButton.accessibilityIdentifier = "option_scan_certificate"
        pdfButton.accessibilityIdentifier = "option_import_pdf"
    }

    private func setupInteraction() {
        qrButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.addQRCertificateTouchUpCallback?()
        }

        pdfButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.addPDFCertificateTouchUpCallback?()
        }
    }
}

class IconButton: UBButton {
    // MARK: - Subviews

    private let textLabel = Label(.textBoldLarge)
    private let icon = UIImageView()

    // MARK: - Init

    init(text: String, iconName: String) {
        super.init()

        textLabel.text = text
        icon.image = UIImage(named: iconName)?.ub_image(with: .cc_green_dark).withRenderingMode(.alwaysOriginal)

        setup()
    }

    // MARK: - Setup

    private func setup() {
        highlightedBackgroundColor = UIColor.cc_touchState
        highlightCornerRadius = 10

        let lr = Padding.small + Padding.medium

        icon.contentMode = .scaleAspectFit

        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(lr / 2)
            make.top.bottom.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        textLabel.textColor = .cc_green_dark

        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(2 * Padding.small)
            make.centerY.equalToSuperview()
        }

        accessibilityLabel = textLabel.text
    }
}
