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

    weak var creditCardTextField: UITextField? {
        didSet {
            creditCardValidation.textField = creditCardTextField
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

    var valid: Bool {
        return ![creditCardValidation, expirationDateValidation, cvvValidation, zipValidation].contains { !$0.valid }
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

}
