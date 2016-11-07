//
//  RZCardEntryCoordinator.swift
//  RZCardEntry
//
//  Created by Jason Clark on 10/17/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

final class RZCardEntryCoordinator {

    var acceptedCardTypes: [CardType] = [.masterCard, .visa, .discover, .amex]

    var creditCardTextField: RZCardNumberTextField? {
        didSet {
            creditCardTextField?.navigationDelegate = self
        }
    }

    var expirationDateTextField: RZExpirationDateTextField? {
        didSet {
            expirationDateTextField?.navigationDelegate = self
        }
    }

    var cvvTextField: RZCVVTextField? {
        didSet {
            cvvTextField?.navigationDelegate = self
        }
    }

    var zipTextField: RZZipCodeTextField? {
        didSet {
            zipTextField?.navigationDelegate = self
        }
    }

    var imageView: UIImageView? {
        didSet {
            imageView?.image = cardImage(forState: creditCardTextField?.cardState ?? .indeterminate)
        }
    }

    var valid: Bool {
        return !fields.contains { !$0.valid }
    }

    var cardNumber: String? {
        return creditCardTextField?.unformattedText
    }

    var expirationMonth: String? {
        return expirationDateTextField?.monthString
    }

    var expirationYear: String? {
        return expirationDateTextField?.yearString
    }

    var cvv: String? {
        return cvvTextField?.text
    }

    var zip: String? {
        return zipTextField?.text
    }

    var fields: [RZFormattableTextField] {
        let possibleFields: [RZFormattableTextField?] = [creditCardTextField, expirationDateTextField, cvvTextField, zipTextField]
        return possibleFields.flatMap{ $0 }
    }

    func cardImage(forState cardState:CardState) -> UIImage? {
        switch cardState {
        case .identified(let cardType):
            switch cardType{
            case .visa:         return #imageLiteral(resourceName: "credit_cards_visa")
            case .masterCard:   return #imageLiteral(resourceName: "credit_cards_mastercard")
            case .amex:         return #imageLiteral(resourceName: "credit_cards_americanexpress")
            case .diners:       return #imageLiteral(resourceName: "credit_cards_generic") //replace
            case .discover:     return #imageLiteral(resourceName: "credit_cards_discover")
            case .jcb:          return #imageLiteral(resourceName: "credit_cards_generic") //replace
            }
        case .invalid:      return #imageLiteral(resourceName: "credit_cards_generic") //replace
        case .indeterminate: return #imageLiteral(resourceName: "credit_cards_generic") //replace
        }
    }

    func cvvImage(forState cardState:CardState) -> UIImage? {
        return nil
    }

    func fieldBefore(field: RZFormattableTextField) -> RZFormattableTextField? {
        if let idx = fields.index(of: field), idx > 0 {
            return fields[idx - 1]
        }
        return nil
    }

    func fieldAfter(field: RZFormattableTextField) -> RZFormattableTextField? {
        if let idx = fields.index(of: field), idx < fields.count - 1{
            return fields[idx + 1]
        }
        return nil
    }

    func updateImage(textField: RZCardEntryTextField) {
        if let imageView = imageView {
            let newImage: UIImage? = {
                if textField is RZCVVTextField {
                    return cvvImage(forState: textField.cardState)
                }
                else {
                    return cardImage(forState: textField.cardState)
                }
            }()
            if newImage != nil && imageView.image != newImage {
                let animation: UIViewAnimationOptions = {
                    switch textField.cardState {
                    case .identified(_): return .transitionFlipFromRight
                    default: return .transitionFlipFromLeft
                    }
                }()
                UIView.transition(with: imageView, duration: 0.3, options: animation, animations: {
                    imageView.image = newImage
                })
            }
        }
    }

}

extension RZCardEntryCoordinator: RZTextFieldNavigationDelegate {

    func textFieldDidBecomeFirstResponder(_ textField: RZFormattableTextField) {
        if let textField = textField as? RZCardEntryTextField {
            updateImage(textField: textField)
        }
    }

    func textFieldDidChange(_ textField: RZFormattableTextField) {
        if let textField = textField as? RZCardNumberTextField {
            if case .identified(let card) = textField.cardState, !acceptedCardTypes.contains(card) {
                textField.notifiyOfInvalidInput()
            }
            fields.flatMap({$0 as? RZCardEntryTextField}).forEach{ $0.cardState = textField.cardState }
            updateImage(textField: textField)
        }
        if textField.valid {
            if let nextField = fieldAfter(field: textField) {
                nextField.becomeFirstResponder()
            }
        }
    }

    func textFieldBackspacePressedWithoutContent(_ textField: RZFormattableTextField) {
        if let previousField = fieldBefore(field: textField) {
            previousField.becomeFirstResponder()
        }
    }

    func textField(_ textField: RZFormattableTextField, shouldForwardInput input: String) {
        if let nextField = fieldAfter(field: textField) {
            nextField.becomeFirstResponder()
            nextField.text = input
            let _ = nextField.internalDelegate.textField(nextField, shouldChangeCharactersIn: NSMakeRange(0, 0), replacementString: input)
            nextField.textFieldDidChange(nextField)
        }
    }

}
