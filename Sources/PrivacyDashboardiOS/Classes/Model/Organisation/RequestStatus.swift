//
//  RequestStatus.swift
//  iGrant
//

import Foundation
import SwiftyJSON

class RequestStatus: RequestStatusWrapper {
    var RequestOngoing : Bool?
    var iD : String?
    var State : Int?
    var StateStr : String?
    var Comment: String?
    var RequestedDate: String?
    var ClosedDate: String?
    var TypeStr: String?
    var type: Int?
    var isActiveRequest = false
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!) {
        if json.isEmpty{
            return
        }
        RequestOngoing = json["RequestOngoing"].boolValue
        iD = json["ID"].stringValue
        State = json["State"].intValue
        StateStr = json["StateStr"].stringValue
        Comment = json["Comment"].stringValue
        RequestedDate = json["RequestedDate"].stringValue
        ClosedDate = json["ClosedDate"].stringValue
        TypeStr = json["TypeStr"].stringValue
        type = json["Type"].int
    }
}

protocol RequestStatusWrapper {
    var RequestOngoing : Bool? { get }
    var iD : String? { get }
    var State : Int? { get }
    var StateStr : String? { get }
    var Comment: String? { get }
    var RequestedDate: String? { get }
    var ClosedDate: String? { get }
    var TypeStr: String? { get }
    var type: Int? { get }
    var isActiveRequest: Bool { get }
}
