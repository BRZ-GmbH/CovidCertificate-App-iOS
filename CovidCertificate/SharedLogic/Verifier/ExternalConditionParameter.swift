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

/**
 Supported external condition parameters
 */
enum ExternalConditionParameter: String {
    case type = "type"
    case testType = "testType"
    case ageInDaysLessThan = "ageInDaysLessThan"
    case ageInDaysMoreThan = "ageInDaysMoreThan"
    case ageInHoursLessThan = "ageInHoursLessThan"
    case ageInHoursMoreThan = "ageInHoursMoreThan"
    case vaccineType = "vaccineType"
    case vaccineTypeNotEqual = "vaccineTypeNotEqual"
    case doseLessThan = "doseLessThan"
    case doseLessThanOrEqual = "doseLessThanOrEqual"
    case doseGreaterThan = "doseGreaterThan"
    case doseGreaterThanOrEqual = "doseGreaterThanOrEqual"
    case doseEqual = "doseEqual"
    case doseNotEqual = "doseNotEqual"
    case personAgeInYearsLessThan = "personAgeInYearsLessThan"
    case personAgeInYearsMoreThan = "personAgeInYearsMoreThan"
    case personAgeInMonthsLessThan = "personAgeInMonthsLessThan"
    case personAgeInMonthsMoreThan = "personAgeInMonthsMoreThan"
    case isIssuedBeforeCurrentCertificate = "isIssuedBeforeCurrentCertificate"
    case isIssuedAfterCurrentCertificate = "isIssuedAfterCurrentCertificate"
}
