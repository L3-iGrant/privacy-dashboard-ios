
//
//  NotificationServiceManager.swift
//  iGrant
//
//  Created by Ajeesh T S on 21/10/18.
//  Copyright © 2018 iGrant.com. All rights reserved.
//

import UIKit
import SwiftyJSON

enum NotificationServiceType {
    case ConsentHistoryList
}
class NotificationServiceManager: BaseWebServiceManager {
    var serviceType = NotificationServiceType.ConsentHistoryList
    deinit{
        self.managerDelegate = nil
    }
    var isLoadMore = false
    
//    func getNotificationList(){
//        self.serviceType = .List
//        DispatchQueue.global().async{
//            let loginService = NotificationWebService()
//            loginService.delegate = self
//            loginService.notificationsList()
//        }
//    }
//    
//    func getNotificationDetails(notId : String){
//        self.serviceType = .Details
//        DispatchQueue.global().async{
//            let loginService = NotificationWebService()
//            loginService.delegate = self
//            loginService.notificationDetailsList(iD: notId)
//        }
//    }
//    
//    
//    func getNotificationLoadMoreList(url:String){
//        self.serviceType = .List
//        self.isLoadMore =  true
//        DispatchQueue.global().async{
//            let loginService = NotificationWebService()
//            loginService.delegate = self
//            loginService.notificationsListLoadMore(apiUrl: url)
//        }
//    }
//
//    func readNotification(notId :String){
//        self.serviceType = .Read
//        DispatchQueue.global().async{
//            let loginService = NotificationWebService()
//            loginService.delegate = self
//            loginService.parameters.updateValue(true as AnyObject, forKey: "readStatus")
//            loginService.notificationRead(iD: notId)
//        }
//    }
    
    func getConsentHistoryList(offset: Int){
        self.serviceType = .ConsentHistoryList
        DispatchQueue.global().async{
            let loginService = NotificationWebService()
            loginService.delegate = self
            loginService.consentHistoryList(offset: offset)
        }
    }
    
    func getConsentHistoryListWith(OrgID: String){
        self.serviceType = .ConsentHistoryList
        DispatchQueue.global().async{
            let loginService = NotificationWebService()
            loginService.delegate = self
            loginService.consentHistoryListWith(OrgID: OrgID)
        }
    }
    
    func getConsentHistoryListWith(startDate: String, endDate: String){
        self.serviceType = .ConsentHistoryList
        DispatchQueue.global().async{
            let loginService = NotificationWebService()
            loginService.delegate = self
            loginService.consentHistoryListWith(startDate: startDate, endDate: endDate)
        }
    }
    
    func getConsentHistoryLoadMoreList(url:String){
        self.serviceType = .ConsentHistoryList
        self.isLoadMore =  true
        DispatchQueue.global().async{
            let loginService = NotificationWebService()
            loginService.delegate = self
            loginService.consentHistoryListLoadMore(apiUrl: url)
        }
    }
}

extension NotificationServiceManager : BaseServiceDelegates {
    func didSuccessfullyReceiveData(response:RestResponse?){
        DispatchQueue.global().async {
            let responseData = response!.response!
            if responseData["errorCode"].string != nil{
                var errorMSg = ""
                if let msg = responseData["errorMsg"].string{
                    errorMSg = msg
                }
                DispatchQueue.main.async {
                    self.managerDelegate?.didFinishTask(from: self, response: (data: response, error: errorMSg))
                    return
                }
            }else{
                switch(self.serviceType) {
//                    case .List:self.handleListResponse(response: response)
//                    case .Details: self.handleNotificationDetailsResponse(response: response)
//                    case .Read : self.handleNotificationReadResponse(response: response)
                    case .ConsentHistoryList : self.handleConsentListResponse(response: response)
                }
            }
        }
        
    }
    
    func didFailedToReceiveData(response:RestResponse?){
        self.managerDelegate?.didFinishTask(from: self, response: (data: response, error: response?.message))
    }
    
}

extension NotificationServiceManager {
//    func handleListResponse(response:RestResponse?){
//        let responseData = response!.response!
//        DispatchQueue.global().async {
//            let notifcations = NotificationsData(fromJson: responseData)
//            response?.responseModel = notifcations as AnyObject?
//            DispatchQueue.main.async {
//                self.managerDelegate?.didFinishTask(from: self, response: (data: response, error: nil))
//            }
//        }
//    }
    
//    func handleNotificationDetailsResponse(response:RestResponse?){
//        let responseData = response!.response!
//        DispatchQueue.global().async {
//            let notifcations = OrgNotificationDetails(fromJson: responseData)
//            response?.responseModel = notifcations as AnyObject?
//            DispatchQueue.main.async {
//                self.managerDelegate?.didFinishTask(from: self, response: (data: response, error: nil))
//            }
//        }
//    }
//
//    func handleNotificationReadResponse(response:RestResponse?){
//        let responseData = response!.response!
//        DispatchQueue.global().async {
//            DispatchQueue.main.async {
//                self.managerDelegate?.didFinishTask(from: self, response: (data: response, error: nil))
//            }
//        }
//    }
    
    func handleConsentListResponse(response:RestResponse?){
        let responseData = response!.response!
        DispatchQueue.global().async {
            let historyData = ConsentHistoryData(fromJson: responseData)
            response?.responseModel = historyData as AnyObject?
            DispatchQueue.main.async {
                self.managerDelegate?.didFinishTask(from: self, response: (data: response, error: nil))
            }
        }
    }

    
}
