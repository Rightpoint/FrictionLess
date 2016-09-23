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

    case Indeterminate
    case Invalid

    static let allValues: [CardType] = [.Visa, .MasterCard, .Amex, .Diners, .Discover, .JCB]

    private var validationRequirements: ValidationRequirement {
        var prefix = [PrefixContainable](), length = [Int]()

        switch self {
        /* // IIN prefixes and length requriements retreived from https://en.wikipedia.org/wiki/Bank_card_number on June 28, 2016 */

        case Visa:          prefix = ["4"]
                            length = [13, 16, 19]

        case MasterCard:    prefix = ["51"..."55", "2221"..."2720"]
                            length = [16]

        case Amex:          prefix = ["34", "37"]
                            length = [15]

        case Discover:      prefix = ["6011", "65"]
                            length = [16]

        case Diners:        prefix = ["300"..."305", "309", "38"..."39"]
                            length = [14]

        case JCB:           prefix = ["3528"..."3589"]
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
        case Amex:      return [4, 6, 5]
        case Diners:    return [4, 6, 4]
        default:        return [4, 4, 4, 4]
        }
    }

    var maxLength: Int {
        return validationRequirements.lengths.maxElement() ?? 16
    }

    func isValidCardNumber(accountNumber: String) -> Bool {
        return validationRequirements.isValid(accountNumber)
    }

    func isValidCardPrefix(accountNumber: String) -> Bool {
        return validationRequirements.isValidPrefix(accountNumber)
    }

}

private struct ValidationRequirement {

    var prefixes = [PrefixContainable]()
    var lengths = [Int]()

    func isValid(accountNumber: String) -> Bool {
        return isValidLength(accountNumber) && isValidPrefix(accountNumber) && isValidPrefix(accountNumber)
    }

    func isValidPrefix(accountNumber: String) -> Bool {
        guard prefixes.count > 0 else { return true }
        return prefixes.contains { $0.prefixMatches(accountNumber) }
    }

    func isValidLength(accountNumber: String) -> Bool {
        guard lengths.count > 0 else { return true }
        return lengths.contains { accountNumber.characters.count == $0 }
    }

}

extension CardType {

    static func fromNumber(cardNumber: String) -> CardType {
        for cardType in CardType.allValues {
            if cardType.isValidCardNumber(cardNumber) {
                return cardType
            }
        }
        return .Invalid
    }

    static func fromPrefix(cardPrefix: String) -> CardType {
        guard !cardPrefix.isEmpty else {
            return .Indeterminate
        }
        
        let possibleTypes = CardType.allValues.filter { $0.isValidCardPrefix(cardPrefix) }
        guard let card = possibleTypes.first else {
            return .Invalid
        }
        if possibleTypes.count == 1 {
            return card
        }
        else {
            return .Indeterminate
        }
    }

    // from: https://gist.github.com/cwagdev/635ce973e8e86da0403a
    private static func luhnCheck(cardNumber: String) -> Bool {
        var sum = 0
        let reversedCharacters = cardNumber.characters.reverse().map { String($0) }
        for (idx, element) in reversedCharacters.enumerate() {
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
    func prefixMatches(text: String) -> Bool
}

extension ClosedInterval: PrefixContainable {
    private func prefixMatches(text: String) -> Bool {
        //cannot include Where clause in protocol conformance, so have to ensure Bound == String :(
        guard !text.isEmpty, let start = start as? String, end = end as? String else { return false }

        let trimmedRange: ClosedInterval<String> = {
            let length = text.characters.count
            let trimmedStart = String(start.characters.prefix(length))
            let trimmedEnd = String(end.characters.prefix(length))
            return trimmedStart...trimmedEnd
        }()

        let trimmedText = String(text.characters.prefix(trimmedRange.start.characters.count))
        return trimmedRange ~= trimmedText
    }
}

extension String: PrefixContainable {
    private func prefixMatches(text: String) -> Bool {
        return hasPrefix(text) || text.hasPrefix(self)
    }
}

