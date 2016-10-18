//
//  RZExpirationDateTextField.swift
//  RZCardEntry
//
//  Created by Jason Clark on 9/21/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

final class RZExpirationDateTextField: RZCardEntryTextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        placeholder = "MM/YY"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func textFieldDidChange(textField: UITextField) {
        reformatExpirationDate()
        super.textFieldDidChange(textField)
    }

    override var formattingCharacterSet: NSCharacterSet {
        return NSCharacterSet(charactersInString: "/")
    }

    override var inputCharacterSet: NSCharacterSet {
        return NSCharacterSet.decimalDigitCharacterSet()
    }

    override var isValid: Bool {
        guard let text = text else {
            return false
        }

        let formatlessText = RZCardEntryTextField.removeCharactersNotContainedInSet(inputCharacterSet, text: text)
        return formatlessText.characters.count == maxLength
    }

    var maxLength: Int {
        return 4
    }

    func expirationDateIsPossible(expDate: String) -> Bool {
        guard expDate.characters.count > 0 else {
            return true
        }
        let monthsRange = "01"..."12"
        guard monthsRange.prefixMatches(expDate) else {
            return false
        }
        //months valid, check year
        guard expDate.characters.count > 2 else {
            return true
        }
        let suffix = expDate.substringFromIndex(expDate.startIndex.advancedBy(2))
        guard validYearRanges.contains({ $0.prefixMatches(suffix) }) else {
            return false
        }
        //year valid, check month year combo
        guard String(currentYearSuffix).prefixMatches(suffix) else {
            return true
        }
        guard !(suffix.characters.count == 1 && String(currentYearSuffix + 1).prefixMatches(suffix)) else {
            //year is incomplete and can potentially be a future year
            return true
        }
        return currentMonth >= Int(suffix)
    }

    static let validFutureExpYearRange = 30
    var validYearRanges: [ClosedInterval<String>] {
        let shortYear = currentYearSuffix
        var endYear = shortYear + RZExpirationDateTextField.validFutureExpYearRange
        if endYear < 100 {
            return [String(shortYear)...String(endYear)]
        }
        else {
            endYear = endYear % 100
            return [String(shortYear)..."99",
                    "00"...String(endYear)]
        }
    }

    var currentYearSuffix: Int {
        let fullYear = NSCalendar.currentCalendar().component(.Year, fromDate: NSDate())
        return fullYear % 100
    }

    var currentMonth: Int {
        return NSCalendar.currentCalendar().component(.Month, fromDate: NSDate())
    }

}

private extension RZExpirationDateTextField {

    func reformatExpirationDate() {
        guard let text = text else { return }

        var cursorOffset: Int = {
            guard let startPosition = selectedTextRange?.start else {
                return 0
            }
            return offsetFromPosition(beginningOfDocument, toPosition: startPosition)
        }()

        let formatlessText = RZCardEntryTextField.removeCharactersNotContainedInSet(inputCharacterSet, text: text, cursorPosition: &cursorOffset)

        guard formatlessText.characters.count <= maxLength else {
            rejectInput()
            return
        }
        let formattedText = formatString(formatlessText, cursorPosition: &cursorOffset)
        self.text = formattedText
        if let targetPosition = positionFromPosition(beginningOfDocument, offset: cursorOffset) {
            selectedTextRange = textRangeFromPosition(targetPosition, toPosition: targetPosition)
        }

        let postFormattedText = RZCardEntryTextField.removeCharactersNotContainedInSet(inputCharacterSet, text: formattedText)
        guard expirationDateIsPossible(postFormattedText) else {
            rejectInput()
            return
        }
    }

    func formatString(text: String, inout cursorPosition: Int) -> String {
        let cursorPositionInFormattlessText = cursorPosition
        var formattedString = String()

        for (index, character) in text.characters.enumerate() {
            if index == 0 && text.characters.count == 1 && "2"..."9" ~= character {
                formattedString.appendContentsOf("0")
                formattedString.append(character)
                formattedString.appendContentsOf("/")
                if index < cursorPositionInFormattlessText {
                    cursorPosition += 2
                }
            }
            else if index == 1 && text.characters.count == 2 && text.characters.first == "1"
                && !("1"..."2" ~= character) && validYearRanges.contains({ $0.prefixMatches(String(character)) }) {
                //digit after leading 1 is not a valid month but is the start of a valid year.
                formattedString.insert("0", atIndex: formattedString.startIndex)
                formattedString.appendContentsOf("/")
                formattedString.append(character)
                if index < cursorPositionInFormattlessText {
                    cursorPosition += 2
                }
            }
            else {
                formattedString.append(character)
                if index == 1 {
                    formattedString.appendContentsOf("/")
                    if index < cursorPositionInFormattlessText {
                        cursorPosition += 1
                    }
                }
            }
        }

        return formattedString
    }
    
}
