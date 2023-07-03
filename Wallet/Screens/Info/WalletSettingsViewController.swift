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
import UIKit

class WalletSettingsViewController: ViewController {
    private let tableView = UITableView(frame: .zero, style: .grouped)

    enum SettingsRow {
        case imprint
        case licenses
        case faq
        case campaignNotifications
        case dataUpdate
        #if DEBUG || RELEASE_ABNAHME || RELEASE_PROD_TEST
            case log
        #endif
    }

    #if DEBUG || RELEASE_ABNAHME || RELEASE_PROD_TEST
        private let rows: [SettingsRow] = [.faq, .campaignNotifications, .dataUpdate, .imprint, .licenses, .log]
    #else
        private let rows: [SettingsRow] = [.faq, .campaignNotifications, .dataUpdate, .imprint, .licenses]
    #endif

    // MARK: - Init

    override init() {
        super.init()
        title = UBLocalized.settings_title.uppercased()
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()

        addDismissButton()
    }

    // MARK: - Setup

    private func setup() {
        view.addSubview(tableView)

        let topLineView = UIView()
        topLineView.backgroundColor = UIColor.cc_line
        view.addSubview(topLineView)

        topLineView.snp.makeConstraints { make in
            make.height.equalTo(1.0)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        setupTableView()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = .zero

        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))

        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 0.0
        tableView.separatorStyle = .none

        tableView.register(SettingsTableViewCell.classForCoder(), forCellReuseIdentifier: SettingsTableViewCell.reuseIdentifier)
        tableView.register(SettingsActionCell.classForCoder(), forCellReuseIdentifier: SettingsActionCell.reuseIdentifier)
        tableView.register(SettingsToggleCell.classForCoder(), forCellReuseIdentifier: SettingsToggleCell.reuseIdentifier)
    }

    private func updateData() {
        ProgressOverlayView.showProgressOverlayIn(view: view, text: UBLocalized.business_rule_update_progress)
        CovidCertificateSDK.restartTrustListUpdate(force: true) { [weak self] _, failed in
            guard let self = self else { return }
            ProgressOverlayView.dismissProgressOverlayIn(view: self.view)

            let alert = UIAlertController(title: nil, message: failed ? UBLocalized.business_rule_update_failed_message : UBLocalized.business_rule_update_success_message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: UBLocalized.business_rule_update_ok_button, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension WalletSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch rows[indexPath.row] {
        case .imprint:
            let vc = WalletImprintViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .licenses:
            let vc = WalletLicenseViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .faq:
            let vc = BasicStaticContentViewController(models: ConfigManager.currentConfig?.viewModels ?? [], title: UBLocalized.wallet_faq_header.uppercased(), contentViewType: .faq)
            navigationController?.pushViewController(vc, animated: true)
        case .campaignNotifications:
            if UIAccessibility.isVoiceOverRunning {
                toggleCampaignNotifications()
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        case .dataUpdate:
            updateData()
        #if DEBUG || RELEASE_ABNAHME || RELEASE_PROD_TEST
            case .log:
                navigationController?.pushViewController(LogViewController(), animated: true)
        #endif
        }
    }
}

extension WalletSettingsViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch rows[indexPath.row] {
        case .imprint:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.reuseIdentifier, for: indexPath) as! SettingsTableViewCell
            cell.showFullWithBottomSeparator = indexPath.row == rows.count - 1
            cell.setTitle(UBLocalized.settings_row_imprint)
            cell.accessibilityIdentifier = "item_imprint"
            return cell
        case .licenses:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.reuseIdentifier, for: indexPath) as! SettingsTableViewCell
            cell.showFullWithBottomSeparator = indexPath.row == rows.count - 1
            cell.setTitle(UBLocalized.settings_row_licenses)
            cell.accessibilityIdentifier = "item_licenses"
            return cell
        case .faq:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.reuseIdentifier, for: indexPath) as! SettingsTableViewCell
            cell.showFullWithBottomSeparator = indexPath.row == rows.count - 1
            cell.setTitle(UBLocalized.settings_row_faqs)
            cell.accessibilityIdentifier = "item_faq"
            return cell
        case .campaignNotifications:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsToggleCell.reuseIdentifier, for: indexPath) as! SettingsToggleCell
            cell.setText(withTitle: UBLocalized.settings_row_campaign_notifications_title, message: UBLocalized.settings_row_campaign_notifications_message, toggle: UBLocalized.settings_row_campaign_notifications_toggle_label, toggleEnabled: WalletUserStorage.hasOptedOutOfNonImportantCampaigns == false, activeAccessibilityLabel: UBLocalized.accessibility_settings_row_campaign_notifications_toggle_active, inactiveAccessbilityLabel: UBLocalized.accessibility_settings_row_campaign_notifications_toggle_inactive, performToggleAccessibilityLabel: UBLocalized.accessibility_change_campaign_notifications_toggle)
            cell.showFullWithBottomSeparator = indexPath.row == rows.count - 1
            cell.accessibilityIdentifier = "item_campaign_notifications"
            cell.toggleSwitch.removeTarget(self, action: #selector(toggleCampaignNotifications), for: .valueChanged)
            cell.toggleSwitch.addTarget(self, action: #selector(toggleCampaignNotifications), for: .valueChanged)
            return cell
        case .dataUpdate:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsActionCell.reuseIdentifier, for: indexPath) as! SettingsActionCell
            cell.showFullWithBottomSeparator = indexPath.row == rows.count - 1
            cell.setTitle(UBLocalized.settings_row_update_data)
            cell.accessibilityIdentifier = "item_faq"
            return cell
        #if DEBUG || RELEASE_ABNAHME || RELEASE_PROD_TEST
            case .log:
                let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.reuseIdentifier, for: indexPath) as! SettingsTableViewCell
                cell.showFullWithBottomSeparator = indexPath.row == rows.count - 1
                cell.setTitle("Log anzeigen")
                cell.accessibilityIdentifier = "item_log"
                return cell
        #endif
        }
    }

    @objc private func toggleCampaignNotifications() {
        WalletUserStorage.hasOptedOutOfNonImportantCampaigns = !WalletUserStorage.hasOptedOutOfNonImportantCampaigns
    }
}
