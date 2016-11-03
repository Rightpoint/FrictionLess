//
//  RZCardNumberTextField.swift
//  RZCardEntry
//
//  Created by Jason Clark on 6/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

fileprivate let emSpace = " "

final class RZCardNumberTextField: RZCardEntryTextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        placeholder = "0000\(emSpace)0000\(emSpace)0000\(emSpace)0000"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func textFieldDidChange(_ textField: UITextField) {
        reformatAsCardNumber()
        if let textField = textField as? RZCardNumberTextField {
            cardState = CardState.fromPrefix(textField.unformattedText)
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
                addedSpacesString.append(emSpace)
                if index < cursorPositionInSpacelessString {
                    cursorPosition += 1
                }
            }
        }

        return addedSpacesString
    }

    override var valid: Bool {
        return CardState.fromNumber(unformattedText) != CardState.invalid
    }

}

private extension RZCardNumberTextField {

    func reformatAsCardNumber() {
        guard let text = text else { return }

        var cursorPos = cursorOffset
        let cardNumber = removeFormatting(text, cursorPosition: &cursorPos)
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
            if cardLength == cardType.maxLength && !cardType.isValid(accountNumber: cardNumber) {
                notifiyOfInvalidInput()
            }

            self.text = RZCardNumberTextField.insertSpacesIntoString(cardNumber, cursorPosition: &cursorPos, groupings: cardType.segmentGroupings)
            if let targetPosition = position(from: beginningOfDocument, offset: cursorOffset) {
                selectedTextRange = textRange(from: targetPosition, to: targetPosition)
            }
        }
    }
}
