//
//  LoginWebService.swift
//  DocuTRUST
//
//  Created by Ajeesh Thankachan on 17/05/18.
//  Copyright © 2018 Marlabs. All rights reserved.
//

import UIKit

class LoginWebService: BBConsentBaseWebService {
    func callLoginService(){
        self.url = baseUrl + "users/login"
        postServiceCall()
    }
    
    func callSignupService(){
        self.url = baseUrl + "users/register"
        postServiceCall()
    }
    
    func getUserInfo(){
      self.url = baseUrl + "user"
      getServiceCall()
      }
    
    func generateOtpService(){
        self.url = baseUrl + "users/verify/phone"
        postServiceCall()
    }
    
    func verifyOtpService(){
        self.url = baseUrl + "users/verify/otp"
        postServiceCall()
    }
    
    func validEmailSerivce(){
        self.url = baseUrl + "users/validate/email"
        postServiceCall()
    }
    
    func forgotPasswordSerivce(){
        self.url = baseUrl + "user/password/forgot"
        putServiceCall()
    }
    
    func validPhoneSerivce(){
        self.url = baseUrl + "users/validate/phone"
        postServiceCall()
    }

    func callForgotpasswordService(){
        self.url = baseUrl + "users/forgotPassword"
        getServiceCall()
    }
    
    func changeProfileImageService(){
        self.url = baseUrl + "user/image"
        postServiceCall()
    }
    
    func updateProfileInfoService(){
        self.url = baseUrl + "user"
        patchServiceCall()
    }
   
    func changePwdService(){
        self.url = baseUrl + "user/password/reset"
        putServiceCall()
    }
    
    func updateDeviceToken(){
        self.url = baseUrl + "user/register/ios"
        postServiceCall()

//        var userId : String = ""
//        if UserInfo.currentUser()?.userId != nil{
//            userId = (UserInfo.currentUser()?.userId)!
//        }
//        var accessToken : String = ""
//        if UserInfo.currentUser()?.token != nil{
//            accessToken = (UserInfo.currentUser()?.token)!
//        }
//        self.url = baseUrl + "users/" + userId + "?access_token=" + accessToken
//        PATCH()
    }
    
    
    func getiGrantUser(orgId: String) {
        self.url = baseUrl + "organizations/" + orgId + "/users/anonymous"
        postServiceCall()
    }
}
