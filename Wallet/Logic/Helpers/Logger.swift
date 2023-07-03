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
import UIKit

class Logger {
    #if ENABLE_LOGGING
        @UBUserDefault(key: "debugLogs", defaultValue: [])
        private static var debugLogs: [String]

        @UBUserDefault(key: "debugDates", defaultValue: [])
        private static var debugDates: [Date]

        private static let logQueue = DispatchQueue(label: "logger")

        static let changedNotification = Notification.Name(rawValue: "LoggerChanged")

        static var lastLogs: [(Date, String)] {
            Array(zip(debugDates, debugLogs))
        }

    #endif

    private init() {}

    public static func log(_ log: Any, appState: Bool = false) {
        #if ENABLE_LOGGING

            Logger.logQueue.async {
                var text = String(describing: log)
                if appState {
                    DispatchQueue.main.sync {
                        switch UIApplication.shared.applicationState {
                        case .active:
                            text += ", active"
                        case .inactive:
                            text += ", inactive"
                        case .background:
                            text += ", background"
                        @unknown default:
                            text += ", unknown"
                        }
                    }
                }
                Logger.debugLogs.append(text)
                Logger.debugDates.append(Date())

                if Logger.debugLogs.count > 100 {
                    Logger.debugLogs = Array(Logger.debugLogs.dropFirst())
                    Logger.debugDates = Array(Logger.debugDates.dropFirst())
                }
            }

        #endif
    }
}
