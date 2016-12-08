//
//  CreditCardFormatter.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/21/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation

struct CreditCardFormatter: Formatter {

    var inputCharacterSet: CharacterSet {
        return .decimalDigits
    }

    var formattingCharacterSet: CharacterSet {
        return .whitespaces
    }

    func validateAndFormat(editingEvent: EditingEvent) -> ValidationResult {
        var cursorPos = editingEvent.newCursorPosition
        let newCardNumber = editingEvent.newValue
        let newCardState = CardState(fromPrefix: newCardNumber)

        let result: ValidationResult = {
            switch newCardState {
            case .invalid:
                return .invalid
            case .indeterminate(_):
                return .valid(editingEvent.newValue, editingEvent.newCursorPosition)
            case .identified(let card):
                let cardLength = newCardNumber.characters.count
                guard cardLength <= card.maxLength else {
                    return .invalid
                }
                if cardLength == card.maxLength && !card.isValid(newCardNumber) {
                    return .invalid
                }
                let formatted = newCardNumber.inserting(" ", formingGroupings: card.segmentGroupings, maintainingCursorPosition: &cursorPos)
                return .valid(formatted, cursorPos)
            }
        }()

        return result
    }

    func valid(_ string: String) -> Bool {
        if case CardState.identified(let card) = CardState(fromNumber: string) {
            return card.isValid(string)
        }
        return false
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
