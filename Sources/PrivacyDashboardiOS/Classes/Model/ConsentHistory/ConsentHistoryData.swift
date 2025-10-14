//
//	ConsentHistoryData.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ConsentHistoryData: ConsentHistoryDataWrapperV2 {
	var consentHistory : [ConsentHistory]?
    var pagination: Pagination?

	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		consentHistory = [ConsentHistory]()
		let consentHistoryArray = json["consentRecordHistory"].arrayValue
		for consentHistoryJson in consentHistoryArray{
			let value = ConsentHistory(fromJson: consentHistoryJson)
			consentHistory?.append(value)
		}
        let tempPagination = json["pagination"]
        if !tempPagination.isEmpty {
            pagination = Pagination(fromJson: tempPagination)
        }
	}
}

// Api version 1
protocol ConsentHistoryDataWrapper {
    var consentHistory : [ConsentHistoryWrapper]? { get }
    var links : Link?  { get }
    var unReadCount : Int?  { get }
}

// Api version 2
protocol ConsentHistoryDataWrapperV2 {
    var consentHistory : [ConsentHistory]? { get }
    var pagination: Pagination? { get }
}

class Pagination: PaginationWrapper, Codable {
    var currentPage: Int?
    var totalItems: Int?
    var totalPages: Int?
    var limit: Int?
    var hasPrevious = false
    var hasNext = false
    
    init(fromJson json: JSON!) {
        if json.isEmpty{
            return
        }
        currentPage = json["currentPage"].intValue
        totalItems = json["totalItems"].intValue
        totalPages = json["totalPages"].intValue
        limit = json["limit"].intValue
        hasPrevious = json["hasPrevious"].boolValue
        hasNext = json["hasNext"].boolValue
    }
}

protocol PaginationWrapper {
    var currentPage: Int? { get }
    var totalItems: Int? { get }
    var totalPages: Int? { get }
    var limit: Int? { get }
    var hasPrevious: Bool { get }
    var hasNext: Bool { get }
}
