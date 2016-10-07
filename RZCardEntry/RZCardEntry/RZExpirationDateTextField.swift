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

        let formatlessText = RZCardEntryTextField.removeNonDigits(text, cursorPosition: &cursorOffset)
        guard formatlessText.characters.count <= 4 else {
            rejectInput()
            return
        }
        self.text = formatString(formatlessText, cursorPosition: &cursorOffset)
        if let targetPosition = positionFromPosition(beginningOfDocument, offset: cursorOffset) {
            selectedTextRange = textRangeFromPosition(targetPosition, toPosition: targetPosition)
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
