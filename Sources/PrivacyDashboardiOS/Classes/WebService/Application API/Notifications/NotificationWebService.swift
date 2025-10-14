
//
//  NotificationWebService.swift
//  iGrant
//
//  Created by Ajeesh T S on 21/10/18.
//  Copyright © 2018 iGrant.com. All rights reserved.
//

import UIKit

class NotificationWebService: BBConsentBaseWebService {

//    func notificationsList(){
//        self.url = baseUrl + "user/notifications"
//        GET()
//    }
//    
//    func notificationsListLoadMore(apiUrl : String){
//        self.url = apiUrl
//        GET()
//    }
//    
//    func notificationDetailsList(iD : String){
//        self.url = baseUrl + "user/notifications/" + iD + "/action"
//        GET()
//    }
//    
//    func notificationRead(iD : String){
//        self.url = baseUrl + "user/notifications/" + iD
//        PATCH()
//    }
    
    func consentHistoryList(offset: Int) {
        self.url = baseUrl + "/service/individual/record/consent-record/history?" + "offset=\(offset)" + "&limit=\(10)"
        getServiceCall()
    }
    
    func consentHistoryListWith(OrgID: String){
        self.url = baseUrl + "user/consenthistory?orgid=" + OrgID
        getServiceCall()
    }
    
    func consentHistoryListWith(startDate: String, endDate: String){
        self.url = baseUrl + "user/consenthistory?startDate=" + startDate + "&endDate=" + endDate
        getServiceCall()
    }
    
    func consentHistoryListLoadMore(apiUrl : String){
        self.url = apiUrl
        getServiceCall()
    }
}
