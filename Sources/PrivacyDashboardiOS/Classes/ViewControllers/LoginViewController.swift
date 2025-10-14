//
//  LoginViewController.swift
//  iGrant
//
//  Created by Ajeesh T S on 07/02/18.
//  Copyright © 2018 iGrant.com. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import UserNotifications

let twitterThemeColour = UIColor(red:0, green:0.62, blue:0.95, alpha:1)

class SignUpData: NSObject {
    var username: String!
    var fname: String!
    var lname: String!
    var title : String!
    var email : String!
    var pasword : String!
    var phone : String!
    
}

class LoginViewController: BBConsentBaseViewController {

    @IBOutlet weak var emailTxtContainer: UIView!
    @IBOutlet weak var passwordTxtContainer: UIView!
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var passwordTxtFld: UITextField!

    @IBOutlet weak var signinBtn: UIButton!
    @IBOutlet weak var revealBtn: UIButton!
    
    @IBOutlet weak var emailValidationImageView: UIImageView!
    @IBOutlet weak var passwordValidationImageView: UIImageView!
    @IBOutlet weak var invalidEmailTextLbl: UILabel!
    @IBOutlet var loginButtonYPostnConstraint : NSLayoutConstraint!

    var isConfirmedEmail = false
    var orgId: String?
    var apiNumber = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        // self.title = Constant.AppSetupConstant.KAppName
        uiSetup()
        setupKeyboard()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on the this view controller
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    func setupKeyboard(){
        emailTxtFld.becomeFirstResponder()
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    
    func uiSetup(){
        signinBtn.showRoundCorner()
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        let backButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.frame =  CGRect.init(x: 0, y: 0, width: 25, height: 40)
        backButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        backButton.titleLabel?.font =  UIFont(name: "OpenSans", size: 14)
        backButton.setTitleColor(twitterThemeColour, for: .normal)
        backButton.addTarget(self, action: #selector(LoginViewController.closeButtonclicked), for: UIControl.Event.touchUpInside)
        let backButtonBar = UIBarButtonItem(customView:backButton)
        self.navigationItem.leftBarButtonItem = backButtonBar

//        if Constant.DeviceType.IS_IPHONE_5s == true{
//            loginButtonYPostnConstraint.constant = 60
//        }

         let color = UIColor(red:0.4, green:0.47, blue:0.53, alpha:1)
        emailTxtFld.attributedPlaceholder = NSAttributedString(string: emailTxtFld.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : color])
        passwordTxtFld.attributedPlaceholder = NSAttributedString(string: passwordTxtFld.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : color])
        //signinMobileBtn.showRoundCorner(roundCorner: 5.0)
    }
    
    @objc func closeButtonclicked(){
//        emailTxtFld.resignFirstResponder()
        IQKeyboardManager.shared.resignFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.dismiss(animated: true, completion: nil)
        })
   }
    
   

    @IBAction func revealButtonClicked(sender:UIButton){
        if sender.tag == 1{
          passwordTxtFld.isSecureTextEntry = false
          sender.tag = 0
            sender.setTitle(NSLocalizedString("Hide password", comment: ""), for: .normal)
        }else{
            passwordTxtFld.isSecureTextEntry = true
            sender.tag = 1
            sender.setTitle(NSLocalizedString("Show password", comment: ""), for: .normal)
        }
        let currentText: String = self.passwordTxtFld.text!
        self.passwordTxtFld.text = " "
        self.passwordTxtFld.text = currentText
    }

    
    @objc func keyboardDoneBtnClicked(){
        IQKeyboardManager.shared.resignFirstResponder()
        if validate() == true{
            callLoginService()
        }
    }
    
    func showOrgDetail(){
        let orgVC = Constant.getStoryboard(vc: self.classForCoder).instantiateViewController(withIdentifier: "OrgDetailedVC") as! BBConsentOrganisationViewController
        orgVC.organisationId = orgId ?? ""
        self.navigationController?.pushViewController(orgVC, animated: true)
    }
    

}


extension LoginViewController{
    
    @IBAction func signInButtonClicked(){
        IQKeyboardManager.shared.resignFirstResponder()
        if validate() == true{
            callLoginService()
        }
    }
    
    func validate() -> Bool{
        guard let email = self.emailTxtFld.text, !email.isBlank else {
            self.showWarningAlert(message: Constant.Alert.KPromptMsgEnterEmail)
            return false
        }
        guard let validEmail = self.emailTxtFld.text, validEmail.isValidEmail else {
            self.showWarningAlert(message: Constant.Alert.KPromptMsgEnterValidEmail)
            return false
        }
       
        guard let password = self.passwordTxtFld.text, !password.isBlank else {
            self.showWarningAlert(message: Constant.Alert.KPromptMsgEnterPassword)
            return false
        }

        return true
    }
    
    
    func callLoginService(){
            self.addLoadingIndicator()
            let serviceManager = LoginServiceManager()
            serviceManager.managerDelegate = self
            serviceManager.loginService(uname: (self.emailTxtFld.text)!, pwd: (self.passwordTxtFld.text)!)
        }
}


extension LoginViewController:WebServiceTaskManagerProtocol,UITextFieldDelegate{
    func didFinishTask(from manager:AnyObject, response:(data:RestResponse?,error:String?)){
        self.removeLoadingIndicator()
        if response.error != nil{
            self.showErrorAlert(message: response.error!)
        }else{
            if let serviceManager = manager as? LoginServiceManager{
                if serviceManager.serviceType == .Login{
                    UserInfo.currentUser()?.userEmail = self.emailTxtFld.text
                    UserInfo.currentUser()?.userPwd = self.passwordTxtFld.text
                    UserInfo.currentUser()?.save()
                    showOrgDetail()
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0{
            passwordTxtFld.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
        
    }

}



