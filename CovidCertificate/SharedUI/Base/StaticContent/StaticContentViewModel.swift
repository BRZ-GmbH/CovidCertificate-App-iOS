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

struct StaticContentViewModel: Codable, Equatable {

    var textAlignment: NSTextAlignment {
        switch alignment {
        case "center":
            return .center
        default:
            return .left
        }
    }
    
       var image: UIImage? {
           guard let imageName = foregroundImage else { return nil }

           return UIImage(named: imageName)
       }
    
    let heading: String?
    let foregroundImage: String?
    let title: String
    let alignment: String
    let textGroups: [TextGroup]
    let expandableTextGroups: [ExpandableTextGroup]

    init(heading: String? = nil,
         foregroundImage: String? = nil,
         title: String,
         alignment: String = "left",
         textGroups: [TextGroup] = [],
         expandableTextGroups: [ExpandableTextGroup] = [])
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
                $0.image == $1.image && $0.imageColor == $1.imageColor && $0.text == $1.text
            } && lhs.expandableTextGroups.elementsEqual(rhs.expandableTextGroups) {
                $0.title == $1.title && $0.text == $1.text && $0.linkTitle == $1.linkTitle && $0.linkUrl == $1.linkUrl
            }
    }

    // MARK: - Factory

    static let theApp = StaticContentViewModel(heading: UBLocalized.wallet_onboarding_app_header,
                                               foregroundImage: "illu-onboarding-hero",
                                               title: UBLocalized.wallet_onboarding_app_title,
                                               alignment: "center",
                                               textGroups: [TextGroup(image: nil, imageColor: nil, imageAltText: nil, text: UBLocalized.wallet_onboarding_app_text)])

    static let store = StaticContentViewModel(heading: UBLocalized.wallet_onboarding_store_header,
                                              foregroundImage: "illu-onboarding-privacy",
                                              title: UBLocalized.wallet_onboarding_store_title,
                                              textGroups: [TextGroup(image: "ic-privacy", imageColor: UIColor.cc_green_dark.ub_hexString, imageAltText: nil, text: UBLocalized.wallet_onboarding_store_text1) /* ,
                                               (UIImage(named: "ic-validation"), UBLocalized.wallet_onboarding_store_text2) */ ])

    static let show = StaticContentViewModel(heading: UBLocalized.wallet_onboarding_show_header,
                                             foregroundImage: "illu-onboarding-covid-certificate",
                                             title: UBLocalized.wallet_onboarding_show_title,
                                             textGroups: [TextGroup(image: "ic-qr-certificate", imageColor: UIColor.cc_green_dark.ub_hexString, imageAltText: nil, text: UBLocalized.wallet_onboarding_show_text1),
                                                          TextGroup(image: "ic-check-mark", imageColor: UIColor.cc_green_dark.ub_hexString, imageAltText: nil, text: UBLocalized.wallet_onboarding_show_text2)])

    static let privacy = StaticContentViewModel(heading: UBLocalized.wallet_onboarding_privacy_header,
                                                foregroundImage: "illu-onboarding-data-protection",
                                                title: UBLocalized.wallet_onboarding_privacy_title,
                                                textGroups: [TextGroup(image: "ic-data-protection", imageColor: UIColor.cc_green_dark.ub_hexString, imageAltText: nil, text: UBLocalized.wallet_onboarding_privacy_text)])

    static let howItWorks = StaticContentViewModel(foregroundImage: "illu-how-it-works",
                                                   title: UBLocalized.wallet_scanner_howitworks_title,
                                                   textGroups: [TextGroup(image: "ic-bund-small", imageColor: nil, imageAltText: nil, text: UBLocalized.wallet_scanner_howitworks_text1),
                                                                TextGroup(image: "ic-one", imageColor: UIColor.cc_green_dark.ub_hexString, imageAltText: nil, text: UBLocalized.wallet_scanner_howitworks_text2),
                                                                TextGroup(image: "ic-two", imageColor: UIColor.cc_green_dark.ub_hexString, imageAltText: nil, text: UBLocalized.wallet_scanner_howitworks_text3),
                                                                TextGroup(image: "ic-three", imageColor: UIColor.cc_green_dark.ub_hexString, imageAltText: nil, text: UBLocalized.wallet_scanner_howitworks_text4)],
                                                   expandableTextGroups: [ExpandableTextGroup(title: UBLocalized.wallet_scanner_howitworks_question1, text: UBLocalized.wallet_scanner_howitworks_answer1, linkTitle: UBLocalized.wallet_scanner_howitworks_external_link_title, linkUrl: UBLocalized.wallet_scanner_howitworks_external_link)])
 
}

