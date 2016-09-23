//
//  RZCardNumberTextFieldTests.swift
//  RZCardEntry
//
//  Created by Jason Clark on 9/22/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import XCTest
@testable import RZCardEntry

class RZCardNumberTextFieldTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRemoveNonDigitsAndPreseverCursorPosition() {
        var input: String
        var output: String
        var expectedOutput: String
        var cursorPosition: Int
        var expectedCursorPosition: Int

        input = "1234 5678 9098 7654"
        expectedOutput = "1234567890987654"
        cursorPosition = 1  // 1|2
        expectedCursorPosition = 1

        output = RZCardEntryTextField.removeNonDigits(input, cursorPosition: &cursorPosition)
        XCTAssert(output == expectedOutput)
        XCTAssert(cursorPosition == expectedCursorPosition, "expected cursor position: \(expectedCursorPosition) got \(cursorPosition)")

        cursorPosition = 4  // 4| 5
        expectedCursorPosition = 4
        RZCardEntryTextField.removeNonDigits(input, cursorPosition: &cursorPosition)
        XCTAssert(cursorPosition == expectedCursorPosition, "expected cursor position: \(expectedCursorPosition) got \(cursorPosition)")

        cursorPosition = 5  // 4 |5
        expectedCursorPosition = 4
        RZCardEntryTextField.removeNonDigits(input, cursorPosition: &cursorPosition)
        XCTAssert(cursorPosition == expectedCursorPosition, "expected cursor position: \(expectedCursorPosition) got \(cursorPosition)")

        cursorPosition = 9  // 8| 9
        expectedCursorPosition = 8
        RZCardEntryTextField.removeNonDigits(input, cursorPosition: &cursorPosition)
        XCTAssert(cursorPosition == expectedCursorPosition, "expected cursor position: \(expectedCursorPosition) got \(cursorPosition)")

        cursorPosition = 10  // 8 |9
        expectedCursorPosition = 8
        RZCardEntryTextField.removeNonDigits(input, cursorPosition: &cursorPosition)
        XCTAssert(cursorPosition == expectedCursorPosition, "expected cursor position: \(expectedCursorPosition) got \(cursorPosition)")

        cursorPosition = 14  // 8| 7
        expectedCursorPosition = 12
        RZCardEntryTextField.removeNonDigits(input, cursorPosition: &cursorPosition)
        XCTAssert(cursorPosition == expectedCursorPosition, "expected cursor position: \(expectedCursorPosition) got \(cursorPosition)")

        cursorPosition = 15  // 8 |7
        expectedCursorPosition = 12
        RZCardEntryTextField.removeNonDigits(input, cursorPosition: &cursorPosition)
        XCTAssert(cursorPosition == expectedCursorPosition, "expected cursor position: \(expectedCursorPosition) got \(cursorPosition)")
    }

    func testInsertSpaces() {
        //test visa spaces
        var groupings = [4,4,4,4] //visa/mastercard/discover: 4444 3333 2222 1111
        testInsertSpaces(groupings, input: "123", cursorPosition: 3, expectedOutput: "123", expectedOutputCursorPosition: 3)
        testInsertSpaces(groupings, input: "1234", cursorPosition: 4, expectedOutput: "1234 ", expectedOutputCursorPosition: 5)
        testInsertSpaces(groupings, input: "12345", cursorPosition: 5, expectedOutput: "1234 5", expectedOutputCursorPosition: 6)
        testInsertSpaces(groupings, input: "12345678", cursorPosition: 8, expectedOutput: "1234 5678 ", expectedOutputCursorPosition: 10)
        testInsertSpaces(groupings, input: "123456789098", cursorPosition: 12, expectedOutput: "1234 5678 9098 ", expectedOutputCursorPosition: 15)
        testInsertSpaces(groupings, input: "1234567890987654", cursorPosition: 16, expectedOutput: "1234 5678 9098 7654", expectedOutputCursorPosition: 19)

        groupings = [4, 6, 5] //amex
        testInsertSpaces(groupings, input: "123", cursorPosition: 3, expectedOutput: "123", expectedOutputCursorPosition: 3)
        testInsertSpaces(groupings, input: "1234", cursorPosition: 4, expectedOutput: "1234 ", expectedOutputCursorPosition: 5)
        testInsertSpaces(groupings, input: "123456789", cursorPosition: 9, expectedOutput: "1234 56789", expectedOutputCursorPosition: 10)
        testInsertSpaces(groupings, input: "1234567890", cursorPosition: 10, expectedOutput: "1234 567890 ", expectedOutputCursorPosition: 12)
        testInsertSpaces(groupings, input: "123456789098765", cursorPosition: 14, expectedOutput: "1234 567890 98765", expectedOutputCursorPosition: 16)

        groupings = [4, 6, 4] //diners
        testInsertSpaces(groupings, input: "123", cursorPosition: 3, expectedOutput: "123", expectedOutputCursorPosition: 3)
        testInsertSpaces(groupings, input: "1234", cursorPosition: 4, expectedOutput: "1234 ", expectedOutputCursorPosition: 5)
        testInsertSpaces(groupings, input: "123456789", cursorPosition: 9, expectedOutput: "1234 56789", expectedOutputCursorPosition: 10)
        testInsertSpaces(groupings, input: "1234567890", cursorPosition: 10, expectedOutput: "1234 567890 ", expectedOutputCursorPosition: 12)
        testInsertSpaces(groupings, input: "12345678909876", cursorPosition: 13, expectedOutput: "1234 567890 9876", expectedOutputCursorPosition: 15)
    }

    func testCardtypeFormatting() {
        //  (input, expectedOutput)
        let visa = ("4444333322221111", "4444 3333 2222 1111")
        let amex = ("378282246310005", "3782 822463 10005")
        let discover = ("6011111111111117", "6011 1111 1111 1117")
        let masterCard = ("5555555555554444", "5555 5555 5555 4444")
        let diners = ("38520000023237", "3852 000002 3237")

        [visa, amex, discover, masterCard, diners].forEach { input, expectedOutput in
            let textField = RZCardNumberTextField()
            textField.addText(input, initialText: "", initialCursorPosition: 0, selectionLength: 0)
            XCTAssert(textField.text == expectedOutput, "expected \(expectedOutput) got \(textField.text)")
        }
    }

    func testDeletingContent() {
        //text field needs to be in a view in a window for responder chain to work.
        let textField = RZCardNumberTextField()
        textField.addToViewHiearchyAndBecomeFirstResponder()

        var expectedOutpt: String
        var expectedCursorPosition: Int

        //"1234_|", backspace pressed. excpect "123|"
        textField.deleteFromInitialText("1234 ", initialCursorPosition: 5, numToDelete: 1)
        expectedOutpt = "123"
        expectedCursorPosition = 3
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text)")
        XCTAssert(textField.currentCursorPosition == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.currentCursorPosition)")

        //"1234_|5", backspace pressed. excpect "123|5_"
        textField.deleteFromInitialText("1234 5", initialCursorPosition: 5, numToDelete: 1)
        expectedOutpt = "1235 "
        expectedCursorPosition = 3
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text)")
        XCTAssert(textField.currentCursorPosition == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.currentCursorPosition)")

        //"4444 3333 2222 1|11" , "_1" deleted. Expect "4444 3333 2222 |11"
        textField.deleteFromInitialText("4444 3333 2222 111", initialCursorPosition: 16, numToDelete: 2)
        expectedOutpt = "4444 3333 2222 11"
        expectedCursorPosition = 15
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text)")
        XCTAssert(textField.currentCursorPosition == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.currentCursorPosition)")

        //"4444 3333 2222 1|11" , "2_1" deleted. Expect "4444 3333 222|1 1"
        textField.deleteFromInitialText("4444 3333 2222 111", initialCursorPosition: 16, numToDelete: 3)
        expectedOutpt = "4444 3333 2221 1"
        expectedCursorPosition = 13
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text)")
        XCTAssert(textField.currentCursorPosition == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.currentCursorPosition)")
    }

    func testAddingContent() {
        let textField = RZCardNumberTextField()
        textField.addToViewHiearchyAndBecomeFirstResponder()

        var expectedOutpt: String
        var expectedCursorPosition: Int

        //"12|34_", "5" added. excpect "125|3 4"
        textField.deleteFromInitialText("1234 ", initialCursorPosition: 5, numToDelete: 1)
        expectedOutpt = "123"
        expectedCursorPosition = 3
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text)")
        XCTAssert(textField.currentCursorPosition == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.currentCursorPosition)")
    }

}

//MARK: - Support Functions
extension RZCardNumberTextFieldTests {

    func testInsertSpaces(groupings: [Int], input: String, cursorPosition: Int, expectedOutput: String, expectedOutputCursorPosition: Int) {
        var cursorPos = cursorPosition
        let output = RZCardNumberTextField.insertSpacesIntoString(input, cursorPosition: &cursorPos, groupings: groupings)
        XCTAssert(output == expectedOutput, "expected \(expectedOutput) got \(output)")
        XCTAssert(cursorPos == expectedOutputCursorPosition, "expected cursor position \(expectedOutputCursorPosition) got \(cursorPos)")
    }

}

extension RZCardNumberTextField {

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
