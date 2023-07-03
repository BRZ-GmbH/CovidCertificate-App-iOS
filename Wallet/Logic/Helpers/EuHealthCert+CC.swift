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

public extension CertType {
    var displayName: String {
        switch self {
        case .recovery:
            return UBLocalized.certificate_reason_recovered
        case .test:
            return UBLocalized.certificate_reason_tested
        case .vaccination:
            return UBLocalized.certificate_reason_vaccinated
        case .vaccinationExemption:
            return UBLocalized.certificate_reason_vaccination_exemption
        }
    }
}

public extension DGCHolder {
    var displayIssuedAt: String? {
        if let i = issuedAt {
            return DateFormatter.ub_dayTimeString(from: i)
        }

        return nil
    }
}

extension String {
    var substringToFirstNonLetter: String {
        if let firstNonLetter = firstIndex(where: { $0.isLetter == false }) {
            return String(self[..<firstNonLetter])
        }
        return self
    }
}

public extension HealthCert {
    var comparableIdentifier: String {
        return String.personGroupingIdentiferForDGCCertificate(withFamilyName: person.standardizedFamilyName, givenName: person.standardizedGivenName, dateOfBirth: dateOfBirth)
    }

    var displayFullName: String? {
        return [person.familyName, person.givenName].compactMap { $0 }.joined(separator: " ")
    }

    var displayBirthDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: dateOfBirth) {
            return DateFormatter.ub_dayString(from: date)
        }

        return dateOfBirth
    }
    
    var birthDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateOfBirth)
    }

    var displayLastName: String? {
        return person.familyName
    }

    var displayName: String? {
        return person.givenName
    }

    var displayMonospacedName: String? {
        return [person.standardizedFamilyName, person.standardizedGivenName].compactMap { $0 }.joined(separator: "<<")
    }
}

extension Vaccination {
    var getNumberOverTotalDose: String {
        return "\(doseNumber)/\(totalDoses)"
    }

    var displayDateOfVaccination: String {
        if let d = dateOfVaccination {
            return DateFormatter.ub_dayString(from: d)
        }

        // fallback
        return vaccinationDate
    }
}

extension Recovery {
    var displayFirstPositiveTest: String? {
        if let d = firstPositiveTestResultDate {
            return DateFormatter.ub_dayString(from: d)
        }

        return nil
    }
}

extension Test {
    var displaySampleDateTime: String? {
        if let d = validFromDate {
            return DateFormatter.ub_dayTimeString(from: d)
        }

        return timestampSample
    }

    var displayResultDateTime: String? {
        if let d = resultDate {
            return DateFormatter.ub_dayTimeString(from: d)
        }

        return timestampResult
    }
}

extension VaccinationExemption {
    var displayValidUntilDate: String {
        if let d = validUntilDate {
            return DateFormatter.ub_dayString(from: d)
        }

        // fallback
        return validUntil
    }
}

extension String {
    func asLocalizedDisplayCountry(showEnglishLocalization: Bool) -> String {
        let country = Locale.current.localizedString(forRegionCode: self) ?? self

        if showEnglishLocalization {
            if let englishLabel = Locale(identifier: "en").localizedString(forRegionCode: self) {
                return "\(country) / \(englishLabel)"
            }
        }

        return country
    }
}
