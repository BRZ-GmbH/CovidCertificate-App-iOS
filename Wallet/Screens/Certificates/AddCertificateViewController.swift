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

/* Controller to handle the displaying of adding the certificate which is received from a direct link or backend call */
class AddCertificateViewController: ViewController {
    // MARK: - Subviews

    let detailViewController = CertificateAddDetailViewController(showScanAgainButton: false)

    // MARK: - Init

    override init() {
        super.init()
        title = UBLocalized.wallet_scanner_title.uppercased()
        navigationItem.accessibilityLabel = UBLocalized.wallet_scanner_title
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewAndInteractions()
        addDismissButton()
    }

    private func setupViewAndInteractions() {
        addSubviewController(detailViewController) { make in
            make.edges.equalToSuperview()
        }

        detailViewController.addOrOkCertificateTouchUpCallback = { certificate in
            guard let c = certificate else { return }

            CertificateStorage.shared.insertCertificate(userCertificate: c)
            self.dismiss(animated: true, completion: nil)
        }

        detailViewController.view.accessibilityViewIsModal = true
        UIAccessibility.post(notification: .screenChanged, argument: detailViewController.view)
    }
}
