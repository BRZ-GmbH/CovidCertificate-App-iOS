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
import CovidCertificateSDK

class UserCertificate: Codable, Equatable {
    let qrCode: String
    let uniqueId: String?
    let createDate: String?

    lazy var decodedCertificate: Result<DGCHolder, CovidCertError> = CovidCertificateSDK.decode(encodedData: qrCode)

    init(qrCode: String, uniqueId: String? = nil, createDate: String? = nil) {
        self.qrCode = qrCode
        self.uniqueId = uniqueId
        self.createDate = createDate
    }

    static func == (lhs: UserCertificate, rhs: UserCertificate) -> Bool {
        return lhs.qrCode == rhs.qrCode
    }
}
