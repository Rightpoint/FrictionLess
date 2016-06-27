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

        let cardNumberWithoutSpaces = removeNonDigits(text, cursorPosition: &curserOffset)
        // derive card type
        // validate length
        self.text = insertSpacesIntoString(cardNumberWithoutSpaces, cursorPosition: &curserOffset, style: .Regular)
        if let targetPosition = positionFromPosition(beginningOfDocument, offset: curserOffset) {
            selectedTextRange = textRangeFromPosition(targetPosition, toPosition: targetPosition)
        }
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

    func insertSpacesIntoString(text: String, inout cursorPosition: Int, style: CardFormatStyle) -> String {

        let cursorPositionInSpacelessString = cursorPosition
        var addedSpacesString = String()

        for (index, character) in text.characters.enumerate() {
            addedSpacesString.append(character)
            if style.shouldAddSpaceAtIndex(index) {
                addedSpacesString.appendContentsOf(" ") //Em-space
                if index < cursorPositionInSpacelessString {
                    cursorPosition += 1
                }
            }
        }

        return addedSpacesString
    }

    enum CardFormatStyle {
        case Regular
        case Amex

        func shouldAddSpaceAtIndex(index: Int) -> Bool {
            switch self {
            case Regular:   return [3, 7, 11].contains(index)
            case Amex:      return [3, 9].contains(index)
            }
        }
    }

    func handleDeletionOfSingleCharacterInSet(characterSet: NSCharacterSet, range: NSRange, replacementString: String) {
        guard let text = text where range.length == 1 else { return }
        let range = text.startIndex.advancedBy(range.location)..<text.startIndex.advancedBy(range.location + range.length)
        if text.rangeOfCharacterFromSet(characterSet, options: NSStringCompareOptions(), range: range) != nil {
            self.text?.removeRange(range)
        }

    }

}

final class RZCardNumberTextFieldDelegate: NSObject, UITextFieldDelegate {

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let textField = textField as? RZCardNumberTextField else { return true }

        textField.handleDeletionOfSingleCharacterInSet(.whitespaceCharacterSet(), range: range, replacementString: string)
        return true
    }

}
