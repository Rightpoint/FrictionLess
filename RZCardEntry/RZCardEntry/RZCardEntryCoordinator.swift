//
//  RZCardEntryCoordinator.swift
//  RZCardEntry
//
//  Created by Jason Clark on 10/17/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

final class RZCardEntryCoordinator: RZCardEntryDelegateProtocol {

    var creditCardTextField: RZCardNumberTextField? {
        didSet {
            creditCardTextField?.cardEntryDelegate = self
        }
    }

    var expirationDateTextField: RZExpirationDateTextField? {
        didSet {
            expirationDateTextField?.cardEntryDelegate = self
        }
    }

    var cvvTextField: RZCVVTextField? {
        didSet {
            cvvTextField?.cardEntryDelegate = self
        }
    }

    var imageView: RZCardImageView?

    var fields: [RZCardEntryTextField] {
        let possibleFields: [RZCardEntryTextField?] = [creditCardTextField, expirationDateTextField, cvvTextField]
        return possibleFields.flatMap{ $0 }
    }

    func cardEntryTextFieldDidChange(_ textField: RZCardEntryTextField) {
//        if let imageView = imageView {
//            UIView.transition(with: imageView, duration: 0.3, options: .transitionFlipFromRight, animations: {
//                //card image
//                }, completion: nil)
//        }
        if textField.isValid {
            if let nextField = fieldAfter(field: textField) {
                nextField.becomeFirstResponder()
            }
        }
    }

    func cardEntryTextFieldBackspacePressedWithoutContent(_ textField: RZCardEntryTextField) {
        if let previousField = fieldBefore(field: textField) {
            previousField.becomeFirstResponder()
        }
    }

    func cardEntryTextField(_ textField: RZCardEntryTextField, shouldForwardInput input: String) {
        if let nextField = fieldAfter(field: textField) {
            nextField.becomeFirstResponder()
            nextField.text = input
            let _ = nextField.internalDelegate.textField(nextField, shouldChangeCharactersIn: NSMakeRange(0, 0), replacementString: input)
            nextField.textFieldDidChange(nextField)
        }
    }

    func fieldBefore(field: RZCardEntryTextField) -> RZCardEntryTextField? {
        if let idx = fields.index(of: field), idx > 0 {
            return fields[idx - 1]
        }
        return nil
    }

    func fieldAfter(field: RZCardEntryTextField) -> RZCardEntryTextField? {
        if let idx = fields.index(of: field), idx < fields.count - 1{
            return fields[idx + 1]
        }
        return nil
    }

}
