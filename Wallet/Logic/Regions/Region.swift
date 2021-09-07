//
/*
 * Copyright (c) 2021 BRZ GmbH
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation

enum Region: String, CaseIterable {
    case nationWide = ""
    case vienna = "W"
    
    var flag: UIImage? {
        switch self {
        case .nationWide: return UIImage(named: "flag_at")
        case .vienna: return UIImage(named: "flag_w")
        }
    }
    
    var name: String {
        switch self {
        case .nationWide: return UBLocalized.region_nationwide
        case .vienna: return UBLocalized.region_wien
        }
    }
}

extension String {
    var regionModifiedProfile: String {
        if WalletUserStorage.shared.selectedValidationRegion.isEmpty {
            return self
        } else {
            return "\(self)-\(WalletUserStorage.shared.selectedValidationRegion)"
        }
    }
}
