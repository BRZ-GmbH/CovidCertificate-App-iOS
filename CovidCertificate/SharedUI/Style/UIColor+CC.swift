/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

public extension UIColor {
    static var cc_bund = UIColor(ub_hexString: "#e6320f")!

    static var cc_black = UIColor.black
    static var cc_grey = UIColor(ub_hexString: "#2B2A29")!
    static var cc_blue = UIColor(ub_hexString: "#143E7F")!
    static var cc_green_dark = UIColor(ub_hexString: "#4D9553")!
    static var cc_green = UIColor(ub_hexString: "#91C88D")!
    static var cc_orange = UIColor(ub_hexString: "#C9872C")!
    static var cc_red = UIColor(ub_hexString: "#a72702")!

    static var cc_recovery = UIColor(ub_hexString: "#892252")!
    static var cc_vaccination = UIColor(ub_hexString: "#143E7F")!
    static var cc_test = UIColor(ub_hexString: "#C9872C")!

    static var cc_recovery_contrast = UIColor(ub_hexString: "#FFFFFF")!
    static var cc_vaccination_contrast = UIColor(ub_hexString: "#FFFFFF")!
    static var cc_test_contrast = UIColor(ub_hexString: "#FFFFFF")!

    static var cc_white = UIColor.white
    static var cc_greyish = UIColor(ub_hexString: "#E9E4DF")!
    static var cc_blueish = UIColor(ub_hexString: "#BFCFE0")!
    static var cc_greenish = UIColor(ub_hexString: "#dfedda")!
    static var cc_orangish = UIColor(ub_hexString: "#FCE6BF")!
    static var cc_redish = UIColor(ub_hexString: "#f2cac6")!

    // makes cc_black -> cc_grey
    static var cc_disabledAlpha: CGFloat = (255.0 - 117.0) / 255.0

    // MARK: - Text color

    static var cc_text: UIColor {
        return .cc_black
    }

    static var cc_greyText: UIColor {
        return .cc_grey
    }

    static var cc_line: UIColor {
        return UIColor(ub_hexString: "#E9E4DF")!
    }

    // MARK: - Background / Lines

    static var cc_background: UIColor {
        return .cc_white
    }

    static var cc_greyBackground: UIColor {
        return UIColor(ub_hexString: "#F6F4F0")!
    }

    static var cc_touchState: UIColor {
        return UIColor(ub_hexString: "#F0ECE8")!
    }

    // MARK: - UIAccessibility Contrast extension

    internal func withHighContrastColor(color: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { _ in UIAccessibility.isDarkerSystemColorsEnabled ? color : self }
        } else {
            return self
        }
    }

    // MARK: - Theme colors, self updating

    internal static func setColorsForTheme(lightColor: UIColor, darkColor: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traits -> UIColor in
                // Return one of two colors depending on light or dark mode
                traits.userInterfaceStyle == .dark ?
                    darkColor :
                    lightColor
            }
        } else {
            return lightColor
        }
    }
}
