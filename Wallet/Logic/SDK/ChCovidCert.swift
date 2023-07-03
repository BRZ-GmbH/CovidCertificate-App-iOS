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

import base45_swift
import Foundation
import Gzip
import JSON
import ValidationCore

public enum CovidCertError: Error, Equatable {
    case NOT_IMPLEMENTED
    case INVALID_SCHEME_PREFIX
    case BASE_45_DECODING_FAILED
    case DECOMPRESSION_FAILED
    case COSE_DESERIALIZATION_FAILED
    case HCERT_IS_INVALID

    public var errorCode: String {
        switch self {
        case .NOT_IMPLEMENTED:
            return "D|NI"
        case .INVALID_SCHEME_PREFIX:
            return "D|ISP"
        case .BASE_45_DECODING_FAILED:
            return "D|B45"
        case .DECOMPRESSION_FAILED:
            return "D|ZLB"
        case .COSE_DESERIALIZATION_FAILED:
            return "D|CDF"
        case .HCERT_IS_INVALID:
            return "D|HII"
        }
    }
}

public struct DGCHolder {
    public var healthCert: HealthCert {
        return cwt.healthCert!
    }

    public var issuedAt: Date? {
        return cwt.issuedAt
    }

    public var expiresAt: Date? {
        return cwt.expiresAt
    }

    public let encodedData: String
    let cwt: CWT

    init(encodedData: String, cwt: CWT) {
        self.encodedData = encodedData
        self.cwt = cwt
    }
}

extension ValidationError {
    func asCovidCertError() -> CovidCertError {
        switch self {
        case .INVALID_SCHEME_PREFIX: return .INVALID_SCHEME_PREFIX
        case .BASE_45_DECODING_FAILED: return .BASE_45_DECODING_FAILED
        case .DECOMPRESSION_FAILED: return .DECOMPRESSION_FAILED
        case .COSE_DESERIALIZATION_FAILED: return .COSE_DESERIALIZATION_FAILED
        case .CBOR_DESERIALIZATION_FAILED: return .COSE_DESERIALIZATION_FAILED
        default: return .COSE_DESERIALIZATION_FAILED
        }
    }
}

public struct ChCovidCert {
    private let validationCore: ValidationCore

    public let environment: SDKEnvironment
    public let apiKey: String

    private let trustlistService: TrustlistService
    private let modernBusinessRulesService: ModernBusinessRulesService
    private let nationalTrustlistService: TrustlistService
    private let valueSetsService: ValueSetsService

    init(environment: SDKEnvironment, apiKey: String) {
        self.environment = environment
        self.apiKey = apiKey

        let dateService = DefaultDateService()
        trustlistService = DefaultTrustlistService(
            dateService: dateService,
            trustlistUrl: environment.trustlistUrl,
            signatureUrl: environment.trustlistSignatureUrl,
            trustAnchor: environment.trustlistAnchor,
            source: .euDgc,
            apiToken: apiKey
        )

        nationalTrustlistService = DefaultTrustlistService(
            dateService: dateService,
            trustlistUrl: environment.nationalTrustlistUrl,
            signatureUrl: environment.nationalTrustlistSignatureUrl,
            trustAnchor: environment.trustlistAnchor,
            source: .atNational,
            apiToken: apiKey
        )

        valueSetsService = DefaultValueSetsService(
            dateService: dateService,
            valueSetsUrl: environment.valueSetsUrl,
            signatureUrl: environment.valueSetsSignatureUrl,
            trustAnchor: environment.trustlistAnchor,
            apiToken: apiKey
        )

        modernBusinessRulesService = DefaultModernBusinessRulesService(
            dateService: dateService,
            businessRulesUrl: environment.modernBusinessRulesUrl,
            signatureUrl: environment.modernBusinessRulesSignatureUrl,
            trustAnchor: environment.trustlistAnchor,
            apiToken: apiKey
        )

        validationCore = ValidationCore(trustlistService: trustlistService,
                                        modernBusinessRulesService: modernBusinessRulesService,
                                        nationalTrustlistService: nationalTrustlistService,
                                        valueSetsService: valueSetsService,
                                        dateService: dateService)
    }

    public func decode(encodedData: String) -> Swift.Result<DGCHolder, CovidCertError> {
        #if DEBUG
            print(encodedData)
        #endif

        let decodingResult = validationCore.decodeCwt(encodedData: encodedData)

        switch decodingResult {
        case let .failure(error):
            return .failure(error.asCovidCertError())
        case let .success(result):
            return .success(DGCHolder(encodedData: encodedData, cwt: result))
        }
    }

    public func decodeAndCheckSignature(encodedData: String, validationClock: Date, _ completionHandler: @escaping (Swift.Result<ValidationResult, ValidationError>) -> Void) {
        trustlistService.updateDateService(ValidationClockDateService.forDate(validationClock))
        nationalTrustlistService.updateDateService(ValidationClockDateService.forDate(validationClock))

        validationCore.validate(encodedData: encodedData) { result in
            if result.isValid {
                completionHandler(.success(result))
            } else {
                if result.error == ValidationError.INVALID_SCHEME_PREFIX {
                    validationCore.validateExemption(encodedData: encodedData) { exemptionResult in
                        if exemptionResult.isValid {
                            completionHandler(.success(exemptionResult))
                        } else {
                            completionHandler(.failure(exemptionResult.error ?? .GENERAL_ERROR))
                        }
                    }
                } else {
                    completionHandler(.failure(result.error ?? .GENERAL_ERROR))
                }
            }
        }
    }

    public func restartTrustListUpdate(force: Bool, completionHandler: @escaping (Bool, Bool) -> Void) {
        validationCore.updateTrustlistAndRules(force: force) { wasUpdated, error in
            DispatchQueue.main.async {
                completionHandler(wasUpdated, error != nil)
            }
        }
    }

    func allRecoveriesAreValid(recoveries _: [Recovery]) -> Bool {
        return false
    }

    func currentValueSets() -> [String: ValueSetEntry] {
        return validationCore.getCurrentValueSets()
    }

    func updateDateServiceForRules(validationClock: Date) {
        modernBusinessRulesService.updateDateService(ValidationClockDateService.forDate(validationClock))
    }

    func currentBusinessRules() -> Swift.Result<[String], ValidationError> {
        return modernBusinessRulesService.currentBusinessRules()
    }
}
