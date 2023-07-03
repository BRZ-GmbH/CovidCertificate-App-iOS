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
import SwiftyJSON
import ValidationCore
import BusinessRulesValidationCore

/**
 Type of campaign
 */
enum CampaignType: String {
    case single = "single" // show single time - not dependent on any certificate
    case repeating = "repeating" // show repeatedly - not dependent on any certificate
    case singleForAnyCertificate = "single_any_certificate" // show single time when any certificate matches conditions
    case singleForEachCertificate = "single_each_certificate" // show single time for each certificate that matches conditions
    case repeatingForAnyCertificate = "repeating_any_certificate" // show repeatedly when any certificate matches conditions
    case repeatingForEachCertificate = "repeating_each_certificate" // show repeating for each certificate that matches conditions
}

/**
 Certificates/Groups for which a campaign applies
 */
enum CampaignApplicationType: String {
    case all = "all"
    case newestCertificatePerPerson = "newest_certificate_per_person"
}

/**
 Button type for a campaign
 */
enum CampaignButtonType: String {
    case dismiss = "dismiss"
    case later = "later"
    case dismissWithAction = "dismiss_action"
    case laterWithAction = "later_action"
}

/**
 An information campaign
 */
struct Campaign: UBCodable {
    let id: String
    
    private let validFromString: String?
    var validFrom: Date {
        guard let validFromString = validFromString else { return Date.distantPast }
        return ISO8601DateFormatter().date(from: validFromString) ?? Date.distantPast
    }
    
    private let validUntilString: String?
    var validUntil: Date {
        guard let validUntilString = validUntilString else { return Date.distantFuture }
        return ISO8601DateFormatter().date(from: validUntilString) ?? Date.distantFuture
    }
    
    private let campaignTypeString: String?
    var campaignType: CampaignType {
        return CampaignType(rawValue: campaignTypeString ?? CampaignType.single.rawValue) ?? .single
    }
    
    let version: Int
    let important: Bool
    let title: LocalizedValue<String>?
    let message: LocalizedValue<String>?
    let repeatInterval: CampaignRepeatInterval?
    
    private let appliesToString: String
    
    private let certificateTypeString: String?
    
    var certificateType: BusinessRuleCertificateType? {
        if let certificateTypeString = certificateTypeString {
            return certificateTypeString.parsedCertificateType()
        }
        return .vaccination
    }
    
    var appliesTo: CampaignApplicationType {
        return CampaignApplicationType(rawValue: appliesToString) ?? .all
    }
    let buttons: [CampaignButton]
    
    let conditionGroups: [[String]]?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case version
        case validFromString = "valid_from"
        case validUntilString = "valid_until"
        case campaignTypeString = "type"
        case important
        case title
        case message
        case repeatInterval = "repeat_interval"
        case appliesToString = "applies_to"
        case buttons
        case conditionGroups = "conditions"
        case certificateTypeString = "certificate_type"
    }
}

struct CampaignButton: UBCodable {
    private let typeString: String
    var type: CampaignButtonType {
        return CampaignButtonType(rawValue: typeString) ?? .dismiss
    }
    let title: LocalizedValue<String>
    
    private let urlString: String?
    var url: URL? {
        guard let urlString = urlString else {
            return nil
        }
        return URL(string: urlString)
    }
    
    private enum CodingKeys: String, CodingKey {
        case typeString = "type"
        case title
        case urlString = "url"
    }
}

struct CampaignRepeatInterval: UBCodable {
    let type: String
    let interval: Int
    
    /**
     Modifies the given date by adding the appropriate time interval
     */
    func dateByAddingRepeatIntervalTo(date: Date) -> Date {
        switch type {
        case "minute":
            return Calendar.autoupdatingCurrent.date(byAdding: .minute, value: interval, to: date) ?? date
        case "hour":
            return Calendar.autoupdatingCurrent.date(byAdding: .hour, value: interval, to: date) ?? date
        case "day":
            return Calendar.autoupdatingCurrent.date(byAdding: .day, value: interval, to: date) ?? date
        case "month":
            return Calendar.autoupdatingCurrent.date(byAdding: .month, value: interval, to: date) ?? date
        default: return date
        }
    }
}

extension Campaign {
    /**
     Returns true if this campaign is currently active based on it's validFrom and validUntil date.
     */
    var isActive: Bool {
        return Date().isAfter(validFrom) && Date().isBefore(validUntil)
    }
    
}
