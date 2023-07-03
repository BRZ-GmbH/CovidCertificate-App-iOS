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

import BusinessRulesValidationCore
import Foundation
import ValidationCore

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

class Verifier: NSObject {
    private var finished: Bool = false
    public var cancelled: Bool = false
    public var important: Bool = false
    private let holder: DGCHolder?
    public let region: String
    private var stateUpdate: ((VerificationResultStatus) -> Void)?
    private var validationTime: Date?
    private var realTime: Date?

    // MARK: - Init

    init(holder: DGCHolder) {
        self.holder = holder
        region = "W"
        super.init()
    }

    init(certificate: UserCertificate, region: String, validationTime: Date?, realTime: Date?) {
        self.region = region
        self.validationTime = validationTime
        self.realTime = realTime

        switch certificate.decodedCertificate {
        case let .success(holder):
            self.holder = holder
        case .failure:
            holder = nil
        }

        super.init()
    }

    // MARK: - Start

    public func isRunningWith(_ time: Date?) -> Bool {
        if finished || cancelled {
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
        finished = false
        cancelled = false
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

        var signatureCheck: VerificationResultStatus = .loading
        var rulesCheck: VerificationResultStatus = .loading

        if validationTime != nil {
            checkSignature(group: group, forceUpdate: forceUpdate) { [weak self] state in
                signatureCheck = state

                if case .success = signatureCheck {
                    self?.checkNationalRules(group: group, region: self?.region ?? "W", forceUpdate: forceUpdate, callback: { state in
                        rulesCheck = state
                    })
                }
            }
        }

        group.notify(queue: .main) {
            self.finished = true

            if self.cancelled {
                return
            }

            if signatureCheck == .error || signatureCheck == .signatureInvalid || signatureCheck == .signatureExpired {
                self.stateUpdate?(signatureCheck)
            } else if signatureCheck == .dataExpired || rulesCheck == .dataExpired {
                if VerifierManager.shared.isSyncingData {
                    self.stateUpdate?(.loading)
                } else {
                    self.stateUpdate?(.dataExpired)
                }
            } else if self.validationTime == nil {
                if VerifierManager.shared.isSyncingTime {
                    self.stateUpdate?(.loading)
                } else {
                    self.stateUpdate?(.timeMissing)
                }
            } else if case .success = signatureCheck, case let .success(result) = rulesCheck {
                self.stateUpdate?(.success(result))
            } else {
                self.stateUpdate?(.error)
            }
        }
    }

    public func restart(forceUpdate: Bool = false, validationTime: Date?, realTime: Date?) {
        guard let su = stateUpdate else { return }
        self.validationTime = validationTime
        self.realTime = realTime
        start(forceUpdate: forceUpdate, stateUpdate: su)
    }
}

// MARK: - Signature

extension Verifier {
    private func checkSignature(group: DispatchGroup, forceUpdate _: Bool, callback: @escaping (VerificationResultStatus) -> Void) {
        guard let holder = holder else { return }

        group.enter()

        DispatchQueue.global(qos: .userInteractive).async {
            CovidCertificateSDK.decodeAndCheckSignature(encodedData: holder.encodedData, validationClock: self.realTime ?? self.validationTime ?? Date()) { result in
                switch result {
                case let .success(result):
                    if result.isValid {
                        callback(.success([:]))
                    } else {
                        callback(.signatureInvalid)
                    }

                case let .failure(err):
                    switch err {
                    case .CBOR_DESERIALIZATION_FAILED:
                        callback(.error)
                    case .CWT_EXPIRED:
                        callback(.success([:]))
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
}

// MARK: - Business Rules

extension Verifier {
    private func checkNationalRules(group: DispatchGroup, region: String, forceUpdate _: Bool, callback: @escaping (VerificationResultStatus) -> Void) {
        guard let holder = holder else { return }
        guard let issuedAt = holder.issuedAt else { return }
        guard let expiresAt = holder.expiresAt else { return }
        guard let validationClock = validationTime else { return }

        let realTimeForCheck = realTime ?? validationClock

        CovidCertificateSDK.updateDateServiceForRules(validationClock: realTimeForCheck)

        group.enter()
        DispatchQueue.global(qos: important ? .userInitiated : .utility).async {
            let certLogicValueSets = CovidCertificateSDK.currentValueSets().mapValues { $0.valueSetValues.map { $0.key } }

            let currentBusinessRules = CovidCertificateSDK.currentBusinessRules()
            switch currentBusinessRules {
            case let .success(rules):
                if let rule = rules.first,
                   let data = rule.data(using: .utf8),
                   let businessRuleContainer = try? BusinessRuleContainer.parsedFrom(data: data) {
                    let core = BusinessRuleValidator(businessRules: businessRuleContainer, valueSets: certLogicValueSets, validationClock: validationClock, externalConditionEvaluator: self, externalConditionEvaluationStrategy: .defaultToFalse)

                    let certificatePayload = try! JSONEncoder().encode(holder.healthCert)
                    let payloadString = String(data: certificatePayload, encoding: .utf8)!

                    let validationResult = core.evaluateCertificate(payloadString, certificateType: holder.healthCert.businessRuleCertificationType!, expiration: expiresAt, issue: issuedAt, country: "AT", region: region, profiles: ["Entry", "NightClub"], originalCertificateObject: holder)
                    callback(.success(validationResult))
                } else {
                    callback(.error)
                }
            case let .failure(error):
                if error == ValidationError.DATA_EXPIRED {
                    callback(.dataExpired)
                } else {
                    callback(.error)
                }
            }
            group.leave()
        }
    }
}

// MARK: - Business Rules External Conditions

extension Verifier: ExternalConditionEvaluator {
    func evaluateExternalCondition(_ condition: String, parameters: [String: String], fromRuleWithId _: String, ruleCertificateType _: String?, region: String, profile: String, originalCertificateObject: Any?) -> Bool? {
        guard let originalCertificateObject = originalCertificateObject as? DGCHolder else {
            return nil
        }

        let originalIdentifier = originalCertificateObject.healthCert.comparableIdentifier

        let otherCertificates = VerifierManager.shared.allCertificates.filter { $0.encodedData != originalCertificateObject.encodedData }
        let otherCertificatesForSamePerson = otherCertificates.filter {
            originalIdentifier == $0.healthCert.comparableIdentifier
        }
        let certLogicValueSets = CovidCertificateSDK.currentValueSets().mapValues { $0.valueSetValues.map { $0.key } }

        let currentBusinessRules = CovidCertificateSDK.currentBusinessRules()
        switch currentBusinessRules {
        case let .success(rules):
            if let rule = rules.first,
               let data = rule.data(using: .utf8),
               let businessRuleContainer = try? BusinessRuleContainer.parsedFrom(data: data) {
                let core = BusinessRuleValidator(businessRules: businessRuleContainer, valueSets: certLogicValueSets, validationClock: validationTime ?? Date(), externalConditionEvaluator: nil, externalConditionEvaluationStrategy: .defaultToTrue)

                let evaluator = ExternalConditionVerifier(originalCertificate: originalCertificateObject, otherCertificates: otherCertificates, otherCertificatesForSamePerson: otherCertificatesForSamePerson, condition: condition, parameters: parameters, region: region, profile: profile, validationTime: validationTime ?? Date(), validationCore: core)
                if let result = evaluator.evaluateCondition() as? Bool {
                    return result
                }
            }
        case .failure:
            return nil
        }
        return nil
    }
}

extension HealthCert {
    var businessRuleCertificationType: BusinessRuleCertificateType? {
        switch type {
        case .vaccination: return .vaccination
        case .test: return .test
        case .recovery: return .recovery
        case .vaccinationExemption: return .vaccinationExemption
        }
    }
}
