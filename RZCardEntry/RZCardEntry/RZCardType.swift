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

    /* // IIN prefixes and length requriements retreived from https://en.wikipedia.org/wiki/Bank_card_number on June 28, 2016 */
    var validationRules: [ValidationRule] {
        switch self {

        case Visa:          return [.begins(.with("4")),
                                    .length(13, 16, 19)]

        case MasterCard:    return [.begins(.between("51"..."55", "2221"..."2720")),
                                    .length(16)]

        case Amex:          return [.begins(.with("34", "37")),
                                    .length(15)]

        case Diners:        return [.begins(.between("300"..."305", "38"..."39"),
                                            .with("309")),
                                    .length(14)]

        case Discover:      return [.begins(.with("6011", "65")),
                                    .length(16)]

        case JCB:           return [.begins(.between("3528"..."3589")),
                                    .length(16)]

        default:            return [.length(16)]
            
        }
    }

    var segmentGroupings: [Int] {
        switch self {
        case Amex:      return [4, 6, 5]
        case Diners:    return [4, 6, 4]
        default:        return [4, 4, 4, 4]
        }
    }
}

extension CardType {
    func isValidCardNumber(cardNumber: String) -> Bool {
        return !validationRules.contains { !$0.isValid(cardNumber) } && CardType.luhnCheck(cardNumber)
    }

    static func fromNumber(cardNumber: String) -> CardType {
        for cardType in CardType.allValues {
            if cardType.isValidCardNumber(cardNumber) {
                return cardType
            }
        }

        return .Invalid
    }

    func isValidCardPrefix(cardPrefix: String) -> Bool {
        return !validationRules.contains {
            switch $0 {
            case .Lengths(_): return false //ignore length requirement for prefix-matching
            default: return !$0.isValid(cardPrefix)
            }
        }
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

enum ValidationRule {

    case Prefixes([PrefixValidationRule])
    case Lengths([Int])

    static func begins(prefixRules: PrefixValidationRule...) -> ValidationRule {
        return .Prefixes(prefixRules)
    }

    static func length(lengths: Int...) -> ValidationRule {
        return .Lengths(lengths)
    }

    func isValid(text: String) -> Bool {
        switch self {
        case Prefixes(let prefixes):
            return prefixes.contains{ $0.isValid(text) }
        case Lengths(let lengths):
            return lengths.contains { $0 == text.characters.count }
        }
    }
}

enum PrefixValidationRule{
    case With([String])
    case Between([ClosedInterval<String>])

    static func with(prefixes: String...) -> PrefixValidationRule {
        return With(prefixes)
    }
    static func between(ranges: ClosedInterval<String>...) -> PrefixValidationRule {
        return Between(ranges)
    }

    func isValid(text: String) -> Bool {
        switch self {
        case With(let prefixes):
            return prefixes.contains { haveMatchingPrefix($0, text) }
        case Between(let ranges):
            return ranges.contains { haveMatchingPrefix($0, text) }
        }
    }

    private func haveMatchingPrefix(text1: String, _ text2: String) -> Bool {
        return text1.hasPrefix(text2) || text2.hasPrefix(text1)
    }

    private func haveMatchingPrefix(range: ClosedInterval<String>, _ text: String) -> Bool {
        guard !text.isEmpty else { return false }

        let trimmedRange: ClosedInterval<String> = {
            let length = text.characters.count
            let trimmedStart = String(range.start.characters.prefix(length))
            let trimmedEnd = String(range.end.characters.prefix(length))
            return trimmedStart...trimmedEnd
        }()

        let trimmedText = String(text.characters.prefix(trimmedRange.start.characters.count))
        return trimmedRange ~= trimmedText
    }
}
