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
import os.log

class OSLogger {
    let osLog: OSLog
    let category: String

    var logger: OSLog {
        #if ENABLE_OS_LOG
            return osLog
        #else
            return OSLog.disabled
        #endif
    }

    init(_ bundle: Bundle = .main, category: String? = nil) {
        self.category = category ?? "default"
        osLog = OSLog(subsystem: bundle.bundleIdentifier ?? "default", category: category ?? "default")
    }

    init(_ aClass: AnyClass, category: String? = nil) {
        self.category = category ?? String(describing: aClass)
        osLog = OSLog(subsystem: Bundle(for: aClass).bundleIdentifier ?? "default", category: category ?? String(describing: aClass))
    }

    @inlinable func log(_ message: StaticString, _ args: CVarArg...) {
        log(message, type: .default, args)
    }

    @inlinable func info(_ message: StaticString, _ args: CVarArg...) {
        log(message, type: .info, args)
    }

    @inlinable func debug(_ message: StaticString, _ args: CVarArg...) {
        log(message, type: .debug, args)
    }

    @inlinable func error(_ message: StaticString, _ args: CVarArg...) {
        log(message, type: .error, args)
    }

    @inlinable func fault(_ message: StaticString, _ args: CVarArg...) {
        log(message, type: .fault, args)
    }

    func print(_ value: @autoclosure () -> Any) {
        log("%{public}@", type: .debug, [String(describing: value())])
    }

    func dump(_ value: @autoclosure () -> Any) {
        var string = String()
        Swift.dump(value(), to: &string)
        log("%{public}@", type: .debug, [string])
    }

    func trace(file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        guard osLog.isEnabled(type: .info) else { return }
        let file = URL(fileURLWithPath: String(describing: file)).deletingPathExtension().lastPathComponent
        var function = String(describing: function)
        function.removeSubrange(function.firstIndex(of: "(")! ... function.lastIndex(of: ")")!)
        log("%{public}@.%{public}@():%ld", type: .default, [file, function, line])
    }

    @usableFromInline internal func log(_ message: StaticString, type: OSLogType, _ a: [CVarArg]) {
        // The Swift overlay of os_log prevents from accepting an unbounded number of args
        // http://www.openradar.me/33203955

        guard logger.isEnabled(type: type) else { return }

        assert(a.count <= 6)
        switch a.count {
        case 6: os_log(message, log: logger, type: type, a[0], a[1], a[2], a[3], a[4], a[5])
        case 5: os_log(message, log: logger, type: type, a[0], a[1], a[2], a[3], a[4])
        case 4: os_log(message, log: logger, type: type, a[0], a[1], a[2], a[3])
        case 3: os_log(message, log: logger, type: type, a[0], a[1], a[2])
        case 2: os_log(message, log: logger, type: type, a[0], a[1])
        case 1: os_log(message, log: logger, type: type, a[0])
        default: os_log(message, log: logger, type: type)
        }
    }
}
