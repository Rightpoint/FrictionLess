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

    var zipTextField: RZZipCodeTextField? {
        didSet {
            zipTextField?.cardEntryDelegate = self
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
        return creditCardTextField?.text
    }

    var expirationDate: String? {
        return expirationDateTextField?.text
    }

    var cvv: String? {
        return cvvTextField?.text
    }

    var zip: String? {
        return zipTextField?.text
    }

    var fields: [RZCardEntryTextField] {
        let possibleFields: [RZCardEntryTextField?] = [creditCardTextField, expirationDateTextField, cvvTextField, zipTextField]
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
/*
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
 */
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

    func updateImage(state: CardState) {

        if let imageView = imageView, let textField = fields.first(where: { $0.isFirstResponder }) {

            let newImage: UIImage? = {
                if textField is RZCVVTextField {
                    return cvvImage(forState: state)
                }
                else {
                    return cardImage(forState: state)
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

extension RZCardEntryCoordinator: RZCardEntryDelegateProtocol {

    func cardEntryTextFieldDidBecomeFirstResponder(_ textField: RZCardEntryTextField) {
        updateImage(state: textField.cardState)
    }

    func cardEntryTextFieldDidChange(_ textField: RZCardEntryTextField) {
        if textField is RZCardNumberTextField {
            if case .identified(let card) = textField.cardState, !acceptedCardTypes.contains(card) {
                textField.notifiyOfInvalidInput()
            }

            fields.forEach{ $0.cardState = textField.cardState }
            updateImage(state: textField.cardState)
        }

        if textField.valid {
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

}
