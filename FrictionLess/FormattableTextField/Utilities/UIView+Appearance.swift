//
//  UIView+Appearance.swift
//  Pods
//
//  Created by Jason Clark on 9/1/17.
//
//

import Foundation

public extension UIView {

    public dynamic var cornerRadius: CGFloat {
        set { layer.cornerRadius = newValue }
        get { return layer.cornerRadius }
    }

    public dynamic var borderColor: UIColor? {
        set { layer.borderColor = newValue?.cgColor }
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
    }

    public dynamic var borderWidth: CGFloat {
        set { layer.borderWidth = newValue }
        get { return layer.borderWidth }
    }
    
}
