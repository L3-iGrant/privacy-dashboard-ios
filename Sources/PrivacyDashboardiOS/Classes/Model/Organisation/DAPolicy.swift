//
//  DAPolicy.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 15/11/23.
//

import Foundation
// MARK: - DataAgreementPolicy
class DAPolicy: Codable {
    var forgettable: Bool?
    var policy: Policy?
    var purpose, lifecycle, purposeDescription: String?
    var dataAttributes: [DataAttributeInPolicy]?
    var compatibleWithVersionID, controllerName: String?
    var signature: Signature?
    var id, controllerID, lawfulBasis, version: String?
    var methodOfUse, dpiaDate: String?
    var active: Bool?
    var dpiaSummaryUrl: String?
    var controllerURL: String?

    enum CodingKeys: String, CodingKey {
        case forgettable, policy, purpose, lifecycle, purposeDescription, dataAttributes
        case compatibleWithVersionID
        case controllerName, signature, id
        case controllerID
        case lawfulBasis, version, methodOfUse, dpiaDate, active
        case dpiaSummaryUrl
        case controllerURL
    }

    init(forgettable: Bool?, policy: Policy?, purpose: String?, lifecycle: String?, purposeDescription: String?, dataAttributes: [DataAttributeInPolicy]?, compatibleWithVersionID: String?, controllerName: String?, signature: Signature?, id: String?, controllerID: String?, lawfulBasis: String?, version: String?, methodOfUse: String?, dpiaDate: String?, active: Bool?, dpiaSummaryUrl: String?, controllerURL: String?) {
        self.forgettable = forgettable
        self.policy = policy
        self.purpose = purpose
        self.lifecycle = lifecycle
        self.purposeDescription = purposeDescription
        self.dataAttributes = dataAttributes
        self.compatibleWithVersionID = compatibleWithVersionID
        self.controllerName = controllerName
        self.signature = signature
        self.id = id
        self.controllerID = controllerID
        self.lawfulBasis = lawfulBasis
        self.version = version
        self.methodOfUse = methodOfUse
        self.dpiaDate = dpiaDate
        self.active = active
        self.dpiaSummaryUrl = dpiaSummaryUrl
        self.controllerURL = controllerURL
    }
}

// MARK: - DataAttribute
class DataAttributeInPolicy: Codable {
    var category, id, description: String?
    var sensitivity: Bool?
    var name: String?

    init(category: String?, id: String?, description: String?, sensitivity: Bool?, name: String?) {
        self.category = category
        self.id = id
        self.description = description
        self.sensitivity = sensitivity
        self.name = name
    }
}

// MARK: - Policy
class Policy: Codable {
    var url: String?
    var dataRetentionPeriodDays: Int?
    var version, id, industrySector, geographicRestriction: String?
    var thirdPartyDataSharing: Bool?
    var jurisdiction, storageLocation, name: String?

    init(url: String?, dataRetentionPeriodDays: Int?, version: String?, id: String?, industrySector: String?, geographicRestriction: String?, thirdPartyDataSharing: Bool?, jurisdiction: String?, storageLocation: String?, name: String?) {
        self.url = url
        self.dataRetentionPeriodDays = dataRetentionPeriodDays
        self.version = version
        self.id = id
        self.industrySector = industrySector
        self.geographicRestriction = geographicRestriction
        self.thirdPartyDataSharing = thirdPartyDataSharing
        self.jurisdiction = jurisdiction
        self.storageLocation = storageLocation
        self.name = name
    }
}

// MARK: - Signature
class Signature: Codable {
    var id: String?
    var signedWithoutObjectReference: Bool?
    var verificationMethod, verificationPayload, payload, timestamp: String?
    var objectType, verificationPayloadHash, objectReference, signature: String?
    var verificationJwsHeader, verificationSignedAs, verificationSignedBy, verificationArtifact: String?

    init(id: String?, signedWithoutObjectReference: Bool?, verificationMethod: String?, verificationPayload: String?, payload: String?, timestamp: String?, objectType: String?, verificationPayloadHash: String?, objectReference: String?, signature: String?, verificationJwsHeader: String?, verificationSignedAs: String?, verificationSignedBy: String?, verificationArtifact: String?) {
        self.id = id
        self.signedWithoutObjectReference = signedWithoutObjectReference
        self.verificationMethod = verificationMethod
        self.verificationPayload = verificationPayload
        self.payload = payload
        self.timestamp = timestamp
        self.objectType = objectType
        self.verificationPayloadHash = verificationPayloadHash
        self.objectReference = objectReference
        self.signature = signature
        self.verificationJwsHeader = verificationJwsHeader
        self.verificationSignedAs = verificationSignedAs
        self.verificationSignedBy = verificationSignedBy
        self.verificationArtifact = verificationArtifact
    }
}
