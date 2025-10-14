//
//  BBConsentDashboardHeaderCell.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 04/09/23.
//


import UIKit
import Kingfisher

class BBConsentDashboardHeaderCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var orgImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var logoBgBtn: UIButton!
    @IBOutlet weak var gradiantView: UIView!
    @IBOutlet weak var gradiantViewTop: UIView!
    
    var orgData : OrganisationModel?
    var baseUrl = BBConsentPrivacyDashboardiOS.shared.baseUrl
    
    override func awakeFromNib() {
        super.awakeFromNib()
        logoImageView.layer.cornerRadius =  logoImageView.frame.size.height/2
        logoBgBtn.layer.cornerRadius =  logoBgBtn.frame.size.height/2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func showData() {
        self.nameLbl.text = self.orgData?.organisation.name
        self.locationLbl.text = self.orgData?.organisation.location
        let modifier = AnyModifier { request in
            var r = request
            r.setValue("Bearer \(UserInfo.currentUser()?.token ?? "")", forHTTPHeaderField: "Authorization")
            if let tokendata = BBConsentKeyChainUtils.load(key: "BBConsentApiKey") {
                let token = String(data: tokendata, encoding: .utf8) ?? ""
                r.setValue("ApiKey \(token)", forHTTPHeaderField: "Authorization")
                r.setValue(BBConsentPrivacyDashboardiOS.shared.userId ?? "", forHTTPHeaderField:  "X-ConsentBB-IndividualId")
            }
            return r
        }
        
        self.orgImageView.image = UIImage(named: Constant.Images.defaultCoverImage)
        let coverImageUrl = URL(string: (orgData?.organisation.coverImageURL ?? ""))
        let placeholder = UIImage(named: Constant.Images.defaultCoverImage, in: Constant.getResourcesBundle(vc: BBConsentBaseViewController().classForCoder), compatibleWith: nil)
        self.orgImageView.kf.setImage(with: coverImageUrl, placeholder: placeholder, options: [.requestModifier(modifier)])
        
        self.logoImageView.image = UIImage(named: Constant.Images.iGrantTick)
        let logoImageUrl = URL(string: (orgData?.organisation.logoImageURL ?? ""))
        let coverImagePlaceholder = UIImage(named: Constant.Images.iGrantTick, in: Constant.getResourcesBundle(vc: BBConsentBaseViewController().classForCoder), compatibleWith: nil)
        self.logoImageView.kf.setImage(with: logoImageUrl, placeholder: coverImagePlaceholder, options: [.requestModifier(modifier)])
    }
}
