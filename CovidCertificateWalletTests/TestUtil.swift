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

class TestUtil {
    enum VaccineType: String {
        case johnson = "EU\\/1\\/20\\/1525"
        case moderna = "EU\\/1\\/21\\/1618"
    }

    class func generateVaccination(_ vaccine: VaccineType, vaccinationAgeInDays: Int, dateOfBirthAge: (years: Int, days: Int), doses: Int, sequence: Int) -> String {
        return generateVaccination(vaccine.rawValue, vaccinationAgeInDays: vaccinationAgeInDays, dateOfBirthAge: dateOfBirthAge, doses: doses, sequence: sequence)
    }

    class func generateVaccination(_ vaccineTypeString: String, vaccinationAgeInDays: Int, dateOfBirthAge: (years: Int, days: Int), doses: Int, sequence: Int) -> String {
        let vaccinationDate = Calendar.autoupdatingCurrent.date(byAdding: .day, value: -vaccinationAgeInDays, to: Date())!
        let birthDate = Calendar.autoupdatingCurrent.date(byAdding: .day, value: -dateOfBirthAge.days, to: Calendar.autoupdatingCurrent.date(byAdding: .year, value: -dateOfBirthAge.years, to: Date())!)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return generateVaccinationCertificate(vaccineTypeString, vaccinationDate: dateFormatter.string(from: vaccinationDate), dateOfBirth: dateFormatter.string(from: birthDate), doses: doses, sequence: sequence)
    }

    private class func generateVaccinationCertificate(_ vaccinationType: String, vaccinationDate: String, dateOfBirth: String, doses: Int, sequence: Int) -> String {
        return """
        {
            "ver": "1.2.1",
            "nam": {
                "fn": "Doe",
                "gn": "John",
                "fnt": "DOE",
                "gnt": "JOHN"
            },
            "dob": "\(dateOfBirth)",
            "v": [
                {
                    "tg": "840539006",
                    "vp": "111\\/9349007",
                    "mp": "\(vaccinationType)",
                    "ma": "ORG-100030215",
                    "dn": \(doses),
                    "sd": \(sequence),
                    "dt": "\(vaccinationDate)",
                    "co": "AT",
                    "is": "Ministry of Health, Austria",
                    "ci": "URN:UVCI:01:AT:10807843F94AEE0EE5093FBC254BD813#B"
                }
            ]
        }
        """
    }

    private class func generateRecoveryCertificate(positiveResultAgeInDays: Int, dateOfBirthAge: (years: Int, days: Int)) -> String {
        let positiveResultDate = Calendar.autoupdatingCurrent.date(byAdding: .day, value: -positiveResultAgeInDays, to: Date())!

        let birthDate = Calendar.autoupdatingCurrent.date(byAdding: .day, value: -dateOfBirthAge.days, to: Calendar.autoupdatingCurrent.date(byAdding: .year, value: -dateOfBirthAge.years, to: Date())!)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return generateRecoveryCertificate(positiveResultDate: dateFormatter.string(from: positiveResultDate), dateOfBirth: dateFormatter.string(from: birthDate))
    }

    private class func generateRecoveryCertificate(positiveResultDate: String, dateOfBirth: String) -> String {
        return """
        {
            "ver": "1.2.1",
            "nam": {
                "fn": "Doe",
                "gn": "John",
                "fnt": "DOE",
                "gnt": "JOHN"
            },
            "dob": "\(dateOfBirth)",
            "r": [
                {
                    "tg": "840539006",
                    "fr": "\(positiveResultDate)",
                    "co": "AT",
                    "is": "Ministry of Health, Austria",
                    "df": "2021-04-04",
                    "du": "2021-10-04",
                    "ci": "URN:UVCI:01:AT:858CC18CFCF5965EF82F60E493349AA5#K"
                }
            ]
        }
        """
    }

    enum TestResult: String {
        case negative = "260415000"
        case positive = "123"
    }

    class func generateRATTestCertificate(sampleCollectionDateAge: (hours: Int, minutes: Int), dateOfBirthAge: (years: Int, days: Int), result: TestResult) -> String {
        let sampleCollectionDate = Calendar.autoupdatingCurrent.date(byAdding: .minute, value: -sampleCollectionDateAge.minutes, to: Calendar.autoupdatingCurrent.date(byAdding: .hour, value: -sampleCollectionDateAge.hours, to: Date())!)!

        let birthDate = Calendar.autoupdatingCurrent.date(byAdding: .day, value: -dateOfBirthAge.days, to: Calendar.autoupdatingCurrent.date(byAdding: .year, value: -dateOfBirthAge.years, to: Date())!)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return generateTestCertificate(sampleCollectionDate: ISO8601DateFormatter().string(from: sampleCollectionDate), dateOfBirth: dateFormatter.string(from: birthDate), testType: "LP217198-3", result: result.rawValue)
    }

    class func generatePCRTestCertificate(sampleCollectionDateAge: (hours: Int, minutes: Int), dateOfBirthAge: (years: Int, days: Int), result: TestResult) -> String {
        let sampleCollectionDate = Calendar.autoupdatingCurrent.date(byAdding: .minute, value: -sampleCollectionDateAge.minutes, to: Calendar.autoupdatingCurrent.date(byAdding: .hour, value: -sampleCollectionDateAge.hours, to: Date())!)!

        let birthDate = Calendar.autoupdatingCurrent.date(byAdding: .day, value: -dateOfBirthAge.days, to: Calendar.autoupdatingCurrent.date(byAdding: .year, value: -dateOfBirthAge.years, to: Date())!)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return generateTestCertificate(sampleCollectionDate: ISO8601DateFormatter().string(from: sampleCollectionDate), dateOfBirth: dateFormatter.string(from: birthDate), testType: "LP6464-4", result: result.rawValue)
    }

    private class func generateTestCertificate(sampleCollectionDate: String, dateOfBirth: String, testType: String, result: String) -> String {
        return """
        {
            "ver": "1.2.1",
            "nam": {
                "fn": "Doe",
                "gn": "John",
                "fnt": "DOE",
                "gnt": "JOHN"
            },
            "dob": "\(dateOfBirth)",
            "t": [
                {
                    "tg": "840539006",
                    "tt": "\(testType)",
                    "ma": "1232",
                    "sc": "\(sampleCollectionDate)",
                    "tr": "\(result)",
                    "tc": "Testing center Vienna 1",
                    "co": "AT",
                    "is": "Ministry of Health, Austria",
                    "ci": "URN:UVCI:01:AT:71EE2559DE38C6BF7304FB65A1A451EC#3"
                }
            ]
        }
        """
    }
}
