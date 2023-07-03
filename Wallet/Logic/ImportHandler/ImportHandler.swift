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
import PDFKit

class ImportHandler {
    private weak var delegate: NavigationController?

    // MARK: - Init

    init(delegate: NavigationController) {
        self.delegate = delegate
    }

    // MARK: - Handle URL

    public func handle(url: URL) {
        _ = url.startAccessingSecurityScopedResource()

        var images: [CGImage] = []

        if isPdf(url: url) {
            images = drawImagesFromPDF(url: url)
        } else if let img = UIImage(contentsOfFile: url.path), let cgImage = img.cgImage {
            images = [cgImage]
        }

        if images.count > 0 {
            let messages = images.compactMap { findQrCodeContent(image: $0) }

            if let message = messages.first {
                handleMessage(message: message)
            } else {
                presentMissingQRCodeError()
            }
        } else {
            presentWrongFileError()
        }

        url.stopAccessingSecurityScopedResource()
    }

    public func handleMessage(message: String) {
        let certificate = UserCertificate(qrCode: message)

        switch certificate.decodedCertificate {
        case .success:
            delegate?.topViewController?.dismiss(animated: false, completion: nil)

            let vc = CertificateAddDetailViewController(showScanAgainButton: false)
            vc.certificate = certificate
            vc.addDismissButton()

            let navVC = NavigationController(rootViewController: vc, useNavigationBar: true)

            vc.addOrOkCertificateTouchUpCallback = { [weak self] certificate in
                guard let c = certificate, let strongSelf = self else { return }

                CertificateStorage.shared.insertCertificate(userCertificate: c)

                (UIApplication.shared.delegate as? AppDelegate)?.didFinishImport()

                navVC.dismiss(animated: true, completion: {
                    if let vc = strongSelf.delegate?.viewControllers.first as? WalletHomescreenViewController {
                        vc.certificatesViewController.changeAccessibilityFocus(toCertificate: c)
                    }
                })
            }

            delegate?.present(navVC, animated: true, completion: nil)

        case .failure:
            presentError()
        }
    }

    func presentMissingQRCodeError() {
        presentError()
    }

    func presentWrongFileError() {
        presentError()
    }

    func presentError() {
        delegate?.topViewController?.dismiss(animated: false, completion: nil)

        let alert = UIAlertController(title: UBLocalized.error_title, message: UBLocalized.wallet_import_error_invalid_format, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: UBLocalized.ok_button, style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))

        delegate?.present(alert, animated: true, completion: nil)
    }

    // MARK: - Helpers

    func isPdf(url: URL) -> Bool {
        return url.pathExtension.caseInsensitiveEquals("pdf")
    }

    func drawImagesFromPDF(url: URL) -> [CGImage] {
        guard let document = CGPDFDocument(url as CFURL) else { return [] }

        guard document.numberOfPages <= 2 else { return [] }

        var images: [CGImage] = []

        // CGPDFDocument pages start at 1
        for i in 1 ..< document.numberOfPages + 1 {
            if let page = document.page(at: i) {
                let pageRect = page.getBoxRect(.mediaBox)
                let renderer = UIGraphicsImageRenderer(size: pageRect.size)

                let img = renderer.image { ctx in
                    UIColor.white.set()
                    ctx.fill(pageRect)

                    ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                    ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                    ctx.cgContext.interpolationQuality = .high

                    ctx.cgContext.drawPDFPage(page)
                }

                if let image = img.cgImage {
                    images.append(image)
                }
            }
        }

        return images
    }

    func findQrCodeContent(image cgImage: CGImage) -> String? {
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) else {
            return nil
        }

        let ciImage = CIImage(cgImage: cgImage)

        let features = detector.features(in: ciImage)
        for feature in features {
            if let feature = feature as? CIQRCodeFeature {
                return feature.messageString
            }
        }

        return nil
    }
}

extension String {
    func caseInsensitiveEquals(_ string: String) -> Bool {
        return caseInsensitiveCompare(string) == .orderedSame
    }
}
