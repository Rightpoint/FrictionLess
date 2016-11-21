//
//  CreditCardForm.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/9/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

class CreditCardForm: FormValidation {

    var creditCardProcessor = FieldProcessor(formatter: CreditCardFormatter())
    var expirationDateProcessor = FieldProcessor(formatter: ExpirationDateFormatter())
    var zipProcessor = FieldProcessor(formatter: ZipFormatter())
    var cvvProcessor = FieldProcessor(formatter: CVVFormatter())

    let processors: [FieldProcessor]

    init() {
        processors = [creditCardProcessor,
                      expirationDateProcessor,
                      cvvProcessor,
                      zipProcessor]
        processors.forEach {
            $0.navigationDelegate = self
        }
    }

    var acceptedCardTypes: [CardType] = [.masterCard, .visa, .discover, .amex]

    weak var creditCardTextField: UITextField? {
        didSet {
            creditCardProcessor.textField = creditCardTextField
            creditCardTextField?.addTarget(self, action: #selector(editingChanged(textField:)), for: .editingChanged)
        }
    }

    weak var expirationTextField: UITextField? {
        didSet {
            expirationDateProcessor.textField = expirationTextField
            expirationTextField?.addTarget(self, action: #selector(editingChanged(textField:)), for: .editingChanged)
        }
    }

    weak var cvvTextField: UITextField? {
        didSet {
            cvvProcessor.textField = cvvTextField
            cvvTextField?.addTarget(self, action: #selector(editingChanged(textField:)), for: .editingChanged)
        }
    }

    weak var zipTextField: UITextField? {
        didSet {
            zipProcessor.textField = zipTextField
            zipTextField?.addTarget(self, action: #selector(editingChanged(textField:)), for: .editingChanged)
        }
    }

    weak var imageView: UIImageView? {
        didSet {
            imageView?.image = cardImage(forState: CardState(fromPrefix: creditCardProcessor.unformattedText))
        }
    }

    var valid: Bool {
        return !processors.contains { !$0.valid }
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

    func cvvLength(forState cardState:CardState) -> Int {
        switch cardState {
        case .identified(let card): return card.cvvLength
        default: return 3
        }
    }

    @objc func editingChanged(textField: UITextField) {
        if textField == creditCardProcessor.textField {
            let unformatted = creditCardProcessor.unformattedText
            let state = CardState(fromPrefix: unformatted)
            if case .identified(let card) = state, !acceptedCardTypes.contains(card) {
                //TODO: card type not accepted error
            }

            imageView?.image = cardImage(forState: state)

            //cvvProcessor.maxLength = cvvLength(forState: state)

        }
        if let processor = processor(textField), processor.valid {
            if nextProcessor(processor)?.textField?.text?.isEmpty ?? true {
                nextProcessor(processor)?.textField?.becomeFirstResponder()
            }
        }
    }

    func processor(_ textField: UITextField) -> FieldProcessor? {
        return processors.filter({ $0.textField == textField }).first
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
        guard let idx = processors.index(of: processor), idx > processors.startIndex else { return nil }
        return processors.suffix(from: idx - 1).first(where: { $0.textField != nil })
    }

    func nextProcessor(_ processor: FieldProcessor) -> FieldProcessor? {
        guard let idx = processors.index(of: processor), idx < processors.endIndex else { return nil }
        return processors.suffix(from: idx + 1).first(where: { $0.textField != nil })
    }
}


