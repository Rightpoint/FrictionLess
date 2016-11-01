//
//  RZCardEntryCoordinator.swift
//  RZCardEntry
//
//  Created by Jason Clark on 10/17/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

final class RZCardEntryCoordinator {

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
            imageView?.image = cardImage(forType: creditCardTextField?.cardType ?? .indeterminate)
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

    func cardImage(forType cardType:CardType) -> UIImage? {
        switch cardType {
        case .visa:         return #imageLiteral(resourceName: "credit_cards_visa")
        case .masterCard:   return #imageLiteral(resourceName: "credit_cards_mastercard")
        case .amex:         return #imageLiteral(resourceName: "credit_cards_americanexpress")
        case .diners:       return #imageLiteral(resourceName: "credit_cards_generic") //replace
        case .discover:     return #imageLiteral(resourceName: "credit_cards_discover")
        case .jcb:          return #imageLiteral(resourceName: "credit_cards_generic") //replace
        case .invalid:      return #imageLiteral(resourceName: "credit_cards_generic") //replace
        case .indeterminate: return #imageLiteral(resourceName: "credit_cards_generic") //replace
        }
    }

    func cvvImage(forType cardType:CardType) -> UIImage? {
        switch cardType {
        default: return nil
            /*
        case .visa:         return #imageLiteral(resourceName: "credit_cards_visa")
        case .masterCard:   return #imageLiteral(resourceName: "credit_cards_mastercard")
        case .amex:         return #imageLiteral(resourceName: "credit_cards_americanexpress")
        case .diners:       return #imageLiteral(resourceName: "credit_cards_generic") //replace
        case .discover:     return #imageLiteral(resourceName: "credit_cards_discover")
        case .jcb:          return #imageLiteral(resourceName: "credit_cards_generic") //replace
        case .invalid:      return #imageLiteral(resourceName: "credit_cards_generic") //replace
        case .indeterminate: return #imageLiteral(resourceName: "credit_cards_generic") //replace
 */
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

    func updateImage(card: CardType) {

        if let imageView = imageView, let textField = fields.first(where: { $0.isFirstResponder }) {

            let newImage: UIImage? = {
                if textField is RZCVVTextField {
                    return cvvImage(forType: card)
                }
                else {
                    return cardImage(forType: card)
                }
            }()

            if newImage != nil && imageView.image != newImage {
                let animation: UIViewAnimationOptions = {
                    switch textField.cardType {
                    case .indeterminate, .invalid: return .transitionFlipFromLeft
                    default: return .transitionFlipFromRight
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
        updateImage(card: textField.cardType)
    }

    func cardEntryTextFieldDidChange(_ textField: RZCardEntryTextField) {
        if textField is RZCardNumberTextField {
            fields.forEach{ $0.cardType = textField.cardType }
            updateImage(card: textField.cardType)
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
