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
import UIKit

struct LocalizedValue<T: Codable>: Codable {
    let dic: [String: T]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        dic = (try container.decode([String: T?].self)).reduce(into: [String: T]()) { result, new in
            guard let value = new.value else { return }
            result[String(new.key.prefix(2))] = value
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(dic)
    }

    var value: T? {
        return value(for: .languageKey)
    }

    func value(for languageKey: String) -> T? {
        return dic[languageKey]
    }
}

struct InfoBox: UBCodable, Equatable {
    let title, msg: String
    let url: URL?
    let urlTitle: String?
    let infoId: String?
    let isDismissible: Bool?
}

class ConfigResponseBody: UBCodable, JWTExtension {
    let ios: String?
    let iosForceDate: String?
    let infoBox: LocalizedValue<InfoBox>?
    let questions: LocalizedValue<FAQEntriesContainer>?
    let works: LocalizedValue<FAQEntriesContainer>?
    let vaccinationRefreshCampaignStart: String?
    let vaccinationRefreshCampaignText: LocalizedValue<VaccinationRefreshCampaignText>?
    
    var forceUpdate: Bool {
        guard let iosForceDate = iosForceDate else { return false }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: iosForceDate) else { return false }
        return date.timeIntervalSinceNow < 0
    }
    
    var formattedForceUpdateDate: String {
        guard let iosForceDate = iosForceDate else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: iosForceDate) else { return "" }
        return DateFormatter.ub_dayString(from: date)
    }
    
    var vaccinationRefreshCampaignStartDate: Date? {
        guard let vaccinationRefreshCampaignStart = vaccinationRefreshCampaignStart else { return nil }
        return ISO8601DateFormatter().date(from: vaccinationRefreshCampaignStart)
    }
    
    private enum CodingKeys: String, CodingKey {
        case ios = "ios"
        case iosForceDate = "ios_force_date"
        case infoBox = "infoBox"
        case questions = "questions"
        case works = "works"
        case vaccinationRefreshCampaignText = "refresh_vaccination_campaign_text"
        case vaccinationRefreshCampaignStart = "refresh_vaccination_campaign_start"
    }

    class FAQEntriesContainer: UBCodable {
        let faqTitle: String
        let faqSubTitle: String
        let faqIconIos: String

        let faqEntries: [FAQEntry]
    }

    class FAQEntry: UBCodable {
        let title: String
        let text: String
        let iconIos: String?
        let linkTitle: String?
        let linkUrl: URL?
    }
    
    class VaccinationRefreshCampaignText: UBCodable {
        let title: String
        let message: String
        let remindAgainButton: String
        let readButton: String
        
        private enum CodingKeys: String, CodingKey {
            case title
            case message
            case remindAgainButton = "remind_again_button"
            case readButton = "read_button"
        }
    }
}

extension ConfigResponseBody {
    var viewModels: [StaticContentViewModel] {
        var models = [StaticContentViewModel]()
        if let imageString1 = questions?.value?.faqIconIos,
           let title1 = questions?.value?.faqTitle,
           let subtitle1 = questions?.value?.faqSubTitle {
            models.append(StaticContentViewModel(heading: nil,
                                                 foregroundImage: imageString1,
                                                 title: title1,
                                                 textGroups: [TextGroup(image: nil,imageColor: nil,imageAltText: nil, text: subtitle1)],
                                                 expandableTextGroups: questions?.value?.faqEntries.compactMap { ExpandableTextGroup(title: $0.title, text: $0.text, linkTitle: $0.linkTitle, linkUrl: $0.linkUrl?.absoluteString) } ?? []))
        }

        if let imageString2 = works?.value?.faqIconIos,
           let title2 = works?.value?.faqTitle,
           let subtitle2 = works?.value?.faqSubTitle {
            models.append(StaticContentViewModel(heading: nil,
                                                 foregroundImage: imageString2,
                                                 title: title2,
                                                 textGroups: [TextGroup(image: nil,imageColor: nil,imageAltText: nil, text: subtitle2)],
                                                 expandableTextGroups: works?.value?.faqEntries.compactMap { ExpandableTextGroup(title: $0.title, text: $0.text, linkTitle: $0.linkTitle, linkUrl: $0.linkUrl?.absoluteString) } ?? []))
        }

        return models
    }
}
