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

extension Date {
    static var nonFractalISO8601Formatter: ISO8601DateFormatter = ISO8601DateFormatter()

    static var fractalISO8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static func fromISO8601(_ dateString: String) -> Date? {
        // `ISO8601DateFormatter` does not support fractional zeros if not
        // configured (`.withFractionalSeconds`) and if configured, does not
        // parse dates without fractional seconds.

        // Try to parse without fractional seconds
        if let d = Date.nonFractalISO8601Formatter.date(from: dateString) {
            return d
        }

        // Retry with fraction
        if let d = Date.fractalISO8601Formatter.date(from: dateString) {
            return d
        }

        // nothing worked, try adding UTC timezone

        // Try to parse without fractional seconds
        if let d = Date.nonFractalISO8601Formatter.date(from: dateString + "Z") {
            return d
        }

        if let d = Date.fractalISO8601Formatter.date(from: dateString + "Z") {
            return d
        }
        return nil
    }

    func isSimiliar(to other: Date, leeway: TimeInterval = 10) -> Bool {
        return abs(timeIntervalSince1970 - other.timeIntervalSince1970) < leeway
    }
}
