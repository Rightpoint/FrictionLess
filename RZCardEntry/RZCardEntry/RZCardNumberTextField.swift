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

    override func replacementStringIsValid(replacementString: String) -> Bool {
        let validInputSet = NSCharacterSet(charactersInString: "1234567890 ")
        let rangeOfInvalidChar = replacementString.rangeOfCharacterFromSet(validInputSet.invertedSet)
        return rangeOfInvalidChar?.isEmpty ?? true
    }

    override var formattingCharacterSet: NSCharacterSet {
        return NSCharacterSet.whitespaceCharacterSet()
    }

}

private extension RZCardNumberTextField {

    func reformatAsCardNumber() {
        guard let text = text else { return }

        var curserOffset: Int = {
            guard let startPosition = selectedTextRange?.start else {
                return 0
            }
            return offsetFromPosition(beginningOfDocument, toPosition: startPosition)
        }()

        let cardNumber = removeNonDigits(text, cursorPosition: &curserOffset)
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

        self.text = insertSpacesIntoString(cardNumber, cursorPosition: &curserOffset, groupings: cardType.segmentGroupings)
        if let targetPosition = positionFromPosition(beginningOfDocument, offset: curserOffset) {
            selectedTextRange = textRangeFromPosition(targetPosition, toPosition: targetPosition)
        }
    }

    func insertSpacesIntoString(text: String, inout cursorPosition: Int, groupings: [Int]) -> String {
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

}
