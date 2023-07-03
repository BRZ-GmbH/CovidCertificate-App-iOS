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

class ProgressOverlayView: UIView {
    static let containerViewTag = 456_987_123
    static let cornerRadius = CGFloat(10)
    static let padding = CGFloat(10)

    static let backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
    static let textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)

    class func showProgressOverlayIn(view: UIView, text: String) {
        let accessoryView = UIActivityIndicatorView(style: .white)
        accessoryView.startAnimating()

        let label = Label(.text)
        label.text = text
        label.textColor = textColor

        // Container view
        let containerView = UIView()

        containerView.tag = containerViewTag
        containerView.layer.cornerRadius = cornerRadius
        containerView.backgroundColor = backgroundColor

        containerView.addSubview(accessoryView)
        containerView.addSubview(label)

        accessoryView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Padding.medium)
            make.top.equalToSuperview().offset(Padding.medium)
            make.bottom.equalToSuperview().offset(-Padding.medium)
        }
        label.snp.makeConstraints { make in
            make.leading.equalTo(accessoryView.snp.trailing).offset(Padding.medium)
            make.top.equalToSuperview().offset(Padding.medium)
            make.bottom.equalToSuperview().offset(-Padding.medium)
            make.trailing.equalToSuperview().offset(-Padding.medium)
        }

        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    class func dismissProgressOverlayIn(view: UIView) {
        view.subviews
            .filter { $0.tag == containerViewTag }
            .forEach { $0.removeFromSuperview() }
    }
}
