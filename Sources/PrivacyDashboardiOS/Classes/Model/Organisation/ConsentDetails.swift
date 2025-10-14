//
//	Consentsli.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ConsentDetails {
	var descriptionField : String?
	var iD : String?
	var status : ConsentStatusWrapper?
	var value : String?

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
	}
}

protocol ConsentDetailsWrapper {
    var descriptionField : String? { get }
    var iD : String? { get }
    var status : ConsentStatusWrapper? { get }
    var value : String? { get } 
}
