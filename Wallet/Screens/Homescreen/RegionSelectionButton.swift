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

class RegionSelectionButton: Button {
    public let leftIconImageView = UIImageView()
    private let rightIconImageView = UIImageView(image: UIImage(named: "ic-arrow-expand")?.ub_image(with: .cc_black))

    public var region: Region? {
        didSet {
            update()
        }
    }

    init() {
        super.init(image: nil, accessibilityName: "")

        setup()
    }

    private func setup() {
        highlightXInset = 0
        highlightYInset = 0

        let s: CGFloat = 56.0
        setContentHuggingPriority(.defaultLow, for: .vertical)
        snp.makeConstraints { make in
            make.height.equalTo(56)
        }

        highlightCornerRadius = s * 0.5
        highlightedBackgroundColor = style.highlightedColor
        snp.removeConstraints()

        addSubview(leftIconImageView)
        leftIconImageView.contentMode = .scaleAspectFill
        leftIconImageView.layer.cornerRadius = 10
        leftIconImageView.layer.masksToBounds = true
        leftIconImageView.layer.borderWidth = 0.5
        leftIconImageView.layer.borderColor = UIColor.cc_line.cgColor
        leftIconImageView.ub_setContentPriorityRequired()
        leftIconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Padding.small)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(20)
        }

        addSubview(rightIconImageView)
        rightIconImageView.contentMode = .scaleAspectFit
        rightIconImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-Padding.small)
            make.centerY.equalToSuperview()
            make.height.equalTo(56)
            make.width.equalTo(16)
        }
        setTitleColor(UIColor.cc_black, for: .normal)
        titleLabel?.font = LabelType.text.font

        contentEdgeInsets = UIEdgeInsets(top: 0, left: 20 + 2.0 * Padding.small + Padding.small, bottom: 0, right: 2.0 * Padding.small + 16)
    }

    override var title: String? {
        didSet {
            let attributedString = NSAttributedString(string: title ?? "", attributes: [NSAttributedString.Key.font: LabelType.text.font, NSAttributedString.Key.foregroundColor: UIColor.cc_black])

            setAttributedTitle(attributedString, for: .normal)
        }
    }

    private func update() {
        title = region?.name
        leftIconImageView.image = region?.flag
        accessibilityLabel = [UBLocalized.accessibility_selected_region, region?.name, UBLocalized.accessibility_change_selected_region].compactMap { $0 }.joined(separator: ",")
    }
}
