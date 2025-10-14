//
//  Inspectables.swift
//  dataWallet
//
//  Created by sreelekh N on 24/10/21.
//

import Foundation
import UIKit
@IBDesignable
class TextField: UITextField {
    @IBInspectable var insetX: CGFloat = 0
    @IBInspectable var insetY: CGFloat = 0

    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }

    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
}

extension UIView {
    @IBInspectable
    var IBcornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable
    var IBborderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable
    var IBborderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }

    @IBInspectable var topLeft: Bool {
        get { return layer.maskedCorners.contains(.layerMinXMinYCorner) }
        set {
            if newValue {
                layer.maskedCorners.insert(.layerMinXMinYCorner)
            } else {
                layer.maskedCorners.remove(.layerMinXMinYCorner)
            }
        }
    }

    @IBInspectable var topRight: Bool {
        get { return layer.maskedCorners.contains(.layerMaxXMinYCorner) }
        set {
            if newValue {
                layer.maskedCorners.insert(.layerMaxXMinYCorner)
            } else {
                layer.maskedCorners.remove(.layerMaxXMinYCorner)
            }
        }
    }

    @IBInspectable var bottomLeft: Bool {
        get { return layer.maskedCorners.contains(.layerMinXMaxYCorner) }
        set {
            if newValue {
                layer.maskedCorners.insert(.layerMinXMaxYCorner)
            } else {
                layer.maskedCorners.remove(.layerMinXMaxYCorner)
            }
        }
    }

    @IBInspectable var bottomRight: Bool {
        get { return layer.maskedCorners.contains(.layerMaxXMaxYCorner) }
        set {
            if newValue {
                layer.maskedCorners.insert(.layerMaxXMaxYCorner)
            } else {
                layer.maskedCorners.remove(.layerMaxXMaxYCorner)
            }
        }
    }

    @IBInspectable
    var bottomMaskedCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    @IBInspectable
    var leftMaskedCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        }
    }

    @IBInspectable
    var maskedCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    
    
    @IBInspectable
    var topMaskedCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }

    @IBInspectable
    var rightMaskedCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    @IBInspectable var addBezierShadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addBezierShadowMethod()
            }
        }
    }
    
    @IBInspectable var addNormalShadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addNormalShadowMethod()
            }
        }
    }
    
    func addBezierShadowMethod() {
        layer.masksToBounds = false
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 5
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }

    func addNormalShadowMethod() {
        layer.masksToBounds = false
        layer.shadowOpacity = 0.5
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 5
    }
}

extension UITextField{
    @IBInspectable var IBplaceHolderColor: UIColor? {
        get {
            return self.IBplaceHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}


extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

struct ScreenMain {
    
    var area: CGRect!
    
    init () {
        area = UIScreen.main.bounds
    }
    
    var width: CGFloat? {
        return area.width
    }
    
    var height: CGFloat? {
        return area.height
    }
}

