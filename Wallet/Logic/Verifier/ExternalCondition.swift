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
 Supported External Conditions
 */
enum ExternalCondition: String {
    case hasValidCertificateForSamePerson
    case getValidCertificateForSamePerson
    case hasNoValidCertificateForSamePerson
    case hasNoCertificateForSamePerson
    case hasCertificateForSamePerson
    case hasNoCertificate
    case hasCertificate
}
