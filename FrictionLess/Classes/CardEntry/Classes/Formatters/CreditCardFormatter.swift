//
//  CreditCardFormatter.swift
//  FrictionLess
//
//  Created by Jason Clark on 11/21/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation

enum CreditCardFormatterError: Error {
    case maxLengthExceeded
    case invalidCardNumber
}

public struct CreditCardFormatter: TextFieldFormatter {

    public var inputCharacterSet: CharacterSet {
        return .decimalDigits
    }

    public var formattingCharacterSet: CharacterSet {
        return .whitespaces
    }

    public func format(editingEvent: EditingEvent) -> FormattingResult {
        let newCardNumber = editingEvent.newValue
        let newCardState = CardState(fromPrefix: newCardNumber)

        let result: FormattingResult = {
            switch newCardState {
            case .invalid:
                return .invalid(formattingError: CreditCardFormatterError.invalidCardNumber)
            case .indeterminate(_):
                return .valid(nil)
            case .identified(let card):
                let cardLength = newCardNumber.characters.count
                guard cardLength <= card.maxLength else {
                    return .invalid(formattingError: CreditCardFormatterError.maxLengthExceeded)
                }
                if cardLength == card.maxLength && !card.isValid(newCardNumber) {
                    return .invalid(formattingError: CreditCardFormatterError.invalidCardNumber)
                }
                let formatted = newCardNumber.inserting(" ", formingGroupings: card.segmentGroupings)
                return .valid(.text(formatted))
            }
        }()

        return result
    }

    public func validate(_ string: String) -> ValidationResult {
        if case CardState.identified(let card) = CardState(fromNumber: string) {
            if card.isValid(string) {
                return .valid
            }
        }
        return .invalid(validationError: CreditCardFormatterError.invalidCardNumber)
    }

    public func isComplete(_ text: String) -> Bool {
        return validate(text) == .valid
    }

    public init() {}

}

extension String {

    //TODO: Can replace this with something simpler
    func inserting(_ formattingString: String, formingGroupings groupings: [Int]) -> String {
        var formattedString = String()
        let formattingIndicies = groupings.dropLast().reduce([], { sums, element in
            return sums + [element + (sums.last ?? -1)]
        })

        characters.enumerated().forEach { offset, character in
            formattedString.append(character)
            if formattingIndicies.contains(offset) {
                formattedString.append(formattingString)
            }
        }
        return formattedString
    }

}
