//
//  DataAgreements.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 04/01/24.
//

import Foundation
// MARK: - DataAgreements
struct DataAgreementsModel: Codable {
    var dataAgreements: [DataAgreements]
    let pagination: PaginationModel
}

// MARK: - DataAgreement
struct DataAgreements: Codable {
    var active: Bool
    let compatibleWithVersionID, controllerID, controllerName: String
    let controllerURL: String
    let dataAttributes: [DataAttributeModel]
    let dpiaDate: String
    let dpiaSummaryURL: String
    let forgettable: Bool
    let id, lawfulBasis, lifecycle, methodOfUse: String
    let policy: PolicyModel
    let purpose, purposeDescription: String
    let signature: SignatureModel
    let version: String

    enum CodingKeys: String, CodingKey {
        case active
        case compatibleWithVersionID = "compatibleWithVersionId"
        case controllerID = "controllerId"
        case controllerName
        case controllerURL = "controllerUrl"
        case dataAttributes, dpiaDate
        case dpiaSummaryURL = "dpiaSummaryUrl"
        case forgettable, id, lawfulBasis, lifecycle, methodOfUse, policy, purpose, purposeDescription, signature, version
    }
}

// MARK: - DataAttribute
struct DataAttributeModel: Codable {
    let category, description, id, name: String
    let sensitivity: Bool
}

// MARK: - Policy
struct PolicyModel: Codable {
    let dataRetentionPeriodDays: Int
    let geographicRestriction, id, industrySector, jurisdiction: String
    let name, storageLocation: String
    let thirdPartyDataSharing: Bool
    let url: String
    let version: String
}

// MARK: - Signature
struct SignatureModel: Codable {
    let id, objectReference, objectType, payload: String
    let signature: String
    let signedWithoutObjectReference: Bool
    let timestamp, verificationArtifact, verificationJwsHeader, verificationMethod: String
    let verificationPayload, verificationPayloadHash, verificationSignedAs, verificationSignedBy: String
}

// MARK: - Pagination
struct PaginationModel: Codable {
    let currentPage, totalItems, totalPages, limit: Int
    let hasPrevious, hasNext: Bool
}
