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
        validators.forEach {
            $0.navigationDelegate = self
        }
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
            expirationTextField?.addTarget(self, action: #selector(editingChanged(textField:)), for: .editingChanged)
        }
    }

    weak var cvvTextField: UITextField? {
        didSet {
            cvvValidation.textField = cvvTextField
            cvvTextField?.addTarget(self, action: #selector(editingChanged(textField:)), for: .editingChanged)
        }
    }

    weak var zipTextField: UITextField? {
        didSet {
            zipValidation.textField = zipTextField
            zipTextField?.addTarget(self, action: #selector(editingChanged(textField:)), for: .editingChanged)
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
            if nextProcessor(processor)?.textField?.text?.isEmpty ?? true {
                nextProcessor(processor)?.textField?.becomeFirstResponder()
            }
        }
    }

    func validation(_ textField: UITextField) -> FieldProcessor? {
        return validators.filter({ $0.textField == textField }).first
    }

}

extension CreditCardForm: FormNavigation {

    func fieldProcessor(_ fieldProcessor: FieldProcessor, navigation: CharacterNavigation) -> Bool {
        switch navigation {
        case .backspace:
            previousProcessor(fieldProcessor)?.textField?.becomeFirstResponder()
            return true
        case .overflow(let string):
            guard let processor = nextProcessor(fieldProcessor), let textField = processor.textField, (textField.text?.isEmpty ?? true) else { return false }
            textField.becomeFirstResponder()
            let didChange = processor.textField(textField, shouldChangeCharactersIn: NSMakeRange(0, 0), replacementString: string)
            if didChange {
                return true
            }
            else {
                //shake?
                return false
            }
        }
    }

}

extension CreditCardForm {

    func previousProcessor(_ processor: FieldProcessor) -> FieldProcessor? {
        guard let idx = validators.index(of: processor), idx > validators.startIndex else { return nil }
        return validators.suffix(from: idx - 1).first(where: { $0.textField != nil })
    }

    func nextProcessor(_ processor: FieldProcessor) -> FieldProcessor? {
        guard let idx = validators.index(of: processor), idx < validators.endIndex else { return nil }
        return validators.suffix(from: idx + 1).first(where: { $0.textField != nil })
    }
}


