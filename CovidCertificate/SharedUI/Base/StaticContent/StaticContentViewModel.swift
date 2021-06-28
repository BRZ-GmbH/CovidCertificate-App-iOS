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

import UIKit

struct StaticContentViewModel: Equatable {
    let heading: String?
    let foregroundImage: UIImage?
    let title: String
    let alignment: NSTextAlignment
    let textGroups: [(UIImage?, String)]
    let expandableTextGroups: [(String, String, String?, URL?)]

    init(heading: String? = nil,
         foregroundImage: UIImage? = nil,
         title: String,
         alignment: NSTextAlignment = .left,
         textGroups: [(UIImage?, String)] = [],
         expandableTextGroups: [(String, String, String?, URL?)] = [])
    {
        self.heading = heading
        self.foregroundImage = foregroundImage
        self.title = title
        self.alignment = alignment
        self.textGroups = textGroups
        self.expandableTextGroups = expandableTextGroups
    }

    static func == (lhs: StaticContentViewModel, rhs: StaticContentViewModel) -> Bool {
        return lhs.heading == rhs.heading &&
            lhs.foregroundImage == rhs.foregroundImage &&
            lhs.title == rhs.title &&
            lhs.alignment == rhs.alignment &&
            lhs.textGroups.elementsEqual(rhs.textGroups) {
                $0.0 == $1.0 && $0.1 == $1.1
            } && lhs.expandableTextGroups.elementsEqual(rhs.expandableTextGroups) {
                $0.0 == $1.0 && $0.1 == $1.1 && $0.2 == $1.2 && $0.3 == $1.3
            }
    }

    // MARK: - Factory

    static let theApp = StaticContentViewModel(heading: UBLocalized.wallet_onboarding_app_header,
                                               foregroundImage: UIImage(named: "illu-onboarding-hero"),
                                               title: UBLocalized.wallet_onboarding_app_title,
                                               alignment: .center,
                                               textGroups: [(nil, UBLocalized.wallet_onboarding_app_text)])

    static let store = StaticContentViewModel(heading: UBLocalized.wallet_onboarding_store_header,
                                              foregroundImage: UIImage(named: "illu-onboarding-privacy"),
                                              title: UBLocalized.wallet_onboarding_store_title,
                                              textGroups: [(UIImage(named: "ic-privacy")?.ub_image(with: .cc_green_dark), UBLocalized.wallet_onboarding_store_text1) /* ,
                                               (UIImage(named: "ic-validation"), UBLocalized.wallet_onboarding_store_text2) */ ])

    static let show = StaticContentViewModel(heading: UBLocalized.wallet_onboarding_show_header,
                                             foregroundImage: UIImage(named: "illu-onboarding-covid-certificate"),
                                             title: UBLocalized.wallet_onboarding_show_title,
                                             textGroups: [(UIImage(named: "ic-qr-certificate")?.ub_image(with: .cc_green_dark), UBLocalized.wallet_onboarding_show_text1),
                                                          (UIImage(named: "ic-check-mark")?.ub_image(with: .cc_green_dark), UBLocalized.wallet_onboarding_show_text2)])

    static let privacy = StaticContentViewModel(heading: UBLocalized.wallet_onboarding_privacy_header,
                                                foregroundImage: UIImage(named: "illu-onboarding-data-protection"),
                                                title: UBLocalized.wallet_onboarding_privacy_title,
                                                textGroups: [(UIImage(named: "ic-data-protection")?.ub_image(with: .cc_green_dark), UBLocalized.wallet_onboarding_privacy_text)])

    static let howItWorks = StaticContentViewModel(foregroundImage: UIImage(named: "illu-how-it-works"),
                                                   title: UBLocalized.wallet_scanner_howitworks_title,
                                                   textGroups: [(UIImage(named: "ic-bund-small"), UBLocalized.wallet_scanner_howitworks_text1),
                                                                (UIImage(named: "ic-one")?.ub_image(with: .cc_green_dark), UBLocalized.wallet_scanner_howitworks_text2),
                                                                (UIImage(named: "ic-two")?.ub_image(with: .cc_green_dark), UBLocalized.wallet_scanner_howitworks_text3),
                                                                (UIImage(named: "ic-three")?.ub_image(with: .cc_green_dark), UBLocalized.wallet_scanner_howitworks_text4)],
                                                   expandableTextGroups: [(UBLocalized.wallet_scanner_howitworks_question1, UBLocalized.wallet_scanner_howitworks_answer1, UBLocalized.wallet_scanner_howitworks_external_link_title, URL(string: UBLocalized.wallet_scanner_howitworks_external_link))])
}
