//
//  FieldProcessor.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

//MARK: - protocols, structs, enums
protocol FormValidation {
    var valid: Bool { get }
}

enum CharacterNavigation {
    case backspace
    case overflow(String)
}
protocol FormNavigation {
    @discardableResult func fieldProcessor(_ fieldProcessor: FieldProcessor, navigation: CharacterNavigation) -> Bool
}

//MARK: - FieldProcessor
class FieldProcessor: NSObject, FormValidation {

    weak var textField: UITextField? {
        didSet {
            textField?.delegate = self
            NotificationCenter.default.removeObserver(self)
            NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidDeleteBackwardNotification(note:)), name: Notification.Name(rawValue: UITextField.deleteBackwardNotificationName), object:textField)
        }
    }

    var formatter: Formatter

    var navigationDelegate: FormNavigation?

    var valid: Bool {
        return formatter.valid(unformattedText)
    }

    init(formatter: Formatter) {
        self.formatter = formatter
        super.init()
    }

    func inputInvalid(textField: UITextField) {
        //TODO: hook for override
        textField.shake()
    }

}

extension FieldProcessor {

    var unformattedText: String {
        guard let text = textField?.text else { return "" }
        return formatter.removeFormatting(text)
    }

    func containsValidChars(text: String?)->Bool {
        let allowedSet = formatter.inputCharacterSet.union(formatter.formattingCharacterSet)
        let rangeOfInvalidChar = text?.rangeOfCharacter(from: allowedSet.inverted)
        guard rangeOfInvalidChar?.isEmpty ?? true else { return false }

        return true
    }


    /*
     This method interprets the deletion of a single formatting character as an attempt by the user to delete the content on the other side of the formatting.
     */
    func handleDeletionOfFormatting(textField: UITextField, editingEvent: EditingEvent) -> EditingEvent {
        var edit = editingEvent
        let deletedSingleChar = editingEvent.editRange.length == 1
        let noTextSelected = textField.selectedTextRange?.isEmpty ?? true
        if (deletedSingleChar && noTextSelected) {
            let range = editingEvent.oldValue.range(fromNSRange: editingEvent.editRange)
            let deletedSingleFormattingChar = editingEvent.oldValue.rangeOfCharacter(from: formatter.formattingCharacterSet, options: NSString.CompareOptions(), range: range) != nil
            if deletedSingleFormattingChar,
                let deleteRange: Range<String.Index> = {
                    //return a range consisting of the first non-formatting character and all trailing formatting characters up to the cursor.
                    for location in stride(from: edit.editRange.location-1, to: 0, by: -1) {
                        let index = editingEvent.newValue.index(editingEvent.newValue.startIndex, offsetBy: location)
                        let oneChar = editingEvent.newValue.index(after: index)
                        if editingEvent.oldValue.rangeOfCharacter(from: formatter.formattingCharacterSet, options: NSString.CompareOptions(), range: index..<oneChar) == nil {
                            return index..<editingEvent.newValue.index(editingEvent.newValue.startIndex, offsetBy: edit.editRange.location)
                        }
                    }
                    return nil
                }() {

                edit.newCursorPosition = edit.newCursorPosition - edit.newValue.distance(from: deleteRange.lowerBound, to: deleteRange.upperBound)
                edit.newValue.removeSubrange(deleteRange)
            }
        }
        return edit
    }

    func removeCharactersTrailingDelete(textField: UITextField, editingEvent: EditingEvent) -> EditingEvent {
        var edit = editingEvent
        if editingEvent.editRange.length > 0 && formatter.deletingShouldRemoveTrailingCharacters {
            edit.newValue = String(edit.newValue.characters.prefix(editingEvent.newCursorPosition))
        }
        return edit
    }

}


extension FieldProcessor: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard containsValidChars(text: string) else {
            inputInvalid(textField: textField)
            return false
        }
        //if user is inserting text at the end of a valid text field, alert delegate to potentially forward the input
        if range.location == textField.text?.characters.count && string.characters.count > 0 && valid {
            let _ = navigationDelegate?.fieldProcessor(self, navigation: .overflow(string))
            //maybe do something here if we didn't overflow
            return false
        }

        if let indexRange = textField.text?.range(fromNSRange: range) {
            let newText = textField.text?.replacingCharacters(in: indexRange, with: string)
            let newRange = range.location + string.characters.count

            let event = EditingEvent(oldValue: textField.text ?? "",
                                     editRange: range,
                                     editString: string,
                                     newValue: newText ?? "",
                                     newCursorPosition: newRange)

            var adjustedEdit = handleDeletionOfFormatting(textField: textField, editingEvent: event)
            adjustedEdit = removeCharactersTrailingDelete(textField: textField, editingEvent: adjustedEdit)
            adjustedEdit.newValue = formatter.removeFormatting(adjustedEdit.newValue, cursorPosition: &adjustedEdit.newCursorPosition)

            let result =  formatter.validateAndFormat(editingEvent: adjustedEdit)
            if case .valid(let string, let cursorPosition) = result {
                textField.text = string
                textField.selectedTextRange = textField.textRange(cursorOffset: cursorPosition)
                textField.sendActions(for: .editingChanged)
            }
            else {
                inputInvalid(textField: textField)
                return false
            }
        }
        return false
    }

}

extension FieldProcessor {

    @objc func textFieldDidDeleteBackwardNotification(note: NSNotification) {
        if let textField = note.object as? UITextField, textField.text?.characters.count == 0 {
            navigationDelegate?.fieldProcessor(self, navigation: .backspace)
        }
    }

}
