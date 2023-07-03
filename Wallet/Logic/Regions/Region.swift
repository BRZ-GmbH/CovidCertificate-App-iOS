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
    case vienna = "W"
    case niederoesterreich = "NOE"
    case oberoesterreich = "OOE"
    case kaernten = "KTN"
    case burgenland = "BGLD"
    case salzburg = "SBG"
    case steiermark = "STMK"
    case tirol = "T"
    case vorarlberg = "VBG"

    var flag: UIImage? {
        switch self {
        case .vienna: return UIImage(named: "flag_w")
        case .niederoesterreich: return UIImage(named: "flag_noe")
        case .oberoesterreich: return UIImage(named: "flag_ooe")
        case .kaernten: return UIImage(named: "flag_ktn")
        case .burgenland: return UIImage(named: "flag_bgld")
        case .salzburg: return UIImage(named: "flag_sbg")
        case .steiermark: return UIImage(named: "flag_stmk")
        case .tirol: return UIImage(named: "flag_t")
        case .vorarlberg: return UIImage(named: "flag_vbg")
        }
    }

    var name: String {
        switch self {
        case .vienna: return UBLocalized.region_wien
        case .niederoesterreich: return UBLocalized.region_niederoesterreich
        case .oberoesterreich: return UBLocalized.region_oberoesterreich
        case .kaernten: return UBLocalized.region_kaernten
        case .burgenland: return UBLocalized.region_burgenland
        case .salzburg: return UBLocalized.region_salzburg
        case .steiermark: return UBLocalized.region_steiermark
        case .tirol: return UBLocalized.region_tirol
        case .vorarlberg: return UBLocalized.region_vorarlberg
        }
    }

    var validityName: String {
        return name
    }

    static func regionFromString(_ value: String?) -> Region? {
        if let value = value {
            for region in Region.allCases {
                if region.rawValue == value {
                    return region
                }
            }
        }
        return nil
    }
}

extension String {
    var regionModifiedProfile: String {
        if let region = WalletUserStorage.shared.selectedValidationRegion, !region.isEmpty {
            return "\(self)-\(region)"
        }
        return self
    }
}
