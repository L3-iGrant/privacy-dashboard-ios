//
//	Status.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON


class Status: StatusWrapper {

	var consented = ConsentType.Allow
	var days : Int?
	var timeStamp : String?


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
        if json["Consented"].stringValue == "Allow"{
            consented = .Allow
        }
        else if json["Consented"].stringValue == "Disallow"{
            consented = .Disallow
        }
        else if json["Consented"].stringValue == "yes"{
            consented = .Allow
        }
        else{
            consented = .AskMe
        }
		days = json["Days"].intValue
		timeStamp = json["TimeStamp"].stringValue
	}

}

protocol StatusWrapper {
    var consented : ConsentType { get }
    var days : Int? { get }
    var timeStamp : String? { get }
}
