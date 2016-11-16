//
//  CardType.swift
//  CardEntry
//
//  Created by Jason Clark on 6/28/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation

//MARK: - CardType

enum CardType {
    case visa
    case masterCard
    case amex
    case diners
    case discover
    case jcb

    static let allValues: [CardType] = [.visa, .masterCard, .amex, .diners, .discover, .jcb]

    fileprivate var validationRequirements: ValidationRequirement {
        var prefix = [PrefixContainable](), length = [Int]()

        switch self {
        /* // IIN prefixes and length requriements retreived from https://en.wikipedia.org/wiki/Bank_card_number on June 28, 2016 */

        case .visa:         prefix = ["4"]
                            length = [13, 16, 19]

        case .masterCard:   prefix = ["51"..."55", "2221"..."2720"]
                            length = [16]

        case .amex:         prefix = ["34", "37"]
                            length = [15]

        case .discover:     prefix = ["6011", "65"]
                            length = [16]

        case .diners:       prefix = ["300"..."305", "309", "38"..."39"]
                            length = [14]

        case .jcb:          prefix = ["3528"..."3589"]
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
        default:         return [4, 4, 4, 4]
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

    func valid(_ accountNumber: String) -> Bool {
        return validationRequirements.valid(accountNumber) && CardType.luhnCheck(accountNumber)
    }

    func prefixValid(_ accountNumber: String) -> Bool {
        return validationRequirements.prefixValid(accountNumber)
    }

}

fileprivate extension CardType {

    struct ValidationRequirement {
        var prefixes = [PrefixContainable]()
        var lengths = [Int]()

        func valid(_ accountNumber: String) -> Bool {
            return lengthValid(accountNumber) && prefixValid(accountNumber)
        }

        func prefixValid(_ accountNumber: String) -> Bool {
            guard prefixes.count > 0 else { return true }
            return prefixes.contains { $0.prefixMatches(accountNumber) }
        }

        func lengthValid(_ accountNumber: String) -> Bool {
            guard lengths.count > 0 else { return true }
            return lengths.contains { accountNumber.characters.count == $0 }
        }
    }

    // from: https://gist.github.com/cwagdev/635ce973e8e86da0403a
    static func luhnCheck(_ cardNumber: String) -> Bool {
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

//MARK: - CardState

enum CardState {
    case identified(CardType)
    case indeterminate([CardType])
    case invalid
}

extension CardState: Equatable {}
func ==(lhs: CardState, rhs: CardState) -> Bool {
    switch (lhs, rhs) {
    case (.invalid, .invalid): return true
    case (.indeterminate, .indeterminate): return true
    case (let .identified(card1), let .identified(card2)): return card1 == card2
    default: return false
    }
}

extension CardState {

    init(fromNumber number: String) {
        for cardType in CardType.allValues {
            if cardType.valid(number) {
                self = .identified(cardType)
            }
        }
        self = .invalid
    }

    init(fromPrefix prefix: String) {
        guard !prefix.isEmpty else {
            self = .indeterminate(CardType.allValues)
            return
        }

        let possibleTypes = CardType.allValues.filter { $0.prefixValid(prefix) }
        guard let card = possibleTypes.first else {
            self = .invalid
            return
        }
        if possibleTypes.count == 1 {
            self = .identified(card)
        }
        else {
            self = .indeterminate(possibleTypes)
        }
    }

}

//MARK: - PrefixContainable

extension Range where Bound: Comparable {

}

fileprivate protocol PrefixContainable {

    func hasCommonPrefix(_ element: String) -> Bool
    func prefix(_ maxLength: Int) -> Self?

}

extension ClosedRange where Bound: PrefixContainable {

//    func hasCommonPrefix(_ text: String) -> Bool {
//
//        //cannot include Where clause in protocol conformance, so have to ensure Bound == String :(
//        guard !text.isEmpty, let lower = lowerBound as? String, let upper = upperBound as? String else { return false }
//
//        let trimmedRange: ClosedRange<String> = {
//            let length = text.characters.count
//            let trimmedStart = String(lower.characters.prefix(length))
//            let trimmedEnd = String(upper.characters.prefix(length))
//            return trimmedStart...trimmedEnd
//        }()
//
//        let trimmedText = String(text.characters.prefix(trimmedRange.lowerBound.characters.count))
//        return trimmedRange ~= trimmedText
//    }


    func hasCommonPrefix(_ text: String) -> Bool {
        //cannot include Where clause in protocol conformance, so have to ensure Bound: PrefixContainable :(

        let length = text.characters.count
        if let trimmedRange = prefix(length) {
            return trimmedRange ~= text as! Bound
        }

        return false
    }

    func prefix(_ maxLength: Int) -> ClosedRange<Bound>? {
        guard let lowerPrefix = lowerBound.prefix(maxLength),
              let upperPrefix = upperBound.prefix(maxLength) else {
                 return nil
        }

        return ClosedRange(uncheckedBounds: (lowerPrefix, upperPrefix))
    }
}

extension Int: PrefixContainable {

    func hasCommonPrefix(_ text: String) -> Bool {
        return true
    }
    func prefix(_ maxLength: Int) -> Int? {
        if let prefixed = String(self).prefix(maxLength) {
            return Int(prefixed)
        }
        else {
            return nil
        }
    }

}

extension String: PrefixContainable {

    func hasCommonPrefix(_ text: String) -> Bool {
        return hasPrefix(text) || text.hasPrefix(self)
    }
    func prefix(_ maxLength: Int) -> String? {
        return String(characters.prefix(maxLength))
    }

}
