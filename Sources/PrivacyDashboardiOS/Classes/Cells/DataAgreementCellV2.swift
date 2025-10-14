//
//  CovidValuesRowTableViewCell.swift
//  Pods
//
//  Created by iGrant on 24/03/25.
//


//
//  DataAgreementCellV2.swift
//  dataWallet
//
//  Created by sonya N on 21/12/21.
//

import UIKit

final class DataAgreementCellV2: UITableViewCell {
    
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var mainLbl: UILabel!
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var bottom: NSLayoutConstraint!
    @IBOutlet weak var contentBack: UIView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var containerStack: UIStackView!
    @IBOutlet weak var leftPadding: NSLayoutConstraint!
    @IBOutlet weak var rightPadding: NSLayoutConstraint!
    @IBOutlet weak var containerStackRighConstaint: NSLayoutConstraint!
    
    var url: String?
    var tapGesture = UITapGestureRecognizer()
    var rightImage: UIImage? {
        didSet {
            rightImageView.isHidden = false
            rightImageView.image = rightImage
            rightImageView.contentMode = .center
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        super.awakeFromNib()
        valueLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLabelTap(_:)))
        valueLabel.addGestureRecognizer(tapGesture)
        // Initialization code
    }
    
    @objc private func handleLabelTap(_ sender: UITapGestureRecognizer) {
        if let urlString = url {
            UIApplication.shared.open(URL(string: urlString)!)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        regularCell()
        rightImageView.isHidden = true
    }
    
    func removePadding(){
        leftPadding.constant = 0
        rightPadding.constant = 0
        self.updateConstraintsIfNeeded()
    }
    
    func setPadding(padding: CGFloat) {
        leftPadding.constant = padding
        rightPadding.constant = padding
        self.updateConstraintsIfNeeded()
    }
    
    func renderUI(index: Int, tot: Int) {
        if tot == 1 {
            roundAllCorner()
        } else if index == 0  {
            roundTop()
        } else if index == (tot - 1) {
            roundBottom()
        } else {
            regularCell()
        }
    }

    
    private func arrangeStack(status: Bool) {
        if status {
            containerStack.axis = .vertical
            containerStack.spacing = 5
        } else {
            containerStack.axis = .horizontal
        }
    }
    
    private func roundTop() {
        top.constant = 8
        bottom.constant = 0
        contentBack.topMaskedCornerRadius = 10
        lineView.isHidden = false
    }
    
    private func roundBottom() {
        top.constant = 0
        bottom.constant = 8
        contentBack.bottomMaskedCornerRadius = 10
        lineView.isHidden = true
    }
    
    private func roundAllCorner(){
        top.constant = 8
        bottom.constant = 8
        contentBack.maskedCornerRadius = 10
        lineView.isHidden = true
    }
    
    private func regularCell() {
        top.constant = 0
        bottom.constant = 0
        contentBack.IBcornerRadius = 0
        lineView.isHidden = false
    }
    
    func arrangeStackForDataAgreement() {
        self.arrangeStack(status: self.checkAlignment())
    }
    
    private func checkAlignment() -> Bool {
        let font = UIFont.systemFont(ofSize: 15)
        let font_2 = UIFont.systemFont(ofSize: 14)
        var width = (ScreenMain.init().width ?? 0) - 70
        //Consider min space between name and value as 15
        let space: CGFloat = 15
        let labelWidth = width - space
        if !rightImageView.isHidden {
            width = width - 60
        }
        let mainLabelText = mainLbl.text ?? mainLbl.attributedText?.string ?? ""
        let blurViewText = valueLabel.text ?? valueLabel.attributedText?.string ?? ""
        if blurViewText.range(of: "\n") != nil {
            return true
        }
        let nameWidth : CGFloat = mainLabelText.widthOfString(usingFont: font)
        let valueWidth : CGFloat = blurViewText.widthOfString(usingFont: font_2)
        let totWidth = nameWidth + valueWidth
        if totWidth > labelWidth {
            return true
        } else {
            return false
        }
    }
}
