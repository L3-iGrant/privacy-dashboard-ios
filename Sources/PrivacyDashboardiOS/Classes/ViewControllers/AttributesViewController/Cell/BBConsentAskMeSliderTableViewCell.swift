
//
//  BBConsentAskMeSliderTableViewCell.swift
//  PrivacyDashboardiOS
//
//  Created by Mumthasir mohammed on 11/09/23.

import UIKit

protocol AskMeSliderCellDelegate: class {
    func askMeSliderValueChanged(days:Int)
    func updatedSliderValue(days:Int,indexPath:IndexPath)

}

class BBConsentAskMeSliderTableViewCell: UITableViewCell {
    weak var delegate: AskMeSliderCellDelegate?

    @IBOutlet weak var selectedDaysLbl: UILabel!
    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var askMeSlider: UISlider!
    var consent :Consent?
    var index : IndexPath!
    var slidercurrentValue = 30

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        slidercurrentValue = Int(sender.value)
        selectedDaysLbl.text = "\(slidercurrentValue) \(Constant.Strings.days.localized)"
        self.delegate?.askMeSliderValueChanged(days: slidercurrentValue)
    }
    
    @IBAction func sliderDidEndSliding() {
        debugPrint("End sliding")
        self.delegate?.updatedSliderValue(days: slidercurrentValue, indexPath: index)
    }
}
