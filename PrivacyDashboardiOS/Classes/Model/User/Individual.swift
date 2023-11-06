//
//  Individual.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 06/11/23.
//

import Foundation

// MARK: - IndividualRecord
class IndividualRecord: Codable {
    var individual: Individual?

    init(individual: Individual?) {
        self.individual = individual
    }
}

// MARK: - Individual
class Individual: Codable {
    var id, externalID, externalIDType, identityProviderID: String?
    var name, iamID, email, phone: String?

    init(id: String?, externalID: String?, externalIDType: String?, identityProviderID: String?, name: String?, iamID: String?, email: String?, phone: String?) {
        self.id = id
        self.externalID = externalID
        self.externalIDType = externalIDType
        self.identityProviderID = identityProviderID
        self.name = name
        self.iamID = iamID
        self.email = email
        self.phone = phone
    }
}
