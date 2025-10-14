//
//  BBConsentBaseWebService.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 31/08/23.
//

import Foundation
import Alamofire
import SwiftyJSON

class RestResponse : NSObject {
    var response : JSON?
    var responseModel : AnyObject?
    var responseCode : Int?
    var responseHttpCode : Int?
    var responseDetail : AnyObject?
    var error : Error?
    var paginationIndex : NSMutableString?
    var requestData : AnyObject?
    var message : String?
    var serviceType = WebServiceType.None
}

class MultipartData: NSObject {
    var data: NSData
    var name: String
    var fileName: String
    var mimeType: String
    init(data: NSData, name: String, fileName: String, mimeType: String) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

@objc protocol BaseServiceDelegates {
    // The service call was successful and the data is passed to the manager
    @objc optional func didSuccessfullyReceiveData(response:RestResponse?)
    // The service call was failed and the error message to be shown is fetched and returned to the manager.
    @objc optional func didFailedToReceiveData(response:RestResponse?)
    @objc optional func imageUploadPrograss(prograssValue : Float)
}

enum WebServiceType {
    case None
    case ReCallLogin
}

class BBConsentBaseWebService: NSObject {
    var serviceType = WebServiceType.None
    var delegate : BaseServiceDelegates?
    var url: String?
    var parameters = [String: Any]()
    var uploadData: [MultipartData]?
    var header:[String : String]?
    var requestInfo : [String:String]?
    var errorMsg : String?
    var baseUrl = BBConsentPrivacyDashboardiOS.shared.baseUrl
    static var shared = BBConsentBaseWebService()

    
    func refreshToken() {
        let refreshToken : String = (UserInfo.currentUser()?.refreshToken)!
        self.parameters =  ["clientId": "igrant-ios-app" as AnyObject, "refreshToken": refreshToken as AnyObject]
        self.url = baseUrl + "user/token"
        self.postServiceCall()
    }

    func failureWithError(error: Error?) {
        let restResponse = RestResponse()
        restResponse.error = error
        restResponse.message = errorMsg
        restResponse.serviceType = self.serviceType
        delegate?.didFailedToReceiveData!(response: restResponse)
    }
    
    func successWithResponse(response:JSON?) {
        let restResponse = RestResponse()
        restResponse.response = response
        restResponse.serviceType = self.serviceType
        restResponse.requestData = self.requestInfo as AnyObject?
        delegate?.didSuccessfullyReceiveData!(response: restResponse)
    }

    func getServiceCall() {
        // Note: If Apikey or UserID not available, use accessToken
        if BBConsentPrivacyDashboardiOS.shared.userId == "" || BBConsentKeyChainUtils.load(key: "BBConsentApiKey") == nil {
            let accessToken = BBConsentPrivacyDashboardiOS.shared.accessToken ?? ""
            let hearDict = ["Authorization":"Bearer \(accessToken)"]
            header = hearDict
        } else {
            if let tokendata = BBConsentKeyChainUtils.load(key: "BBConsentApiKey") {
                let token = String(data: tokendata, encoding: .utf8) ?? ""
                let hearDict = ["Authorization":"ApiKey \(token)", "X-ConsentBB-IndividualId": BBConsentPrivacyDashboardiOS.shared.userId ?? ""]
                header = hearDict
            } else {
                debugPrint("###No API key available!")
            }
        }
        
        AF.request(url!, parameters: parameters, headers:HTTPHeaders.init(header ?? [:]))
            .validate()
            .responseJSON { response in
                switch response.result{
                case .success(let value):
                    //                    if let val = response.result.value {
                    let json = JSON(value)
                    self.successWithResponse(response: json)
                    //                    }
                case .failure(let error):
                    if let data = response.data, let utf8Text = String.init(data: data, encoding: String.Encoding.utf8) {
                        print("Data: \(utf8Text)")
                    }
                    let json = JSON(response.data as Any)
                    if let errormsg = json["error_description"].string{
                        self.errorMsg = errormsg
                    }
                    if let errormsg = json["Message"].string{
                        self.errorMsg = errormsg
                    }
                    self.failureWithError(error: error)
                }
            }
    }
    
    func postUploadServiceCall() {
        if let data = uploadData {
            self.upload(data: data)
        }
        else {
            postServiceCall()
        }
    }
    
    
    func postServiceCall() {
        // Note: If Apikey or UserID not available, use accessToken
        if BBConsentPrivacyDashboardiOS.shared.userId == "" || BBConsentKeyChainUtils.load(key: "BBConsentApiKey") == nil {
            let accessToken = BBConsentPrivacyDashboardiOS.shared.accessToken ?? ""
            let hearDict = ["Authorization":"Bearer \(accessToken)"]
            header = hearDict
        } else {
            if let tokendata = BBConsentKeyChainUtils.load(key: "BBConsentApiKey") {
                let token = String(data: tokendata, encoding: .utf8) ?? ""
                let hearDict = ["Authorization":"ApiKey \(token)", "X-ConsentBB-IndividualId": BBConsentPrivacyDashboardiOS.shared.userId ?? ""]
                header = hearDict
            } else {
                debugPrint("###No API key available!")
            }
        }
        
        if serviceType == .ReCallLogin{
            header = nil
        }
        AF.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default , headers:HTTPHeaders.init(header ?? [:]))
            .validate()
            .responseJSON { response in
                switch response.result{
                case .success(let value):
                    //                    if let val = response.result.value {
                    let json = JSON(value)
                    self.successWithResponse(response: json)
                    //                    }
                case .failure(let error):
                    if let data = response.data, let utf8Text = String.init(data: data, encoding: String.Encoding.utf8) {
                        print("Data: \(utf8Text)")
                    }
                    let json = JSON(response.data as Any)
                    if let errormsg = json["error_description"].string{
                        self.errorMsg = errormsg
                    }
                    if let errormsg = json["Message"].string{
                        self.errorMsg = errormsg
                    }
                    self.failureWithError(error: error)
                }
            }
    }
    
    func putServiceCall() {
        // Note: If Apikey or UserID not available, use accessToken
        if BBConsentPrivacyDashboardiOS.shared.userId == "" || BBConsentKeyChainUtils.load(key: "BBConsentApiKey") == nil {
            let accessToken = BBConsentPrivacyDashboardiOS.shared.accessToken ?? ""
            let hearDict = ["Authorization":"Bearer \(accessToken)"]
            header = hearDict
        } else {
            if let tokendata = BBConsentKeyChainUtils.load(key: "BBConsentApiKey") {
                let token = String(data: tokendata, encoding: .utf8) ?? ""
                let hearDict = ["Authorization":"ApiKey \(token)", "X-ConsentBB-IndividualId": BBConsentPrivacyDashboardiOS.shared.userId ?? ""]
                header = hearDict
            } else {
                debugPrint("###No API key available!")
            }
        }
        
        AF.request(url!, method: .put, parameters: parameters,  encoding: JSONEncoding.default, headers:HTTPHeaders.init(header ?? [:]))
            .validate()
            .responseJSON { response in
                switch response.result{
                case .success(let value):
                    //                    if let val = response.result.value {
                    let json = JSON(value)
                    self.successWithResponse(response: json)
                    //                    }
                case .failure(let error):
                    if let data = response.data, let utf8Text = String.init(data: data, encoding: String.Encoding.utf8) {
                        print("Data: \(utf8Text)")
                    }
                    let json = JSON(response.data as Any)
                    if let errormsg = json["error_description"].string{
                        self.errorMsg = errormsg
                    }
                    if let errormsg = json["Message"].string{
                        self.errorMsg = errormsg
                    }
                    self.failureWithError(error: error)
                }
            }
    }
    
    
    func patchServiceCall() {
        // Note: If Apikey or UserID not available, use accessToken
        if BBConsentPrivacyDashboardiOS.shared.userId == "" || BBConsentKeyChainUtils.load(key: "BBConsentApiKey") == nil {
            let accessToken = BBConsentPrivacyDashboardiOS.shared.accessToken ?? ""
            let hearDict = ["Authorization":"Bearer \(accessToken)"]
            header = hearDict
        } else {
            if let tokendata = BBConsentKeyChainUtils.load(key: "BBConsentApiKey") {
                let token = String(data: tokendata, encoding: .utf8) ?? ""
                let hearDict = ["Authorization":"ApiKey \(token)", "X-ConsentBB-IndividualId": BBConsentPrivacyDashboardiOS.shared.userId ?? ""]
                header = hearDict
            } else {
                debugPrint("###No API key available!")
            }
        }
        
        AF.request(url!, method: .patch, parameters: parameters, encoding: JSONEncoding.default,headers:HTTPHeaders.init(header ?? [:])
        )
        .validate()
        .responseJSON {response in
            switch response.result{
            case .success(let value):
                //                    if let val = response.result.value {
                let json = JSON(value)
                self.successWithResponse(response: json)
                //                    }
            case .failure(let error):
                if let data = response.data, let utf8Text = String.init(data: data, encoding: String.Encoding.utf8) {
                    print("Data: \(utf8Text)")
                }
                let json = JSON(response.data as Any)
                if let errormsg = json["error_description"].string{
                    self.errorMsg = errormsg
                }
                if let errormsg = json["Message"].string{
                    self.errorMsg = errormsg
                }
                self.failureWithError(error: error)
            }
        }
    }
    
    
    func deleteServiceCall() {
        // Note: If Apikey or UserID not available, use accessToken
        if BBConsentPrivacyDashboardiOS.shared.userId == "" || BBConsentKeyChainUtils.load(key: "BBConsentApiKey") == nil {
            let accessToken = BBConsentPrivacyDashboardiOS.shared.accessToken ?? ""
            let hearDict = ["Authorization":"Bearer \(accessToken)"]
            header = hearDict
        } else {
            if let tokendata = BBConsentKeyChainUtils.load(key: "BBConsentApiKey") {
                let token = String(data: tokendata, encoding: .utf8) ?? ""
                let hearDict = ["Authorization":"ApiKey \(token)", "X-ConsentBB-IndividualId": BBConsentPrivacyDashboardiOS.shared.userId ?? ""]
                header = hearDict
            } else {
                debugPrint("###No API key available!")
            }
        }
        
        AF.request(url!, method: .delete, headers:HTTPHeaders.init(header ?? [:]))
            .validate()
            .responseJSON { response in
                switch response.result{
                case .success(let value):
                    //                    if let val = value {
                    let json = JSON(value as Any)
                    self.successWithResponse(response: json)
                    //                    }
                case .failure(let error):
                    let json = JSON(response.data as Any)
                    if let errormsg = json["error_description"].string{
                        self.errorMsg = errormsg
                    }
                    if let errormsg = json["Message"].string{
                        self.errorMsg = errormsg
                    }
                    self.failureWithError(error: error)
                }
            }
    }
    
    func upload(data: [MultipartData]) {
        // Note: If Apikey or UserID not available, use accessToken
        if BBConsentPrivacyDashboardiOS.shared.userId == "" || BBConsentKeyChainUtils.load(key: "BBConsentApiKey") == nil {
            let accessToken = BBConsentPrivacyDashboardiOS.shared.accessToken ?? ""
            let hearDict = ["Authorization":"Bearer \(accessToken)"]
            header = hearDict
        } else {
            if let tokendata = BBConsentKeyChainUtils.load(key: "BBConsentApiKey") {
                let token = String(data: tokendata, encoding: .utf8) ?? ""
                let hearDict = ["Authorization":"ApiKey \(token)", "X-ConsentBB-IndividualId": BBConsentPrivacyDashboardiOS.shared.userId ?? ""]
                header = hearDict
            } else {
                debugPrint("###No API key available!")
            }
        }
        
        let urlRequest = try! URLRequest(url: url!, method: .post, headers: HTTPHeaders.init(header ?? [:]))
        AF.upload(multipartFormData: { multipartFormData in
            for (key,value) in self.parameters {
                if let valueString = value as? String {
                    multipartFormData.append(valueString.data(using: String.Encoding.utf8)!, withName: key)
                }
            }
            for data in self.uploadData! {
                multipartFormData.append(data.data as Data, withName: data.name, fileName: data.fileName, mimeType: data.mimeType)
            }
        }, to: url!).responseJSON { (encodingResult) in
            switch encodingResult.result {
            case .success(let value):
                //                upload.responseJSON { response in
                debugPrint(value)
                let json = JSON(value as Any)
                self.successWithResponse(response: json)
                //                }
            case .failure(let encodingError):
                print(encodingError)
                self.failureWithError(error: encodingError)
            }
        }
    }
}

// MARK: - Single Almofire call for all API's
extension BBConsentBaseWebService {
    
    enum ApiType: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
    
    func makeAPICall(urlString: String, parameters: [String: Any] = [:], headers: [String: String] = [:], method: ApiType, completion:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
        var finalHeaders = headers
        
        if let accessToken = BBConsentPrivacyDashboardiOS.shared.accessToken, !accessToken.isEmpty {
            finalHeaders["Authorization"] = "Bearer \(accessToken)"
        } else if let tokenData = BBConsentKeyChainUtils.load(key: "BBConsentApiKey"), let token = String(data: tokenData, encoding: .utf8), !token.isEmpty {
            finalHeaders["Authorization"] = "ApiKey \(token)"
            if let userId = BBConsentPrivacyDashboardiOS.shared.userId, !userId.isEmpty {
                finalHeaders["X-ConsentBB-IndividualId"] = userId
            }
        } else {
            debugPrint("### No API key available!")
        }
        
        if let orgId = BBConsentPrivacyDashboardiOS.shared.orgId, !orgId.isEmpty {
            finalHeaders["organizationId"] = orgId
        }
        
        var encoding: ParameterEncoding = JSONEncoding.default
        if method == .get {
            encoding = URLEncoding.default
        }
        
        AF.request(urlString, method: HTTPMethod(rawValue: method.rawValue), parameters: parameters, encoding: encoding, headers: HTTPHeaders(finalHeaders))
            .responseJSON { response in
                debugPrint("### URL Request: \(String(describing: response.request))")
                debugPrint("### URL Response: \(String(describing: response.response))")
                debugPrint("### Data: \(String(describing: response.data))")
                debugPrint("### Result: \(response.result)")
                debugPrint("### Parameters: \(parameters)")
                
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        completion(true, json)
                    } else {
                        completion(false, [:])
                    }
                case .failure(let error):
                    debugPrint(error)
                    completion(false, [:])
                }
            }
    }
}


let kResponseBaseKey = "data"
protocol WebServiceTaskManagerProtocol {
    
    /*******************************************************************************
     *  Function Name       : didFinishTask: manager: response
     *  Purpose             : delegate method to notify the controller about the completion
     status of the task assigned to the manager.
     *  Parametrs           : manager - the manager class from which the method is called.
     response - the response tuple of the task.
     data - the response data if any.
     error - error message to be displayed if any error occurs
     during the task performing.
     *  Return Values       : nil
     ********************************************************************************/
    func didFinishTask(from manager:AnyObject, response:(data:RestResponse?,error:String?))
    
    
}


class BaseWebServiceManager: NSObject {

    var managerDelegate : WebServiceTaskManagerProtocol?
    deinit {
        self.managerDelegate = nil
    }
}
