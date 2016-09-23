//
//  RZCardEntryTextField.swift
//  RZCardEntry
//
//  Created by Jason Clark on 9/21/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

class RZCardEntryTextField: UITextField {

    let internalDelegate = RZCardEntryTextFieldDelegate()
    var previousText: String?
    var previousSelection: UITextRange?

    override init(frame: CGRect) {
        super.init(frame: frame)

        delegate = internalDelegate
        addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        placeholder = "0000 0000 0000 0000"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func removeNonDigits(text: String, inout cursorPosition: Int) -> String {

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

    @objc func textFieldDidChange(textField: UITextField) {

    }

    func replacementStringIsValid(replacementString: String) -> Bool {
        return true
    }

    var formattingCharacterSet: NSCharacterSet {
        return NSCharacterSet()
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

    func rejectInput() {
        text = previousText
        selectedTextRange = previousSelection
        notifiyOfInvalidInput()
    }

    func notifiyOfInvalidInput() {
        shake()
    }

    func shake() {
        print("shake")
    }

}

final class RZCardEntryTextFieldDelegate: NSObject, UITextFieldDelegate {

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let textField = textField as? RZCardEntryTextField else { return true }

        // TODO: forward to next text field if necessary

        guard textField.replacementStringIsValid(string) else {
            textField.notifiyOfInvalidInput()
            return false
        }

        textField.previousText = textField.text
        textField.previousSelection = textField.selectedTextRange
        textField.handleDeletionOfSingleCharacterInSet(textField.formattingCharacterSet, range: range, replacementString: string)
        return true
    }
    
}