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

#if DEBUG || RELEASE_ABNAHME || RELEASE_PROD_TEST
    /**
     This view controller display entries from Logger.lastLogs in debug and test builds
     */
    class LogViewController: ViewController {
        private static let reuseIdentifier = "log.cell"

        private let tableView = UITableView(frame: .zero, style: .grouped)

        private let logEntries: [(Date, String)] = Logger.lastLogs.reversed()

        // MARK: - Init

        override init() {
            super.init()
            title = "Logs"
        }

        // MARK: - View

        override func viewDidLoad() {
            super.viewDidLoad()

            setup()
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
            tableView.separatorInset = .zero

            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))

            tableView.sectionHeaderHeight = 0.0
            tableView.sectionFooterHeight = 0.0
            tableView.separatorStyle = .none

            tableView.register(LogTableViewCell.classForCoder(), forCellReuseIdentifier: LogViewController.reuseIdentifier)
        }
    }

    extension LogViewController: UITableViewDataSource {
        func numberOfSections(in _: UITableView) -> Int {
            return 1
        }

        func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
            return logEntries.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: LogViewController.reuseIdentifier, for: indexPath) as! LogTableViewCell
            let logEntry = logEntries[indexPath.row]
            cell.logDateLabel.text = DateFormatter.ub_dayTimeString(from: logEntry.0)
            cell.logTextLabel.text = logEntry.1
            return cell
        }
    }

    class LogTableViewCell: UITableViewCell {
        let logDateLabel = Label(.textBold)
        let logTextLabel = Label(.text)

        private let bottomLineView = UIView()

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
            logDateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            logDateLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            logTextLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            contentView.addSubview(logDateLabel)
            contentView.addSubview(logTextLabel)

            logDateLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(Padding.medium)
                make.firstBaseline.equalTo(logTextLabel.snp.firstBaseline)
            }
            logTextLabel.snp.makeConstraints { make in
                make.leading.equalTo(logDateLabel.snp.trailing).offset(Padding.small)
                make.top.equalToSuperview().offset(Padding.medium)
                make.trailing.equalToSuperview().offset(-Padding.medium)
                make.bottom.equalToSuperview().offset(-Padding.medium)
            }

            bottomLineView.backgroundColor = UIColor.cc_line
            addSubview(bottomLineView)
            bottomLineView.snp.makeConstraints { make in
                make.height.equalTo(1.0)
                make.left.equalTo(logDateLabel.snp.left)
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
    }
#endif
