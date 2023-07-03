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

import Foundation
import ValidationCore

let DATE_FORMAT = "yyyy-MM-dd"

public struct VerificationResult {
    public let isValid: Bool
    public let validUntil: Date?
    public let validFrom: Date?
}

enum Disease: String, Equatable {
    case SarsCov2 = "840539006"
}

public enum TestType: String, Equatable, Codable {
    case Rat = "LP217198-3"
    case Pcr = "LP6464-4"
}

enum TestResult: String, Equatable, Codable {
    case Detected, Positive = "260373001"
    case NotDetected, Negative = "260415000"
}
