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
import SnapKit
import UIKit

class HomescreenBaseViewController: ViewController {
    // MARK: - Content

    private let backgroundView: AngledBackgroundView
    public let logoView = UIImageView(image: UIImage(named: "ic-bund"))
    private let settingsButton = Button(image: UIImage(named: "ic-settings-outline"), accessibilityName: UBLocalized.accessibility_info_button)

    public var backgroundViewOffset: CGPoint = .zero

    public let regionSelectionButton = RegionSelectionButton()

    public var settingsButtonCallback: (() -> Void)?

    public var regionSelectionButtonCallback: (() -> Void)?

    // MARK: - Init

    init(color: UIColor) {
        backgroundView = AngledBackgroundView(backgroundColor: color)
        super.init()
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(backgroundView)
        view.addSubview(logoView)

        logoView.ub_setContentPriorityRequired()

        logoView.snp.makeConstraints { make in
            let statusHeight = UIApplication.shared.statusBarFrame.height
            make.top.equalTo(view.safeAreaLayoutGuide).inset(statusHeight > 20.0 ? 11.0 : 18.0)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(48)
        }

        backgroundView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.left.right.bottom.equalToSuperview()
        }

        view.addSubview(settingsButton)

        settingsButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.logoView)
            make.right.equalToSuperview().inset(Padding.medium)
            make.size.equalTo(44.0)
        }

        settingsButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.settingsButtonCallback?()
        }

        view.addSubview(regionSelectionButton)
        regionSelectionButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.logoView)
            make.right.equalTo(settingsButton.snp.left).offset(-Padding.small)
        }

        regionSelectionButton.touchUpCallback = { [weak self] in
            self?.regionSelectionButtonCallback?()
        }

        setupAccessibilityIdentifiers()
    }

    private func setupAccessibilityIdentifiers() {
        logoView.accessibilityIdentifier = "bund_logo"
        settingsButton.accessibilityIdentifier = "header_settings"
        regionSelectionButton.accessibilityIdentifier = "header_region_text"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundView.updatePath()
    }
}
