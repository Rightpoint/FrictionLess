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
        inputCharacterSet = .decimalDigits
        formattingCharacterSet = .whitespaces
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

    static func insertSpacesIntoString(_ text: String, cursorPosition: inout Int, groupings: [Int]) -> String {

        var addedSpacesString = String()
        let cursorPositionInSpacelessString = cursorPosition
        let spaceIndicies = groupings.dropLast().reduce([], { sums, element in
            return sums + [element + (sums.last ?? -1)]
        })

        text.characters.enumerated().forEach { offset, character in
            addedSpacesString.append(character)
            if spaceIndicies.contains(offset) {
                addedSpacesString.append(emSpace)
                if offset < cursorPositionInSpacelessString {
                    cursorPosition += 1
                }
            }
        }
        return addedSpacesString
    }

    override var valid: Bool {
        if case CardState.identified(let card) = CardState.fromNumber(unformattedText) {
            return card.isValid(accountNumber: unformattedText)
        }
        return false
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
            selectedTextRange = textRange(cursorOffset: cursorPos)
        }
    }
    
}
