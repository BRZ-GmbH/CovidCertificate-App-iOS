//
/*
 * Copyright (c) 2021 BRZ GmbH
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation

class RegionSelectionHeaderView: UIView {
    
    private let titleLabel = Label(.textBoldLarge)
    private let messageLabel = Label(.text)
    
    init(title: String, message: String) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        messageLabel.text = message
        
        setup()
        setupAccessibilityIdentifiers()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(2.0 * Padding.small)
            make.right.equalToSuperview().offset(-2.0 * Padding.small)
            make.top.equalToSuperview().offset(Padding.medium)
        }
        
        addSubview(messageLabel)
        messageLabel.numberOfLines = 0
        
        messageLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(2.0 * Padding.small)
            make.right.equalToSuperview().offset(-2.0 * Padding.small)
            make.top.equalTo(titleLabel.snp.bottom).offset(Padding.medium)
            make.bottom.equalToSuperview().offset(-Padding.medium)
        }
    }
    
    private func setupAccessibilityIdentifiers() {
        titleLabel.accessibilityIdentifier = "region_list_header_title"
        messageLabel.accessibilityIdentifier = "region_list_header_text"
    }
}
