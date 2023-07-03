//
//  File.swift
//
//
//  Created by Martin Fitzka-Reichart on 12.07.21.
//

import Foundation
import SwiftCBOR
import ValidationCore

extension Optional where Wrapped: Collection {
    /// Check if this optional array is nil or empty
    func isNilOrEmpty() -> Bool {
        // if self is nil `self?.isEmpty` is nil and hence the value after the ?? operator is used
        // otherwise self!.isEmpty checks for an empty array
        return self?.isEmpty ?? true
    }
}

extension HealthCert {
    func certIdentifiers() -> [String] {
        switch type {
        case .vaccination:
            return vaccinations!.map { vac in
                vac.certificateIdentifier
            }
        case .recovery:
            return recovery!.map { rec in
                rec.certificateIdentifier
            }
        case .test:
            return tests!.map { test in
                test.certificateIdentifier
            }
        case .vaccinationExemption:
            return vaccinationExemption!.map { vaccinationExemption in
                vaccinationExemption.certificateIdentifier
            }
        }
    }
}

public extension Vaccination {
    var isTargetDiseaseCorrect: Bool {
        return disease == Disease.SarsCov2.rawValue
    }

    /// we need a date of vaccination which needs to be in the format of yyyy-MM-dd
    internal var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DATE_FORMAT
        return dateFormatter
    }

    var dateOfVaccination: Date? {
        return dateFormatter.date(from: vaccinationDate)
    }

    var name: String? {
        return ProductNameManager.shared.vaccineProductName(key: medicinialProduct)
    }

    var authHolder: String? {
        return ProductNameManager.shared.vaccineManufacturer(key: marketingAuthorizationHolder)
    }

    var prophylaxis: String? {
        return ProductNameManager.shared.vaccineProphylaxisName(key: vaccine)
    }
}

public extension Test {
    var isPcrTest: Bool {
        return type == TestType.Pcr.rawValue
    }

    var isRatTest: Bool {
        return type == TestType.Rat.rawValue
    }

    var validFromDate: Date? {
        return Date.fromISO8601(timestampSample)
    }

    var resultDate: Date? {
        if let res = timestampResult {
            return Date.fromISO8601(res)
        }

        return nil
    }

    var isTargetDiseaseCorrect: Bool {
        return disease == Disease.SarsCov2.rawValue
    }

    var isNegative: Bool {
        return result == TestResult.Negative.rawValue
    }

    var testType: String? {
        return ProductNameManager.shared.testTypeName(key: type)
    }

    var readableTestName: String? {
        switch type {
        case TestType.Pcr.rawValue:
            return testName ?? "PCR"
        case TestType.Rat.rawValue:
            return testName
        default:
            return nil
        }
    }

    var readableManufacturer: String? {
        if let val = ProductNameManager.shared.testManufacturerName(key: manufacturer) {
            var r = val.replacingOccurrences(of: testName ?? "", with: "").trimmingCharacters(in: .whitespacesAndNewlines)

            if let last = r.last, last == "," {
                r.removeLast()
            }

            return r.isEmpty ? nil : r
        }

        return nil
    }
}

public extension Recovery {
    internal var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DATE_FORMAT
        return dateFormatter
    }

    var firstPositiveTestResultDate: Date? {
        return dateFormatter.date(from: dateFirstPositiveTest)
    }

    var isTargetDiseaseCorrect: Bool {
        return disease == Disease.SarsCov2.rawValue
    }
}

public extension VaccinationExemption {
    var isTargetDiseaseCorrect: Bool {
        return disease == Disease.SarsCov2.rawValue
    }

    /// we need a date of vaccination which needs to be in the format of yyyy-MM-dd
    internal var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DATE_FORMAT
        return dateFormatter
    }

    var validUntilDate: Date? {
        guard let date = dateFormatter.date(from: validUntil) else { return nil }

        return Calendar.autoupdatingCurrent.date(byAdding: DateComponents(day: 1, second: -1), to: Calendar.autoupdatingCurrent.startOfDay(for: date))!
    }
}
