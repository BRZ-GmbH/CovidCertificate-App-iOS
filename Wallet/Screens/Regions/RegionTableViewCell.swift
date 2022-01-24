//
/*
 * Copyright (c) 2021 BRZ GmbH
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation

class RegionTableViewCell: UITableViewCell {
    
    public var region: Region? {
        didSet {
            update()
        }
    }
    
    private let regionImageView = UIImageView()
    private let nameLabel = Label(.textBold)
    private let selectedIndicator = UIImageView(image: UIImage(named: "ic-check")?.ub_image(with: .cc_green_dark))
    private let bottomLineView = UIView()
    
    public var showBottomSeparator: Bool = true {
        didSet {
            update()
        }
    }
    
    public var isSelectedRegion: Bool = false {
        didSet {
            update()
        }
    }
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        contentView.addSubview(regionImageView)
        regionImageView.contentMode = .scaleAspectFill
        regionImageView.layer.cornerRadius = 10
        regionImageView.layer.masksToBounds = true
        regionImageView.layer.borderWidth = 0.5
        regionImageView.layer.borderColor = UIColor.cc_line.cgColor
        regionImageView.ub_setContentPriorityRequired()
        regionImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(2.0 * Padding.small)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(20)
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Padding.medium + 2.0)
            make.left.equalTo(self.regionImageView.snp.right).offset(2.0 * Padding.small)
            make.bottom.equalToSuperview().inset(Padding.medium + 2.0)
        }
        
        contentView.addSubview(selectedIndicator)
        selectedIndicator.contentMode = .center
        selectedIndicator.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(2.0 * Padding.small)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(24)
        }
        
        bottomLineView.backgroundColor = UIColor.cc_line
        addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { make in
            make.height.equalTo(1.0)
            make.left.equalTo(regionImageView.snp.left)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.cc_touchState
        self.selectedBackgroundView = selectedBackgroundView
        
        setupAccessibilityIdentifiers()
    }
    
    private func setupAccessibilityIdentifiers() {
        nameLabel.accessibilityIdentifier = "item_region_list_name"
        selectedIndicator.accessibilityIdentifier = "item_region_list_radio"
    }
    
    private func update() {
        guard let region = self.region else { return }
        nameLabel.text = region.name
        
        accessibilityLabel = [region.name, isSelectedRegion ? UBLocalized.accessibility_region_active : UBLocalized.accessibility_region_in_active].compactMap({ $0 }).joined(separator: ",")
        regionImageView.image = region.flag
        selectedIndicator.isHidden = isSelectedRegion == false

        bottomLineView.isHidden = showBottomSeparator == false
    }
}
