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

class SettingsTableViewCell: UITableViewCell {
    static let reuseIdentifier = "settings.cell"

    private let titleLabel = Label(.textBold)
    private let bottomLineView = UIView()
    private let chevronImageView = UIImageView(image: UIImage(named: "ic-chevron-right"))
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
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        contentView.addSubview(titleLabel)
        chevronImageView.tintColor = UIColor.cc_green_dark
        chevronImageView.contentMode = .right
        contentView.addSubview(chevronImageView)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Padding.medium)
            make.trailing.equalTo(chevronImageView.snp.leading).inset(Padding.medium)
            make.top.equalToSuperview().inset(Padding.large)
            make.bottom.equalToSuperview().inset(Padding.large)
        }

        chevronImageView.snp.makeConstraints { make in
            make.width.equalTo(10)
            make.trailing.equalToSuperview().inset(Padding.medium)
            make.centerY.equalToSuperview()
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

    func setTitle(_ title: String) {
        titleLabel.text = title
        accessibilityLabel = title
    }
}
