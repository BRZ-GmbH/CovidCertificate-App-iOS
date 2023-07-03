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

/* Extension of HomescreenViewController to handle the direct links to add a certificate*/
extension WalletHomescreenViewController {
    func addCertificateDirectly(url: URL, secret: String, signature: String) {
        activeDirectLinkURL = url
        
        directLinkActionPopupView.addCertificateTouchUpCallback = { [weak self] birthday in
            self?.addCertificateTouchUpCallback(secret: secret, secretSignature: signature, birthday: birthday)
        }

        errorRetryHandler = { _ in
            self.directLinkActionPopupView.presentFrom(view: self.view)
            self.dismiss(animated: true, completion: nil)
        }
        onErrorMessage = UBLocalized.error_retrieving_certificate

        directLinkActionPopupView.presentFrom(view: view)
    }

    func addCertificateTouchUpCallback(secret: String, secretSignature: String, birthday: Date?) {
        let request = getRequestWithBirthday(secret: secret, secretSignature: secretSignature, birthday: birthday)
        HttpRequestHandler.sendRequest(request, handleResponse: handleResponse)
    }

    func addCertificateDirectlyWithBpt(url: URL, secret: String, secretSignature: String, bpt: String) {
        activeDirectLinkURL = url
        
        let request = getRequestWithBpt(secret: secret, secretSignature: secretSignature, bpt: bpt)

        errorRetryHandler = { _ in
            HttpRequestHandler.sendRequest(request, handleResponse: self.handleResponse)

            self.dismiss(animated: true, completion: nil)
        }
        onErrorMessage = UBLocalized.error_retrieve_certificate_bypass

        HttpRequestHandler.sendRequest(request, handleResponse: handleResponse)
    }

    func getRequestWithBirthday(secret: String, secretSignature: String, birthday: Date?) -> URLRequest {
        let components = NSCalendar.current.dateComponents([.day, .month, .year], from: (birthday ?? Date()) as Date)
        let json: [String: Any] = [
            "secret": secret,
            "secretSignature": secretSignature,
            "birthdate": [
                "day": components.day!,
                "month": components.month!,
                "year": components.year!,
            ],
            "request": ["qr"],
        ]

        return HttpRequestHandler.makePostRequest(url: URL(string: Environment.current.directLinkUrl)!, json: json)
    }

    func getRequestWithBpt(secret: String, secretSignature: String, bpt: String) -> URLRequest {
        let json: [String: Any] = [
            "secret": secret,
            "secretSignature": secretSignature,
            "bypassToken": bpt,
            "request": ["qr"],
        ]

        return HttpRequestHandler.makePostRequest(url: URL(string: Environment.current.directLinkUrl)!, json: json)
    }

    func handleResponse(data: Data?, response: URLResponse?, error: Error?) {
        if let err = error as? URLError, err.code == URLError.Code.notConnectedToInternet {
            DispatchQueue.main.async {
                self.networkError()
            }
            return
        }

        guard let res = response as? HTTPURLResponse, let data = data, res.statusCode == 200 else {
            DispatchQueue.main.async {
                self.onError()
            }
            return
        }

        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let responseJSON = responseJSON as? [String: Any] else {
            DispatchQueue.main.async {
                self.onError()
            }
            return
        }

        DispatchQueue.main.async {
            if let qrCode = responseJSON["qr"] as? String {
                self.addCertificate(qrCode: qrCode)
            } else if let url = self.activeDirectLinkURL {
                self.showErrorAboutMissingQRCode(url: url)
            } else {
                self.onError()
            }
        }
    }

    func addCertificate(qrCode: String) {
        let cert = UserCertificate(qrCode: qrCode)

        switch cert.decodedCertificate {
        case .success:
            let feedback = UIImpactFeedbackGenerator(style: .heavy)
            feedback.impactOccurred()

            let vc = AddCertificateViewController()
            vc.detailViewController.certificate = cert
            vc.presentInNavigationController(from: self)
            self.activeDirectLinkURL = nil
        case .failure:
            onError()
        }
    }

    private func showErrorAboutMissingQRCode(url: URL) {
        guard let url = activeDirectLinkURL else { return }
        
        let alert = UIAlertController(title: UBLocalized.error_title, message: UBLocalized.error_retrieve_certificate_no_code, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: UBLocalized.cancel_button, style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
            self.activeDirectLinkURL = nil
        }))
        alert.addAction(UIAlertAction(title: UBLocalized.open_browser_button, style: .default, handler: { _ in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            self.activeDirectLinkURL = nil
        }))
        
        present(alert, animated: true, completion: nil)
    }

    private func onError() {
        let alert = UIAlertController(title: UBLocalized.error_title, message: onErrorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: UBLocalized.cancel_button, style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
            self.activeDirectLinkURL = nil
        }))
        alert.addAction(UIAlertAction(title: UBLocalized.error_action_retry, style: .cancel, handler: errorRetryHandler))

        present(alert, animated: true, completion: nil)
    }

    func invalidLinkError() {
        let alert = UIAlertController(title: UBLocalized.invalid_link_title, message: UBLocalized.invalid_link_text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: UBLocalized.ok_button, style: .default, handler: nil))

        present(alert, animated: true, completion: nil)
        self.activeDirectLinkURL = nil
    }

    func networkError() {
        ProgressOverlayView.dismissProgressOverlayIn(view: view)

        let alert = UIAlertController(title: UBLocalized.error_network_title, message: UBLocalized.error_network_text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: UBLocalized.ok_button, style: .default, handler: nil))

        alert.addAction(UIAlertAction(title: UBLocalized.error_action_retry, style: .cancel, handler: errorRetryHandler))

        present(alert, animated: true, completion: nil)
        self.activeDirectLinkURL = nil
    }
}
