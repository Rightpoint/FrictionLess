//
//  RZCardNumberTextField.swift
//  RZCardEntry
//
//  Created by Jason Clark on 6/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

final class RZCardNumberTextField: RZCardEntryTextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        placeholder = "0000 0000 0000 0000"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func textFieldDidChange(_ textField: UITextField) {
        reformatAsCardNumber()
        if let text = text {
            let cardNumber = RZCardEntryTextField.removeCharactersNotContainedIn(characterSet: inputCharacterSet, text: text)
            cardState = CardState.fromPrefix(cardNumber)
        }
        super.textFieldDidChange(textField)
    }

    override var inputCharacterSet: CharacterSet {
        return CharacterSet.decimalDigits
    }

    override var formattingCharacterSet: CharacterSet {
        return CharacterSet.whitespaces
    }

    static func insertSpacesIntoString(_ text: String, cursorPosition: inout Int, groupings: [Int]) -> String {
        let cursorPositionInSpacelessString = cursorPosition
        var addedSpacesString = String()

        let shouldAddSpace: (Int, [Int]) -> Bool = { idx, groups in
            var sum = 0
            for grouping in groups.dropLast() { //don't add a space after the card number
                sum += grouping
                if idx > sum {
                    continue
                }
                else {
                    return idx == sum - 1
                }
            }
            return false
        }

        for (index, character) in text.characters.enumerated() {
            addedSpacesString.append(character)
            if shouldAddSpace(index, groupings) {
                addedSpacesString.append(" ") //Em-space
                if index < cursorPositionInSpacelessString {
                    cursorPosition += 1
                }
            }
        }

        return addedSpacesString
    }

    override var valid: Bool {
        if let text = text {
            let cardNumber = RZCardEntryTextField.removeCharactersNotContainedIn(characterSet: inputCharacterSet, text: text)
            return CardState.fromNumber(cardNumber) != CardState.invalid
        }
        return false
    }

}

private extension RZCardNumberTextField {

    func reformatAsCardNumber() {
        guard let text = text else { return }

        var cursorOffset: Int = {
            guard let startPosition = selectedTextRange?.start else {
                return 0
            }
            return offset(from: beginningOfDocument, to: startPosition)
        }()

        let cardNumber = RZCardEntryTextField.removeCharactersNotContainedIn(characterSet: inputCharacterSet, text: text, cursorPosition: &cursorOffset)
        let cardState = CardState.fromPrefix(cardNumber)

        guard cardState != .invalid else {
            rejectInput()
            return
        }

        if case .identified(let cardType) = cardState {
            let cardLength = cardNumber.characters.count
            guard cardLength <= cardType.maxLength else {
                rejectInput()
                return
            }
            if cardLength == cardType.maxLength {
                if cardType.isValid(accountNumber: cardNumber) {
                    notifiyOfInvalidInput()
                }
            }

            self.text = RZCardNumberTextField.insertSpacesIntoString(cardNumber, cursorPosition: &cursorOffset, groupings: cardType.segmentGroupings)
            if let targetPosition = position(from: beginningOfDocument, offset: cursorOffset) {
                selectedTextRange = textRange(from: targetPosition, to: targetPosition)
            }
        }
    }
}
