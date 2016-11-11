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
extension UITextField {

    func addText(_ textToAdd: String, initialText: String, initialCursorPosition: Int, selectionLength: Int) {
        //set original state
        text = initialText
        selectedTextRange = textRangeForCursorPosition(initialCursorPosition, length: selectionLength)

        //simulate adding text
        let _ = delegate?.textField?(self, shouldChangeCharactersIn: NSMakeRange(initialCursorPosition, selectionLength), replacementString: textToAdd)
    }

    func deleteFromInitialText(_ initialText: String, initialCursorPosition: Int, numToDelete: Int) {
        text = initialText
        selectedTextRange = textRangeForCursorPosition(initialCursorPosition - (numToDelete - 1), length: (numToDelete - 1))
        let deleteRange = NSMakeRange(initialCursorPosition-numToDelete, numToDelete)
        let _ = delegate?.textField?(self, shouldChangeCharactersIn: deleteRange, replacementString: "")
    }

    func textRangeForCursorPosition(_ cursorPosition:Int, length: Int) -> UITextRange? {
        guard let startPosition = position(from: beginningOfDocument, offset: cursorPosition),
            let endPosition = position(from: beginningOfDocument, offset: cursorPosition + length) else {
                return nil
        }
        return textRange(from: startPosition, to: endPosition)
    }

    func addToViewHiearchyAndBecomeFirstResponder() {
        let window = UIWindow()
        let view = UIView()
        window.addSubview(view)
        view.addSubview(self)
        becomeFirstResponder()
    }
    
}
