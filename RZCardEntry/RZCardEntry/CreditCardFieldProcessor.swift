//
//  CreditCardFieldProcessor.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

class CreditCardFieldProcessor: FieldProcessor {

    var cardState: CardState = .indeterminate

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

}

private extension CreditCardFieldProcessor {

    func reformat() {
        guard let textField = textField, let text = textField.text else { return }

        var cursorPos = textField.cursorOffset
        let cardNumber = removeFormatting(text, cursorPosition: &cursorPos)
        let cardState = CardState.fromPrefix(cardNumber)

        guard cardState != .invalid else {
            //rejectInput()
            return
        }

        if case .identified(let cardType) = cardState {
            let cardLength = cardNumber.characters.count
            guard cardLength <= cardType.maxLength else {
                //rejectInput()
                return
            }
            if cardLength == cardType.maxLength && !cardType.isValid(accountNumber: cardNumber) {
                //notifyOfInvalidInput()
            }

            textField.text = cardNumber.inserting(" ", formingGroupings: cardType.segmentGroupings, maintainingCursorPosition: &cursorPos)
            textField.selectedTextRange = textField.textRange(cursorOffset: cursorPos)
        }
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
