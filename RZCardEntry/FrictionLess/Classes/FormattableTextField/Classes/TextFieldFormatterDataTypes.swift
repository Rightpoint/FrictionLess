//
//  TextFieldFormatterDataTypes.swift
//  Raizlabs
//
//  Created by Jason Clark on 3/29/17.
//
//

import Foundation

/**
 A structure representing a `UITextField` editing event.
 */
public struct EditingEvent {
    /// The textField `text` prior to the editing event.
    var oldValue: String

    /// The `NSRange` of the text to be replaced.
    var editRange: NSRange

    /// The `NSRange` of the selected text prior to edit
    var selectedTextRange: NSRange?

    /// The new text to be replaced at `editRange`.
    var editString: String

    /// The text that would result if editString was inserted at editRange.
    var newValue: String

    /// The location of the cursor if editString was inserted at editRange.
    var newCursorPosition: Int
}

public extension EditingEvent {

    /// `true` if this editing event representes a deletion of text
    var isDelete: Bool {
        return editRange.length > 0 && editString.isEmpty
    }

    /// `true` if this editing event representes a backspace of exactly 1 character
    var isSingleCharBackspace: Bool {
        return editRange.length == 1 && editString.isEmpty && (selectedTextRange?.length == 0)
    }

    /**
     - Returns: true if edit event includes a deletion of a character in `characterSet`
     */
    func deletesCharacterInSet(characterSet: CharacterSet) -> Bool {
        let range = oldValue.range(fromNSRange: editRange)
        return oldValue.rangeOfCharacter(from: characterSet, options: NSString.CompareOptions(), range: range) != nil
    }

    /**
     - deletes consecutive characters of a CharacterSet preceeding the cursor.
     */
    mutating func deleteConsecutiveCharactersInSet(characterSet: CharacterSet) {
        // a range consisting of consecutive characters in a CharacterSet preceeding the cursor.
        if let deleteRange: Range<String.Index> = {
            for location in stride(from: editRange.location-1, through: 0, by: -1) {
                let index = newValue.index(newValue.startIndex, offsetBy: location)
                let oneChar = newValue.index(after: index)
                if oldValue.rangeOfCharacter(from: characterSet, options: NSString.CompareOptions(), range: index..<oneChar) == nil {
                    return index..<newValue.index(newValue.startIndex, offsetBy: editRange.location)
                }
            }
            return nil
            }() {
            let deleteLength = newValue.distance(from: deleteRange.lowerBound, to: deleteRange.upperBound)
            editRange.length = deleteLength
            editRange.location -= deleteLength
            newCursorPosition -= deleteLength
            newValue.removeSubrange(deleteRange)
        }
    }

    func cursorPosition(inFormattedText text: String, withinSet characterSet: CharacterSet) -> Int {
        if let fingerpint = newValue.fingerprint(ofCursorPosition: newCursorPosition, characterSet: characterSet), let position = text.position(ofCursorFingerprint: fingerpint) {
            return position
        }
        else {
            return text.characters.count
        }
    }

}

/**
 The result of formatting in response to an `EditingEvent`.
 */
public enum FormattingResult {
    case valid(Reformatting?)
    case invalid(formattingError: Error)
}

public enum Reformatting {
    case text(String)
    case textAndCursor(String, Int)
}

/**
 The result of validating a `String` against a `TextFieldFormatter`.
 */
public enum ValidationResult {
    case valid
    case invalid(validationError: Error)
}

public func == (lhs: ValidationResult, rhs: ValidationResult) -> Bool {
    switch (lhs, rhs) {
    case (.valid, .valid): return true
    case (.invalid(_), .invalid(_)): return true
    default: return false
    }
}
