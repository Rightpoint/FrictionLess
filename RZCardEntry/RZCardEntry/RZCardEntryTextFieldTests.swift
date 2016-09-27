//
//  RZCardEntryTextFieldTests.swift
//  RZCardEntry
//
//  Created by Jason Clark on 9/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import XCTest
@testable import RZCardEntry

class RZCardEntryTextFieldTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

}

//MARK:- Helper Methods

extension RZCardEntryTextField {

    func addText(textToAdd: String, initialText: String, initialCursorPosition: Int, selectionLength: Int) {
        //set original state
        text = initialText
        selectedTextRange = textRangeForCursorPosition(initialCursorPosition, length: selectionLength)

        //simulate adding text
        delegate?.textField?(self, shouldChangeCharactersInRange: NSMakeRange(initialCursorPosition, selectionLength), replacementString: textToAdd)
        let range = initialText.startIndex.advancedBy(initialCursorPosition)..<initialText.startIndex.advancedBy(initialCursorPosition+selectionLength)
        text = initialText.stringByReplacingCharactersInRange(range, withString: textToAdd)
        selectedTextRange = textRangeForCursorPosition(initialCursorPosition + textToAdd.characters.count, length: 0)

        //simulate delegate callback
        textFieldDidChange(self)
    }

    func deleteFromInitialText(initialText: String, initialCursorPosition: Int, numToDelete: Int) {
        text = initialText
        selectedTextRange = textRangeForCursorPosition(initialCursorPosition - (numToDelete - 1), length: (numToDelete - 1))
        var deleteRange = NSMakeRange(initialCursorPosition-numToDelete, numToDelete)
        delegate?.textField?(self, shouldChangeCharactersInRange: deleteRange, replacementString: "")

        if text != initialText {
            //in the case of deleting a single formatting char, the delegate will delete that for us, so deleting 1 char turns to deleting 2
            deleteRange = NSMakeRange(initialCursorPosition - numToDelete - 1, 1)
        }

        let range = initialText.startIndex.advancedBy(deleteRange.location)..<initialText.startIndex.advancedBy(deleteRange.location + deleteRange.length)
        text = initialText.stringByReplacingCharactersInRange(range, withString: "")
        selectedTextRange = textRangeForCursorPosition(initialCursorPosition - numToDelete, length: 0)
        textFieldDidChange(self)
    }

    func textRangeForCursorPosition(cursorPosition:Int, length: Int) -> UITextRange? {
        guard let startPosition = positionFromPosition(beginningOfDocument, offset: cursorPosition),
            endPosition = positionFromPosition(beginningOfDocument, offset: cursorPosition + length) else {
                return nil
        }
        return textRangeFromPosition(startPosition, toPosition: endPosition)
    }

    var currentCursorPosition: Int {
        return offsetFromPosition(beginningOfDocument, toPosition: selectedTextRange!.start)
    }

    func addToViewHiearchyAndBecomeFirstResponder() {
        let window = UIWindow()
        let view = UIView()
        window.addSubview(view)
        view.addSubview(self)
        becomeFirstResponder()
    }
    
}
