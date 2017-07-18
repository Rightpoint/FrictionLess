//
//  CreditEntryViewModel.swift
//  SimpliSafe
//
//  Created by Jason Clark on 3/29/17.
//
//

import Foundation

public struct CreditEntryViewModel {

    let acceptedCardTypes: [CardType] = [.masterCard, .visa, .discover, .amex]
    var number: String = ""
    var expiration: String = ""
    var cvv: String = ""

    mutating func update(number: String, expiration: String, cvv: String) {
        if self.number != number {
            self.number = number
        }
        if self.expiration != expiration {
            self.expiration = expiration
        }
        if self.cvv != cvv {
            self.cvv = cvv
        }
    }

    public init() {}

}

public extension CreditEntryViewModel {

    var state: CardState {
        return CardState(fromPrefix: number)
    }

    var isAccepted: Bool {
        if case .identified(let card) = state,
            !acceptedCardTypes.contains(card) {
            return false
        }
        else {
            return true
        }
    }

}

public extension CardType {

    var name: String {
        switch self {
        case .amex:         return Strings.Frictionless.Cardentry.Cardtype.amex
        case .diners:       return Strings.Frictionless.Cardentry.Cardtype.diners
        case .discover:     return Strings.Frictionless.Cardentry.Cardtype.discover
        case .jcb:          return Strings.Frictionless.Cardentry.Cardtype.jcb
        case .masterCard:   return Strings.Frictionless.Cardentry.Cardtype.masterCard
        case .visa:         return Strings.Frictionless.Cardentry.Cardtype.visa
        }
    }

}

public extension CreditEntryViewModel {

    var notAcceptedErrorMessage: String {
        if case .identified(let card) = state {
            return Strings.Frictionless.Cardentry.Validation.notAccepted(card.name)
        }
        else {
            return Strings.Frictionless.Cardentry.Validation.Notaccepted.generic
        }
    }

    func errorString(forFormatter formatter: TextFieldFormatter, error: Error) -> String? {
        switch formatter {
        case is CreditCardFormatter:
            if !isAccepted {
                return notAcceptedErrorMessage
            }
            else {
                switch error {
                case FormattableTextFieldError.invalidInput: break
                case CreditCardFormatterError.invalidCardNumber: return Strings.Frictionless.Cardentry.Validation.cardNumberInvalid
                case CreditCardFormatterError.maxLengthExceeded: break
                default: break
                }
            }

        case is ExpirationDateFormatter:
            switch error {
            case FormattableTextFieldError.invalidInput: break
            case ExpirationDateFormatterError.expired: return Strings.Frictionless.Cardentry.Validation.expired
            case ExpirationDateFormatterError.invalidMonth: break
            case ExpirationDateFormatterError.invalidYear: return Strings.Frictionless.Cardentry.Validation.expirationInvalid
            case ExpirationDateFormatterError.maxLength: break
            default: break
            }

        case is CVVFormatter:
            switch error {
            case FormattableTextFieldError.invalidInput: break
            case CVVFormatterError.maxLength: break
            default: break
            }

        default: break
        }
        return nil
    }

}
