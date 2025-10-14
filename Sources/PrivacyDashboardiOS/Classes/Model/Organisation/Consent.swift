//
//    Consent.swift
//    Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import SwiftyJSON

class Consent: ConsentWrapper {

    var data : String?
    var iD : String?
    var orgID : String?
    var status : StatusWrapper?
    var userID : String?
    var value : String?


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!) {
        if json.isEmpty{
            return
        }
        data = json["Data"].stringValue
        iD = json["ID"].stringValue
        orgID = json["OrgID"].stringValue
        let statusJson = json["Status"]
        if !statusJson.isEmpty{
            status = Status(fromJson: statusJson)
        }
        userID = json["UserID"].stringValue
        value = json["Value"].stringValue
    }
}

protocol ConsentWrapper {
    var data : String? { get }
    var iD : String? { get }
    var orgID : String? { get }
    var status : StatusWrapper? { get }
    var userID : String? { get }
    var value : String? { get }
}
