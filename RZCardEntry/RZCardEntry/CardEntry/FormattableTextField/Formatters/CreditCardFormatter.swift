//
//  CreditCardFormatter.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/21/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation

enum CreditCardFormatterError: Error {
    case maxLengthExceeded
    case invalidCardNumber
}

struct CreditCardFormatter: TextFieldFormatter {

    var inputCharacterSet: CharacterSet {
        return .decimalDigits
    }

    var formattingCharacterSet: CharacterSet {
        return .whitespaces
    }

    func format(editingEvent: EditingEvent) -> FormattingResult {
        var cursorPos = editingEvent.newCursorPosition
        let newCardNumber = editingEvent.newValue
        let newCardState = CardState(fromPrefix: newCardNumber)

        let result: FormattingResult = {
            switch newCardState {
            case .invalid:
                return .invalid(formattingError: CreditCardFormatterError.invalidCardNumber)
            case .indeterminate(_):
                return .valid(formattedString: editingEvent.newValue, cursorPosition: editingEvent.newCursorPosition)
            case .identified(let card):
                let cardLength = newCardNumber.characters.count
                guard cardLength <= card.maxLength else {
                    return .invalid(formattingError: CreditCardFormatterError.maxLengthExceeded)
                }
                if cardLength == card.maxLength && !card.isValid(newCardNumber) {
                    return .invalid(formattingError: CreditCardFormatterError.invalidCardNumber)
                }
                let formatted = newCardNumber.inserting(" ", formingGroupings: card.segmentGroupings, maintainingCursorPosition: &cursorPos)
                return .valid(formattedString: formatted, cursorPosition: cursorPos)
            }
        }()

        return result
    }

    func validate(_ string: String) -> ValidationResult {
        if case CardState.identified(let card) = CardState(fromNumber: string) {
            if card.isValid(string) {
                return .valid
            }
        }
        return .invalid(validationError: CreditCardFormatterError.invalidCardNumber)
    }

    func isComplete(_ text: String) -> Bool {
        return validate(text) == .valid
    }

}

extension String {

    func inserting(_ formattingString: String, formingGroupings groupings: [Int], maintainingCursorPosition cursorPosition: inout Int) -> String {
        var formattedString = String()
        let startingCursorPosition = cursorPosition
        let formattingIndicies = groupings.dropLast().reduce([], { sums, element in
            return sums + [element + (sums.last ?? -1)]
        })

        characters.enumerated().forEach { offset, character in
            formattedString.append(character)
            if formattingIndicies.contains(offset) {
                formattedString.append(formattingString)
                if offset < startingCursorPosition {
                    cursorPosition += formattingString.characters.count
                }
            }
        }
        return formattedString
    }

}
