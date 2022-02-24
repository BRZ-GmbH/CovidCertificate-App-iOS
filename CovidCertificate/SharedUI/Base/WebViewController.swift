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
import WebKit
import CovidCertificateSDK

class WebViewController: ViewController {
    // MARK: - Variables

    private let webView: WKWebView
    private var loadCount: Int = 0
    private let closeable: Bool
    private let mode: Mode

    enum Mode {
        case local(String)
    }

    // MARK: - Init

    init(mode: Mode, closeable: Bool = true) {
        self.mode = mode
        self.closeable = closeable

        let config = WKWebViewConfiguration()
        config.dataDetectorTypes = []

        switch mode {
        case .local:
            // Disable zoom in web view
            let source: String = "var meta = document.createElement('meta');" +
                "meta.name = 'viewport';" +
                "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
                "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
            let script = WKUserScript(source: source, injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true)

            let contentController = WKUserContentController()
            contentController.addUserScript(script)
            config.userContentController = contentController
        }

        webView = WKWebView(frame: .zero, configuration: config)
        
        super.init()
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        switch mode {
        case let .local(local):
            loadLocal(local)
        }

        if closeable {
            addDismissButton()
        }
        setupAccessibilityIdentifiers()
    }
    
    private func setupAccessibilityIdentifiers() {        
        webView.accessibilityIdentifier = "html_webview"
    }

    private func loadLocal(_ local: String) {
        guard let path = Bundle.main.path(forResource: local, ofType: "html", inDirectory: "Impressum/\(String.languageKey)/")
        else { return }

        let url = URL(fileURLWithPath: path)

        do {
            var string = try String(contentsOf: url)

            string = string.replacingOccurrences(of: "{VERSION}", with: Bundle.appVersion)

            string = string.replacingOccurrences(of: "{APP_NAME}", with: UBLocalized.wallet_onboarding_app_title)
            string = string.replacingOccurrences(of: "{LAW_LINK}", with: UBLocalized.wallet_terms_privacy_link)

            webView.loadHTMLString(string, baseURL: url.deletingLastPathComponent())
        } catch {}
    }

    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Setup

    private func setup() {
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        webView.scrollView.showsHorizontalScrollIndicator = false

        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.backgroundColor = UIColor.cc_background

        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
    }

    // MARK: - Navigation

    @objc private func didPressClose() {
        dismiss(animated: true, completion: nil)
    }
    
    private func updateData() {
        ProgressOverlayView.showProgressOverlayIn(view: self.view, text: UBLocalized.business_rule_update_progress)
        CovidCertificateSDK.restartTrustListUpdate(force: true) { [weak self] wasUpdated, failed in
            guard let self = self else { return }
            ProgressOverlayView.dismissProgressOverlayIn(view: self.view)
            
            let alert = UIAlertController(title: nil, message: failed ? UBLocalized.business_rule_update_failed_message : UBLocalized.business_rule_update_success_message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: UBLocalized.business_rule_update_ok_button, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension WebViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Disable vertical scrolling
        scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        switch navigationAction.navigationType {
        case .linkActivated:
            guard let url = navigationAction.request.url,
                  let scheme = url.scheme
            else {
                decisionHandler(.allow)
                return
            }

            if scheme == "http" || scheme == "https" || scheme == "mailto" || scheme == "tel" {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
            return

        default:
            decisionHandler(.allow)
            return
        }
    }
    
    private func updateCampaignOptOutElement() {
        self.webView.evaluateJavaScript("document.getElementById('campaignOptOut').innerHTML = \"\(WalletUserStorage.hasOptedOutOfNonImportantCampaigns ? UBLocalized.campaigns_opt_in_action : UBLocalized.campaigns_opt_out_action)\";", completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       updateCampaignOptOutElement()
    }
}

extension Bundle {
    static var environment: String {
        #if ENABLE_TESTING
            switch Environment.current {
            case .dev:
                return " DEV"
            case .abnahme:
                return " ABNAHME"
            case .prod:
                return " PROD"
            }
        #else
            switch Environment.current {
            case .dev:
                return " DEV"
            case .abnahme:
                return " ABNAHME"
            case .prod:
                return "p"
            }
        #endif
    }
}
