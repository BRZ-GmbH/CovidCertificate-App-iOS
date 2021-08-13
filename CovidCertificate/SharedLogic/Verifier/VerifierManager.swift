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

import CovidCertificateSDK
import Foundation
import Kronos

final class VerifierManager {
    // MARK: - Singleton

    static let shared = VerifierManager()

    var timeStatus: (fetched: Bool, time: Date?)? = (false, nil)

    private init() {}

    // MARK: - Properties

    private var verifiers: [String: Verifier] = [:]

    // MARK: - State Observers

    private struct Observer {
        weak var object: AnyObject?
        var block: (VerificationResultStatus) -> Void
    }

    private var observers: [String: [Observer]] = [:]

    private var timeRetryTimer: Timer?

    func resetTime() {
        timeStatus = (false, nil)
        timeRetryTimer?.invalidate()
        timeRetryTimer = nil
    }

    @objc private func fetchTime() {
        timeRetryTimer?.invalidate()
        timeRetryTimer = nil

        fetchCurrentTime(main: true)
    }

    private func fetchCurrentTime(main: Bool) {
        Clock.sync(from: main ? "ts1.univie.ac.at" : "ts2.univie.ac.at", samples: 2, first: nil) { [weak self] fetchedDate, _ in
            guard let self = self else { return }
            let oldStatus = self.timeStatus?.time

            if fetchedDate != nil {
                self.timeStatus = (true, Clock.now)
            } else {
                self.timeStatus = (true, nil)

                if main {
                    self.fetchCurrentTime(main: false)
                } else {
                    self.timeRetryTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { [weak self] _ in
                        self?.fetchTime()
                    })
                }
            }

            if oldStatus != self.timeStatus?.time {
                self.verifiers.forEach { _, verifier in
                    verifier.restart(forceUpdate: true, validationTime: self.timeStatus?.time)
                }
            }
        }
    }

    func updateTime() {
        fetchTime()
    }

    private func updateObservers(for qrString: String, state: VerificationResultStatus) {
        guard let list = observers[qrString] else { return }
        let newList = list.filter { $0.object != nil }

        guard !newList.isEmpty else {
            verifiers[qrString] = nil
            return
        }

        DispatchQueue.main.async {
            newList.forEach { $0.block(state) }
        }
    }

    // MARK: - Public API

    func addObserver(_ object: AnyObject, for qrString: String, regions: [String], checkDefaultRegion: Bool, forceUpdate: Bool = false, block: @escaping (VerificationResultStatus) -> Void) {
        if observers[qrString] != nil {
            observers[qrString] = observers[qrString]!.filter { $0.object != nil && !$0.object!.isEqual(object) }
            observers[qrString]?.append(Observer(object: object, block: block))
        } else {
            observers[qrString] = [Observer(object: object, block: block)]
        }

        if let v = verifiers[qrString] {
            v.restart(forceUpdate: forceUpdate, validationTime: timeStatus?.time)
        } else {
            let v = Verifier(qrString: qrString, regions: regions, checkDefaultRegion: checkDefaultRegion, validationTime: timeStatus?.time)
            verifiers[qrString] = v
            v.start(forceUpdate: forceUpdate) { state in
                self.updateObservers(for: qrString, state: state)
            }
        }
    }
}
