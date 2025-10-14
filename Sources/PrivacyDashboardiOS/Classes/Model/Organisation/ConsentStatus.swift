//
//    Statu.swift
//    Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import SwiftyJSON

class ConsentStatus: ConsentStatusWrapper {
    var consented = ConsentType.Allow
    var days : Int?
    var remaining : Int?
    var timeStamp : String?

    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!) {
        if json.isEmpty{
            return
        }
//        consented = json["Consented"].stringValue
        days = json["Days"].intValue
        remaining = json["Remaining"].intValue
        timeStamp = json["TimeStamp"].stringValue
        if json["Consented"].stringValue.lowercased() == "Allow".lowercased(){
            consented = .Allow
        }
        else if json["Consented"].stringValue.lowercased() == "DisAllow".lowercased(){
            consented = .Disallow
        }
        else if json["Consented"].stringValue.lowercased() == "yes".lowercased(){
            consented = .Allow
        }
        else{
            consented = .AskMe
        }
    }
}

protocol ConsentStatusWrapper {
    var consented: ConsentType { get set }
    var days : Int? { get set }
    var remaining : Int? { get }
    var timeStamp : String? { get }
}
