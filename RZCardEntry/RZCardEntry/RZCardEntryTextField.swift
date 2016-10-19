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
    var cardType: CardType = .Indeterminate

    override init(frame: CGRect) {
        super.init(frame: frame)

        delegate = internalDelegate
        addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        placeholder = "0000 0000 0000 0000"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func removeCharactersNotContainedInSet(characterSet: NSCharacterSet, text: String) -> String {
        var ignoredCursor = 0
        return removeCharactersNotContainedInSet(characterSet, text: text, cursorPosition: &ignoredCursor)
    }

    static func removeCharactersNotContainedInSet(characterSet: NSCharacterSet, text: String, inout cursorPosition: Int) -> String {
        let originalCursorPosition = cursorPosition
        var validChars = String()
        for (index, character) in text.characters.enumerate() {
            if String(character).rangeOfCharacterFromSet(characterSet) != nil {
                validChars.append(character)
            }
            else if index < originalCursorPosition {
                cursorPosition -= 1
            }
        }

        return validChars
    }

    @objc func textFieldDidChange(textField: UITextField) {
        cardEntryDelegate?.cardEntryTextFieldDidChange(self)
    }

    func replacementStringIsValid(replacementString: String) -> Bool {
        let set = inputCharacterSet.mutableCopy()
        set.formUnionWithCharacterSet(formattingCharacterSet)
        let rangeOfInvalidChar = replacementString.rangeOfCharacterFromSet(set.invertedSet)
        return rangeOfInvalidChar?.isEmpty ?? true
    }

    var formattingCharacterSet: NSCharacterSet {
        return NSCharacterSet()
    }

    var inputCharacterSet: NSCharacterSet {
        return NSCharacterSet.alphanumericCharacterSet()
    }

    var isValid: Bool {
        return false
    }

    var deletingShouldRemoveTrailingCharacters: Bool {
        return false
    }

    func willChangeCharactersInRange(range: NSRange, replacementString string: String) {
        guard let text = text else { return }
        let deletedSingleChar = range.length == 1
        let noTextSelected = selectedTextRange?.empty ?? true
        if (deletedSingleChar && noTextSelected){
            let range = text.startIndex.advancedBy(range.location)..<text.startIndex.advancedBy(range.location + range.length)
            if text.rangeOfCharacterFromSet(formattingCharacterSet, options: NSStringCompareOptions(), range: range) != nil {
                self.text?.removeRange(range)
                if let previousSelection = previousSelection, startPosition = positionFromPosition(previousSelection.start, offset: -1), endPosition = positionFromPosition(previousSelection.end, offset: -1) {
                    selectedTextRange = textRangeFromPosition(startPosition, toPosition: endPosition)
                }
            }
        }
        if range.length > 0 && deletingShouldRemoveTrailingCharacters {
            if let selectedTextRange = selectedTextRange {
                let offset = offsetFromPosition(self.beginningOfDocument, toPosition: selectedTextRange.end)
                self.text = self.text?.substringToIndex(text.startIndex.advancedBy(offset))
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
        layer.removeAnimationForKey(animationKey)

        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.3
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0 ]
        layer.addAnimation(animation, forKey: animationKey)
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

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
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