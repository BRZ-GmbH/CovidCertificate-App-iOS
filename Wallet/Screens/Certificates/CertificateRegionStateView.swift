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
        validityStackView.spacing = 0
        validityStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        validityStackView.axis = .horizontal

        backgroundColor = .cc_orange
    }

    private func update(animated _: Bool) {
        validityStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        results.forEach { result in
            let textLabel = Label(.textLarge, textAlignment: .center)
            switch result.region {
            case "ET": textLabel.text = UBLocalized.region_type_ET
            case "NG": textLabel.text = UBLocalized.region_type_NG
            default: break
            }
            textLabel.textColor = .cc_white
            textLabel.backgroundColor = result.valid ? .cc_green_light : .cc_red
            validityStackView.addArrangedSubview(textLabel)
        }
    }
}
