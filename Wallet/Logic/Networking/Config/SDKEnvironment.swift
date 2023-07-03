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

public enum SDKEnvironment {
    case dev
    case abn
    case prod

    var trustlistUrl: String {
        switch self {
        case .dev:
            return "https://dgc.a-sit.at/ehn/cert/listv2"
        case .abn:
            return "https://dgc-trusttest.qr.gv.at/trustlist"
        case .prod:
            return "https://dgc-trust.qr.gv.at/trustlist"
        }
    }

    var trustlistSignatureUrl: String {
        switch self {
        case .dev:
            return "https://dgc.a-sit.at/ehn/cert/sigv2"
        case .abn:
            return "https://dgc-trusttest.qr.gv.at/trustlistsig"
        case .prod:
            return "https://dgc-trust.qr.gv.at/trustlistsig"
        }
    }

    var nationalTrustlistUrl: String {
        switch self {
        case .dev:
            return "https://dgc.a-sit.at/ehn/cert/listv2"
        case .abn:
            return "https://dgc-trusttest.qr.gv.at/at-trustlist"
        case .prod:
            return "https://dgc-trust.qr.gv.at/at-trustlist"
        }
    }

    var nationalTrustlistSignatureUrl: String {
        switch self {
        case .dev:
            return "https://dgc.a-sit.at/ehn/cert/sigv2"
        case .abn:
            return "https://dgc-trusttest.qr.gv.at/at-trustlistsig"
        case .prod:
            return "https://dgc-trust.qr.gv.at/at-trustlistsig"
        }
    }

    var trustlistAnchor: String {
        switch self {
        case .dev:
            return """
            MIIBJTCBy6ADAgECAgUAwvEVkzAKBggqhkjOPQQDAjAQMQ4wDAYDVQQDDAVFQy1N
            ZTAeFw0yMTA0MjMxMTI3NDhaFw0yMTA1MjMxMTI3NDhaMBAxDjAMBgNVBAMMBUVD
            LU1lMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE/OV5UfYrtE140ztF9jOgnux1
            oyNO8Bss4377E/kDhp9EzFZdsgaztfT+wvA29b7rSb2EsHJrr8aQdn3/1ynte6MS
            MBAwDgYDVR0PAQH/BAQDAgWgMAoGCCqGSM49BAMCA0kAMEYCIQC51XwstjIBH10S
            N701EnxWGK3gIgPaUgBN+ljZAs76zQIhAODq4TJ2qAPpFc1FIUOvvlycGJ6QVxNX
            EkhRcgdlVfUb
            """.replacingOccurrences(of: "\n", with: "")
        case .abn:
            return """
            MIIB6zCCAZGgAwIBAgIKAXmEuohlRbR2qzAKBggqhkjOPQQDAjBQMQswCQYDVQQG
            EwJBVDEPMA0GA1UECgwGQk1TR1BLMQowCAYDVQQLDAFRMQwwCgYDVQQFEwMwMDEx
            FjAUBgNVBAMMDUFUIERHQyBDU0NBIDEwHhcNMjEwNTE5MTMwNDQ3WhcNMjIwNjE5
            MTMwNDQ3WjBRMQswCQYDVQQGEwJBVDEPMA0GA1UECgwGQk1TR1BLMQowCAYDVQQL
            DAFRMQ8wDQYDVQQFEwYwMDEwMDExFDASBgNVBAMMC0FUIERHQyBUTCAxMFkwEwYH
            KoZIzj0CAQYIKoZIzj0DAQcDQgAE29KpT1eIKsy5Jx3J0xpPLW+fEBF7ma9943/j
            4Z+o1TytLVok9cWjsdasWCS/zcRyAh7HBL+oyMWdFBOWENCQ76NSMFAwDgYDVR0P
            AQH/BAQDAgeAMB0GA1UdDgQWBBQYmsL5sXTdMCyW4UtP5BMxq+UAVzAfBgNVHSME
            GDAWgBR2sKi2xkUpGC1Cr5ehwL0hniIsJzAKBggqhkjOPQQDAgNIADBFAiBse17k
            F5F43q9mRGettRDLprASrxsDO9XxUUp3ObjcWQIhALfUWnserGEPiD7Pa25tg9lj
            wkrqDrMdZHZ39qb+Jf/E
            """.replacingOccurrences(of: "\n", with: "")
        case .prod:
            return """
            MIIB1DCCAXmgAwIBAgIKAXnM+Z3eG2QgVzAKBggqhkjOPQQDAjBEMQswCQYDVQQG
            EwJBVDEPMA0GA1UECgwGQk1TR1BLMQwwCgYDVQQFEwMwMDExFjAUBgNVBAMMDUFU
            IERHQyBDU0NBIDEwHhcNMjEwNjAyMTM0NjIxWhcNMjIwNzAyMTM0NjIxWjBFMQsw
            CQYDVQQGEwJBVDEPMA0GA1UECgwGQk1TR1BLMQ8wDQYDVQQFEwYwMDEwMDExFDAS
            BgNVBAMMC0FUIERHQyBUTCAxMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEl2tm
            d16CBHXwcBN0r1Uy+CmNW/b2V0BNP85y5N3JZeo/8l9ey/jIe5mol9fFcGTk9bCk
            8zphVo0SreHa5aWrQKNSMFAwDgYDVR0PAQH/BAQDAgeAMB0GA1UdDgQWBBRTwp6d
            cDGcPUB6IwdDja/a3ncM0TAfBgNVHSMEGDAWgBQfIqwcZRYptMGYs2Nvv90Jnbt7
            ezAKBggqhkjOPQQDAgNJADBGAiEAlR0x3CRuQV/zwHTd2R9WNqZMabXv5XqwHt72
            qtgnjRgCIQCZHIHbCvlgg5uL8ZJQzAxLavqF2w6uUxYVrvYDj2Cqjw==
            """.replacingOccurrences(of: "\n", with: "")
        }
    }

    var businessRulesUrl: String {
        switch self {
        case .dev:
            return "https://dgc.a-sit.at/ehn/rules/v1/bin"
        case .abn:
            return "https://dgc-trusttest.qr.gv.at/rules"
        case .prod:
            return "https://dgc-trust.qr.gv.at/rules"
        }
    }

    var businessRulesSignatureUrl: String {
        switch self {
        case .dev:
            return "https://dgc.a-sit.at/ehn/rules/v1/sig"
        case .abn:
            return "https://dgc-trusttest.qr.gv.at/rulessig"
        case .prod:
            return "https://dgc-trust.qr.gv.at/rulessig"
        }
    }

    var valueSetsUrl: String {
        switch self {
        case .dev:
            return "https://dgc.a-sit.at/ehn/values/v1/bin"
        case .abn:
            return "https://dgc-trusttest.qr.gv.at/valuesets"
        case .prod:
            return "https://dgc-trust.qr.gv.at/valuesets"
        }
    }

    var valueSetsSignatureUrl: String {
        switch self {
        case .dev:
            return "https://dgc.a-sit.at/ehn/values/v1/sig"
        case .abn:
            return "https://dgc-trusttest.qr.gv.at/valuesetssig"
        case .prod:
            return "https://dgc-trust.qr.gv.at/valuesetssig"
        }
    }

    var modernBusinessRulesUrl: String {
        switch self {
        case .dev:
            return "https://dgc-trusttest.qr.gv.at/extendedrulesbin"
        case .abn:
            return "https://dgc-trusttest.qr.gv.at/extendedrulesbin"
        case .prod:
            return "https://dgc-trust.qr.gv.at/extendedrulesbin"
        }
    }

    var modernBusinessRulesSignatureUrl: String {
        switch self {
        case .dev:
            return "https://dgc-trusttest.qr.gv.at/extendedrulessig"
        case .abn:
            return "https://dgc-trusttest.qr.gv.at/extendedrulessig"
        case .prod:
            return "https://dgc-trust.qr.gv.at/extendedrulessig"
        }
    }
}
