//
//  BBConsentLog.swift
//  PrivacyDashboardiOS
//

import Foundation
import os

// Logging of the SDK. Debug messages are off by default. When they are on,
// the message text is private: the unified log shows it only on a device
// that has a debugger attached. Do not log tokens, API keys or bodies with
// personal data in warnings.
enum BBConsentLog {
    static var isEnabled = false
    private static let logger = Logger(subsystem: "io.igrant.PrivacyDashboardiOS", category: "sdk")

    static func debug(_ message: @autoclosure () -> String) {
        guard isEnabled else { return }
        let text = message()
        logger.debug("\(text, privacy: .private)")
    }

    // Always on. Use only for static texts without secrets or personal data.
    static func warning(_ message: String) {
        logger.warning("\(message, privacy: .public)")
    }
}
