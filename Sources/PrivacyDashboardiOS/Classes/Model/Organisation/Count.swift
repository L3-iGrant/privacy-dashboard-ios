//
//    Count.swift
//    Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import SwiftyJSON

 class Count: CountWrapper {
    var consented : Int?
    var total : Int?

    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!) {
        if json.isEmpty{
            return
        }
        consented = json["Consented"].intValue
        total = json["Total"].intValue
    }
}

protocol CountWrapper {
    var consented : Int? { get }
    var total : Int? { get }
}
