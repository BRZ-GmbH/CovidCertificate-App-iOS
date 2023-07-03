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
    case type
    case testType
    case ageInDaysLessThan
    case ageInDaysMoreThan
    case ageInHoursLessThan
    case ageInHoursMoreThan
    case vaccineType
    case vaccineTypeNotEqual
    case doseLessThan
    case doseLessThanOrEqual
    case doseGreaterThan
    case doseGreaterThanOrEqual
    case doseEqual
    case doseNotEqual
    case personAgeInYearsLessThan
    case personAgeInYearsMoreThan
    case personAgeInMonthsLessThan
    case personAgeInMonthsMoreThan
    case isIssuedBeforeCurrentCertificate
    case isIssuedAfterCurrentCertificate
}
