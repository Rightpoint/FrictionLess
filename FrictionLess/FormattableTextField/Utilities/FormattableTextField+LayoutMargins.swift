//
//  FormattableTextField+LayoutMargins.swift
//  FrictionLess
//
//  Created by Jason Clark on 7/14/17.
//  Copyright © 2017 Raizlabs. All rights reserved.
//

import UIKit

extension FormattableTextField {

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, layoutMargins)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, layoutMargins)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, layoutMargins)
    }
    
}
