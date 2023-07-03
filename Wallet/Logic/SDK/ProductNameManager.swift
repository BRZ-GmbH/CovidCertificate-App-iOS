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

class ProductNameManager {
    // MARK: - Shared instance

    public static let shared = ProductNameManager()

    // MARK: - API

    public func vaccineManufacturer(key: String?) -> String? {
        guard let key = key else { return nil }
        return CovidCertificateSDK.currentValueSets()["vaccines-covid-19-auth-holders"]?.valueSetValues[key]?.display ?? key
    }

    public func vaccineProductName(key: String?) -> String? {
        guard let key = key else { return nil }
        return CovidCertificateSDK.currentValueSets()["vaccines-covid-19-names"]?.valueSetValues[key]?.display ?? key
    }

    public func vaccineProphylaxisName(key: String?) -> String? {
        guard let key = key else { return nil }
        return CovidCertificateSDK.currentValueSets()["sct-vaccines-covid-19"]?.valueSetValues[key]?.display ?? key
    }

    public func testManufacturerName(key: String?) -> String? {
        guard let key = key else { return nil }
        return CovidCertificateSDK.currentValueSets()["covid-19-lab-test-manufacturer-and-name"]?.valueSetValues[key]?.display ?? key
    }

    public func testTypeName(key: String?) -> String? {
        guard let key = key else { return nil }
        return CovidCertificateSDK.currentValueSets()["covid-19-lab-test-type"]?.valueSetValues[key]?.display ?? key
    }
}
