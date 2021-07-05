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

class ScreenProtector {
    private var warningWindow: UIWindow?

    private var window: UIWindow? {
        return UIApplication.shared.windows.first
    }

    func startPreventingRecording() {
        NotificationCenter.default.addObserver(self, selector: #selector(captureDidChange), name: UIScreen.capturedDidChangeNotification, object: nil)
        captureDidChange()
    }

    @objc private func captureDidChange() {
        DispatchQueue.main.async {
            if UIScreen.main.isCaptured {
                self.hideScreenAndPresentWarningWindow()
            } else {
                self.showScreenAndRemoveWarningWindow()
            }
        }
    }

    private func showScreenAndRemoveWarningWindow() {
        UIView.animate(withDuration: 0.15) {
            self.warningWindow?.alpha = 0
            self.window?.alpha = 1
        } completion: { _ in
            self.warningWindow?.removeFromSuperview()
            self.warningWindow = nil
        }
        window?.alpha = 1
    }

    private func hideScreenAndPresentWarningWindow() {
        UIView.animate(withDuration: 0.15) {
            self.window?.alpha = 0
        }

        // Remove exsiting
        warningWindow?.removeFromSuperview()
        warningWindow = nil

        guard let frame = window?.bounds else { return }

        // Warning label
        let label = Label(.title, textColor: .white, textAlignment: .center)
        label.numberOfLines = 0
        label.text = UBLocalized.warning_screen_recording

        // warning window
        let warningWindow = UIWindow(frame: frame)

        warningWindow.frame = frame
        warningWindow.backgroundColor = .cc_green_dark
        warningWindow.windowLevel = UIWindow.Level.statusBar + 1
        warningWindow.clipsToBounds = true
        warningWindow.isHidden = false
        warningWindow.alpha = 0
        warningWindow.addSubview(label)

        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Padding.medium)
        }

        self.warningWindow = warningWindow

        UIView.animate(withDuration: 0.15) {
            warningWindow.alpha = 1.0
        }
        warningWindow.makeKeyAndVisible()
    }
}
