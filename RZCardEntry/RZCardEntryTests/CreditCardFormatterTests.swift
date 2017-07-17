//
//  CreditCardFormatterTests.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/11/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import XCTest
@testable import RZCardEntry

class CreditCardFormatterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRemoveFormatting() {
        let set = CharacterSet.decimalDigits
        var input: String
        var output: String
        var expectedOutput: String
        var cursorPosition: Int
        var expectedCursorPosition: Int

        input = "1234 5678 9098 7654"
        expectedOutput = "1234567890987654"
        cursorPosition = 1  // 1|2
        expectedCursorPosition = 1

        output = input.filteringWith(characterSet: set, index: &cursorPosition)
        XCTAssert(output == expectedOutput)
        XCTAssert(cursorPosition == expectedCursorPosition, "expected cursor position: \(expectedCursorPosition) got \(cursorPosition)")

        cursorPosition = 4  // 4| 5
        expectedCursorPosition = 4
        _ = input.filteringWith(characterSet: set, index: &cursorPosition)
        XCTAssert(cursorPosition == expectedCursorPosition, "expected cursor position: \(expectedCursorPosition) got \(cursorPosition)")

        cursorPosition = 5  // 4 |5
        expectedCursorPosition = 4
        _ = input.filteringWith(characterSet: set, index: &cursorPosition)
        XCTAssert(cursorPosition == expectedCursorPosition, "expected cursor position: \(expectedCursorPosition) got \(cursorPosition)")

        cursorPosition = 9  // 8| 9
        expectedCursorPosition = 8
        _ = input.filteringWith(characterSet: set, index: &cursorPosition)
        XCTAssert(cursorPosition == expectedCursorPosition, "expected cursor position: \(expectedCursorPosition) got \(cursorPosition)")

        cursorPosition = 10  // 8 |9
        expectedCursorPosition = 8
        _ = input.filteringWith(characterSet: set, index: &cursorPosition)
        XCTAssert(cursorPosition == expectedCursorPosition, "expected cursor position: \(expectedCursorPosition) got \(cursorPosition)")

        cursorPosition = 14  // 8| 7
        expectedCursorPosition = 12
        _ = input.filteringWith(characterSet: set, index: &cursorPosition)
        XCTAssert(cursorPosition == expectedCursorPosition, "expected cursor position: \(expectedCursorPosition) got \(cursorPosition)")

        cursorPosition = 15  // 8 |7
        expectedCursorPosition = 12
        _ = input.filteringWith(characterSet: set, index: &cursorPosition)
        XCTAssert(cursorPosition == expectedCursorPosition, "expected cursor position: \(expectedCursorPosition) got \(cursorPosition)")
    }

    func testFormatting() {
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
            let textField = FormattableTextField(formatter: CreditCardFormatter())
            textField.addText(input, initialText: "", initialCursorPosition: 0, selectionLength: 0)
            XCTAssert(textField.text == expectedOutput, "expected \(expectedOutput) got \(textField.text ?? "")")
        }
    }

    func testDeletingContent() {
        //text field needs to be in a view in a window for responder chain to work.
        let textField = FormattableTextField(formatter: CreditCardFormatter())
        textField.addToViewHiearchyAndBecomeFirstResponder()

        var expectedOutpt: String
        var expectedCursorPosition: Int

        //"4321_|", backspace pressed. excpect "432|"
        textField.deleteFromInitialText("4321 ", initialCursorPosition: 5, numToDelete: 1)
        expectedOutpt = "432"
        expectedCursorPosition = 3
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text ?? "")")
        XCTAssert(textField.cursorOffset == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.cursorOffset)")

        //"4321_|5", backspace pressed. excpect "432|5_"
        textField.deleteFromInitialText("4321 5", initialCursorPosition: 5, numToDelete: 1)
        expectedOutpt = "4325 "
        expectedCursorPosition = 3
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text ?? "")")
        XCTAssert(textField.cursorOffset == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.cursorOffset)")

        //"4321_|5678_901", backspace pressed. excpect "432|5_6789_01"
        textField.deleteFromInitialText("4321 5678 901", initialCursorPosition: 5, numToDelete: 1)
        expectedOutpt = "4325 6789 01"
        expectedCursorPosition = 3
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text ?? "")")
        XCTAssert(textField.cursorOffset == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.cursorOffset)")

        //"4444 3333 2222 1|11" , "_1" deleted. Expect "4444 3333 2222 |11"
        textField.deleteFromInitialText("4444 3333 2222 111", initialCursorPosition: 16, numToDelete: 2)
        expectedOutpt = "4444 3333 2222 11"
        expectedCursorPosition = 15
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text ?? "")")
        XCTAssert(textField.cursorOffset == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.cursorOffset)")

        //"4444 3333 2222 1|11" , "2_1" deleted. Expect "4444 3333 222|1 1"
        textField.deleteFromInitialText("4444 3333 2222 111", initialCursorPosition: 16, numToDelete: 3)
        expectedOutpt = "4444 3333 2221 1"
        expectedCursorPosition = 13
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text ?? "")")
        XCTAssert(textField.cursorOffset == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.cursorOffset)")
    }

    func testAddingContent() {
        let textField = FormattableTextField(formatter: CreditCardFormatter())
        textField.addToViewHiearchyAndBecomeFirstResponder()

        var expectedOutpt: String
        var expectedCursorPosition: Int

        //"43|21_", "5" added. excpect "435|2 1"
        textField.addText("5", initialText: "4321 ", initialCursorPosition: 2, selectionLength: 0)
        expectedOutpt = "4352 1"
        expectedCursorPosition = 3
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text ?? "")")
        XCTAssert(textField.cursorOffset == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.cursorOffset)")

        //"432|", "1" added. excpect "4321_|"
        textField.addText("1", initialText: "432", initialCursorPosition: 3, selectionLength: 0)
        expectedOutpt = "4321 "
        expectedCursorPosition = 5
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text ?? "")")
        XCTAssert(textField.cursorOffset == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.cursorOffset)")

        //"4|3", "21" added. Expect "421|3 "
        textField.addText("21", initialText: "43", initialCursorPosition: 1, selectionLength: 0)
        expectedOutpt = "4213 "
        expectedCursorPosition = 3
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text ?? "")")
        XCTAssert(textField.cursorOffset == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.cursorOffset)")

        //"|", "4444333322221111" added. Expect "4444 3333 2222 1111"
        textField.addText("4444333322221111", initialText: "", initialCursorPosition: 0, selectionLength: 0)
        expectedOutpt = "4444 3333 2222 1111"
        expectedCursorPosition = 19
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text ?? "")")
        XCTAssert(textField.cursorOffset == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.cursorOffset)")

        //"|", "1234567890987654321012" added. Expect "|"
        textField.addText("1234567890987654321012", initialText: "", initialCursorPosition: 0, selectionLength: 0)
        expectedOutpt = ""
        expectedCursorPosition = 0
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text ?? "")")
        XCTAssert(textField.cursorOffset == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.cursorOffset)")

        //"1234 56789 0|", "1234567890987654321012" added. Expect "1234 56789 0|"
        textField.addText("1234567890987654321012", initialText: "1234 56789 0", initialCursorPosition: 9, selectionLength: 0)
        expectedOutpt = "1234 56789 0"
        expectedCursorPosition = 9
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text ?? "")")
        XCTAssert(textField.cursorOffset == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.cursorOffset)")

        //"1234 5|6789 0", "1234567890987654321012" added. Expect "1234 56789 0|"
        textField.addText("1234567890987654321012", initialText: "1234 56789 0", initialCursorPosition: 6, selectionLength: 0)
        expectedOutpt = "1234 56789 0"
        expectedCursorPosition = 6
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text ?? "")")
        XCTAssert(textField.cursorOffset == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.cursorOffset)")
    }

    func testInsertingTextWithOtherTextSelected() {
        let textField = FormattableTextField(formatter: CreditCardFormatter())
        textField.addToViewHiearchyAndBecomeFirstResponder()

        var expectedOutpt: String
        var expectedCursorPosition: Int

        //"43|21_|", "9999" added. excpect "4399 99|"
        textField.addText("9999", initialText: "4321 ", initialCursorPosition: 2, selectionLength: 3)
        expectedOutpt = "4399 99"
        expectedCursorPosition = 7
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text ?? "")")
        XCTAssert(textField.cursorOffset == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.cursorOffset)")

        //"|4444 3333 2222 1111|", "378282246310005" added. excpect "3782 822463 10005|"
        textField.addText("3782 822463 10005", initialText: "4444 3333 2222 1111", initialCursorPosition: 0, selectionLength: 19)
        expectedOutpt = "3782 822463 10005"
        expectedCursorPosition = 17
        XCTAssert(textField.text == expectedOutpt, "expected \(expectedOutpt) got \(textField.text ?? "")")
        XCTAssert(textField.cursorOffset == expectedCursorPosition, "expected \(expectedCursorPosition) got \(textField.cursorOffset)")
    }

}

// MARK: - Support Functions

extension CreditCardFormatterTests {

    func testInsertSpaces(_ groupings: [Int], input: String, cursorPosition: Int, expectedOutput: String, expectedOutputCursorPosition: Int, file: StaticString = #file, line: UInt = #line) {
        let output = input.inserting(" ", formingGroupings: groupings)
        let outputCursor = input.position(ofCursorLocation: cursorPosition, inOtherString: output)

        guard output == expectedOutput else {
            XCTFail("expected \(expectedOutput) got \(output)", file: file, line: line)
            return
        }
        guard outputCursor == expectedOutputCursorPosition else {
            XCTFail("expected cursor position \(expectedOutputCursorPosition) got \(outputCursor)", file: file, line: line)
            return
        }
    }

}
