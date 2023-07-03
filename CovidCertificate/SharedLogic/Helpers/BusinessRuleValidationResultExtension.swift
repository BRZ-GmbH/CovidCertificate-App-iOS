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
import BusinessRulesValidationCore

extension BusinessRuleValidationResult {
    var formattedValidFrom: String? {
        guard let validFrom = self.validFrom.first else {
            return nil
        }
        switch validFrom.format {
        case .date:
            return DateFormatter.ub_dayString(from: validFrom.time)
        case .dateTime:
            return DateFormatter.ub_dayTimeString(from: validFrom.time)
        }
    }
    
    var formattedValidUntil: String? {
        guard let validUntil = self.validUntil.first else {
            return nil
        }
        switch validUntil.format {
        case .date:
            return DateFormatter.ub_dayString(from: validUntil.time)
        case .dateTime:
            return DateFormatter.ub_dayTimeString(from: validUntil.time)
        }
    }
}
