//
//  RZCardEntryCoordinator.swift
//  RZCardEntry
//
//  Created by Jason Clark on 10/17/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation

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

    var fields: [RZCardEntryTextField] {
        let possibleFields: [RZCardEntryTextField?] = [creditCardTextField, expirationDateTextField, cvvTextField]
        return possibleFields.flatMap{ $0 }
    }

    func cardEntryTextFieldDidChange(textField: RZCardEntryTextField) {
        if textField.isValid {
            if let nextField = fieldAfterField(textField) {
                nextField.becomeFirstResponder()
            }
        }
    }

    func cardEntryTextFieldBackspacePressedWithoutContent(textField: RZCardEntryTextField) {
        if let previousField = fieldBeforeField(textField) {
            previousField.becomeFirstResponder()
        }
    }

    func cardEntryTextField(textField: RZCardEntryTextField, shouldForwardInput input: String) {
        if let nextField = fieldAfterField(textField) {
            nextField.becomeFirstResponder()
            nextField.text = input
            nextField.internalDelegate.textField(nextField, shouldChangeCharactersInRange: NSMakeRange(0, 0), replacementString: input)
            nextField.textFieldDidChange(nextField)
        }
    }

    func fieldBeforeField(textField: RZCardEntryTextField) -> RZCardEntryTextField? {
        if let idx = fields.indexOf(textField) where idx > 0 {
            return fields[idx - 1]
        }
        return nil
    }

    func fieldAfterField(textField: RZCardEntryTextField) -> RZCardEntryTextField? {
        if let idx = fields.indexOf(textField) where idx < fields.count - 1{
            return fields[idx + 1]
        }
        return nil
    }

}