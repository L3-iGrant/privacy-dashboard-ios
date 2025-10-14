//
//  BBConsentDashboardDataAgreementCell.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 20/10/23.
//

import UIKit

class BBConsentDashboardDataAgreementCell: UITableViewCell {

    @IBOutlet weak var dataAgreementsLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        dataAgreementsLbl.text = Constant.Strings.dataAgreements.localized
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
