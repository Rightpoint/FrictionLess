//
//  RZCardType.swift
//  RZCardEntry
//
//  Created by Jason Clark on 6/28/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation

enum CardType {
    case Visa
    case MasterCard
    case Amex
    case Diners
    case Discover
    case JCB

    static let allValues: [CardType] = [.Visa, .MasterCard, .Amex, .Diners, .Discover, .JCB]

    var regex: String {
        switch self {
                            //All Visa card numbers start with a 4. New cards have 16 digits. Old cards have 13.
        case Visa:          return "^4[0-9]{12}(?:[0-9]{3})?$"

                            //MasterCard numbers either start with the numbers 51 through 55 or with the numbers 2221 through 2720. All have 16 digits.
        case MasterCard:    return "^(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}$"

                            //American Express card numbers start with 34 or 37 and have 15 digits.
        case Amex:          return "^3[47][0-9]{13}$"

                            //Diners Club card numbers begin with 300 through 305, 36 or 38. All have 14 digits.
        case Diners:        return "^3(?:0[0-5]|[68][0-9])[0-9]{11}$"

                            //Discover card numbers begin with 6011 or 65. All have 16 digits.
        case Discover:      return "^6(?:011|5[0-9]{2})[0-9]{12}$"

                            //JCB cards beginning with 2131 or 1800 have 15 digits. JCB cards beginning with 35 have 16 digits.
        case JCB:           return "^(?:2131|1800|35[0-9]{3})[0-9]{11}$"
        }
    }

    static func fromNumber(cardNumber: String) -> CardType? {
        for cardType in CardType.allValues {
            if cardNumber.rangeOfString(cardType.regex, options: .RegularExpressionSearch) != nil {
                return cardType
            }
        }

        return nil
    }

}
