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
import UIKit

class CertificateNoteView: UIView {
    // MARK: - Subviews

    private let label = Label(.text)

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        setup()

        label.text = UBLocalized.wallet_certificate_detail_note
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        let v = UIView()
        v.backgroundColor = UIColor.cc_greenish
        v.layer.cornerRadius = 9.0

        addSubview(v)

        v.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(-Padding.large)
        }

        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
