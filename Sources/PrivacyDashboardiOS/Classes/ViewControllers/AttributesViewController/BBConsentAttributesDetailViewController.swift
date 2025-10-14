//
//  BBConsentEditAttributesViewController.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 08/09/23.
//

import UIKit

enum ConsentType {
    case Allow
    case Disallow
    case AskMe
}

class BBConsentAttributesDetailViewController: BBConsentBaseViewController {
    @IBOutlet weak var tableView: UITableView!
    var consent :ConsentDetails?
    var purposeDetails : ConsentListingResponse?
    var selectedConsentType = ConsentType.Allow
    var preIndexPath : IndexPath?
    var orgID : String?
    var consentID : String = ""
    var purposeID : String = ""
    var purposeName : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.title = consent?.descriptionField
        tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableView.automaticDimension
        if let data = purposeDetails?.consentID {
            consentID = data
        }
        
        if let data = purposeDetails?.consents?.purpose?.iD {
            purposeID = data
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func changeConsentValue(valueDict:[String: AnyObject]) {
        if self.orgID != nil && consent?.iD != nil{
            NotificationCenter.default.post(name: .consentChange, object: nil)
            self.addLoadingIndicator()
            let serviceManager = OrganisationWebServiceManager()
            serviceManager.managerDelegate = self
            serviceManager.updateConsent(orgId: (self.orgID)!, consentID: consentID, attributeId: (consent?.iD)!, purposeId:purposeID, valuesDict: valueDict)
        }
    }
}

extension BBConsentAttributesDetailViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if BBConsentPrivacyDashboardiOS.shared.turnOnAskMeSection {
            return 3
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row != 2 {
            return 45
        } else {
            return 95
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row != 2 {
            let allowCell = tableView.dequeueReusableCell(withIdentifier:Constant.CustomTabelCell.KOrgDetailedConsentAllowCellID,for: indexPath)
            if indexPath.row == 0 {
                allowCell.textLabel?.text = Constant.Alert.allow.localized
                if consent?.status?.consented == .Allow {
                    allowCell.accessoryType = .checkmark
                    preIndexPath = indexPath
                } else {
                    allowCell.accessoryType = .none
                }
            } else {
                allowCell.textLabel?.text = Constant.Alert.disallow.localized
                if consent?.status?.consented == .Disallow {
                    preIndexPath = indexPath
                    allowCell.accessoryType = .checkmark
                } else {
                    allowCell.accessoryType = .none
                }
            }
            allowCell.textLabel?.font = UIFont(name: "OpenSans", size: 15)
            return allowCell
            
        } else {
            let askMeCell = tableView.dequeueReusableCell(withIdentifier:Constant.CustomTabelCell.KOrgDetailedConsentAskMeCellID,for: indexPath) as! BBConsentAskMeSliderTableViewCell
            askMeCell.delegate = self
            askMeCell.index = indexPath
            
            if consent?.status?.consented == .AskMe {
                askMeCell.tickImage.isHidden = false
                let days : Int = (consent?.status?.days)!
                askMeCell.selectedDaysLbl.text = "\(days) " + Constant.Strings.days.localized
                askMeCell.askMeSlider.setValue(Float(days), animated: false)
                preIndexPath = indexPath

            } else {
                let days = 30
                askMeCell.tickImage.isHidden = true
                askMeCell.selectedDaysLbl.text = "\(days) " + Constant.Strings.days.localized
                askMeCell.askMeSlider.setValue(Float(days), animated: false)
            }
            return askMeCell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Constant.Strings.consent.localized
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var consentTitle : String = ""
        if consent?.descriptionField != nil {
           consentTitle = (consent?.descriptionField)!
        }
        
        if consent?.status?.consented == .Allow {
            return Constant.Strings.consentAllowedNoteOne.localized + (consentTitle) + Constant.Strings.consentAllowedNoteTwo
        } else if consent?.status?.consented == .Disallow {
            return Constant.Strings.consentDisAllowedNote.localized
        } else {
            return Constant.Strings.consentDefaultNote.localized
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if preIndexPath != indexPath {
                consent?.status?.consented = .Allow
                self.changeConsentValue(valueDict: ["consented":"Allow" as AnyObject])
                preIndexPath = indexPath
                self.tableView.reloadData()
            }
        } else if indexPath.row == 1 {
            if preIndexPath != indexPath {
                consent?.status?.consented = .Disallow
                self.changeConsentValue(valueDict: ["consented":"DisAllow" as AnyObject])
                preIndexPath = indexPath
            }
            self.tableView.reloadData()
        }
    }
}

extension BBConsentAttributesDetailViewController: WebServiceTaskManagerProtocol {
    
    func didFinishTask(from manager:AnyObject, response:(data:RestResponse?,error:String?)) {
        self.removeLoadingIndicator()
        if response.error != nil{
            self.showErrorAlert(message: (response.error)!)
            return
        }
        
        if let serviceManager = manager as? OrganisationWebServiceManager{
            if serviceManager.serviceType == .UpdateConsent{
            }
        }
    }
}

extension  BBConsentAttributesDetailViewController: AskMeSliderCellDelegate {
    func askMeSliderValueChanged(days:Int) {
        consent?.status?.consented = .AskMe
        consent?.status?.days = days
        self.tableView.reloadData()
    }
    
    func updatedSliderValue(days:Int,indexPath:IndexPath) {
        preIndexPath = indexPath
        self.changeConsentValue(valueDict: ["days":days as AnyObject])
    }
}


