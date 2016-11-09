//
//  CreditCardForm.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/9/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

class CreditCardForm: FormValidation {

    let creditCardValidation = CreditCardFieldProcessor()
    let expirationDateValidation = ExpirationDateFieldProcessor()
    let cvvValidation = CVVFieldProcessor()
    let zipValidation = ZipCodeFieldProcessor()
    let validators: [FieldProcessor]

    init() {
        validators = [creditCardValidation,
                      expirationDateValidation,
                      cvvValidation,
                      zipValidation]

        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidDeleteBackwardNotification(note:)), name: Notification.Name(rawValue: UITextField.deleteBackwardNotificationName), object:nil)
    }

    var acceptedCardTypes: [CardType] = [.masterCard, .visa, .discover, .amex]

    weak var creditCardTextField: UITextField? {
        didSet {
            creditCardValidation.textField = creditCardTextField
            creditCardTextField?.addTarget(self, action: #selector(editingChanged(textField:)), for: .editingChanged)
        }
    }

    weak var expirationTextField: UITextField? {
        didSet {
            expirationDateValidation.textField = expirationTextField
        }
    }

    weak var cvvTextField: UITextField? {
        didSet {
            cvvValidation.textField = cvvTextField
        }
    }

    weak var zipTextField: UITextField? {
        didSet {
            zipValidation.textField = zipTextField
        }
    }

    weak var imageView: UIImageView? {
        didSet {
            imageView?.image = cardImage(forState: creditCardValidation.cardState)
        }
    }

    var valid: Bool {
        return !validators.contains { !$0.valid }
    }

}

extension CreditCardForm {

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

    @objc func editingChanged(textField: UITextField) {
        if textField == creditCardValidation.textField {
            if case .identified(let card) = creditCardValidation.cardState, !acceptedCardTypes.contains(card) {
                //TODO: card type not accepted error
            }

            cvvValidation.cardState = creditCardValidation.cardState
            imageView?.image = cardImage(forState: creditCardValidation.cardState)
        }
        if let processor = validation(textField), processor.valid {
            //move to next text field
            print("valid")
        }
    }

    @objc func textFieldDidDeleteBackwardNotification(note: NSNotification) {
        if let textField = note.object as? UITextField, textField.text?.characters.count == 0 {
            //move to previous text field.
            print("delete pressed without content")
        }
    }

    func validation(_ textField: UITextField) -> FieldProcessor? {
        return validators.filter({ $0.textField == textField }).first
    }

}


