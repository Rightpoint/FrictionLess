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

        case Visa:         return [.beginsWith(4),
                                    .length(13, 16, 19)]

        case MasterCard:   return [.beginsBetween(51...55, 2221...2720),
                                    .length(16)]

        case Amex:         return [.beginsWith(34, 37),
                                    .length(15)]

        case Diners:       return [.beginsBetween(300...305, 38...39),
                                    .beginsWith(309, 36),
                                    .length(14)]

        case Discover:     return [.beginsWith(6011, 65),
                                    .length(16)]

        case JCB:           return [.beginsBetween(3528...3589),
                                    .length(16)]

        }
    }

    func isValidCardNumber(cardNumber: String) -> Bool {
        return !validationRules.contains { !$0.isValid(cardNumber) }
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

    static func fromPrefix(cardPrefix: String) -> [CardType]? {
        return CardType.allValues.filter { $0.isValidCardPrefix(cardPrefix) }
    }

}

enum ValidationRule {
    case BeginsWith([Int])
    case BeginsBetween([Range<Int>])
    case Length([Int])

    static func beginsWith(num: Int...) -> ValidationRule {
        return .BeginsWith(num)
    }

    static func beginsBetween(ranges: Range<Int>...) -> ValidationRule {
        return .BeginsBetween(ranges)
    }

    static func length(lengths: Int...) -> ValidationRule {
        return .Length(lengths)
    }

    func isValid(text: String) -> Bool {
        switch self {
        case BeginsWith(let nums):
            return nums.contains { text.hasPrefix(String($0)) }
        case BeginsBetween(let ranges):
            return ranges.contains { range in
                let size = String(range.startIndex).characters.count
                let substring = String(text.characters.prefix(size))
                if let num = Int(substring) {
                    return range ~= num
                }
                return false
            }
        case Length(let lengths):
            return lengths.contains { $0 == text.characters.count }
        }
    }

}
