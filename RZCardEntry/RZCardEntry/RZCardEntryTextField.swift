//
//  RZCardEntryTextField.swift
//  RZCardEntry
//
//  Created by Jason Clark on 9/21/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

class RZCardEntryTextField: UITextField {

    var cardEntryDelegate: RZCardEntryDelegateProtocol?
    let internalDelegate = RZCardEntryTextFieldDelegate()
    var previousText: String?
    var previousSelection: UITextRange?
    var cardType: CardType = .indeterminate

    override init(frame: CGRect) {
        super.init(frame: frame)

        delegate = internalDelegate
        addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        placeholder = "0000 0000 0000 0000"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func removeCharactersNotContainedInSet(_ characterSet: CharacterSet, text: String) -> String {
        var ignoredCursor = 0
        return removeCharactersNotContainedInSet(characterSet, text: text, cursorPosition: &ignoredCursor)
    }

    static func removeCharactersNotContainedInSet(_ characterSet: CharacterSet, text: String, cursorPosition: inout Int) -> String {
        let originalCursorPosition = cursorPosition
        var validChars = String()
        for (index, character) in text.characters.enumerated() {
            if String(character).rangeOfCharacter(from: characterSet) != nil {
                validChars.append(character)
            }
            else if index < originalCursorPosition {
                cursorPosition -= 1
            }
        }

        return validChars
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        cardEntryDelegate?.cardEntryTextFieldDidChange(self)
    }

    func replacementStringIsValid(_ replacementString: String) -> Bool {
        let set = (inputCharacterSet as NSCharacterSet).mutableCopy()
        (set as AnyObject).formUnion(with: formattingCharacterSet)
        let rangeOfInvalidChar = replacementString.rangeOfCharacter(from: (set as AnyObject).inverted)
        return rangeOfInvalidChar?.isEmpty ?? true
    }

    var formattingCharacterSet: CharacterSet {
        return CharacterSet()
    }

    var inputCharacterSet: CharacterSet {
        return CharacterSet.alphanumerics
    }

    var isValid: Bool {
        return false
    }

    var deletingShouldRemoveTrailingCharacters: Bool {
        return false
    }

    func willChangeCharactersInRange(_ range: NSRange, replacementString string: String) {
        guard let text = text else { return }
        let deletedSingleChar = range.length == 1
        let noTextSelected = selectedTextRange?.isEmpty ?? true
        if (deletedSingleChar && noTextSelected){
            let range = text.characters.index(text.startIndex, offsetBy: range.location)..<text.characters.index(text.startIndex, offsetBy: range.location + range.length)
            if text.rangeOfCharacter(from: formattingCharacterSet, options: NSString.CompareOptions(), range: range) != nil {
                self.text?.removeSubrange(range)
                if let previousSelection = previousSelection, let startPosition = position(from: previousSelection.start, offset: -1), let endPosition = position(from: previousSelection.end, offset: -1) {
                    selectedTextRange = textRange(from: startPosition, to: endPosition)
                }
            }
        }
        if range.length > 0 && deletingShouldRemoveTrailingCharacters {
            if let selectedTextRange = selectedTextRange {
                let offset = self.offset(from: self.beginningOfDocument, to: selectedTextRange.end)
                self.text = self.text?.substring(to: text.characters.index(text.startIndex, offsetBy: offset))
            }
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
        let animationKey = "shake"
        layer.removeAnimation(forKey: animationKey)

        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.3
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0 ]
        layer.add(animation, forKey: animationKey)
    }

    override func deleteBackward() {
        if text?.characters.count == 0 {
            //if delete is pressed in an empty textfield, interpret this as a navigation to previous field
            cardEntryDelegate?.cardEntryTextFieldBackspacePressedWithoutContent(self)
        }
        super.deleteBackward()
    }

}

final class RZCardEntryTextFieldDelegate: NSObject, UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textField = textField as? RZCardEntryTextField else { return true }

        //if user is inserting text at the end of a valid text field, alert delegate to potentially forward the input
        if range.location == textField.text?.characters.count && string.characters.count > 0 && textField.isValid {
            textField.cardEntryDelegate?.cardEntryTextField(textField, shouldForwardInput: string)
            return false
        }

        guard textField.replacementStringIsValid(string) else {
            textField.notifiyOfInvalidInput()
            return false
        }

        textField.previousText = textField.text
        textField.previousSelection = textField.selectedTextRange
        textField.willChangeCharactersInRange(range, replacementString: string)
        return true
    }
}
