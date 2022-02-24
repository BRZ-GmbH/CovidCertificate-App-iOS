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

class BasicStaticContentViewController: StaticContentViewController {
    init(models: [StaticContentViewModel], title: String, contentViewType: StaticContentViewType) {
        super.init(models: models, contentViewType: contentViewType)

        self.title = title
        addDismissButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .cc_background

        stackScrollView.stackView.arrangedSubviews.forEach({ $0.subviews.first?.alpha = 1 })
    }
}
