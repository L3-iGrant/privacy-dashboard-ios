//
//    OrgType.swift
//    Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import SwiftyJSON

class OrgType: OrgTypeWrapper {
    var iD : String?
    var icon : URL?
    var type : String?
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!) {
        if json.isEmpty{
            return
        }
        iD = json["ID"].stringValue
        icon = json["ImageURL"].url
        type = json["Type"].stringValue
    }
}

protocol OrgTypeWrapper {
    var iD : String? { get set }
    var icon : URL? { get }
    var type : String? { get set }
}
