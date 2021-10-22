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

    private let qrCodeInset: CGFloat
    let qrCodeLayoutGuide = UILayoutGuide()

    // MARK: - Init

    init(qrCodeInset: CGFloat = 0) {
        self.qrCodeInset = qrCodeInset
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
            make.top.equalTo(self.imageView.snp.bottom).offset(Padding.medium)
            make.leading.trailing.equalToSuperview().inset(self.qrCodeInset)
        }

        birthdayLabelView.snp.makeConstraints { make in
            make.top.equalTo(self.nameView.snp.bottom).offset(Padding.small)
            make.leading.trailing.equalToSuperview().inset(self.qrCodeInset)
            make.bottom.equalToSuperview()
        }

        nameView.ub_setContentPriorityRequired()
        birthdayLabelView.ub_setContentPriorityRequired()
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
}
