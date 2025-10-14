//
//	Consent.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ConsentListDetails {
	var descriptionField : String?
	var iD : String?
	var status : ConsentStatus?
	var value : String?
	var consents : [Consent]?
	var count : Count?
	var purpose : Purpose?

	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!) {
		if json.isEmpty{
			return
		}
		descriptionField = json["Description"].stringValue
		iD = json["ID"].stringValue
		let statusJson = json["Status"]
		if !statusJson.isEmpty{
			status = ConsentStatus(fromJson: statusJson)
		}
		value = json["Value"].stringValue
		consents = [Consent]()
		let consentsArray = json["Consents"].arrayValue
		for consentsJson in consentsArray{
			let value = Consent(fromJson: consentsJson)
			consents?.append(value)
		}
		let countJson = json["Count"]
		if !countJson.isEmpty{
			count = Count(fromJson: countJson)
		}
		let purposeJson = json["Purpose"]
		if !purposeJson.isEmpty{
			purpose = Purpose(fromJson: purposeJson)
		}
	}
}

protocol ConsentListDetailsWrapper {
    var descriptionField : String? { get }
    var iD : String? { get }
    var status : ConsentStatus? { get }
    var value : String? { get }
    var consents : [Consent]? { get }
    var count : Count? { get }
    var purpose : Purpose? { get }
}
