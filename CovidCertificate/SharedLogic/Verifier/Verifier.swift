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

enum VerificationError: Equatable, Comparable {
    case signature
    case typeInvalid
    case revocation
    case expired(Date)
    case signatureExpired
    case notYetValid(Date)
    case otherNationalRules
    case unknown
}

enum RetryError: Equatable {
    case network
    case noInternetConnection
    case unknown
}

/**
 Represents the verification result for an invididual region
 */
struct VerificationRegionResult: Equatable {
    let region: String?
    let valid: Bool
}

/**
 Represents the verification result for a certificate
 */
enum VerificationResultStatus: Equatable {
    case loading
    case signatureInvalid
    case error
    case timeMissing
    case dataExpired
    case success([VerificationRegionResult])

    public func isSuccess() -> Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }

    /**
     Return the invididual region results for the success state
     */
    public func results() -> [VerificationRegionResult] {
        switch self {
        case let .success(result): return result
        default: return []
        }
    }

    /**
     Returns true if the result is error, signatureInvalid or contains any invalid region result
     */
    public func isInvalid() -> Bool {
        switch self {
        case .signatureInvalid: return true
        case .error: return true
        case .success: return containsOnlyInvalidVerification()
        default: return false
        }
    }

    /**
     Returns true if the result contains any invalid region result
     */
    public func containsOnlyInvalidVerification() -> Bool {
        switch self {
        case let .success(result): return result.filter { $0.valid }.count == 0
        default: return false
        }
    }
}

class Verifier: NSObject {
    private var finished: Bool = false
    public var cancelled: Bool = false
    public var important: Bool = false
    private let holder: DGCHolder?
    public let regions: [String]
    private let checkDefaultRegion: Bool
    private var stateUpdate: ((VerificationResultStatus) -> Void)?
    private var validationTime: Date?

    // MARK: - Init

    init(holder: DGCHolder) {
        self.holder = holder
        regions = []
        checkDefaultRegion = true
        super.init()
    }

    init(qrString: String, regions: [String], checkDefaultRegion: Bool, validationTime: Date?) {
        let result = CovidCertificateSDK.decode(encodedData: qrString)

        self.regions = regions
        self.checkDefaultRegion = checkDefaultRegion
        self.validationTime = validationTime

        switch result {
        case let .success(holder):
            self.holder = holder
        case .failure:
            holder = nil
        }

        super.init()
    }

    // MARK: - Start
    
    public func isRunningWith(_ time: Date?) -> Bool {
        if self.finished {
            return false
        }
        if let time = time {
            if let validationTime = validationTime {
                return validationTime == time
            } else {
                return false
            }
        }
        return false
    }

    public func start(forceUpdate: Bool = false, stateUpdate: @escaping ((VerificationResultStatus) -> Void)) {
        self.finished = false
        self.stateUpdate = stateUpdate

        guard holder != nil else {
            // should never happen
            self.stateUpdate?(.error)
            return
        }

        DispatchQueue.main.async {
            self.stateUpdate?(.loading)
        }

        let group = DispatchGroup()

        var states: [VerificationResultStatus] = [.loading]

        checkSignature(group: group, forceUpdate: forceUpdate) { state in states[0] = state }

        if validationTime != nil {
            if checkDefaultRegion {
                let index = states.count
                states.append(.loading)
                checkNationalRules(group: group, region: nil, forceUpdate: forceUpdate, callback: { state in states[index] = state })
            }

            regions.forEach { region in
                let index = states.count
                states.append(.loading)
                checkNationalRules(group: group, region: region, forceUpdate: forceUpdate, callback: { state in states[index] = state })
            }
        }

        group.notify(queue: .main) {
            self.finished = true
            if self.cancelled {
                return
            }
            if states[0] == .error || states[0] == .signatureInvalid {
                self.stateUpdate?(states[0])
            } else if states.contains(where: { $0 == VerificationResultStatus.dataExpired }) {
                self.stateUpdate?(.dataExpired)
            } else if states.allSatisfy({ $0.isSuccess() }) {
                if self.validationTime != nil {
                    let results = states.flatMap { $0.results() }
                    self.stateUpdate?(.success(results))
                } else {
                    self.stateUpdate?(.timeMissing)
                }
            } else {
                self.stateUpdate?(.error)
            }
        }
    }

    public func restart(forceUpdate: Bool = false, validationTime: Date?) {
        guard let su = stateUpdate else { return }
        self.validationTime = validationTime
        start(forceUpdate: forceUpdate, stateUpdate: su)
    }

    // MARK: - Signature

    private func checkSignature(group: DispatchGroup, forceUpdate _: Bool, callback: @escaping (VerificationResultStatus) -> Void) {
        guard let holder = self.holder else { return }

        group.enter()

        DispatchQueue.global(qos: .userInteractive).async {
            CovidCertificateSDK.decodeAndCheckSignature(encodedData: holder.encodedData, validationClock: self.validationTime ?? Date()) { result in
                switch result {
                case let .success(result):
                    if result.isValid {
                        callback(.success([]))
                    } else {
                        callback(.signatureInvalid)
                    }

                case let .failure(err):
                    switch err {
                    case .CBOR_DESERIALIZATION_FAILED:
                        callback(.error)
                    case .CWT_EXPIRED:
                        callback(.success([]))
                    case .KEY_NOT_IN_TRUST_LIST:
                        callback(.signatureInvalid)
                    case .DATA_EXPIRED:
                        callback(.dataExpired)
                    default:
                        callback(.error)
                    }
                }

                group.leave()
            }
        }
    }

    private func checkNationalRules(group: DispatchGroup, region: String?, forceUpdate: Bool, callback: @escaping (VerificationResultStatus) -> Void) {
        guard let holder = self.holder else { return }
        guard let issuedAt = holder.issuedAt else { return }
        guard let expiresAt = holder.expiresAt else { return }
        guard let validationClock = validationTime else { return }

        group.enter()
        DispatchQueue.global(qos: important ? .userInitiated : .utility).async {
            CovidCertificateSDK.checkNationalRules(dgc: holder.healthCert, validationClock: validationClock, issuedAt: issuedAt, expiresAt: expiresAt, countryCode: "AT", region: region, forceUpdate: forceUpdate) { result in
                switch result {
                case let .success(result):
                    if result.isValid {
                        callback(.success([VerificationRegionResult(region: region, valid: true)]))
                    } else {
                        callback(.success([VerificationRegionResult(region: region, valid: false)]))
                    }
                case let .failure(error):
                    if error == .DATA_EXPIRED {
                        callback(.dataExpired)
                    } else {
                        callback(.success([VerificationRegionResult(region: region, valid: false)]))
                    }
                }

                group.leave()
            }
        }
    }
}
