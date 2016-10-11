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

    @objc override func textFieldDidChange(textField: UITextField) {
        reformatAsCardNumber()
        super.textFieldDidChange(textField)
    }

    override var inputCharacterSet: NSCharacterSet {
        return NSCharacterSet.decimalDigitCharacterSet()
    }

    override var formattingCharacterSet: NSCharacterSet {
        return NSCharacterSet.whitespaceCharacterSet()
    }

    static func insertSpacesIntoString(text: String, inout cursorPosition: Int, groupings: [Int]) -> String {
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

        for (index, character) in text.characters.enumerate() {
            addedSpacesString.append(character)
            if shouldAddSpace(index, groupings) {
                addedSpacesString.appendContentsOf(" ") //Em-space
                if index < cursorPositionInSpacelessString {
                    cursorPosition += 1
                }
            }
        }

        return addedSpacesString
    }

    override var isValid: Bool {
        if let text = text {
            let cardNumber = RZCardEntryTextField.removeCharactersNotContainedInSet(inputCharacterSet, text: text)
            return CardType.fromNumber(cardNumber) != .Invalid
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
            return offsetFromPosition(beginningOfDocument, toPosition: startPosition)
        }()

        let cardNumber = RZCardEntryTextField.removeCharactersNotContainedInSet(inputCharacterSet, text: text, cursorPosition: &cursorOffset)
        let cardType = CardType.fromPrefix(cardNumber)

        let cardLength = cardNumber.characters.count
        guard cardLength <= cardType.maxLength else {
            rejectInput()
            return
        }
        if cardLength == cardType.maxLength {
            if cardType.isValidCardNumber(cardNumber) {
                notifiyOfInvalidInput()
            }
        }

        self.text = RZCardNumberTextField.insertSpacesIntoString(cardNumber, cursorPosition: &cursorOffset, groupings: cardType.segmentGroupings)
        if let targetPosition = positionFromPosition(beginningOfDocument, offset: cursorOffset) {
            selectedTextRange = textRangeFromPosition(targetPosition, toPosition: targetPosition)
        }
    }

}
