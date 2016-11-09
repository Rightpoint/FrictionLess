//
//  FieldProcessor.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

protocol FormValidation {
    var valid: Bool { get }
}

class FieldProcessor: NSObject, FormValidation {

    weak var textField: UITextField?
    var inputCharacterSet = CharacterSet.alphanumerics
    var formattingCharacterSet = CharacterSet()
    var deletingShouldRemoveTrailingCharacters = false

    var valid: Bool {
        return true
    }

    func isValid(replacementString: String) -> Bool {
        let set = inputCharacterSet.union(formattingCharacterSet)
        let rangeOfInvalidChar = replacementString.rangeOfCharacter(from: set)
        return rangeOfInvalidChar?.isEmpty ?? true
    }

    func inputInvalid(textField: UITextField) {
        //TODO: hook for override
        textField.shake()
    }

    func handleDeletionOfFormatting(textField: UITextField, range: NSRange, replacementString string: String) {
        guard let text = textField.text else { return }
        let deletedSingleChar = range.length == 1
        let noTextSelected = textField.selectedTextRange?.isEmpty ?? true
        if (deletedSingleChar && noTextSelected) {
            let range = text.range(fromNSRange: range)
            if text.rangeOfCharacter(from: formattingCharacterSet, options: NSString.CompareOptions(), range: range) != nil {
                textField.text?.removeSubrange(range)
                if let selection = textField.selectedTextRange, let offset = textField.offsetTextRange(selection, by: -1) {
                    textField.selectedTextRange = offset
                }
            }
        }
        if range.length > 0 && deletingShouldRemoveTrailingCharacters {
            if let selectedTextRange = textField.selectedTextRange {
                let offset = textField.offset(from: textField.beginningOfDocument, to: selectedTextRange.end)
                textField.text = textField.text?.substring(to: text.characters.index(text.startIndex, offsetBy: offset))
            }
        }
    }

}

extension FieldProcessor {

    func unformattedText(_ textField: UITextField?) -> String {
        guard let text = textField?.text else { return "" }
        return removeFormatting(text)
    }

    func removeFormatting(_ text: String) -> String {
        return text.filteringWith(characterSet: inputCharacterSet)
    }

    func removeFormatting(_ text: String, cursorPosition: inout Int) -> String {
        return text.filteringWith(characterSet: inputCharacterSet, cursorPosition: &cursorPosition)
    }

}

extension String {

    func filteringWith(characterSet: CharacterSet) -> String {
        return components(separatedBy: characterSet.inverted).joined()
    }

    func filteringWith(characterSet: CharacterSet, cursorPosition: inout Int) -> String {
        let originalCursorPosition = cursorPosition
        var validChars = String()
        for (index, character) in characters.enumerated() {
            if String(character).rangeOfCharacter(from: characterSet) != nil {
                validChars.append(character)
            }
            else if index < originalCursorPosition {
                cursorPosition -= 1
            }
        }
        return validChars
    }

}

extension FieldProcessor: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //if user is inserting text at the end of a valid text field, alert delegate to potentially forward the input
        if range.location == textField.text?.characters.count && string.characters.count > 0 && valid {
            //textField.navigationDelegate?.textField(textField, shouldForwardInput: string)
            return false
        }

        guard isValid(replacementString: string) else {
            inputInvalid(textField: textField)
            return false
        }

        handleDeletionOfFormatting(textField: textField, range: range, replacementString: string)
        return true
    }
}
