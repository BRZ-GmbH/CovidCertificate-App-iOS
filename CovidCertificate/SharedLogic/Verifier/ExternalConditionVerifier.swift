//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 * Copyright (c) 2021 BRZ GmbH <https://www.brz.gv.at>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation
import CovidCertificateSDK
import BusinessRulesValidationCore
import ValidationCore


/**
 Verification class to evaluate external conditions that the app allows to handle
 */
class ExternalConditionVerifier {
    
    let originalCertificate: DGCHolder?
    let otherCertificates: [DGCHolder]
    let otherCertificatesForSamePerson: [DGCHolder]
    let condition: String
    let parameters: [String:String]
    let region: String
    let profile: String
    let validationTime: Date
    let validationCore: BusinessRuleValidator?
    
    init(originalCertificate: DGCHolder?,
         otherCertificates: [DGCHolder],
         otherCertificatesForSamePerson: [DGCHolder],
         condition: String,
         parameters: [String:String],
         region: String,
         profile: String,
         validationTime: Date,
         validationCore: BusinessRuleValidator?) {
        self.originalCertificate = originalCertificate
        self.otherCertificates = otherCertificates
        self.otherCertificatesForSamePerson = otherCertificatesForSamePerson
        self.condition = condition
        self.parameters = parameters
        self.region = region
        self.profile = profile
        self.validationTime = validationTime
        self.validationCore = validationCore
    }
    
    func evaluateCondition() -> Any? {
        guard let externalCondition = ExternalCondition(rawValue: condition) else { return nil }

        switch externalCondition {
        case .hasValidCertificateForSamePerson:
            guard let type = parameters[ExternalConditionParameter.type.rawValue]?.parsedCertificateType() else { return nil }
            
            return hasValidCertificateForPerson(type: type, parameters: parameters)
        case .getValidCertificateForSamePerson:
            guard let type = parameters[ExternalConditionParameter.type.rawValue]?.parsedCertificateType() else { return nil }
            
            return getValidCertificateForPerson(type: type, parameters: parameters)
        case .hasNoValidCertificateForSamePerson:
            guard let type = parameters[ExternalConditionParameter.type.rawValue]?.parsedCertificateType() else { return nil }
            
            return hasValidCertificateForPerson(type: type, parameters: parameters) == false
        case .hasNoCertificateForSamePerson:
            guard let type = parameters[ExternalConditionParameter.type.rawValue]?.parsedCertificateType() else { return nil }
            
            return hasCertificate(type: type, parameters: parameters, forSamePerson: true) == false
        case .hasCertificateForSamePerson:
            guard let type = parameters[ExternalConditionParameter.type.rawValue]?.parsedCertificateType() else { return nil }
            
            return hasCertificate(type: type, parameters: parameters, forSamePerson: true)
        case .hasNoCertificate:
            guard let type = parameters[ExternalConditionParameter.type.rawValue]?.parsedCertificateType() else { return nil }
            
            return hasCertificate(type: type, parameters: parameters, forSamePerson: false) == false
        case .hasCertificate:
            guard let type = parameters[ExternalConditionParameter.type.rawValue]?.parsedCertificateType() else { return nil }
            
            return hasCertificate(type: type, parameters: parameters, forSamePerson: false)
        }
    }
    
    private func hasCertificate(type: BusinessRuleCertificateType, parameters: [String:String], forSamePerson: Bool) -> Bool {
        return getCertificate(type: type, parameters: parameters, forSamePerson: forSamePerson) != nil
    }
    
    private func hasValidCertificateForPerson(type: BusinessRuleCertificateType, parameters: [String:String]) -> Bool {
        return getValidCertificateForPerson(type: type, parameters: parameters) != nil
    }
    
    private func getCertificate(type: BusinessRuleCertificateType, parameters: [String:String], forSamePerson: Bool) -> DGCHolder? {
        let certificates = (forSamePerson ? otherCertificatesForSamePerson : otherCertificates).filter({ $0.healthCert.businessRuleCertificationType == type })
        
        for cert in certificates {
            if certificateMatchesAdditionalParameters(type: type, certificate: cert, parameters: parameters) {
                return cert
            }
        }
        return nil
    }
    
    private func getValidCertificateForPerson(type: BusinessRuleCertificateType, parameters: [String:String]) -> DGCHolder? {
        let certificates = otherCertificatesForSamePerson.filter({ $0.healthCert.businessRuleCertificationType == type })
        
        for cert in certificates {
            let certificatePayload = try! JSONEncoder().encode(cert.healthCert)
            let payloadString = String(data: certificatePayload, encoding: .utf8)!
            
            if let validationResult = validationCore?.evaluateCertificate(payloadString, certificateType: cert.healthCert.businessRuleCertificationType!, expiration: cert.expiresAt!, issue: cert.issuedAt!, country: "AT", region: region, profile: profile, originalCertificateObject: cert) {
                if case .valid = validationResult {
                    if certificateMatchesAdditionalParameters(type: type, certificate: cert, parameters: parameters) {
                        return cert
                    }
                }
            }
        }
        return nil
    }
    
    private func certificateMatchesAdditionalParameters(type: BusinessRuleCertificateType, certificate: DGCHolder, parameters: [String:String]) -> Bool {
        for parameter in parameters {
            if let externalConditionParameter = ExternalConditionParameter(rawValue: parameter.key) {
                switch externalConditionParameter {
                case .type: break
                case .testType:
                    if parameter.value == TestType.Pcr.readableName && certificate.healthCert.tests?.first?.isPcrTest != true {
                        return false
                    }
                    if parameter.value == TestType.Rat.readableName && certificate.healthCert.tests?.first?.isRatTest != true {
                        return false
                    }
                case .ageInDaysLessThan:
                    if let age = Int(parameter.value) {
                        var date: Date? = nil
                        if let test = certificate.healthCert.tests?.first {
                            date = test.validFromDate
                        } else if let recovery = certificate.healthCert.recovery?.first {
                            date = recovery.firstPositiveTestResultDate
                        } else if let vaccination = certificate.healthCert.vaccinations?.first {
                            date = vaccination.dateOfVaccination
                        }
                        if let date = date {
                            if date.dateByAddingUnitAndValue(unit: .day, interval: age).isAfter(validationTime) == false {
                                return false
                            }
                        }
                    }
                case .ageInDaysMoreThan:
                    if let age = Int(parameter.value) {
                        var date: Date? = nil
                        if let test = certificate.healthCert.tests?.first {
                            date = test.validFromDate
                        } else if let recovery = certificate.healthCert.recovery?.first {
                            date = recovery.firstPositiveTestResultDate
                        } else if let vaccination = certificate.healthCert.vaccinations?.first {
                            date = vaccination.dateOfVaccination
                        }
                        if let date = date {
                            if date.dateByAddingUnitAndValue(unit: .day, interval: age).isBefore(validationTime) == false {
                                return false
                            }
                        }
                    }
                case .ageInHoursLessThan:
                    if let age = Int(parameter.value) {
                        var date: Date? = nil
                        if let test = certificate.healthCert.tests?.first {
                            date = test.validFromDate
                        } else if let recovery = certificate.healthCert.recovery?.first {
                            date = recovery.firstPositiveTestResultDate
                        } else if let vaccination = certificate.healthCert.vaccinations?.first {
                            date = vaccination.dateOfVaccination
                        }
                        if let date = date {
                            if date.dateByAddingUnitAndValue(unit: .hour, interval: age).isAfter(validationTime) == false {
                                return false
                            }
                        }
                    }
                case .ageInHoursMoreThan:
                    if let age = Int(parameter.value) {
                        var date: Date? = nil
                        if let test = certificate.healthCert.tests?.first {
                            date = test.validFromDate
                        } else if let recovery = certificate.healthCert.recovery?.first {
                            date = recovery.firstPositiveTestResultDate
                        } else if let vaccination = certificate.healthCert.vaccinations?.first {
                            date = vaccination.dateOfVaccination
                        }
                        if let date = date {
                            if date.dateByAddingUnitAndValue(unit: .hour, interval: age).isBefore(validationTime) == false {
                                return false
                            }
                        }
                    }
                case .vaccineType:
                    if let vaccination = certificate.healthCert.vaccinations?.first {
                        if vaccination.medicinialProduct != parameter.value {
                            return false
                        }
                    }
                case .vaccineTypeNotEqual:
                    if let vaccination = certificate.healthCert.vaccinations?.first {
                        if vaccination.medicinialProduct == parameter.value {
                            return false
                        }
                    }
                case .doseLessThan:
                    if let dose = Int(parameter.value) {
                        if let vaccination = certificate.healthCert.vaccinations?.first {
                            if (vaccination.doseNumber < dose) == false {
                                return false
                            }
                        }
                    }
                case .doseLessThanOrEqual:
                    if let dose = Int(parameter.value) {
                        if let vaccination = certificate.healthCert.vaccinations?.first {
                            if (vaccination.doseNumber <= dose) == false {
                                return false
                            }
                        }
                    }
                case .doseGreaterThan:
                    if let dose = Int(parameter.value) {
                        if let vaccination = certificate.healthCert.vaccinations?.first {
                            if (vaccination.doseNumber > dose) == false {
                                return false
                            }
                        }
                    }
                case .doseGreaterThanOrEqual:
                    if let dose = Int(parameter.value) {
                        if let vaccination = certificate.healthCert.vaccinations?.first {
                            if (vaccination.doseNumber >= dose) == false {
                                return false
                            }
                        }
                    }
                case .doseEqual:
                    if let dose = Int(parameter.value) {
                        if let vaccination = certificate.healthCert.vaccinations?.first {
                            if (vaccination.doseNumber == dose) == false {
                                return false
                            }
                        }
                    }
                case .doseNotEqual:
                    if let dose = Int(parameter.value) {
                        if let vaccination = certificate.healthCert.vaccinations?.first {
                            if (vaccination.doseNumber != dose) == false {
                                return false
                            }
                        }
                    }
                case .personAgeInYearsLessThan:
                    if let birthdate = certificate.healthCert.birthDate {
                        if let years = Int(parameter.value) {
                            if let date = Calendar.autoupdatingCurrent.date(byAdding: .year, value: years, to: birthdate) {
                                if date.isAfter(validationTime) == false {
                                    return false
                                }
                            }
                        }
                    }
                case .personAgeInYearsMoreThan:
                    if let birthdate = certificate.healthCert.birthDate {
                        if let years = Int(parameter.value) {
                            if let date = Calendar.autoupdatingCurrent.date(byAdding: .year, value: years, to: birthdate) {
                                if date.isBefore(validationTime) == false {
                                    return false
                                }
                            }
                        }
                    }
                case .personAgeInMonthsLessThan:
                    if let birthdate = certificate.healthCert.birthDate {
                        if let months = Int(parameter.value) {
                            if let date = Calendar.autoupdatingCurrent.date(byAdding: .month, value: months, to: birthdate) {
                                if date.isAfter(validationTime) == false {
                                    return false
                                }
                            }
                        }
                    }
                case .personAgeInMonthsMoreThan:
                    if let birthdate = certificate.healthCert.birthDate {
                        if let months = Int(parameter.value) {
                            if let date = Calendar.autoupdatingCurrent.date(byAdding: .month, value: months, to: birthdate) {
                                if date.isBefore(validationTime) == false {
                                    return false
                                }
                            }
                        }
                    }
                case .isIssuedBeforeCurrentCertificate:
                    if let currentCertificateIssueDate = certificate.issuedAt, let certificateIssueDate = originalCertificate?.issuedAt {
                        if parameter.value == "true" {
                            if currentCertificateIssueDate.isBefore(certificateIssueDate) == false {
                                return false
                            }
                        } else {
                            if currentCertificateIssueDate.isAfter(certificateIssueDate) == false {
                                return false
                            }
                        }
                    }
                case .isIssuedAfterCurrentCertificate:
                    if let currentCertificateIssueDate = certificate.issuedAt, let certificateIssueDate = originalCertificate?.issuedAt {
                        if parameter.value == "true" {
                            if currentCertificateIssueDate.isAfter(certificateIssueDate) == false {
                                return false
                            }
                        } else {
                            if currentCertificateIssueDate.isBefore(certificateIssueDate) == false {
                                return false
                            }
                        }
                    }
                }
            }
        }
        return true
    }
}

extension TestType {
    var readableName: String {
        switch self {
            case .Pcr: return "PCR"
            case .Rat: return "RAT"
        }
    }
}
