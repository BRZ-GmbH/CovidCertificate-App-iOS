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
        timeStatus = (false, Clock.now)
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
                var shouldRestart = true
                if let old = oldStatus, let new = self.timeStatus?.time, abs(old.timeIntervalSince(new)) < 5 {
                    shouldRestart = false
                }
                if shouldRestart {
                    self.restartAllVerifiers()
                }
            }
        }
    }

    func updateTime() {
        fetchTime()
        timeStatus = (false, Clock.now)
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
    
    /**
     In test builds (for Q as well as P environment) we allow switching a setting for the app to either use the real time fetched from a time server (behaviour in the published app) or to use the current device time for validating the business rules.
     */
    #if RELEASE_ABNAHME || RELEASE_PROD_TEST
    @UBUserDefault(key: "wallet.test.useDeviceTime", defaultValue: false)
    public var useDeviceTime: Bool {
        didSet {
            self.restartAllVerifiers()
        }
    }
    #endif
    
    private func restartAllVerifiers() {
        var validationTime = timeStatus?.time
        
        /**
         In test builds (for Q as well as P environment) we allow switching a setting for the app to either use the real time fetched from a time server (behaviour in the published app) or to use the current device time for validating the business rules.
         */
        #if RELEASE_ABNAHME || RELEASE_PROD_TEST
        if useDeviceTime {
            validationTime = Date()
        }
        #endif
        
        self.verifiers.forEach { _, verifier in
            verifier.restart(forceUpdate: true, validationTime: validationTime)
        }
    }

    // MARK: - Public API

    func addObserver(_ object: AnyObject, for qrString: String, regions: [String], checkDefaultRegion: Bool, forceUpdate: Bool = false, important: Bool = false, block: @escaping (VerificationResultStatus) -> Void) {
        var validationTime = timeStatus?.time
        /**
         In test builds (for Q as well as P environment) we allow switching a setting for the app to either use the real time fetched from a time server (behaviour in the published app) or to use the current device time for validating the business rules.
         */
        #if RELEASE_ABNAHME || RELEASE_PROD_TEST
            if useDeviceTime {
                validationTime = Date()
            }
        #endif
        
        if observers[qrString] != nil {
            observers[qrString] = observers[qrString]!.filter { $0.object != nil && !$0.object!.isEqual(object) }
            observers[qrString]?.append(Observer(object: object, block: block))
        } else {
            observers[qrString] = [Observer(object: object, block: block)]
        }

        if let v = verifiers[qrString], v.regions.elementsEqual(regions) {
            if v.isRunningWith(validationTime) == false {
                v.important = important
                v.restart(forceUpdate: forceUpdate, validationTime: validationTime)
            }
        } else {
            if let v = verifiers[qrString] {
                v.cancelled = true
            }
            let v = Verifier(qrString: qrString, regions: regions, checkDefaultRegion: checkDefaultRegion, validationTime: validationTime)
            v.important = important
            verifiers[qrString] = v
            v.start(forceUpdate: forceUpdate) { state in
                self.updateObservers(for: qrString, state: state)
            }
        }
    }
}
