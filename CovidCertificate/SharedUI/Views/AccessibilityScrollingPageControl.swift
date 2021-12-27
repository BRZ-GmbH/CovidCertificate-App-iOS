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
import ScrollingPageControl

/// The ScrollingPageControl doesn't support accessibility.
class AccessibilityScrollingPageControl: ScrollingPageControl {

    var pageChangeCallback: (() -> ())?
    override var selectedPage: Int {
        didSet {
            updatePageControllAccessibilityValue()
        }
    }
    
    func updatePageControllAccessibilityValue() {
        accessibilityValue = [UBLocalized.accessibility_page_control_page,
                              "\(selectedPage + 1)",
                              UBLocalized.accessibility_of_text,
                              "\(pages)"].compactMap({$0}).joined(separator: " ")
    }
    
    open override func accessibilityIncrement() {
        /// Parent class handles the overflows
        selectedPage += 1
        updatePageControllAccessibilityValue()
        pageChangeCallback?()
    }
    
    open override func accessibilityDecrement() {
        /// Parent class handles the overflows
        selectedPage -= 1
        updatePageControllAccessibilityValue()
        pageChangeCallback?()
    }
}
