
//
//  PDAttributeTableViewCell.swift
//  PrivacyDashboardiOS

//  Created by Mumthasir mohammed on 11/09/23.
//

import UIKit

class PDAttributeTableViewCell: UITableViewCell {
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dataLbl: UILabel!
    @IBOutlet weak var consentTypeLbl: UILabel!
    var consentInfo : DataAttribute?
    var consent: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func showData() {
        self.titleLbl.text = self.consentInfo?.name
        self.dataLbl.text = ""
        if consent == true {
            self.consentTypeLbl.text = Constant.Strings.allow.localized
        } else{
            self.consentTypeLbl.text = Constant.Strings.disallow.localized
        }
    }
}
