//
//  CreditCardFieldProcessor.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

class CreditCardFieldProcessor: FieldProcessor {

    var cardState: CardState = .indeterminate(CardType.allValues)

    override init() {
        super.init()

        inputCharacterSet = .decimalDigits
        formattingCharacterSet = .whitespaces
    }

    override var textField: UITextField? {
        didSet {
            textField?.placeholder = "0000 0000 0000 0000"
        }
    }

    override var valid: Bool {
        let accountNumber = unformattedText(textField)
        if case CardState.identified(let card) = CardState.fromNumber(accountNumber) {
            return card.isValid(accountNumber: accountNumber)
        }
        return false
    }

    override func validateAndFormat(edit: EditingEvent) -> ValidationResult {
        var cursorPos = edit.newCursorPosition
        let newCardNumber = removeFormatting(edit.newValue, cursorPosition: &cursorPos)
        let newCardState = CardState.fromPrefix(newCardNumber)

        let result: ValidationResult = {
            switch cardState {
            case .invalid:
                return .invalid
            case .indeterminate:
                return .valid(edit.newValue, edit.newCursorPosition)
            case .identified(let card):
                let cardLength = newCardNumber.characters.count
                guard cardLength <= card.maxLength else {
                    return .invalid
                }
                if cardLength == card.maxLength && !card.isValid(accountNumber: newCardNumber) {
                    return .invalid
                }
                let formatted = newCardNumber.inserting(" ", formingGroupings: card.segmentGroupings, maintainingCursorPosition: &cursorPos)
                return .valid(formatted, cursorPos)
            }
        }()

        if case .valid(_) = result {
            cardState = newCardState
        }

        return result
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
                    cursorPosition += 1
                }
            }
        }
        return formattedString
    }

}
