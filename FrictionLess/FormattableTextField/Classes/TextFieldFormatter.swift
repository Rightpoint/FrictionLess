//
//  TextFieldFormatter.swift
//  FrictionLess
//
//  Created by Jason Clark on 11/21/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

public protocol TextFieldFormatter {

    /// A character set containing allowed input characters
    var inputCharacterSet: CharacterSet { get }

    /// A character set containing formatting characters (white space, /, etc)
    var formattingCharacterSet: CharacterSet { get }

    /// Set to `true` if deleting should erase all characters trailing the cursor.
    var deletingShouldRemoveTrailingCharacters: Bool { get }

    /**
     Validate text against the formatter.
     Returns `.valid` if the input is valid and complete.

     - Parameter text: The text to be validated.

     - Returns: A `ValidationResult` containing either `.valid` or `.invalid` with a validation error.
     */
    func validate(_ text: String) -> ValidationResult

    /**
     Format an incoming TextField `EditingEvent`. A successful format returns the formatted string and the updated cursor position.

     - Parameter editingEvent: A structure encapsulating the proposed edit and edit range.

     - Returns: A `FormattingResult` containing either
     - the formatted text and the updated cursor position, or
     - a formatting error.
     */
    func format(editingEvent: EditingEvent) -> FormattingResult

    /**
     Whether or not text satifies a "one-and-only" valid state. 
     Used to auto-advance.

     Think: credit card, expiration date, CVV

    - Returns: A Bool indicating if the input is necessarily complete.
    */
    func isComplete(_ text: String) -> Bool
}

// MARK: - Protocol Defaults
public extension TextFieldFormatter {

    var inputCharacterSet: CharacterSet {
        return CharacterSet().inverted
    }

    var formattingCharacterSet: CharacterSet {
        return CharacterSet()
    }

    var deletingShouldRemoveTrailingCharacters: Bool {
        return false
    }

    func validate(_ text: String) -> ValidationResult {
        return .valid
    }

    func format(editingEvent: EditingEvent) -> FormattingResult {
        return .valid(nil)
    }

    func isComplete(_ text: String) -> Bool {
        return false
    }

}

// MARK: - Functionality
public extension TextFieldFormatter {

    /**
        Trim out formatting characters.

        - Returns: A string with all characters removed that aren't included in the formatter's `inputCharacterSet`
    */
    func removeFormatting(_ text: String) -> String {
        return text.filteringWith(characterSet: inputCharacterSet)
    }

    /**
        This method interprets the deletion of a single formatting character as an attempt by the user to delete the content on the other side of the formatting.

        This only applies for deletes where the selectedTextRange length is 0. So if a user explicitly highlights a range containing the formatting character,
        the leading character will remain unchanged.

        - Parameter editingEvent: A structure encapsulating the proposed edit and edit range.

        - Returns: A new `EditingEvent`, which removes in-between formatting characters, allowing for the formatter to carry out the intended edit.
     */
    func handleDeletionOfFormatting(editingEvent: EditingEvent) -> EditingEvent {
        var edit = editingEvent
        let deletesSingleFormattingCharacter = edit.isSingleCharBackspace && edit.deletesCharacterInSet(characterSet: formattingCharacterSet)
        if deletesSingleFormattingCharacter {
            edit.deleteConsecutiveCharactersInSet(characterSet: formattingCharacterSet)
        }
        return edit
    }

    /**
        - Returns: `true` if the input consists only of characters found in the formatter's `inputCharacterSet` or `formattingCharacterSet`
     */
    func containsValidChars(text: String?) -> Bool {
        let allowedSet = inputCharacterSet.union(formattingCharacterSet)
        let rangeOfInvalidChar = text?.rangeOfCharacter(from: allowedSet.inverted)
        guard rangeOfInvalidChar?.isEmpty ?? true else { return false }

        return true
    }

    /**
        If an editing event represents a delete of an input character and `deletingShouldRemoveTrailingCharacters` == true, removes all characters trailing the delete.

        - Returns: an adjusted `EditingEvent`
     */
    func removeCharactersTrailingDelete(textField: UITextField, editingEvent: EditingEvent) -> EditingEvent {
        var edit = editingEvent
        if editingEvent.editRange.length > 0 && editingEvent.deletesCharacterInSet(characterSet: inputCharacterSet) && deletingShouldRemoveTrailingCharacters {
            edit.newValue = String(edit.newValue.characters.prefix(editingEvent.newCursorPosition))
        }
        return edit
    }

}
