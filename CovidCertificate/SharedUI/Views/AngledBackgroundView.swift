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
import UIKit

class AngledBackgroundView: UIView {
    let angleLayer = CAShapeLayer()

    init(backgroundColor: UIColor) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        angleLayer.fillColor = UIColor.cc_white.cgColor

        layer.addSublayer(angleLayer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func updatePath() {
        angleLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height * 2)).cgPath
        angleLayer.anchorPoint = .zero
        let degrees = -25.0
        let radians = CGFloat(degrees * .pi / 180)
        angleLayer.transform = CATransform3DMakeRotation(radians, 0.0, 0.0, 1.0)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let t = super.hitTest(point, with: event)

        // allow buttons to be on the round edge to be captured
        for v in subviews.filter({ $0 is UIButton }) {
            let translatedPoint = v.convert(point, from: self)

            if v.bounds.contains(translatedPoint) {
                return v.hitTest(translatedPoint, with: event)
            }
        }

        return t
    }
}
