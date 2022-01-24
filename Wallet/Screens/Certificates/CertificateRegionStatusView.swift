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
import CovidCertificateSDK

/**
 Display the status of a single region
 */
class CertificateRegionStatusView: UIView {
    
    private let containerView = UIView()
    private let imageView = UIImageView()
    private let label = Label(.text, textAlignment: .center)
    private let isHomescreen: Bool
    
    var result: VerificationRegionResult? = nil {
        didSet {
            if result?.region?.hasPrefix("ET") == true {
                label.text = UBLocalized.region_type_ET
                if isHomescreen {
                    label.accessibilityIdentifier = "certificate_page_info_et"
                    imageView.accessibilityIdentifier = "certificate_page_info_et_icon"
                } else {
                    label.accessibilityIdentifier = "certificate_detail_info_et"
                    imageView.accessibilityIdentifier = "certificate_detail_info_et_icon"
                }
            } else if result?.region?.hasPrefix("NG") == true {
                label.text = UBLocalized.region_type_NG
                if isHomescreen {
                    label.accessibilityIdentifier = "certificate_page_info_ng"
                    imageView.accessibilityIdentifier = "certificate_page_info_ng_icon"
                } else {
                    label.accessibilityIdentifier = "certificate_detail_info_ng"
                    imageView.accessibilityIdentifier = "certificate_detail_info_ng_icon"
                }
            }
            
            label.numberOfLines = 1
            label.lineBreakMode = .byTruncatingTail
            backgroundColor = result?.valid == true ? .cc_green_valid : .cc_red_invalid
            imageView.image = result?.valid == true ? UIImage(named: "check-circle") : UIImage(named: "minus-circle")
            isAccessibilityElement = true
            accessibilityLabel = [(result?.valid == true ? UBLocalized.region_type_valid : UBLocalized.region_type_invalid), label.text].compactMap({$0}).joined(separator: ", ")
        }
    }
    
    init(isHomescreen: Bool) {
        self.isHomescreen = isHomescreen
        super.init(frame: .zero)
        label.isAccessibilityElement = true

        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        containerView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        containerView.addSubview(label)
        label.textColor = .cc_white
        label.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(8)
        }
    }
}
