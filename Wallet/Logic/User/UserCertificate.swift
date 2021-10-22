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
        
    lazy var decodedCertificate: Result<DGCHolder, CovidCertError> = {
        return CovidCertificateSDK.decode(encodedData: qrCode)
    }()
    
    init(qrCode: String) {
        self.qrCode = qrCode
    }
    
    static func == (lhs: UserCertificate, rhs: UserCertificate) -> Bool {
        return lhs.qrCode == rhs.qrCode
    }
    
    private enum CodingKeys: String, CodingKey {
        case qrCode
    }
}
