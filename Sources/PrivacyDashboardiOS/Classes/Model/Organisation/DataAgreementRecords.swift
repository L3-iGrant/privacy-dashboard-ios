//
//  DataAgreementRecords.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 26/10/23.
//

import Foundation

// MARK: - DataAgreementRecords
struct DataAgreementRecords: Codable {
    var consentRecords: [ConsentRecord]?
    var pagination: Pagination?
}

// MARK: - DataAgreementRecord
class ConsentRecord: Codable {
    var id, dataAgreementId, dataAgreementRevisionId, dataAgreementRevisionHash: String?
    var individualID: String?
    var optIn: Bool?
    var state, signatureID: String?
}
