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

class HomescreenOnboardingViewController: ViewController {
    // MARK: - Touch Up Callback

    public var addQRCertificateTouchUpCallback: (() -> Void)?
    public var addPDFCertificateTouchUpCallback: (() -> Void)?

    // MARK: - Subviews

    private let stackScrollView = StackScrollView(axis: .vertical)

    private let titleLabel = Label(.uppercaseBold, textColor: .cc_text, textAlignment: .center)
    private var questionLabel = Label(.title, textColor: .cc_text, textAlignment: .center)
    private let homescreenButtons = WalletHomescreenActionView()

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

        homescreenButtons.addQRCertificateTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.addQRCertificateTouchUpCallback?()
        }

        homescreenButtons.addPDFCertificateTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.addPDFCertificateTouchUpCallback?()
        }
    }

    // MARK: - Setup

    private func setupViews() {
        view.backgroundColor = UIColor.clear
        view.addSubview(stackScrollView)

        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackScrollView.scrollView.alwaysBounceVertical = false
        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        let p = Padding.large + Padding.small
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0.0, left: p, bottom: 0.0, right: p)

        stackScrollView.addSpacerView(Padding.large)

        stackScrollView.addArrangedView(titleLabel)
        stackScrollView.addSpacerView(Padding.large + Padding.medium)

        stackScrollView.addArrangedView(questionLabel)

        stackScrollView.addSpacerView(Padding.medium + Padding.small)

        stackScrollView.addArrangedView(homescreenButtons)
        stackScrollView.addSpacerView(Padding.medium + 115)

        titleLabel.text = UBLocalized.wallet_certificate
        questionLabel.text = UBLocalized.wallet_homescreen_what_to_do
        questionLabel.accessibilityTraits = [.header]
    }
}
