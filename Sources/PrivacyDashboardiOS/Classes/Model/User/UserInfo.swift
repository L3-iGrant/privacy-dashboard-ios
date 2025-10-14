//
//  UserInfo.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 31/08/23.
//

import Foundation
import SwiftyJSON

class UserInfo: NSObject,NSCoding {
    
    var errorCode : String?
    var errorMsg : String?
    var userID: String?
    var userPwd: String?
    var userEmail: String?
    var userName: String?
    var phone: String?
    var imageUrl: String?
    var refreshToken: String?
    var isSavedPassword : Int?
    var isEnabledBiometricLogin : Int?
    var isUserAuthenticated = false
    var token : String?
    // var organisation: [Organization]?
    
    private static var __currentUser: UserInfo? = nil
    
    class func createSessionWith(json: JSON) {
        __currentUser = UserInfo(json: json)
    }
    
    class func createDummySession() {
        __currentUser = UserInfo()
        
    }
    
    class func currentUser() -> UserInfo? {
        return __currentUser
    }
    
    override init() {
        self.userID = "5abbb5a71a776200019f77ee"
    }
    
    init(json: JSON) {
        guard let userData = json["User"].dictionaryObject, let tokenData = json["Token"].dictionaryObject else{return}
        
        if let data = tokenData["access_token"] as? String {
            self.token = data
        }
        if let data = tokenData["refresh_token"] as? String {
            self.refreshToken = data
        }
        if let data = userData["ID"] as? String  {
            self.userID = data
        }
        if let data = json["errorMsg"].string {
            self.errorMsg = data
        }
        if let data = json["userAuthenticatedSuccessfully"].bool {
            self.isUserAuthenticated = data
        }
        if UserDefaults.standard.value(forKey: "isEnabledBiometricLogin") != nil {
            if let data = UserDefaults.standard.value(forKey: "isEnabledBiometricLogin") as? Int {
                self.isEnabledBiometricLogin = data
            }
        }
    }
    
    func save() {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: self)
        saveData(data: encodedData as NSData?)
    }
    
    func clearSession() {
        UserDefaults.standard.setValue(UserInfo.currentUser()?.isEnabledBiometricLogin, forKey:"isEnabledBiometricLogin")
        saveData(data: nil)
    }
    
    class func restoreSession() -> Bool {
        if let data = UserDefaults.standard.object(forKey: Constant.AppSetupConstant.KSavingUSerInfoUserDefaultKey) as? NSData {
            __currentUser = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? UserInfo
        }else{
            __currentUser = nil
        }
        return (__currentUser != nil)
    }
    
    private func saveData(data: NSData?) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: Constant.AppSetupConstant.KSavingUSerInfoUserDefaultKey)
        userDefaults.synchronize()
    }
    
    func encode(with aCoder: NSCoder){
        if let value = errorCode {
            aCoder.encode(value, forKey: "errorCode")
        }
        if let value = errorMsg {
            aCoder.encode(value, forKey: "errorMsg")
        }
        if let value = userID {
            aCoder.encode(value, forKey: "userID")
        }
        //        if let value = isUserAuthenticated {
        aCoder.encode(isUserAuthenticated, forKey: "isUserAuthenticated")
        //        }
        if let value = token {
            aCoder.encode(value, forKey: "token")
        }
        //refreshToken
        if let value = refreshToken {
            aCoder.encode(value, forKey: "refreshToken")
        }
        if let value = userPwd {
            aCoder.encode(value, forKey: "userPwd")
        }
        if let value = userEmail {
            aCoder.encode(value, forKey: "userEmail")
        }
        if let value = userName {
            aCoder.encode(value, forKey: "userName")
        }
        if let value = imageUrl {
            aCoder.encode(value, forKey: "imageUrl")
        }
        if let value = phone {
            aCoder.encode(value, forKey: "phone")
        }
//        if let value = language {
//            aCoder.encode(value, forKey: "language")
//        }
        if let value = isSavedPassword {
            aCoder.encode(value, forKey: "isSavedPassword")
        }
        if let value = isEnabledBiometricLogin {
            aCoder.encode(value, forKey: "isEnabledBiometricLogin")
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        errorCode = aDecoder.decodeObject(forKey: "errorCode") as? String
        errorMsg = aDecoder.decodeObject(forKey: "errorMsg") as? String
        userID = aDecoder.decodeObject(forKey: "userID") as? String
        userPwd = aDecoder.decodeObject(forKey: "userPwd") as? String
        userEmail = aDecoder.decodeObject(forKey: "userEmail") as? String
        token = aDecoder.decodeObject(forKey: "token") as? String
        phone = aDecoder.decodeObject(forKey: "phone") as? String
        refreshToken = aDecoder.decodeObject(forKey: "refreshToken") as? String
        //language = aDecoder.decodeObject(forKey: "language") as? String
        userName = aDecoder.decodeObject(forKey: "userName") as? String
        imageUrl = aDecoder.decodeObject(forKey: "imageUrl") as? String
        isSavedPassword = aDecoder.decodeInteger(forKey: "isSavedPassword")
        isEnabledBiometricLogin = aDecoder.decodeInteger(forKey: "isEnabledBiometricLogin")
    }
}
