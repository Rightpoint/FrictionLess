//
//  RZFormattableTextFieldTestHelpers.swift
//  RZCardEntry
//
//  Created by Jason Clark on 9/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import XCTest
@testable import RZCardEntry

//MARK:- Helper Methods
extension RZFormattableTextField {

    func addText(_ textToAdd: String, initialText: String, initialCursorPosition: Int, selectionLength: Int) {
        //set original state
        text = initialText
        selectedTextRange = textRangeForCursorPosition(initialCursorPosition, length: selectionLength)

        //simulate adding text
        let _ = delegate?.textField?(self, shouldChangeCharactersIn: NSMakeRange(initialCursorPosition, selectionLength), replacementString: textToAdd)
        let range = initialText.characters.index(initialText.startIndex, offsetBy: initialCursorPosition)..<initialText.characters.index(initialText.startIndex, offsetBy: initialCursorPosition+selectionLength)
        text = text?.replacingCharacters(in: range, with: textToAdd)
        selectedTextRange = textRangeForCursorPosition(initialCursorPosition + textToAdd.characters.count, length: 0)

        //simulate delegate callback
        textFieldDidChange(self)
    }

    func deleteFromInitialText(_ initialText: String, initialCursorPosition: Int, numToDelete: Int) {
        text = initialText
        selectedTextRange = textRangeForCursorPosition(initialCursorPosition - (numToDelete - 1), length: (numToDelete - 1))
        var deleteRange = NSMakeRange(initialCursorPosition-numToDelete, numToDelete)
        let _ = delegate?.textField?(self, shouldChangeCharactersIn: deleteRange, replacementString: "")

        if text != initialText {
            //in the case of deleting a single formatting char, the delegate will delete that for us, so deleting 1 char turns to deleting 2
            deleteRange = NSMakeRange(initialCursorPosition - numToDelete - 1, 1)
        }

        let range = initialText.characters.index(initialText.startIndex, offsetBy: deleteRange.location)..<initialText.characters.index(initialText.startIndex, offsetBy: deleteRange.location + deleteRange.length)
        text = initialText.replacingCharacters(in: range, with: "")
        selectedTextRange = textRangeForCursorPosition(initialCursorPosition - numToDelete, length: 0)
        textFieldDidChange(self)
    }

    func textRangeForCursorPosition(_ cursorPosition:Int, length: Int) -> UITextRange? {
        guard let startPosition = position(from: beginningOfDocument, offset: cursorPosition),
            let endPosition = position(from: beginningOfDocument, offset: cursorPosition + length) else {
                return nil
        }
        return textRange(from: startPosition, to: endPosition)
    }

    var currentCursorPosition: Int {
        return offset(from: beginningOfDocument, to: selectedTextRange!.start)
    }

    func addToViewHiearchyAndBecomeFirstResponder() {
        let window = UIWindow()
        let view = UIView()
        window.addSubview(view)
        view.addSubview(self)
        becomeFirstResponder()
    }
    
}
