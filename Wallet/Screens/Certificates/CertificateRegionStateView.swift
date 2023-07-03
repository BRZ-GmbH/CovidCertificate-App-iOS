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

import BusinessRulesValidationCore
import Foundation
import UIKit

/**
 Displays the individual verification states for regions
 */
class CertificateRegionStateView: UIView {
    private let validityStackView = UIStackView()
    var isHomescreen: Bool = false

    var results: [String: ValidationResult] = [:] {
        didSet {
            update(animated: true)
        }
    }

    init() {
        super.init(frame: .zero)
        isAccessibilityElement = true

        setup()

        update(animated: false)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubview(validityStackView)
        validityStackView.spacing = 8
        validityStackView.distribution = .fillEqually
        validityStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        validityStackView.axis = .horizontal

        backgroundColor = .cc_white
    }

    private func update(animated _: Bool) {
        validityStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        var statusView = CertificateRegionStatusView(isHomescreen: isHomescreen)
        statusView.result = ("Entry", results["Entry"])
        validityStackView.addArrangedSubview(statusView)

        statusView = CertificateRegionStatusView(isHomescreen: isHomescreen)
        statusView.result = ("NightClub", results["NightClub"])
        validityStackView.addArrangedSubview(statusView)

        accessibilityLabel = validityStackView.subviews.compactMap { $0.accessibilityLabel }.joined(separator: ", ")
    }
}
