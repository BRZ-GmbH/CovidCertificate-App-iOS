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

class HomescreenCertificatesViewController: ViewController {
    // MARK: - API

    public var touchedCertificateCallback: ((UserCertificate) -> Void)?

    // MARK: - Subviews

    private let stackScrollView = StackScrollView(axis: .horizontal, spacing: 0)

    private lazy var pageControl: UIView = {
        // On iOS 14 or later, UIPageControl supports handling more pages than fit on the screen. Pre iOS 14 we use a custom PageControl that can handle this accordingly.
        if #available(iOS 14.0, *) {
            return UIPageControl()
        } else {
            return AccessibilityScrollingPageControl()
        }
    }()

    private var certificateViews: [HomescreenCertificateView] = []
    private let maxDots = 11
    private let centerDots = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupAccessibilityIdentifiers()

        UIStateManager.shared.addObserver(self) { [weak self] state in
            guard let strongSelf = self else { return }
            strongSelf.refresh(state.certificateState.certificates)
        }
    }

    public func changeAccessibilityFocus(toCertificate certificate: UserCertificate) {
        if let certView = certificateViews.first(where: { $0.certificate == certificate }) {
            UIAccessibility.post(notification: .screenChanged, argument: certView)
        }
    }

    private func setup() {
        view.backgroundColor = .clear
        view.addSubview(pageControl)

        let isSmall = UIScreen.main.bounds.width <= 375
        let pageControlBottomPadding = isSmall ? Padding.small : (Padding.large + Padding.medium)

        pageControl.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Padding.large)
            make.bottom.equalToSuperview().inset(pageControlBottomPadding)
        }

        stackScrollView.scrollView.isPagingEnabled = true
        view.addSubview(stackScrollView)

        stackScrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Padding.large - HomescreenCertificateView.inset)
            make.top.equalToSuperview()
            make.bottom.equalTo(self.pageControl.snp.top).offset(-Padding.medium)
        }

        if let pageControl = pageControl as? UIPageControl {
            pageControl.accessibilityTraits = .adjustable
            pageControl.addTarget(self, action: #selector(handlePageChange), for: .valueChanged)
        } else if let pageControl = pageControl as? AccessibilityScrollingPageControl {
            pageControl.dotSize = 7.5
            pageControl.spacing = 10
            pageControl.selectedColor = .cc_white
            pageControl.dotColor = .cc_black
            pageControl.accessibilityTraits = .adjustable
            pageControl.pageChangeCallback = handlePageChange
        }
        stackScrollView.clipsToBounds = false
        stackScrollView.scrollView.clipsToBounds = false
        stackScrollView.stackView.clipsToBounds = false
        stackScrollView.scrollView.delegate = self
    }

    private func setupAccessibilityIdentifiers() {
        pageControl.accessibilityIdentifier = "homescreen_certificates_tab_layout"
    }

    private var currentPageControlPage: Int {
        get {
            if let pageControl = pageControl as? UIPageControl {
                return pageControl.currentPage
            } else if let pageControl = pageControl as? AccessibilityScrollingPageControl {
                return pageControl.selectedPage
            }
            return 0
        }
        set {
            if let pageControl = pageControl as? UIPageControl {
                pageControl.currentPage = newValue
            } else if let pageControl = pageControl as? AccessibilityScrollingPageControl {
                pageControl.selectedPage = newValue
            }
        }
    }

    @objc private func handlePageChange() {
        let width = stackScrollView.scrollView.frame.width

        stackScrollView.scrollView.delegate = nil
        UIView.animate(withDuration: 0.3) {
            self.stackScrollView.scrollView.setContentOffset(CGPoint(x: width * CGFloat(self.currentPageControlPage), y: 0.0), animated: false)
        } completion: { _ in
            self.stackScrollView.scrollView.delegate = self
        }

        pageControl.accessibilityValue = [UBLocalized.accessibility_page_control_page,
                                          "\(currentPageControlPage + 1)",
                                          UBLocalized.accessibility_of_text,
                                          "\((pageControl as? UIPageControl)?.numberOfPages ?? 0)"].compactMap { $0 }.joined(separator: " ")
    }

    private func refresh(_ certificates: [UserCertificate]) {
        stackScrollView.removeAllViews()

        certificateViews.removeAll()

        if let pageControl = pageControl as? UIPageControl {
            pageControl.numberOfPages = certificates.count
            pageControl.alpha = certificates.count <= 1 ? 0.0 : 1.0
        } else if let pageControl = pageControl as? AccessibilityScrollingPageControl {
            pageControl.maxDots = maxDots
            pageControl.centerDots = certificates.count <= maxDots ? maxDots : centerDots
            pageControl.selectedPage = 0
            pageControl.isAccessibilityElement = true
            pageControl.pages = certificates.count
            pageControl.alpha = certificates.count <= 1 ? 0.0 : 1.0
        }

        for c in certificates {
            let v = HomescreenCertificateView(certificate: c)
            stackScrollView.addArrangedView(v)
            certificateViews.append(v)

            v.snp.makeConstraints { make in
                make.width.equalTo(stackScrollView)
            }

            v.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.touchedCertificateCallback?(c)
            }
        }
        startChecks()
    }

    private func startChecks() {
        var index = 0
        for i in certificateViews {
            VerifierManager.shared.addObserver(self, for: i.certificate, region: WalletUserStorage.shared.selectedValidationRegion ?? "W", important: index < 2) { [weak i] state in
                i?.state = state
            }
            index = index + 1
        }
    }
}

extension HomescreenCertificatesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = round(scrollView.contentOffset.x / scrollView.frame.width)
        currentPageControlPage = Int(page)

        if let _ = pageControl as? UIPageControl {
            pageControl.accessibilityValue = [UBLocalized.accessibility_page_control_page,
                                              "\(currentPageControlPage + 1)",
                                              UBLocalized.accessibility_of_text,
                                              "\((pageControl as? UIPageControl)?.numberOfPages ?? 0)"].compactMap { $0 }.joined(separator: " ")
        }
    }
}

extension UIScrollView {
    var currentPage: Int {
        return Int((contentOffset.x + 0.5 * frame.size.width) / frame.width)
    }
}
