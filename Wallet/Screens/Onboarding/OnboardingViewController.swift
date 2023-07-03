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

class OnboardingViewController: OnboardingBaseViewController {
    var viewControllers: [StaticContentViewController] = {
        var vcs = [.theApp, .store, .show, .privacy].compactMap { StaticContentViewController(models: [$0], contentViewType: .onboarding) }
        return vcs
    }()

    override internal var stepViewControllers: [OnboardingContentViewController] {
        return viewControllers
    }

    override internal var finalStepIndex: Int {
        return stepViewControllers.dropLast().count
    }

    override public func completedOnboarding() {
        WalletUserStorage.shared.hasCompletedOnboarding = true
        WalletUserStorage.lastInstalledAppVersion = ConfigManager.shortAppVersion
        (UIApplication.shared.delegate as? AppDelegate)?.didCompleteOnboarding()
    }
}
