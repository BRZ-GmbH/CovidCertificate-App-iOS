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

extension String {
    /**
     Extension method to parse string to BusinessRuleCertificateType
     */
    func parsedCertificateType() -> BusinessRuleCertificateType? {
        if BusinessRuleCertificateType.vaccination.rawValue.lowercased() == lowercased() {
            return .vaccination
        } else if BusinessRuleCertificateType.test.rawValue.lowercased() == lowercased() {
            return .test
        } else if BusinessRuleCertificateType.recovery.rawValue.lowercased() == lowercased() {
            return .recovery
        } else if BusinessRuleCertificateType.vaccinationExemption.rawValue.lowercased() == lowercased() {
            return .vaccinationExemption
        }
        return nil
    }
}
