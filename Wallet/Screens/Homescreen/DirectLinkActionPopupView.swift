//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 * Copyright (c) 2021 BRZ GmbH <https://www.brz.gv.at>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation
import UIKit

/**
 Displays the popup view for the direct link, which includes a date picker for the birthday
  */
class DirectLinkActionPopupView: PopupView {
    // MARK: - Subviews

    private let stackView = UIStackView()
    private let getCertificateView = DirectLinkCertificateView()

    // MARK: - API

    public var addCertificateTouchUpCallback: ((_ birthday: Date?) -> Void)?
    public var cancelTouchUpCallback: (() -> Void)?

    // MARK: - Setup

    override func setup() {
        super.setup()

        setupLayout()
        setupInteraction()
    }

    private func setupLayout() {
        contentView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(5.0 * Padding.large + Padding.medium)
            make.left.right.equalToSuperview().inset(Padding.large)
        }

        contentView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        stackView.axis = .vertical
        stackView.spacing = 2.0 * Padding.small

        stackView.addArrangedView(getCertificateView)
    }

    private func setupInteraction() {
        getCertificateView.addCertificateTouchUpCallback = { [weak self] date in
            guard let strongSelf = self else { return }
            strongSelf.dismiss()
            strongSelf.addCertificateTouchUpCallback?(date)
        }

        getCertificateView.cancelTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismiss()
            strongSelf.cancelTouchUpCallback?()
        }
    }
}

class DirectLinkCertificateView: UIView {
    // MARK: - API

    public var addCertificateTouchUpCallback: ((_ birthday: Date?) -> Void)?
    public var cancelTouchUpCallback: (() -> Void)?

    // MARK: - Subviews

    private let topLabel = Label(.textBoldLarge)
    private let textLabel = Label(.text)

    private let datePicker = UIDatePicker()

    private let cancelButton = SimpleTextButton(title: UBLocalized.cancel_button, color: .cc_grey, font: LabelType.textLarge.font)
    private let addButton = SimpleTextButton(title: UBLocalized.retrieve_certificate, font: LabelType.textBoldLarge.font)

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
        textLabel.text = UBLocalized.enter_birthday_text

        let lr = Padding.small + Padding.medium
        let tb = Padding.medium

        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.maximumDate = Date()

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

        addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(textLabel.snp.bottom).offset(Padding.large)
            make.left.right.equalToSuperview().inset(lr / 2)
        }

        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(Padding.medium + 2.0)
            make.left.right.equalToSuperview().inset(lr / 2)
            make.bottom.lessThanOrEqualToSuperview().inset(2.0 * Padding.medium)
        }

        addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.top.equalTo(cancelButton.snp.bottom).offset(Padding.medium)
            make.left.right.equalToSuperview().inset(lr / 2)
            make.bottom.lessThanOrEqualToSuperview().inset(2.0 * Padding.medium)
        }

        accessibilityLabel = [topLabel.text, textLabel.text].compactMap { $0 }.joined(separator: ", ")
    }

    private func setupInteraction() {
        addButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.addCertificateTouchUpCallback?(strongSelf.datePicker.date)
        }

        cancelButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.cancelTouchUpCallback?()
        }
    }
}
