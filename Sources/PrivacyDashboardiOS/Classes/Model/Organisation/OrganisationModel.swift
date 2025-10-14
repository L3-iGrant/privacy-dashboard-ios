//
//  OrganisationModel.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 05/01/24.
//

import Foundation

// MARK: - Organisation
struct OrganisationModel: Codable {
    let organisation: OrganisationClass
}

// MARK: - OrganisationClass
struct OrganisationClass: Codable {
    let id, name, description, sector: String
    let location: String
    let policyURL: String
    let coverImageID: String
    let coverImageURL: String
    let logoImageID: String
    let logoImageURL: String

    enum CodingKeys: String, CodingKey {
        case id, name, description, sector, location
        case policyURL = "policyUrl"
        case coverImageID = "coverImageId"
        case coverImageURL = "coverImageUrl"
        case logoImageID = "logoImageId"
        case logoImageURL = "logoImageUrl"
    }
}
