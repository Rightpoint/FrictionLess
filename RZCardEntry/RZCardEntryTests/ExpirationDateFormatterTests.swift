//
//  ExpirationDateFormatterTests.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/11/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import XCTest
@testable import RZCardEntry

class ExpirationDateFormatterTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testRemoveFormatting() {
        let set = CharacterSet.decimalDigits
        var input: String
        var output: String
        var expectedOutput: String
        var cursorPosition: Int
        var expectedCursorPosition: Int

        input = "03/20"
        expectedOutput = "0320"
        cursorPosition = 0  // |03/20
        expectedCursorPosition = 0

        output = input.filteringWith(characterSet:set)
        cursorPosition = input.position(ofCursorLocation: cursorPosition, in: output, within: set)
        XCTAssert(output == expectedOutput)
        XCTAssert(cursorPosition == expectedCursorPosition, "expected cursor position: \(expectedCursorPosition) got \(cursorPosition)")

        cursorPosition = 1  // 0|3/20
        expectedCursorPosition = 1
        _ = input.filteringWith(characterSet:set)
        cursorPosition = input.position(ofCursorLocation: cursorPosition, in: output, within: set)
        XCTAssert(cursorPosition == expectedCursorPosition, "expected cursor position: \(expectedCursorPosition) got \(cursorPosition)")

        cursorPosition = 3  //03/|20
        expectedCursorPosition = 2
        _ = input.filteringWith(characterSet:set)
        cursorPosition = input.position(ofCursorLocation: cursorPosition, in: output, within: set)
        XCTAssert(cursorPosition == expectedCursorPosition, "expected cursor position: \(expectedCursorPosition) got \(cursorPosition)")

        cursorPosition = 5  //03/20|
        expectedCursorPosition = 4
        _ = input.filteringWith(characterSet:set)
        cursorPosition = input.position(ofCursorLocation: cursorPosition, in: output, within: set)
        XCTAssert(cursorPosition == expectedCursorPosition, "expected cursor position: \(expectedCursorPosition) got \(cursorPosition)")
    }

    func testInsertFormatting() {
        var input: String
        var expectedOutput: String
        var expectedCursorPosition: Int
        let textField = FormattableTextField(formatter: ExpirationDateFormatter())
        textField.addToViewHiearchyAndBecomeFirstResponder()

        //leading with 1 could be Jan, Oct, Nov, Dec. Do not format
        input = "1"
        expectedOutput = "1"
        textField.addText(input, initialText: "", initialCursorPosition: 0, selectionLength: 0)
        XCTAssert(textField.text == expectedOutput, "expected \(expectedOutput) got \(textField.text ?? "")")

        //leading with 2 must be Feb, change to 02 and add slash
        input = "2"
        expectedOutput = "02/"
        textField.addText(input, initialText: "", initialCursorPosition: 0, selectionLength: 0)
        XCTAssert(textField.text == expectedOutput, "expected \(expectedOutput) got \(textField.text ?? "")")
        expectedCursorPosition = 3
        XCTAssert(textField.cursorOffset == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.cursorOffset)")

        //leading with 0 is someone following instructions, do not format
        input = "0"
        expectedOutput = "0"
        textField.addText(input, initialText: "", initialCursorPosition: 0, selectionLength: 0)
        XCTAssert(textField.text == expectedOutput, "expected \(expectedOutput) got \(textField.text ?? "")")

        //if someone inputs a slash after a 1, pad the 0
        let initialText = "1"
        let initialCursor = 1
        input = "/"
        expectedOutput = "01/"
        textField.addText(input, initialText: initialText, initialCursorPosition: initialCursor, selectionLength: 0)
        XCTAssert(textField.text == expectedOutput, "expected \(expectedOutput) got \(textField.text ?? "")")

        //add a slash for valid 2 digit months
        input = "10"
        expectedOutput = "10/"
        textField.addText(input, initialText: "", initialCursorPosition: 0, selectionLength: 0)
        XCTAssert(textField.text == expectedOutput, "expected \(expectedOutput) got \(textField.text ?? "")")
        expectedCursorPosition = 3
        XCTAssert(textField.cursorOffset == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.cursorOffset)")

        //if input carries over max, reject
        input = "12/345"
        expectedOutput = ""
        textField.addText(input, initialText: "", initialCursorPosition: 0, selectionLength: 0)
        XCTAssert(textField.text == expectedOutput, "expected \(expectedOutput) got \(textField.text ?? "")")
    }

}
