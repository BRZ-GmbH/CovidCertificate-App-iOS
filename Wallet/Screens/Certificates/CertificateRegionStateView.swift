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

/**
 Displays the individual verification states for regions
 */
class CertificateRegionStateView: UIView {
    private let validityStackView = UIStackView()

    var results: [VerificationRegionResult] = [] {
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

        results.forEach { result in

            let statusView = CertificateRegionStatusView()
            statusView.result = result
            validityStackView.addArrangedSubview(statusView)
        }
        accessibilityLabel = validityStackView.subviews.compactMap({$0.accessibilityLabel}).joined(separator: ", ")
    }
}
