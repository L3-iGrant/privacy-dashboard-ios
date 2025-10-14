//
//  RecordsModel.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 05/01/24.
//

import Foundation

// MARK: - Records
class RecordsModel: Codable {
    var consentRecords: [ConsentRecordModel]
    let pagination: RecordsPagination
}

// MARK: - ConsentRecord
class ConsentRecordModel: Codable {
    let id, dataAgreementID, dataAgreementRevisionID, dataAgreementRevisionHash: String
    let individualID: String
    var optIn: Bool
    let state, signatureID: String

    enum CodingKeys: String, CodingKey {
        case id
        case dataAgreementID = "dataAgreementId"
        case dataAgreementRevisionID = "dataAgreementRevisionId"
        case dataAgreementRevisionHash
        case individualID = "individualId"
        case optIn, state
        case signatureID = "signatureId"
    }
}

// MARK: - Pagination
class RecordsPagination: Codable {
    let currentPage, totalItems, totalPages, limit: Int
    let hasPrevious, hasNext: Bool
}
