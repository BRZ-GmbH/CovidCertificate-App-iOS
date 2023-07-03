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

import BusinessRulesValidationCore
import Foundation

/**
 Represents the verification result for a certificate
 */
enum VerificationResultStatus: Equatable {
    case loading
    case signatureInvalid
    case signatureExpired
    case error
    case timeMissing
    case dataExpired
    case success([String: ValidationResult])

    public func isSuccess() -> Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }

    /**
     Return the invididual region results for the success state
     */
    public func results() -> [String: ValidationResult] {
        switch self {
        case let .success(result): return result
        default: return [:]
        }
    }

    /**
     Returns true if the result is error, signatureInvalid or contains any invalid region result
     */
    public func isInvalid() -> Bool {
        switch self {
        case .signatureInvalid: return true
        case .error: return true
        case .success: return containsOnlyInvalidVerification()
        default: return false
        }
    }

    /**
     Returns true if the result contains any invalid region result
     */
    public func containsOnlyInvalidVerification() -> Bool {
        switch self {
        case let .success(result): return result.values.filter {
                switch $0 {
                case .valid: return true
                default: return false
                }
            }.count == 0
        default: return false
        }
    }
}
