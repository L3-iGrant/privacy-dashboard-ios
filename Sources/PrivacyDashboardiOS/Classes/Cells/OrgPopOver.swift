//
//  OrgPopOver.swift
//  iGrant
//
//  Created by Ajeesh T S on 31/07/18.
//  Copyright © 2018 iGrant.com. All rights reserved.
//

import UIKit

class OrgPopOver: UIView {
    
    @IBOutlet weak var forgetMeButton: UIButton!
    @IBOutlet weak var downloadDataButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var requestedStatus: UIButton!
    @IBOutlet weak var consentHistory: UIButton!
    
    class func instanceFromNib(vc: AnyClass) -> OrgPopOver {
        return UINib(nibName: "PopOverView", bundle: Bundle.init(for: vc)).instantiate(withOwner: nil, options: nil)[0] as! OrgPopOver
    }
    
}

