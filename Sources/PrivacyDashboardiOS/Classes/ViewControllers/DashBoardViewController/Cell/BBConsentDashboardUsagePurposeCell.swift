//
//  BBConsentDashboardUsagePurposeCell.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 04/09/23.
//

import UIKit

protocol PurposeCellDelegate: AnyObject {
    func purposeSwitchValueChanged(status:Bool,purposeInfo:PurposeConsent?,cell:BBConsentDashboardUsagePurposeCell, shouldShowPopup: Bool)
}

class BBConsentDashboardUsagePurposeCell: UITableViewCell {
    weak var delegate: PurposeCellDelegate?
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dataLbl: UILabel!
    @IBOutlet weak var statusSwitch: UISwitch!

    var consentInfo : DataAgreements?
    var consentedCount: Int?
    var totalCount: Int?
    var swictOn: Bool = false
    var shouldShowAlertOnConsentChange: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func showData() {
        self.statusSwitch.isOn = self.swictOn ? true : false
        if consentInfo?.lawfulBasis == "consent" || consentInfo?.lawfulBasis == "legitimate_interest" {
            self.statusSwitch.isEnabled = true
        } else {
            self.statusSwitch.isEnabled = false
        }
        
        self.titleLbl.text = self.consentInfo?.purpose
        
        if consentedCount ?? 0 > 0 {
            var valueString = "bb_consent_data_attribute_allow".localized
            self.dataLbl.text = valueString
        } else {
            self.dataLbl.text = "bb_consent_dashboard_disallow".localized
        }
    }

    @IBAction func switchValueChanged(sender: UISwitch) {
        self.delegate?.purposeSwitchValueChanged(status: sender.isOn, purposeInfo: self.consentInfo as? PurposeConsent, cell: self, shouldShowPopup: shouldShowAlertOnConsentChange ?? true)
    }
}
