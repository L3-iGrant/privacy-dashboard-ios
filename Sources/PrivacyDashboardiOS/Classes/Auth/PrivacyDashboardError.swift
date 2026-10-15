//
//  PrivacyDashboardError.swift
//  PrivacyDashboardiOS
//

import Foundation

public enum PrivacyDashboardError: Error {
    // No token provider is set. Call `PrivacyDashboard.configure(baseUrl:organisationId:tokenProvider:)`.
    case notConfigured
    // The token provider gave an empty token.
    case invalidToken
}
