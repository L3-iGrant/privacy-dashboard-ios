//
//  BBConsentDownloadDataProgressViewController.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 19/09/23.
//

import UIKit
import StepProgressView

class BBConsentDownloadDataProgressViewController: BBConsentBaseViewController {
    @IBOutlet weak var stepView: StepProgressView!
    var requestStatus: RequestStatus?
    var organisationId: String?
    var requestType: RequestType?
    @IBOutlet weak var cancelButton: UIButton!
    var fromHistory = false;
    let Steps = [
        Constant.Strings.requestInitiated.localized,
        Constant.Strings.requestAcknowledged.localized,
        Constant.Strings.requestProcessed.localized
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        stepView.steps = Steps
        stepView.verticalPadding = 60
        stepView.lastStepShape = .circle
        stepView.lineWidth = 3
        stepView.pastStepColor = .darkGray
        stepView.pastTextColor = stepView.pastStepColor
        stepView.pastStepFillColor = stepView.pastStepColor
        stepView.currentStepColor = #colorLiteral(red: 0, green: 0.3553411961, blue: 0.6003383994, alpha: 1)
        stepView.currentTextColor = stepView.currentStepColor
        stepView.currentDetailColor =  UIColor.gray
        stepView.futureStepColor = UIColor.lightGray
        stepView.currentStep = ((requestStatus?.State ?? 1) - 1)
        stepView.currentDetailColor = UIColor.black
        
        self.navigationController?.navigationBar.isHidden = false
        
        if self.requestType == RequestType.DownloadData || self.requestStatus?.type == 2 {
            self.title = Constant.Strings.downloadDataRequestStatus
        } else {
            self.title = Constant.Strings.deleteDataRequestStatus
        }
        let comments = [ 0 : formattedDate(dateStr: requestStatus?.RequestedDate ?? ""),
                         1 : " ",
                         2 : (stepView.currentStep > 1) ? (requestStatus?.StateStr ?? "") : ""];
        stepView.details = comments
        cancelButton.showRoundCorner()
        if fromHistory {
            cancelButton.isHidden = true
        }
    }
    
    func formattedDate(dateStr: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = dateFormatter.date(from: dateStr.replacingOccurrences(of: " +0000 UTC", with: ""))
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        dateFormatter.timeZone = TimeZone.current
        let timeStamp = dateFormatter.string(from: date ?? Date())
        
        return timeStamp
    }
    @IBAction func cancelButtonAction(_ sender: Any) {
        let alert = UIAlertController(title: Constant.Alert.cancelRequest, message: Constant.Alert.doYouWantToCancelThisRequest, preferredStyle: UIAlertController.Style.alert)
        
        // Add an action (button)
        alert.addAction(UIAlertAction(title: Constant.Alert.OK, style: UIAlertAction.Style.default, handler: { action in
            self.callCancelRequestApi()
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Constant.Alert.cancel, style: UIAlertAction.Style.default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        // Show the alert
        self.present(alert, animated: true, completion: nil)
    }

    func callCancelRequestApi() {
        self.addLoadingIndicator()
        let serviceManager = OrganisationWebServiceManager()
        serviceManager.managerDelegate = self
        serviceManager.cancelRequest(orgId: self.organisationId ?? "", requestId: self.requestStatus?.iD ?? "", type: self.requestType ?? RequestType.DownloadData)
    }
}
extension BBConsentDownloadDataProgressViewController: WebServiceTaskManagerProtocol {
    func didFinishTask(from manager:AnyObject, response:(data:RestResponse?,error:String?)) {
        self.removeLoadingIndicator()
        if response.error != nil{
            self.showErrorAlert(message: (response.error)!)
            return
        }
        
        if let serviceManager = manager as? OrganisationWebServiceManager{
            if serviceManager.serviceType == .cancelRequest{
                let alert = UIAlertController(title: Constant.Alert.cancelRequest, message: Constant.Alert.yourRequestCancelled, preferredStyle: UIAlertController.Style.alert)
                
                // Add an action (button)
                alert.addAction(UIAlertAction(title: Constant.Alert.OK, style: UIAlertAction.Style.default, handler: { action in
                    self.navigationController?.popViewController(animated: true)
                    alert.dismiss(animated: true, completion: nil)
                }))
                
                // Show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
