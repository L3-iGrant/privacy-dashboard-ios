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

@objc protocol BaseServiceDelegates {
    // The service call was successful and the data is passed to the manager
    @objc optional func didSuccessfullyReceiveData(response:RestResponse?)
    // The service call was failed and the error message to be shown is fetched and returned to the manager.
    @objc optional func didFailedToReceiveData(response:RestResponse?)
}

enum WebServiceType {
    case None
}

class BBConsentBaseWebService: NSObject {
    var serviceType = WebServiceType.None
    var delegate : BaseServiceDelegates?
    var url: String?
    var parameters = [String: Any]()
    var requestInfo : [String:String]?
    var errorMsg : String?
    var baseUrl = BBConsentPrivacyDashboardiOS.shared.baseUrl
    static var shared = BBConsentBaseWebService()


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
        serviceCall(method: .get, encoding: URLEncoding.default)
    }

    func postServiceCall() {
        serviceCall(method: .post, encoding: JSONEncoding.default)
    }

    func putServiceCall() {
        serviceCall(method: .put, encoding: JSONEncoding.default)
    }

    func patchServiceCall() {
        serviceCall(method: .patch, encoding: JSONEncoding.default)
    }

    func deleteServiceCall() {
        serviceCall(method: .delete, encoding: URLEncoding.default)
    }

    private func serviceCall(method: HTTPMethod, encoding: ParameterEncoding) {
        var requestParameters: Parameters? = parameters
        if method == HTTPMethod.delete {
            requestParameters = nil
        }
        let request = BBConsentNetwork.session.request(url ?? "", method: method, parameters: requestParameters, encoding: encoding, interceptor: BBConsentAuthInterceptor(legacyOrder: .apiKeyFirst))
        request
            .validate()
            .responseJSON { response in
                switch response.result{
                case .success(let value):
                    let json = JSON(value)
                    self.successWithResponse(response: json)
                case .failure(let error):
                    if let data = response.data, let utf8Text = String.init(data: data, encoding: String.Encoding.utf8) {
                        BBConsentLog.debug("Data: \(utf8Text)")
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
}

// MARK: - Single Almofire call for all API's
extension BBConsentBaseWebService {
    
    enum ApiType: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    func makeAPICall(urlString: String, parameters: [String: Any] = [:], headers: [String: String] = [:], method: ApiType, completion:@escaping (_ success: Bool, _ resultVal: [String: Any]) -> Void) {
        var finalHeaders = headers
        if let orgId = BBConsentPrivacyDashboardiOS.shared.orgId, !orgId.isEmpty {
            finalHeaders["organizationId"] = orgId
        }
        
        var encoding: ParameterEncoding = JSONEncoding.default
        if method == .get {
            encoding = URLEncoding.default
        }
        
        BBConsentNetwork.session.request(urlString, method: HTTPMethod(rawValue: method.rawValue), parameters: parameters, encoding: encoding, headers: HTTPHeaders(finalHeaders), interceptor: BBConsentAuthInterceptor(legacyOrder: .accessTokenFirst))
            .validate(BBConsentAuthInterceptor.validateUnauthorised)
            .responseJSON { response in
                BBConsentLog.debug("URL Request: \(String(describing: response.request)), URL Response: \(String(describing: response.response)), Result: \(response.result)")
                
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        completion(true, json)
                    } else {
                        completion(false, [:])
                    }
                case .failure(let error):
                    BBConsentLog.debug("\(error)")
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
