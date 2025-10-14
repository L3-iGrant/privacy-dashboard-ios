//
//  ConsentHeaderTableViewCell.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 11/09/23.

import UIKit

class BBConsentAttributesHeaderCell: UITableViewCell {
    
    @IBOutlet weak var dataAttributeLbl: UILabel!
    @IBOutlet weak var policyButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        dataAttributeLbl.text = Constant.Strings.dataAttributes.localized
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
