//
//	ConsentListing.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ConsentListingResponse: ConsentListingResponseWrapper {
    var dataAttributes: [DataAttribute]?
	var consentID : String?
	var consents : PurposeDetails?
	var iD : String?
	var orgID : String?
	var userID : String?

	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
        
        let dataAttributesArray = json["dataAttributes"].arrayValue
        dataAttributes = [DataAttribute]()
        for dataAttribute in dataAttributesArray{
            let value = DataAttribute(fromJson: dataAttribute)
            dataAttributes?.append(value)
        }
        
		consentID = json["ConsentID"].stringValue
		let consentsJson = json["Consents"]
		if !consentsJson.isEmpty{
			consents = PurposeDetails(fromJson: consentsJson)
		}
		iD = json["ID"].stringValue
		orgID = json["OrgID"].stringValue
		userID = json["UserID"].stringValue
	}
}


protocol ConsentListingResponseWrapper {
    var consentID : String? { get }
    var consents : PurposeDetails? { get }
    var iD : String? { get }
    var orgID : String? { get }
    var userID : String? { get }
    var dataAttributes: [DataAttribute]? { get }
}

// MARK: - DataAttribute
class DataAttribute {
    var id, version: String?
    var name, description: String?
    var sensitivity: Bool?
    var category: String?
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        id = json["id"].stringValue
        version = json["version"].stringValue
        name = json["name"].stringValue
        description = json["description"].stringValue
        sensitivity = json["sensitivity"].boolValue
        category = json["category"].stringValue
    }
}

