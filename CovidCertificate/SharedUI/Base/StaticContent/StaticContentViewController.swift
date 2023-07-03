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

import UIKit

class StaticContentViewController: OnboardingContentViewController {
    private let models: [StaticContentViewModel]
    private let contentViewType: StaticContentViewType

    internal let continueButton = Button(title: UBLocalized.continue_button, style: .normal(.cc_green_dark))
    internal let continueButtonShown: Bool!

    /**
        Enum to distinguish the context in which the static content view is used to correctly vary accessibility identifiers
     */
    enum StaticContentViewType {
        case onboarding
        case faq
        case scannerHowTo
    }

    init(models: [StaticContentViewModel], contentViewType: StaticContentViewType, continueButtonShown: Bool = false) {
        self.models = models
        self.contentViewType = contentViewType
        self.continueButtonShown = continueButtonShown
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    internal func setupViews(addBottomSpacer: Bool = true) {
        for model in models {
            if let heading = model.heading {
                let headingLabel = Label(.uppercaseBold)

                headingLabel.text = heading
                headingLabel.accessibilityTraits = [.header]
                headingLabel.accessibilityIdentifier = "onboarding_subtitle"
                let headingContainer = UIView()
                headingContainer.addSubview(headingLabel)
                headingLabel.snp.makeConstraints { make in
                    make.left.right.equalToSuperview().inset(Padding.medium)
                    make.top.bottom.equalToSuperview()
                }
                addArrangedView(headingContainer, spacing: Padding.large)
            }

            if let img = model.foregroundImage {
                addArrangedView(UIImageView(image: UIImage(named: img)), spacing: 20)
            }

            let titleLabel = Label(.title, textAlignment: model.textAlignment)
            if contentViewType == .onboarding {
                titleLabel.accessibilityIdentifier = "onboarding_title"
            } else {
                titleLabel.accessibilityIdentifier = "item_faq_header_title"
            }
            titleLabel.accessibilityTraits = [.header]
            titleLabel.text = model.title
            let titleContainer = UIView()
            titleContainer.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(2 * Padding.medium)
                make.top.bottom.equalToSuperview()
            }
            addArrangedView(titleContainer, spacing: Padding.medium)
            titleContainer.snp.makeConstraints { make in
                make.leading.trailing.equalTo(self.stackScrollView.stackView)
            }

            for textgroup in model.textGroups {
                let v = OnboardingInfoView(accessibilityImage: textgroup.loadAccessibilityImage, text: textgroup.text, alignment: model.textAlignment, textAccessibilityIdentifier: textgroup.accessibilityIdentifier)
                addArrangedView(v)
                v.snp.makeConstraints { make in
                    make.leading.trailing.equalTo(self.stackScrollView.stackView)
                }
            }

            if !model.expandableTextGroups.isEmpty {
                stackScrollView.addSpacerView(2 * Padding.medium)

                for expandableTextGroup in model.expandableTextGroups {
                    addExpandableBox((expandableTextGroup.title, expandableTextGroup.text, expandableTextGroup.linkTitle, expandableTextGroup.link))
                }
            }

            if let externalLink = model.externalLink, let url = externalLink.url {
                let button = ExternalLinkButton(title: externalLink.label)
                button.touchUpCallback = {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }

                let v = UIView()
                v.addSubview(button)

                button.snp.makeConstraints { make in
                    make.top.equalToSuperview().offset(Padding.large + Padding.medium)
                    make.bottom.equalToSuperview()
                    make.left.equalToSuperview().offset(70.0)
                    make.right.lessThanOrEqualToSuperview().inset(Padding.medium)
                }

                button.accessibilityIdentifier = externalLink.accessibilityIdentifier

                addArrangedView(v)

                v.snp.makeConstraints { make in
                    make.width.equalTo(self.view)
                    make.left.right.equalToSuperview()
                }
            }

            if let buttonText = model.continueButtonText {
                continueButtonText = buttonText
            }

            if continueButtonShown {
                stackScrollView.addSpacerView(2 * Padding.medium)

                addArrangedView(continueButton)
                continueButton.snp.makeConstraints { make in
                    make.top.equalToSuperview()
                    make.leading.trailing.equalToSuperview().inset(Padding.medium)
                }
            }

            if model == models.last, addBottomSpacer {
                let bottomSpacer = UIView()
                bottomSpacer.snp.makeConstraints { make in
                    make.height.equalTo(40)
                }
                addArrangedView(bottomSpacer)
            } else if model != models.last {
                stackScrollView.addSpacerView(Padding.large)
            }
        }
    }
}
