//
//  RequestedStatusHistory.swift
//  iGrant
//


import Foundation
import SwiftyJSON

class RequestedStatusHistory: RequestedStatusHistoryWrapper {
    var DataRequests: [RequestStatus]?
    var IsRequestsOngoing: Bool?
    var IsDataDeleteRequestOngoing: Bool?
    var IsDataDownloadRequestOngoing: Bool?
    var links: Link?
    var isActiveDeleteDataShown = false
    var isActiveDownloadDataShown = false
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!) {
        if json.isEmpty {
            return
        }
        let linksJson = json["Links"]
        if !linksJson.isEmpty {
            links = Link(fromJson: linksJson)
        }
        IsRequestsOngoing = json["IsRequestsOngoing"].boolValue
        IsDataDeleteRequestOngoing = json["IsDataDeleteRequestOngoing"].boolValue
        IsDataDownloadRequestOngoing = json["IsDataDownloadRequestOngoing"].boolValue
        DataRequests = [RequestStatus]()
        let DataRequestsArray = json["DataRequests"].arrayValue
        for DataRequestJson in DataRequestsArray {
            let value = RequestStatus(fromJson: DataRequestJson)
            if value.type == 1 {
                if (IsDataDeleteRequestOngoing ?? false) && !isActiveDeleteDataShown {
                    value.isActiveRequest = true
                    isActiveDeleteDataShown = true
                }
            } else if value.type == 2 {
                if (IsDataDownloadRequestOngoing ?? false) && !isActiveDownloadDataShown {
                    value.isActiveRequest = true
                    isActiveDownloadDataShown = true
                }
            }
            DataRequests?.append(value)
        }
    }
}

protocol RequestedStatusHistoryWrapper {
    var DataRequests: [RequestStatus]? { get }
    var IsRequestsOngoing: Bool? { get }
    var IsDataDeleteRequestOngoing: Bool? { get }
    var IsDataDownloadRequestOngoing: Bool? { get }
    var links: Link? { get }
    var isActiveDeleteDataShown: Bool { get }
    var isActiveDownloadDataShown: Bool { get }
}
