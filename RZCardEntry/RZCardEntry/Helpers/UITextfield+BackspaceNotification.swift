//
//  UITextField+BackspaceNotification.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

extension UITextField {

    internal static let deleteBackwardNotificationName = "deleteBackwardNotificationName"

    static var swizzleDeleteBackward: () = {
        let originalSelector = #selector(UIKeyInput.deleteBackward)
        let swizzledSelector = #selector(swizzled_deleteBackward)

        let originalMethod = class_getInstanceMethod(UITextField.self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(UITextField.self, swizzledSelector)

        let didAddMethod = class_addMethod(UITextField.self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

        if didAddMethod {
            class_replaceMethod(UITextField.self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()

    override open class func initialize() {
        // make sure this isn't a subclass
        if self !== UITextField.self {
            return
        }

        let _ = swizzleDeleteBackward
    }

    // MARK: - Method Swizzling
    func swizzled_deleteBackward() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UITextField.deleteBackwardNotificationName), object: self)
        self.swizzled_deleteBackward()
    }
}
