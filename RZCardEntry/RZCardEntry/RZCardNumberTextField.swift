//
//  RZCardNumberTextField.swift
//  RZCardEntry
//
//  Created by Jason Clark on 6/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

final class RZCardNumberTextField: UITextField {

    private let internalDelegate = RZCardNumberTextFieldDelegate()
    private var previousText: String?
    private var previousSelection: UITextRange?

    override init(frame: CGRect) {
        super.init(frame: frame)

        delegate = internalDelegate
        addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        placeholder = "0000 0000 0000 0000"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private extension RZCardNumberTextField {

    @objc func textFieldDidChange(textField: UITextField) {
        reformatAsCardNumber()
    }

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

    func rejectInput() {
        text = previousText
        selectedTextRange = previousSelection
        notifiyOfInvalidInput()
    }

    func notifiyOfInvalidInput() {
        shake()
    }

    func removeNonDigits(text: String, inout cursorPosition: Int) -> String {

        let originalCursorPosition = cursorPosition
        var digitsOnlyString = String()
        for (index, character) in text.characters.enumerate() {
            if "0"..."9" ~= character {
                digitsOnlyString.append(character)
            }
            else if index < originalCursorPosition {
                cursorPosition -= 1
            }
        }

        return digitsOnlyString
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

    func handleDeletionOfSingleCharacterInSet(characterSet: NSCharacterSet, range: NSRange, replacementString: String) {
        let deletedSingleChar = range.length == 1
        let noTextSelected = selectedTextRange?.empty ?? true
        guard let text = text where deletedSingleChar && noTextSelected else { return }

        let range = text.startIndex.advancedBy(range.location)..<text.startIndex.advancedBy(range.location + range.length)
        if text.rangeOfCharacterFromSet(characterSet, options: NSStringCompareOptions(), range: range) != nil {
            self.text?.removeRange(range)
        }
    }

    func replacementStringIsValid(replacementString: String) -> Bool {
        let validInputSet = NSCharacterSet(charactersInString: "1234567890 ")
        let rangeOfInvalidChar = replacementString.rangeOfCharacterFromSet(validInputSet.invertedSet)
        return rangeOfInvalidChar?.isEmpty ?? true
    }

}

final class RZCardNumberTextFieldDelegate: NSObject, UITextFieldDelegate {

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let textField = textField as? RZCardNumberTextField else { return true }

        // forward to next text field if necessary

        guard textField.replacementStringIsValid(string) else {
            textField.notifiyOfInvalidInput()
            return false
        }

        textField.previousText = textField.text
        textField.previousSelection = textField.selectedTextRange
        textField.handleDeletionOfSingleCharacterInSet(.whitespaceCharacterSet(), range: range, replacementString: string)
        return true
    }

}

private extension UITextField {
    func shake() {
        print("shake")
    }
}
