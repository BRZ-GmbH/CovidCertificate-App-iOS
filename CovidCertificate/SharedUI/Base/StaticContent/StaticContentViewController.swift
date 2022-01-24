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
    
    /**
        Enum to distinguish the context in which the static content view is used to correctly vary accessibility identifiers
     */
    enum StaticContentViewType {
        case onboarding
        case faq
        case scannerHowTo
    }
    
    init(models: [StaticContentViewModel], contentViewType: StaticContentViewType) {
        self.models = models
        self.contentViewType = contentViewType
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
            if self.contentViewType == .onboarding {
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
