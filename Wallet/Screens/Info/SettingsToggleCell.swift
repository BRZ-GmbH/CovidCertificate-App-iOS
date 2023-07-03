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
import SnapKit
import UIKit

class SettingsToggleCell: UITableViewCell {
    static let reuseIdentifier = "settings.toggle_cell"

    private let titleLabel = Label(.textBoldLarge)
    private let messageLabel = Label(.text)
    private let toggleLabel = Label(.textBold)

    let toggleSwitch = UISwitch()

    private let bottomLineView = UIView()
    private var bottomLineLeadingConstraint: Constraint?

    public var showFullWithBottomSeparator: Bool = false {
        didSet {
            bottomLineLeadingConstraint?.update(inset: showFullWithBottomSeparator ? 0 : Padding.medium)
        }
    }

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(toggleLabel)
        contentView.addSubview(toggleSwitch)

        toggleLabel.textColor = UIColor.cc_green_dark

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Padding.medium)
            make.trailing.equalToSuperview().inset(Padding.medium)
            make.top.equalToSuperview().inset(Padding.large)
        }

        messageLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Padding.medium)
            make.trailing.equalToSuperview().inset(Padding.medium)
            make.top.equalTo(titleLabel.snp.bottom).offset(Padding.medium)
        }

        toggleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Padding.medium)
            make.trailing.equalTo(toggleSwitch.snp.leading).inset(Padding.small)
            make.top.equalTo(messageLabel.snp.bottom).offset(Padding.large)
            make.bottom.equalToSuperview().inset(Padding.large)
        }

        toggleSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Padding.medium)
            make.centerY.equalTo(toggleLabel.snp.centerY)
        }

        bottomLineView.backgroundColor = UIColor.cc_line
        addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { make in
            make.height.equalTo(1.0)
            bottomLineLeadingConstraint = make.leading.equalToSuperview().inset(Padding.medium).constraint
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.cc_touchState
        self.selectedBackgroundView = selectedBackgroundView
    }

    func setText(withTitle title: String, message: String, toggle: String, toggleEnabled: Bool, activeAccessibilityLabel: String, inactiveAccessbilityLabel: String, performToggleAccessibilityLabel: String) {
        titleLabel.text = title
        messageLabel.text = message
        toggleLabel.text = toggle
        toggleSwitch.isOn = toggleEnabled
        accessibilityLabel = [toggleEnabled ? activeAccessibilityLabel : inactiveAccessbilityLabel, message, performToggleAccessibilityLabel].joined(separator: ", ")
    }
}
