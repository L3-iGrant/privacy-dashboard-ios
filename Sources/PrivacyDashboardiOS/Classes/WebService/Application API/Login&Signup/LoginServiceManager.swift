//
//  LoginServiceManager.swift
//
//  Created by Ajeesh Thankachan on 17/05/18.
//

import UIKit

enum LoginServiceType {
    case Login
    case ForgotPwd
    case SignUp
    case UpdateProfileImage
    case UpdateProfileInfo
    case ChangePassword
    case ValidEmail
    case ValidPhoneNumber
    case GenarateOTP
    case VerifyOTP
    case UpdateDeviceToken
    case getUserInfo
    case getiGrantUser

}

class LoginServiceManager: BaseWebServiceManager {
    var newPassword = ""
    var apiSequenceNumber = 0
    var deviceTokenStr = ""
    var serviceType = LoginServiceType.Login
    deinit{
        self.managerDelegate = nil
    }
    
    func loginService(uname:String, pwd:String){
        self.serviceType = .Login
        DispatchQueue.global().async{
            let loginService = LoginWebService()
            loginService.delegate = self
            loginService.parameters =  ["username": uname as AnyObject, "password": pwd as AnyObject]
            loginService.callLoginService()
        }
    }
    
    func getUserDetails(){
              self.serviceType = .getUserInfo
              DispatchQueue.global().async{
                  let loginService = LoginWebService()
                  loginService.delegate = self
                  loginService.getUserInfo()
              }
          }
    
    func forgotPasswordService(email:String){
        self.serviceType = .Login
        DispatchQueue.global().async{
            let loginService = LoginWebService()
            loginService.delegate = self
            loginService.parameters =  ["email": email as AnyObject]
            loginService.callForgotpasswordService()
        }
    }
    
    func updateDeviceToken(deviceToken:String){
        deviceTokenStr = deviceToken
        self.serviceType = .UpdateDeviceToken
        DispatchQueue.global().async{
            let loginService = LoginWebService()
            loginService.delegate = self
            loginService.parameters =  ["devicetoken": deviceToken as AnyObject]
            loginService.updateDeviceToken()
        }
        
    }
    
    
    func validateEmail(email:String){
        self.serviceType = .ValidEmail
        DispatchQueue.global().async{
            let loginService = LoginWebService()
            loginService.delegate = self
            loginService.parameters =  ["email": email as AnyObject]
            loginService.validEmailSerivce()
        }
    }
    
    func forgotPassword(email:String){
        self.serviceType = .ForgotPwd
        DispatchQueue.global().async{
            let loginService = LoginWebService()
            loginService.delegate = self
            loginService.parameters =  ["username": email as AnyObject]
            loginService.forgotPasswordSerivce()
        }
    }
    
    func validatePhoneNumber(phone:String){
        self.serviceType = .ValidPhoneNumber
        DispatchQueue.global().async{
            let loginService = LoginWebService()
            loginService.delegate = self
            loginService.parameters =  ["phone": phone as AnyObject]
            loginService.validPhoneSerivce()
        }
    }
    
    func updateProfile(image:UIImage){
        self.serviceType = .UpdateProfileImage
        DispatchQueue.global().async{
            let loginService = LoginWebService()
            loginService.delegate = self
            let data = image.jpegData(compressionQuality: 0.5)
            let multipartData = MultipartData(data: data! as NSData, name: "userimage", fileName: "image.jpg", mimeType: "image/jpeg")
            loginService.uploadData = [multipartData]
            loginService.changeProfileImageService()
        }
    }
    
    func updateProfileInfo(phone:String?,userName : String?){
        self.serviceType = .UpdateProfileInfo
        DispatchQueue.global().async{
            let loginService = LoginWebService()
            loginService.delegate = self
            if phone != nil{
                loginService.parameters.updateValue(phone as AnyObject, forKey: "Phone")

            }
            if userName != nil{
                loginService.parameters.updateValue(userName as AnyObject, forKey: "name")
            }
            loginService.updateProfileInfoService()
        }
    }
    
    func signupService(userInfo:SignUpData){
        self.serviceType = .SignUp
        DispatchQueue.global().async{
            let loginService = LoginWebService()
            loginService.delegate = self
            loginService.parameters.updateValue(userInfo.username as AnyObject, forKey: "Name")
            loginService.parameters.updateValue(userInfo.pasword as AnyObject, forKey: "password")
            loginService.parameters.updateValue(userInfo.email as AnyObject, forKey: "username")
            loginService.parameters.updateValue(userInfo.phone as AnyObject, forKey: "phone")

            loginService.callSignupService()
        }
    }
    
    func changepassword(newpassword: String){
        newPassword = newpassword
        self.serviceType = .ChangePassword
        let loginService = LoginWebService()
        loginService.delegate = self
        loginService.parameters.updateValue(newpassword as AnyObject, forKey: "password")
        loginService.changePwdService()
    }

    func genarateOtpNumber(userInfo:SignUpData,phone:String){
        self.serviceType = .GenarateOTP
        DispatchQueue.global().async{
            let loginService = LoginWebService()
            loginService.delegate = self
            loginService.parameters.updateValue(userInfo.email as AnyObject, forKey: "email")
            loginService.parameters.updateValue(phone as AnyObject, forKey: "phone")
            loginService.parameters.updateValue(userInfo.username as AnyObject, forKey: "name")
            loginService.generateOtpService()
        }
    }
    
    func verfiyOtpNumber(phone:String,otp : String){
        self.serviceType = .VerifyOTP
        DispatchQueue.global().async{
            let loginService = LoginWebService()
            loginService.delegate = self
            loginService.parameters.updateValue(phone as AnyObject, forKey: "Phone")
            loginService.parameters.updateValue(otp as AnyObject, forKey: "otp")
            loginService.verifyOtpService()
        }
    }
    
    func getiGrantUser(orgId: String){
        self.serviceType = .getiGrantUser
        DispatchQueue.global().async{
            let loginService = LoginWebService()
            loginService.delegate = self
            loginService.getiGrantUser(orgId: orgId)
        }
    }
}


extension LoginServiceManager : BaseServiceDelegates {
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
                    case .Login:self.handleLoginResponse(response: response)
                    case .ForgotPwd: self.handleFogotPasswordResponse(response: response)
                    case .SignUp :self.handleSignupResponse(response: response)
                    case .UpdateProfileImage : self.handlePrifleImageUpdateResponse(response: response)
                    case .UpdateProfileInfo : self.handlePrifleInfoUpdateResponse(response: response)
                    case .ChangePassword : self.handleChangePasswordResponse(response: response)
                    case .ValidEmail : self.handleEmailValidatioResponse(response: response)
                    case .ValidPhoneNumber : self.handleEmailValidatioResponse(response: response)
                    case .GenarateOTP : self.handleOTPGenerationResponse(response: response)
                    case .VerifyOTP : self.handleEmailValidatioResponse(response: response)
                    case .UpdateDeviceToken :self.handleDeviceTokenUpdateResponse(response: response)
                    case .getUserInfo: self.handleUserInfoResponse(response: response)
                    case .getiGrantUser: self.handleGetiGrantUser(response: response)
                }
            }
        }
        
    }
    
    func didFailedToReceiveData(response:RestResponse?){
        self.managerDelegate?.didFinishTask(from: self, response: (data: response, error: response?.message))
    }
    
}


extension LoginServiceManager {
    func handleLoginResponse(response:RestResponse?){
        let responseData = response!.response!
        DispatchQueue.global().async {
            UserInfo.createSessionWith(json: responseData)
//            UserInfo.currentUser()?.userEmail = AppSharedData.sharedInstance.email
//            UserInfo.currentUser()?.userPwd = AppSharedData.sharedInstance.password
            UserInfo.currentUser()?.isSavedPassword = 1
            UserInfo.currentUser()?.save()
            DispatchQueue.main.async {
                self.managerDelegate?.didFinishTask(from: self, response: (data: response, error: nil))
            }
        }
    }
    
    func handleFogotPasswordResponse(response:RestResponse?){
        let responseData = response!.response!
        if let msg = responseData["msg"].string{
            response?.message = msg
        }
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.managerDelegate?.didFinishTask(from: self, response: (data: response, error: nil))
            }
        }
    }
    
    func handleUserInfoResponse(response:RestResponse?){
        var responseData = response!.response!
               DispatchQueue.global().async {
                responseData["Token"] = ["access_token" : ""]
                   UserInfo.createSessionWith(json: responseData)
       //
       //            UserInfo.currentUser()?.userEmail = AppSharedData.sharedInstance.email
       //            UserInfo.currentUser()?.userPwd = AppSharedData.sharedInstance.password
                   if UserInfo.currentUser()?.isSavedPassword == nil {
                       UserInfo.currentUser()?.isSavedPassword = 1
                   }
                   UserInfo.currentUser()?.save()
                   DispatchQueue.main.async {
                       self.managerDelegate?.didFinishTask(from: self, response: (data: response, error: nil))
                   }
               }
           }
    
    func handleSignupResponse(response:RestResponse?){
        let responseData = response!.response!
        DispatchQueue.global().async {
            UserInfo.createSessionWith(json: responseData)
            UserInfo.currentUser()?.save()
            DispatchQueue.main.async {
                self.managerDelegate?.didFinishTask(from: self, response: (data: response, error: nil))
            }
        }
    }
    
    
    
    func handleEmailValidatioResponse(response:RestResponse?){
        let responseData = response!.response!
        DispatchQueue.global().async {
            if let status = responseData["Result"].bool{
                if status == false{
                    response?.responseCode = 0
                }else{
                    response?.responseCode = 1
                }
            }
            if let msg = responseData["Message"].string{
                response?.message = msg
            }
            DispatchQueue.main.async {
                self.managerDelegate?.didFinishTask(from: self, response: (data: response, error: nil))
            }
        }
    }
    
    
    func handleOTPGenerationResponse(response:RestResponse?){
        let responseData = response!.response!
        DispatchQueue.global().async {
            if let status = responseData["Result"].bool{
                if status == false{
                    response?.responseCode = 0
                }else{
                    response?.responseCode = 1
                }
            }
            if let msg = responseData["Message"].string{
                response?.message = msg
            }
            DispatchQueue.main.async {
                self.managerDelegate?.didFinishTask(from: self, response: (data: response, error: nil))
            }
        }
    }
    
    func handlePrifleImageUpdateResponse(response:RestResponse?){
        let responseData = response!.response!
        DispatchQueue.global().async {
            if let userData = responseData["User"].dictionary{
                if let data = userData["ImageURL"]?.string{
                    UserInfo.currentUser()?.imageUrl = data
                }
            }
            UserInfo.currentUser()?.save()
            DispatchQueue.main.async {
                self.managerDelegate?.didFinishTask(from: self, response: (data: response, error: nil))
            }
        }
    }
    
    func handleChangePasswordResponse(response:RestResponse?){
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.managerDelegate?.didFinishTask(from: self, response: (data: response, error: nil))
            }
        }
    }
    
    func handleGetiGrantUser(response:RestResponse?){
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.managerDelegate?.didFinishTask(from: self, response: (data: response, error: nil))
            }
        }
    }
    func handlePrifleInfoUpdateResponse(response:RestResponse?){
        let responseData = response!.response!
        DispatchQueue.global().async {
            if let userData = responseData["User"].dictionary{
                if let data = userData["Name"]?.string{
                  UserInfo.currentUser()?.userName = data
                }
                if let data = userData["Email"]?.string{
                    UserInfo.currentUser()?.userEmail = data
                }
                if let data = userData["ImageURL"]?.string{
                    UserInfo.currentUser()?.imageUrl = data
                }
                if let data = userData["Phone"]?.string{
                    UserInfo.currentUser()?.phone = data
                }
            }
            UserInfo.currentUser()?.save()
            DispatchQueue.main.async {
                self.managerDelegate?.didFinishTask(from: self, response: (data: response, error: nil))
            }
        }
    }
    
    
    
    func handleDeviceTokenUpdateResponse(response:RestResponse?){
        
        UserDefaults.standard.set(self.deviceTokenStr, forKey:Constant.DeviceToken.KUserDeviceTokenKey)
        UserDefaults.standard.synchronize()
        //        let responseData = response!.response!
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.managerDelegate?.didFinishTask(from: self, response: (data: response, error: nil))
            }
        }
    }
    
}
