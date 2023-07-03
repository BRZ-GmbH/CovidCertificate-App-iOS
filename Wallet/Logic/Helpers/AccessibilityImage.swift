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
struct AccessibilityImage: Equatable {
    let image: UIImage?
    let altText: String?

    static func == (lhs: AccessibilityImage, rhs: AccessibilityImage) -> Bool {
        return lhs.image == rhs.image &&
            lhs.altText == rhs.altText
    }
}
