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

class RegionSelectionViewController: ViewController {
    private static let reuseIdentifier = "region.cell"
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    private let tableHeaderView = RegionSelectionHeaderView(title: UBLocalized.wallet_region_selection_header_title, message: UBLocalized.wallet_region_selection_header_message)
    
    private let regions: [Region] = Region.allCases.sorted { r1, r2 in
        return r1.validityName < r2.validityName
    }
    
    // MARK: - Init
    
    override init() {
        super.init()
        title = UBLocalized.wallet_region_selection_title.uppercased()
    }
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()

        if Region.regionFromString(WalletUserStorage.shared.selectedValidationRegion) != nil {
            addDismissButton()
        } else {
            if #available(iOS 13.0, *) {
                isModalInPresentation = true
            }
        }
    }
    
    // MARK: - Setup

    private func setup() {
        view.backgroundColor = .cc_white
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        setupTableView()
    }

    private func setupTableView() {
        tableView.backgroundColor = .cc_white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = .zero

        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))

        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 0.0
        tableView.separatorStyle = .none

        tableView.register(RegionTableViewCell.classForCoder(), forCellReuseIdentifier: RegionSelectionViewController.reuseIdentifier)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(tableHeaderView)
        tableHeaderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.tableHeaderView = containerView
        
        containerView.snp.makeConstraints { make in
            make.centerX.equalTo(tableView.snp.centerX)
            make.width.equalTo(tableView.snp.width)
            make.top.equalTo(tableView.snp.top)
        }
        
        self.tableView.tableHeaderView?.layoutIfNeeded()
        self.tableView.tableHeaderView = self.tableView.tableHeaderView
    }
}

extension RegionSelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let region = regions[indexPath.row]
        WalletUserStorage.shared.selectedValidationRegion = region.rawValue
        dismiss(animated: true, completion: nil)
    }
    
}

extension RegionSelectionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regions.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RegionSelectionViewController.reuseIdentifier, for: indexPath) as! RegionTableViewCell
        let region = regions[indexPath.row]
        cell.region = region
        cell.isSelectedRegion = WalletUserStorage.shared.selectedValidationRegion == region.rawValue
        cell.showBottomSeparator = indexPath.row < (regions.count - 1)
        return cell
    }
    
}
