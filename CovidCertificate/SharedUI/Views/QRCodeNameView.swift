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
import UIKit

class QRCodeNameView: UIView {
    // MARK: - Public API

    public var certificate: UserCertificate? {
        didSet { update() }
    }

    public var enabled: Bool = true {
        didSet { alpha = enabled ? 1.0 : UIColor.cc_disabledAlpha }
    }

    // MARK: - Subviews

    private let imageView = UIImageView()
    private let nameView = Label(.title, textAlignment: .center)
    private let birthdayLabelView = Label(.textSmall, textAlignment: .center)

    private let isHomescreen: Bool
    
    private let qrCodeInset: CGFloat
    let qrCodeLayoutGuide = UILayoutGuide()
    private let shrinkCodeIfNecessary: Bool
    private let reversed: Bool

    // MARK: - Init

    init(qrCodeInset: CGFloat = 0, shrinkCodeIfNecessary: Bool, reversed: Bool) {
        self.qrCodeInset = qrCodeInset
        self.shrinkCodeIfNecessary = shrinkCodeIfNecessary
        self.reversed = reversed
        self.isHomescreen = reversed
        super.init(frame: .zero)
        setup()

        isAccessibilityElement = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        addSubview(imageView)
        addSubview(nameView)
        addSubview(birthdayLabelView)

        if reversed {
            nameView.snp.makeConstraints { make in
                let isSmall = UIScreen.main.bounds.width <= 375
                
                make.top.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(self.qrCodeInset)
            }

            birthdayLabelView.snp.makeConstraints { make in
                make.top.equalTo(self.nameView.snp.bottom).offset(Padding.small)
                make.leading.trailing.equalToSuperview().inset(self.qrCodeInset)
            }
            
            
            imageView.snp.makeConstraints { make in
                make.top.equalTo(self.birthdayLabelView.snp.bottom).offset(Padding.medium)
                make.centerX.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(self.qrCodeInset).priority(.medium)
                make.trailing.lessThanOrEqualToSuperview().inset(self.qrCodeInset)
                make.leading.greaterThanOrEqualToSuperview().inset(self.qrCodeInset)
                make.width.equalTo(self.imageView.snp.height)
                make.bottom.equalToSuperview()
            }

            addLayoutGuide(qrCodeLayoutGuide)
            qrCodeLayoutGuide.snp.makeConstraints { make in
                make.edges.equalTo(imageView)
            }
        } else {
            imageView.snp.makeConstraints { make in
                make.top.centerX.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(self.qrCodeInset).priority(.medium)
                make.trailing.lessThanOrEqualToSuperview().inset(self.qrCodeInset)
                make.leading.greaterThanOrEqualToSuperview().inset(self.qrCodeInset)
                make.width.equalTo(self.imageView.snp.height)
            }

            addLayoutGuide(qrCodeLayoutGuide)
            qrCodeLayoutGuide.snp.makeConstraints { make in
                make.edges.equalTo(imageView)
            }

            nameView.snp.makeConstraints { make in
                let isSmall = UIScreen.main.bounds.width <= 375
                
                make.top.equalTo(self.imageView.snp.bottom).offset(isSmall ? Padding.small : Padding.medium)
                make.leading.trailing.equalToSuperview().inset(self.qrCodeInset)
            }

            birthdayLabelView.snp.makeConstraints { make in
                make.top.equalTo(self.nameView.snp.bottom).offset(Padding.small)
                make.leading.trailing.equalToSuperview().inset(self.qrCodeInset)
                make.bottom.equalToSuperview()
            }
        }
        nameView.ub_setContentPriorityRequired()
        birthdayLabelView.ub_setContentPriorityRequired()
        
        setupAccessibilityIdentifiers()
    }
    
    private func setupAccessibilityIdentifiers() {
        if isHomescreen {
            imageView.accessibilityIdentifier = "certificate_page_qr_code"
            nameView.accessibilityIdentifier = "certificate_page_name"
            birthdayLabelView.accessibilityIdentifier = "certificate_page_birthdate"
        } else {
            imageView.accessibilityIdentifier = "certificate_detail_qr_code"
            nameView.accessibilityIdentifier = "certificate_detail_name"
            birthdayLabelView.accessibilityIdentifier = "certificate_detail_birthdate"
        }
    }

    // MARK: - Update

    private func update() {
        guard let cert = certificate else { return }

        switch cert.decodedCertificate {
        case let .success(holder):
            nameView.text = holder.healthCert.displayFullName
            birthdayLabelView.text = holder.healthCert.displayBirthDate
        case .failure:
            break
        }

        imageView.setQrCode(cert.qrCode)

        accessibilityLabel = [imageView.accessibilityLabel, nameView.text, birthdayLabelView.text].compactMap { $0 }.joined(separator: ", ")
    }
    
    override var frame: CGRect {
        didSet {
            updateLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    /// Some Devices with Large text can't show the full QRCode
    /// Check if the QRCodeImageView is greater than the StackScrollView
    func updateLayout() {
        /// First Superview: StackView.
        /// Second Superview: ContentView.
        /// Third  Superview: StackScrollView
        
        guard shrinkCodeIfNecessary else { return }
        
        guard (self.superview?.frame.height ?? 0) > 0 else { return }
        
        guard let scrollViewContentWidth = self.superview?.frame.width,
              let containerHeight = self.superview?.superview?.superview?.frame.height else { return }
        
        // Attempt to make ImageView small enough to fix all content without scrolling, but do not shrink below 80 pt
        let optimalImageHeight = floor(fmin(fmax(containerHeight - 20, 80), scrollViewContentWidth - 32))
        
        // Determine the remaining height for a fully visible QR code image (subtract padding that is applied to the StackView and 10pt extra room
        let fullyVisibleHeight = floor(fmin(scrollViewContentWidth - 32, containerHeight - birthdayLabelView.frame.maxY - Padding.medium * 3 - 10) - (UIDevice.current.userInterfaceIdiom == .pad ? 32 : 0))
        
        let imageHeight = (fullyVisibleHeight > scrollViewContentWidth * 0.6 && (fullyVisibleHeight < scrollViewContentWidth - 32)) ? fullyVisibleHeight : optimalImageHeight
        
        /// Remake the Constraints when the ImageView is greater
        imageView.snp.remakeConstraints { make in
            if reversed {
                make.top.equalTo(self.birthdayLabelView.snp.bottom).offset(Padding.medium)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview()
            } else {
                make.top.centerX.equalToSuperview()
            }
            make.height.equalTo(imageHeight)
            make.width.equalTo(imageHeight)
        }
    }
}
