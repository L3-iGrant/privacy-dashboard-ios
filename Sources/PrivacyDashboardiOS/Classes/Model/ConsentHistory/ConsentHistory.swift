//
//	ConsentHistory.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ConsentHistory: ConsentHistoryWrapperV2 {
	var iD : String?
	var log : String?
	var orgID : String?
	var dataAgreementID : String?
	var timeStamp : String?

	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		iD = json["id"].stringValue
		log = json["log"].stringValue
		orgID = json["organisationId"].stringValue
        dataAgreementID = json["dataAgreementId"].stringValue
		timeStamp = json["timestamp"].stringValue
	}
}

// Api version 2
protocol ConsentHistoryWrapperV2 {
    var iD : String? { get }
    var log : String? { get }
    var orgID : String? { get }
    var dataAgreementID : String? { get }
    var timeStamp : String? { get }
}

// Api version 1
protocol ConsentHistoryWrapper {
    var iD : String? { get }
    var log : String? { get }
    var orgID : String? { get }
    var purposeID : String? { get }
    var timeStamp : String? { get }
}
