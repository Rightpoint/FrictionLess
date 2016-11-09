//
//  UITextField+Animations.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

internal extension UITextField {

    func shake() {
        let animationKey = "shake"
        layer.removeAnimation(forKey: animationKey)

        let shake: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.duration = 0.3
            animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0 ]
            return animation
        }()
        layer.add(shake, forKey: animationKey)
    }
    
}
