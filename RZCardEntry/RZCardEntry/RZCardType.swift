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

    /* // IIN prefixes and length requriements retreived from https://en.wikipedia.org/wiki/Bank_card_number on June 28, 2016 */
    var validationRules: [ValidationRule] {
        switch self {

        case Visa:         return [.beginsWith("4"),
                                   .length(13, 16, 19)]

        case MasterCard:   return [.beginsBetween("51"..."55", "2221"..."2720"),
                                   .length(16)]

        case Amex:         return [.beginsWith("34", "37"),
                                   .length(15)]

        case Diners:       return [.beginsBetween("300"..."305", "38"..."39"),
                                   .beginsWith("309", "36"),
                                   .length(14)]

        case Discover:     return [.beginsWith("6011", "65"),
                                   .length(16)]

        case JCB:           return [.beginsBetween("3528"..."3589"),
                                    .length(16)]

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

    static func fromNumber(cardNumber: String) -> CardType? {
        for cardType in CardType.allValues {
            if cardType.isValidCardNumber(cardNumber) {
                return cardType
            }
        }

        return nil
    }

    func isValidCardPrefix(cardPrefix: String) -> Bool {
        return !validationRules.contains {
            switch $0 {
            case .Length(_): return false //ignore length requirement for prefix-matching
            default: return !$0.isValid(cardPrefix)
            }
        }
    }

    static func fromPrefix(cardPrefix: String) -> [CardType] {
        return CardType.allValues.filter { $0.isValidCardPrefix(cardPrefix) }
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
    case BeginsWith([String])
    case BeginsBetween([ClosedInterval<String>])
    case Length([Int])

    static func beginsWith(text: String...) -> ValidationRule {
        return .BeginsWith(text)
    }

    static func beginsBetween(ranges: ClosedInterval<String>...) -> ValidationRule {
        return .BeginsBetween(ranges)
    }

    static func length(lengths: Int...) -> ValidationRule {
        return .Length(lengths)
    }

    func isValid(text: String) -> Bool {
        switch self {
        case BeginsWith(let prefixes):
            return prefixes.contains { haveMatchingPrefix($0, text) }
        case BeginsBetween(let ranges):
            return ranges.contains { haveMatchingPrefix($0, text) }
        case Length(let lengths):
            return lengths.contains { $0 == text.characters.count }
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
        return trimmedRange ~= text
    }

}
