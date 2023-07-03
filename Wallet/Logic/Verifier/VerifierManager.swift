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

    private(set) var isSyncingTime = false

    var isSyncingData = false

    private var timeRetryTimer: Timer?

    struct VerificationResult {
        let timestamp: Date
        let state: VerificationResultStatus
    }

    private var lastKnownResults: [String: VerificationResult] = [:]

    var currentTime: Date? {
        #if RELEASE_ABNAHME || RELEASE_PROD_TEST
            if useDeviceTime {
                return Date()
            }
        #endif
        return timeStatus?.time
    }

    func resetTime() {
        timeStatus = (false, Clock.now)
        timeRetryTimer?.invalidate()
        timeRetryTimer = nil
        lastKnownResults = [:]
        verifiers.values.forEach { $0.cancelled = true }
    }

    @objc private func fetchTime() {
        timeRetryTimer?.invalidate()
        timeRetryTimer = nil

        fetchCurrentTime(main: true)
    }

    private func fetchCurrentTime(main: Bool) {
        let syncStart = Date().timeIntervalSinceReferenceDate
        isSyncingTime = true
        Clock.sync(from: main ? "ts1.univie.ac.at" : "ts2.univie.ac.at", samples: 2, first: nil) { [weak self] fetchedDate, _ in
            guard let self = self else { return }
            self.isSyncingTime = false
            let oldStatus = self.timeStatus?.time
            let syncDuration = Date().timeIntervalSinceReferenceDate - syncStart

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

            if oldStatus != self.timeStatus?.time || (oldStatus == nil && self.timeStatus?.time == nil) {
                var shouldRestart = true
                // We need to take the response time for the sync into account to correctly compare
                if let old = oldStatus, let new = self.timeStatus?.time, abs(old.addingTimeInterval(syncDuration).timeIntervalSince(new)) < 30 {
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

        lastKnownResults[qrString] = VerificationResult(timestamp: Clock.now ?? Date(), state: state)

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
                restartAllVerifiers()
            }
        }
    #endif

    private(set) var allCertificates: [DGCHolder] = []

    public func restartAllVerifiers() {
        var validationTime = timeStatus?.time

        allCertificates = reloadAllCertificates()

        /**
         In test builds (for Q as well as P environment) we allow switching a setting for the app to either use the real time fetched from a time server (behaviour in the published app) or to use the current device time for validating the business rules.
         */
        #if RELEASE_ABNAHME || RELEASE_PROD_TEST
            if useDeviceTime {
                validationTime = Date()
            }
        #endif

        lastKnownResults = [:]

        verifiers.forEach { _, verifier in
            verifier.restart(forceUpdate: true, validationTime: validationTime, realTime: timeStatus?.time)
        }
    }

    // MARK: - Public API

    private func reloadAllCertificates() -> [DGCHolder] {
        return CertificateStorage.shared.userCertificates.compactMap {
            if case let .success(holder) = $0.decodedCertificate {
                return holder
            }
            return nil
        }.sorted(by: { ($0.issuedAt ?? Date()).isAfter($1.issuedAt ?? Date()) })
    }

    func addObserver(_ object: AnyObject, for certificate: UserCertificate, region: String, forceUpdate: Bool = false, important: Bool = false, block: @escaping (VerificationResultStatus) -> Void) {
        var validationTime = timeStatus?.time
        /**
         In test builds (for Q as well as P environment) we allow switching a setting for the app to either use the real time fetched from a time server (behaviour in the published app) or to use the current device time for validating the business rules.
         */
        #if RELEASE_ABNAHME || RELEASE_PROD_TEST
            if useDeviceTime {
                validationTime = Date()
            }
        #endif

        if observers[certificate.qrCode] != nil {
            observers[certificate.qrCode] = observers[certificate.qrCode]!.filter { $0.object != nil && !$0.object!.isEqual(object) }
            observers[certificate.qrCode]?.append(Observer(object: object, block: block))
        } else {
            observers[certificate.qrCode] = [Observer(object: object, block: block)]
        }

        if let v = verifiers[certificate.qrCode], v.region == region {
            if v.isRunningWith(validationTime) == false {
                // EPIEMSCO-1506: Cache the last known result for up to five minutes if not invalidated for some other reason
                if let knownResult = lastKnownResults[certificate.qrCode], (Clock.now ?? Date()).timeIntervalSince(knownResult.timestamp) < (5 * 60) {
                    block(knownResult.state)
                    return
                }
                v.important = important
                v.restart(forceUpdate: forceUpdate, validationTime: validationTime, realTime: timeStatus?.time)
            }
        } else {
            if let v = verifiers[certificate.qrCode] {
                v.cancelled = true
            }
            let v = Verifier(certificate: certificate, region: region, validationTime: validationTime, realTime: timeStatus?.time)
            v.important = important
            verifiers[certificate.qrCode] = v
            v.start(forceUpdate: forceUpdate) { state in
                self.updateObservers(for: certificate.qrCode, state: state)
            }
        }
    }

    func removeObserver(_ object: AnyObject, for certificate: UserCertificate) {
        observers[certificate.qrCode] = observers[certificate.qrCode]!.filter { $0.object != nil && !$0.object!.isEqual(object) }
    }
}
