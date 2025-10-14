//
//	Link.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class Link: LinkWrapper {
	var next : String?
	var current : String?

	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		next = json["next"].stringValue
		current = json["self"].stringValue
	}
}

protocol LinkWrapper {
    var next : String? { get }
    var current : String? { get }
}
