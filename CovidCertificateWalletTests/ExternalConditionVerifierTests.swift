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

import BusinessRulesValidationCore
@testable import CovidCertificateWallet
import XCTest

class ExternalConditionVerifierTests: XCTestCase {
    static let pcrTestCertificateApril25 = "HC1:NCF5W17C8OJ2P10DCBCNGVLG.JKA6HROKUPQIN65LRL1FUJOQPN0D0+NB/SJGT0FP7YNP8*MIP09:4NK5MQ2:75 SRPDKWTBSBLZC2:C8:4V48FZ-1SX72825DHP+3. T7YS7EU$E85*OJX6Q0WGDBCGWATDD9VLLJ-Y1J6T2PCFN3%EU7RU*RH-8W %HXAQJD8CCV446Z3FQL5OKE5VL7LJ.JI2:GKNRDB6FM11G4YKSR+MVLOWXBT66023LQ9C-5Q QYEU3*8AXM8WTTIL24LT 70%D6PLBG7LFJ$-D:.4*JCNTNRWE%E4L%BBIH..TJ:H*KOD*IHDO/0M$*ODZG. ORCH+MAG:HXAU*/PVI84GDZLCD-GDOVZXAJ*KPBG30I FH.TLYM88FBO7PSE2/987KJ3D91$GUH9*OOOPN-M2Y0FXZGE%O5UL0TF/SRPCRCRH-QR UK2OTI 1T9KQ+0N%CQL9GCH3JAAP0OO5WRDUOJX034B1E5R$BO/Y6N+M*8SMBF.YE-XNFFK4/QK3S%HL3ZUQ+3I:N746.VV34C%REWKT6YSH0FY*MNHOQDSNCRX1QENQ1OQ9TL718:RF:+VBKF MN+8T7+I:EU:8TD1P0TM.GBU1S/ SZZT%/H25WA0AK:I"

    static let ratTestCertificateApril25 = "HC1:NCF5W1W08$$QWS3*61HNKR/RQ7JUHQO3LOFV2AU5G7ULNMUP5S6KSJE+1VQ1ZCS46F+ I3WN9*N2ONQH74U2JS0$8EGLU IAS4DB21RW0VJLPMAE+E5Y9*XR:EUFOVN/HU$G8/IQMB/TPU$VC6HKTG-DT/+IKFJ -B6SL6URW3F%8R2QF1AT67LO65BTA-DR 0J8WSFUTOE90MRF9200OZ+M1/KET6BX2E17D3JAPM+WC.YF0.UF4D-AJR265DO1%IBTU4ZV CJ $N3.OW EXWABV7QZI8X0VSJ8P9+OO5W31MK/55$R4E12 73/A6IT9X:RC%9XZ0N.E57T3$PL0LM$5426H1GA%G$XA/I6XI32H6P+0NI17B33CI:Z9S22HLNVONHEM6-JF3L2IO5-6-MA0E4EKM199UK6IMH46BNHUC9B8NA-47F67E-AHFUOF6WD1455G5OCLR5FP6FJ4ICK+MG:5YF1YQQBAMCV16 OE940JGP:8ZON6KRB.B5 NN+2Z:MZ6EUWP3CTT4WJCQ3WVO9WFOUK VT5WP4GB38OKR7ECG9UTMQRO6V5RIESY0O%1W1/N27WT/2LQ72COF$T*/V77HVOSO37Y5SP+U9DI"

    static let vaccination2of2April25 = "HC1:NCFMX1VX7YUO%20TDCF.O332/ZOGIAQZJG:N0Q46B532L0Y9E2L-YMQG7E%5EVQ4$DUSQ0EL0NGV74O10OW5IFUST2IJO*98I-0ADEX.4G-02-08/496OUGUB5EEZ9SYL*PUF/3P6O:FN-G7RLCT 2L*SQ5D7K9218MV04SE:B9$7PLVQND3A15.XK+9ADIABX7+TJ-B0S-I:AA9R8I92W$56MUI1PANCT69OR7%PH-%7F/4Q-DY.80I96S4EJ3K0J%Q8A84EGUQC21/L0R1W*QL 6:MB.%A%IKH%D-.VC9F.3MN-1J99C65LY6S GE00.24XBIS.M%:U2O1042ZB0%E9BC19CSYD4MO0ND0XLITNL441H+OF1USBJ3$GWGKGFH358BMJV$BE$RJHF-3MAIFQWPW-8AYAP0MA8VV T8%3K*R*HCG8IGZ4V*P*/F*.Q6FB+-O%EB7LA%67:D9RR2PIJIWT2P280L3LU $6U2NOTO%P66/26*QV8K 8TV+PUVEX$AU93-NQ0.JP5JU.FXDRTGVB$R-ZFY:VD:E68TV:OS2T%WN MOM1HN37-3JRLB2Q1T5WS%DS/BXIKZXTYEH"

    static let secondVaccination2of2April25 = "HC1:NCFMX1BM7YUO%20JFC US.24B1O/MH9UIF5FRYK4NHNILJXQBZAIK3E03$W4YPJ2UBQLJ X0%80:USJ34X25/.9YHQ-D80I7SMKZKHVIT5XMVQUE8H6DC6+EDR1+Q44TF-1TZAM4UHNZ8+SLEV8J*M2KBBDQN4R7TSZ2UYW9P82-N6IQBR$OM3BJ4MDW8QOVFTC0GOSNI8G8M70 TSDGN7K58K07T0QTE+DR-H2KHR*Q0MIO%B68W1S9BFGHKA8S80+9B-TMM441HFL26PKA T3HVLWIC*ZIR%H 9IPZ12.I6DEBQSY6SE3L112DCO*M00TS%D1U:1536WCC454 ZIQ 4K774ZO6HGW80PBIQ851B4MD7IEA CD/A95SP3ZOS%OEAH%W18.8B$MGND-3N-1VVF1E6R2WTD*5.WDX47S5LU$O71UG$D5EDLF9ZKTK7RVOJD7IPTM+*JT5QY6BPU3.%S8Y4%Z41R6%VL 5E*72+B042PSRN ASEOF7T72HLO+NCHQY/EH3WUZ51PU7KRCOQ64A1FVV/NDCS:SV*EV743A4S7DTC6JCFE/0E/6EKRL//V*9F0ZD8J08+HV0"

    static let recoveryApril04 = "HC1:NCFOXN%TSMAHN-H3ZSUZK+.V0ET9%6-AH-XI1ROR$SIOOU.IROUG*I%E57$FSSLNO4*J8OX4UZ85XPWLI+J53O8J.V J8$XJK*L5R1ZP3LYLGS9/ZJ/T1H$JH$JGS9-.P:%BJS54-REP11Y9C+H1Y9SU3G 9L/N:PIWEG%*4AZKZ734234LTW9JSCA+G9AXGT6DGTSFW2TAFCNNG.8G%8VD98-O+SQ4IJZJJ1W4*$I*NVPC1LJL4A7N832F14+KJJIU%O0QIRR97I2HOAXL92L0G+SB.V Q5FN9ML1X/BB-S-*O5W41FD+.K588/HL*DD2IHJSN37HMX3.7KO7JDKBLZI19JA2K7VA$IJVTI ZJY1B QTOD3CQSP$SR$S3NDC9UOD3Y.TJET9G3:ZJ83BDPSCFTB.SBVT6NJF0JEYI1DLCZKO63VEKCXDZNCHPE+ZSNPU3P7S16I:N.NNYJ6Q6QUDTZ0AP$DBAMN7OCY2Q9M*CVT:9H UO+S:$O+F69Y2U%P72QY%C9R4T6Q+%T8M2U$I%00: 0%1"

    func testConditionsWithTestCertificate() throws {
        if case let .success(parsedTest) = CovidCertificateSDK.decode(encodedData: ExternalConditionVerifierTests.pcrTestCertificateApril25) {
            var verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedTest],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.test.rawValue,
                    ExternalConditionParameter.testType.rawValue: TestType.Pcr.readableName,
                    ExternalConditionParameter.ageInHoursMoreThan.rawValue: "2",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == true)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedTest],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.test.rawValue,
                    ExternalConditionParameter.testType.rawValue: TestType.Pcr.readableName,
                    ExternalConditionParameter.ageInHoursLessThan.rawValue: "2",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedTest],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.test.rawValue,
                    ExternalConditionParameter.testType.rawValue: TestType.Rat.readableName,
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedTest],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.test.rawValue,
                    ExternalConditionParameter.testType.rawValue: TestType.Pcr.readableName,
                    ExternalConditionParameter.ageInDaysLessThan.rawValue: "0",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedTest],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.test.rawValue,
                    ExternalConditionParameter.testType.rawValue: TestType.Pcr.readableName,
                    ExternalConditionParameter.ageInDaysMoreThan.rawValue: "100000",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedTest],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.test.rawValue,
                    ExternalConditionParameter.testType.rawValue: TestType.Pcr.readableName,
                    ExternalConditionParameter.ageInHoursMoreThan.rawValue: "1000000",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)
        } else {
            XCTFail()
        }
    }

    func testIssueDateConditions() throws {
        if case let .success(parsedVaccination) = CovidCertificateSDK.decode(encodedData: ExternalConditionVerifierTests.vaccination2of2April25),
           case let .success(secondParsedVaccination) = CovidCertificateSDK.decode(encodedData: ExternalConditionVerifierTests.secondVaccination2of2April25) {
            var verifier = ExternalConditionVerifier(
                originalCertificate: parsedVaccination,
                otherCertificates: [secondParsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.isIssuedBeforeCurrentCertificate.rawValue: "true",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: parsedVaccination,
                otherCertificates: [secondParsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.isIssuedBeforeCurrentCertificate.rawValue: "false",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == true)

            verifier = ExternalConditionVerifier(
                originalCertificate: parsedVaccination,
                otherCertificates: [secondParsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.isIssuedAfterCurrentCertificate.rawValue: "true",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == true)

            verifier = ExternalConditionVerifier(
                originalCertificate: parsedVaccination,
                otherCertificates: [secondParsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.isIssuedAfterCurrentCertificate.rawValue: "false",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

        } else {
            XCTFail()
        }
    }

    func testVaccineConditions() throws {
        if case let .success(parsedVaccination) = CovidCertificateSDK.decode(encodedData: ExternalConditionVerifierTests.vaccination2of2April25) {
            var verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.doseEqual.rawValue: "15",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.doseEqual.rawValue: "2",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == true)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.doseNotEqual.rawValue: "2",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.doseNotEqual.rawValue: "1",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == true)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.doseLessThan.rawValue: "1",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.doseLessThan.rawValue: "3",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == true)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.doseLessThanOrEqual.rawValue: "1",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.doseLessThanOrEqual.rawValue: "2",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == true)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.doseGreaterThan.rawValue: "10",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.doseGreaterThan.rawValue: "1",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == true)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.doseGreaterThanOrEqual.rawValue: "10",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.doseGreaterThanOrEqual.rawValue: "2",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == true)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.vaccineType.rawValue: "EU/1/20/1528",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == true)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.vaccineType.rawValue: "EU/1/20/1529",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.vaccineTypeNotEqual.rawValue: "EU/1/20/1528",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.vaccineTypeNotEqual.rawValue: "EU/1/20/1529",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == true)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.ageInHoursMoreThan.rawValue: "1000000",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.ageInHoursLessThan.rawValue: "1",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.ageInDaysMoreThan.rawValue: "1000000",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.ageInDaysLessThan.rawValue: "1",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)
        } else {
            XCTFail()
        }
    }

    func testRecoveryConditions() throws {
        if case let .success(parsedRecovery) = CovidCertificateSDK.decode(encodedData: ExternalConditionVerifierTests.recoveryApril04) {
            var verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedRecovery],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.recovery.rawValue,
                    ExternalConditionParameter.ageInHoursMoreThan.rawValue: "1000000",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedRecovery],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.recovery.rawValue,
                    ExternalConditionParameter.ageInHoursLessThan.rawValue: "1",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedRecovery],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.recovery.rawValue,
                    ExternalConditionParameter.ageInDaysMoreThan.rawValue: "1000000",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedRecovery],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.recovery.rawValue,
                    ExternalConditionParameter.ageInDaysLessThan.rawValue: "1",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)
        } else {
            XCTFail()
        }
    }

    func testPersonAgeConditions() throws {
        if case let .success(parsedVaccination) = CovidCertificateSDK.decode(encodedData: ExternalConditionVerifierTests.vaccination2of2April25) {
            var verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.personAgeInYearsLessThan.rawValue: "5",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.personAgeInYearsMoreThan.rawValue: "100",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.personAgeInMonthsLessThan.rawValue: "5",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)

            verifier = ExternalConditionVerifier(
                originalCertificate: nil,
                otherCertificates: [parsedVaccination],
                otherCertificatesForSamePerson: [],
                condition: ExternalCondition.hasCertificate.rawValue,
                parameters: [
                    ExternalConditionParameter.type.rawValue: BusinessRuleCertificateType.vaccination.rawValue,
                    ExternalConditionParameter.personAgeInMonthsMoreThan.rawValue: "10000",
                ],
                region: "",
                profile: "",
                validationTime: Date(),
                validationCore: nil
            )

            XCTAssertTrue((verifier.evaluateCondition() as? Bool) == false)
        } else {
            XCTFail()
        }
    }
}
