//
//	Consent.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class PurposeDetails {
	var consentslist : [ConsentDetails]?
	var count : Count?
	var purpose : Purpose?

	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!) {
		if json.isEmpty{
			return
		}
		consentslist = [ConsentDetails]()
		let consentslisArray = json["Consents"].arrayValue
		for consentslisJson in consentslisArray{
			let value = ConsentDetails(fromJson: consentslisJson)
			consentslist?.append(value)
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

protocol PurposeDetailsWrapper {
    var consentslist : [ConsentDetails]? { get }
    var count : Count? { get }
    var purpose : Purpose? { get }
}
