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
import SwiftyJSON
import jsonlogic

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

class ConfigResponseBody: UBCodable {
    let ios: String?
    let iosForceDate: String?
    let questions: LocalizedValue<FAQEntriesContainer>?
    let works: LocalizedValue<FAQEntriesContainer>?
    let campaigns: [Campaign]?
    let conditions: [String:CertificateCondition]?
    
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
    
    private enum CodingKeys: String, CodingKey {
        case ios = "ios"
        case iosForceDate = "ios_force_date"
        case questions = "questions"
        case works = "works"
        case campaigns = "campaigns"
        case conditions = "conditions"
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
}

class CertificateCondition: UBCodable {
    let logic: String
    
    private enum CodingKeys: String, CodingKey {
        case logic
    }
    
    private var _parsedJsonLogic: JsonLogic? = nil
    
    func parsedJsonLogic() throws -> JsonLogic {
      if let _parsedJsonLogic = _parsedJsonLogic {
        return _parsedJsonLogic
      }
      let parsedJsonLogicObject = try JsonLogic(logic)
      _parsedJsonLogic = parsedJsonLogicObject
      return parsedJsonLogicObject
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
                                                 textGroups: [TextGroup(image: nil,imageColor: nil,imageAltText: nil, text: subtitle1, accessibilityIdentifier: "item_faq_header_text")],
                                                 expandableTextGroups: questions?.value?.faqEntries.compactMap { ExpandableTextGroup(title: $0.title, text: $0.text, linkTitle: $0.linkTitle, linkUrl: $0.linkUrl?.absoluteString) } ?? []))
        }

        if let imageString2 = works?.value?.faqIconIos,
           let title2 = works?.value?.faqTitle,
           let subtitle2 = works?.value?.faqSubTitle {
            models.append(StaticContentViewModel(heading: nil,
                                                 foregroundImage: imageString2,
                                                 title: title2,
                                                 textGroups: [TextGroup(image: nil,imageColor: nil,imageAltText: nil, text: subtitle2, accessibilityIdentifier: "item_faq_header_text")],
                                                 expandableTextGroups: works?.value?.faqEntries.compactMap { ExpandableTextGroup(title: $0.title, text: $0.text, linkTitle: $0.linkTitle, linkUrl: $0.linkUrl?.absoluteString) } ?? []))
        }

        return models
    }
}
