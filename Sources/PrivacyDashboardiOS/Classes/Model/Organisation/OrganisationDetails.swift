//
//  OrganisationDetails.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 06/09/23.
//

import Foundation
import SwiftyJSON

class OrganisationDetails: OrganisationDetailsWrapper {
    
    var consents : [ConsentWrapper]?
    var organization : OrganizationWrapper?
    var purposeConsents : [PurposeConsentWrapperV2]?
    var consentID : String?

    init(fromJson json: JSON!) {
        if json.isEmpty{
            return
        }
        consents = [Consent]()
        consentID = json["ConsentID"].string
        let consentsArray = json["Consents"].arrayValue
        for consentsJson in consentsArray{
            let value = Consent(fromJson: consentsJson)
            consents?.append(value)
        }
        purposeConsents = [PurposeConsent]()
        let purposeConsentsArray = json["dataAgreements"].arrayValue
        for purposeConsentsJson in purposeConsentsArray{
            let value = PurposeConsent(fromJson: purposeConsentsJson)
            purposeConsents?.append(value)
        }
    }
}

protocol OrganisationDetailsWrapper {
    var consents : [ConsentWrapper]? { get }
    var organization : OrganizationWrapper? { get }
    var purposeConsents : [PurposeConsentWrapperV2]? { get }
    var consentID : String? { get }
}
