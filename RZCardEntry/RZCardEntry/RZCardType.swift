//
//  RZCardType.swift
//  RZCardEntry
//
//  Created by Jason Clark on 6/28/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation

enum CardType {
    case visa
    case masterCard
    case amex
    case diners
    case discover
    case jcb

    case indeterminate
    case invalid

    static let allValues: [CardType] = [.visa, .masterCard, .amex, .diners, .discover, .jcb]

    fileprivate var validationRequirements: ValidationRequirement {
        var prefix = [PrefixContainable](), length = [Int]()

        switch self {
        /* // IIN prefixes and length requriements retreived from https://en.wikipedia.org/wiki/Bank_card_number on June 28, 2016 */

        case .visa:          prefix = ["4"]
                            length = [13, 16, 19]

        case .masterCard:    prefix = ["51"..."55", "2221"..."2720"]
                            length = [16]

        case .amex:          prefix = ["34", "37"]
                            length = [15]

        case .discover:      prefix = ["6011", "65"]
                            length = [16]

        case .diners:        prefix = ["300"..."305", "309", "38"..."39"]
                            length = [14]

        case .jcb:           prefix = ["3528"..."3589"]
                            length = [16]

        default:
                            length = [16]
        }

        var card = ValidationRequirement()
        card.prefixes = prefix
        card.lengths = length
        return card
    }

    var segmentGroupings: [Int] {
        switch self {
        case .amex:      return [4, 6, 5]
        case .diners:    return [4, 6, 4]
        default:        return [4, 4, 4, 4]
        }
    }

    var maxLength: Int {
        return validationRequirements.lengths.max() ?? 16
    }

    var cvvLength: Int {
        switch self {
        case .amex: return 4
        default: return 3
        }
    }

    func isValidCardNumber(_ accountNumber: String) -> Bool {
        return validationRequirements.isValid(accountNumber) && CardType.luhnCheck(accountNumber)
    }

    func isValidCardPrefix(_ accountNumber: String) -> Bool {
        return validationRequirements.isValidPrefix(accountNumber)
    }

}

private struct ValidationRequirement {

    var prefixes = [PrefixContainable]()
    var lengths = [Int]()

    func isValid(_ accountNumber: String) -> Bool {
        return isValidLength(accountNumber) && isValidPrefix(accountNumber)
    }

    func isValidPrefix(_ accountNumber: String) -> Bool {
        guard prefixes.count > 0 else { return true }
        return prefixes.contains { $0.prefixMatches(accountNumber) }
    }

    func isValidLength(_ accountNumber: String) -> Bool {
        guard lengths.count > 0 else { return true }
        return lengths.contains { accountNumber.characters.count == $0 }
    }

}

extension CardType {

    static func fromNumber(_ cardNumber: String) -> CardType {
        for cardType in CardType.allValues {
            if cardType.isValidCardNumber(cardNumber) {
                return cardType
            }
        }
        return .invalid
    }

    static func fromPrefix(_ cardPrefix: String) -> CardType {
        guard !cardPrefix.isEmpty else {
            return .indeterminate
        }
        
        let possibleTypes = CardType.allValues.filter { $0.isValidCardPrefix(cardPrefix) }
        guard let card = possibleTypes.first else {
            return .invalid
        }
        if possibleTypes.count == 1 {
            return card
        }
        else {
            return .indeterminate
        }
    }

    // from: https://gist.github.com/cwagdev/635ce973e8e86da0403a
    fileprivate static func luhnCheck(_ cardNumber: String) -> Bool {
        var sum = 0
        let reversedCharacters = cardNumber.characters.reversed().map { String($0) }
        for (idx, element) in reversedCharacters.enumerated() {
            guard let digit = Int(element) else { return false }
            switch ((idx % 2 == 1), digit) {
            case (true, 9): sum += 9
            case (true, 0...8): sum += (digit * 2) % 9
            default: sum += digit
            }
        }
        return sum % 10 == 0
    }

}

private protocol PrefixContainable {
    func prefixMatches(_ text: String) -> Bool
}

extension ClosedRange: PrefixContainable {
    func prefixMatches(_ text: String) -> Bool {

        //cannot include Where clause in protocol conformance, so have to ensure Bound == String :(
        guard !text.isEmpty, let lower = lowerBound as? String, let upper = upperBound as? String else { return false }

        let trimmedRange: ClosedRange<String> = {
            let length = text.characters.count
            let trimmedStart = String(lower.characters.prefix(length))
            let trimmedEnd = String(upper.characters.prefix(length))
            return trimmedStart...trimmedEnd
        }()

        let trimmedText = String(text.characters.prefix(trimmedRange.lowerBound.characters.count))
        return trimmedRange ~= trimmedText
    }
}

extension String: PrefixContainable {
    func prefixMatches(_ text: String) -> Bool {
        return hasPrefix(text) || text.hasPrefix(self)
    }
}

