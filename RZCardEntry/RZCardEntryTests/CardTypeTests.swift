//
//  CardTypeTests.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/21/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import XCTest
@testable import RZCardEntry

class CardTypeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

//MARK: - Amex
    func testAmex() {
        let amex: CardType = .amex

        XCTAssert(amex.cvvLength == 4, "expected CVV length of 4, got \(amex.cvvLength))")

        let testPrefixes = ["3", "34", "37", "345", "376"]
        testPrefixes.forEach {
            XCTAssert(amex.prefixValid($0) == true, "\($0) should be a valid prefix")
        }

        let invalidPrefixes = ["4", "35", "38"]
        invalidPrefixes.forEach {
            XCTAssert(amex.prefixValid($0) == false, "\($0) is not a valid amex prefix")
        }

        let testNumbers = ["378282246310005",
                           "371449635398431",
                           "378734493671000"
                           ]

        testNumbers.forEach {
            XCTAssert(amex.prefixValid($0) == true, "\($0) should be a valid prefix")
            XCTAssert(amex.valid($0) == true, "\($0) should be valid")
        }

        let failsLuhn = "378282246310006"
        XCTAssert(amex.prefixValid(failsLuhn) == true, "invalid amex should still match amex prefix")
        XCTAssert(amex.valid(failsLuhn) == false, "invalid amex should fail luhn check")

    }

//MARK: - Diners
    func testDiners() {
        let diners: CardType = .diners

        XCTAssert(diners.cvvLength == 3, "expected CVV length of 3, got \(diners.cvvLength))")

        let testPrefixes = ["3", "30", "38", "39", "36",
                            "300", "301", "302", "303", "304", "305",
                            "309", "3020", "3099"]
        testPrefixes.forEach {
            XCTAssert(diners.prefixValid($0) == true, "\($0) should be a valid prefix")
        }

        let invalidPrefixes = ["4", "31", "306"]
        invalidPrefixes.forEach {
            XCTAssert(diners.prefixValid($0) == false, "\($0) is not a valid diners prefix")
        }

        let testNumbers = ["30569309025904",
                           "38520000023237"]

        testNumbers.forEach {
            XCTAssert(diners.prefixValid($0) == true, "\($0) should be a valid prefix")
            XCTAssert(diners.valid($0) == true, "\($0) should be valid")
        }

        let failsLuhn = "30569309025905"
        XCTAssert(diners.prefixValid(failsLuhn) == true, "invalid diners should still match diners prefix")
        XCTAssert(diners.valid(failsLuhn) == false, "invalid diners should fail luhn check")
        
    }

//MARK: - Discover
    func testDiscover() {
        let discover: CardType = .discover

        XCTAssert(discover.cvvLength == 3, "expected CVV length of 3, got \(discover.cvvLength))")

        let testPrefixes = ["6", "60", "601", "6011", "65", "655", "60112",
                            "64", "644","645","646","647","648","649",
                            "622126", "622925", "62", "622", "6223"]
        testPrefixes.forEach {
            XCTAssert(discover.prefixValid($0) == true, "\($0) should be a valid prefix")
        }

        let invalidPrefixes = ["4", "61", "600", "630"]
        invalidPrefixes.forEach {
            XCTAssert(discover.prefixValid($0) == false, "\($0) should not a valid discover prefix")
        }

        let testNumbers = ["6011111111111117",
                           "6011000990139424",
                           "6510000000000000"]

        testNumbers.forEach {
            XCTAssert(discover.prefixValid($0) == true, "\($0) should be a valid prefix")
            XCTAssert(discover.valid($0) == true, "\($0) should be valid")
        }

        let failsLuhn = "6011111111111118"
        XCTAssert(discover.prefixValid(failsLuhn) == true, "invalid discover should still match discover prefix")
        XCTAssert(discover.valid(failsLuhn) == false, "invalid discover should fail luhn check")
    }

//MARK: - JCB
    func testJCB() {
        let jcb: CardType = .jcb

        XCTAssert(jcb.cvvLength == 3, "expected CVV length of 3, got \(jcb.cvvLength))")

        let testPrefixes = ["3","35","352","355","358","3528","3530","3589"]
        testPrefixes.forEach {
            XCTAssert(jcb.prefixValid($0) == true, "\($0) should be a valid prefix")
        }

        let invalidPrefixes = ["4", "34", "36", "351", "359"]
        invalidPrefixes.forEach {
            XCTAssert(jcb.prefixValid($0) == false, "\($0) should not a valid jcb prefix")
        }

        let testNumbers = ["3530111333300000",
                           "3566002020360505"]

        testNumbers.forEach {
            XCTAssert(jcb.prefixValid($0) == true, "\($0) should be a valid prefix")
            XCTAssert(jcb.valid($0) == true, "\($0) should be valid")
        }

        let failsLuhn = "3530111333300001"
        XCTAssert(jcb.prefixValid(failsLuhn) == true, "invalid jcb should still match jcb prefix")
        XCTAssert(jcb.valid(failsLuhn) == false, "invalid jcb should fail luhn check")
    }

//MARK: - MasterCard
    func testMastercard() {
        let mastercard: CardType = .masterCard

        XCTAssert(mastercard.cvvLength == 3, "expected CVV length of 3, got \(mastercard.cvvLength))")

        let testPrefixes = ["5","51","53","55", "2", "22", "25", "27", "222", "272", "2221", "2720"]
        testPrefixes.forEach {
            XCTAssert(mastercard.prefixValid($0) == true, "\($0) should be a valid prefix")
        }

        let invalidPrefixes = ["4", "50", "57", "221", "2220", "2721"]
        invalidPrefixes.forEach {
            XCTAssert(mastercard.prefixValid($0) == false, "\($0) should not a valid mastercard prefix")
        }

        let testNumbers = ["5555555555554444",
                           "5105105105105100",
                           "5454545454545454",
                           "2221900000000000"]

        testNumbers.forEach {
            XCTAssert(mastercard.prefixValid($0) == true, "\($0) should be a valid prefix")
            XCTAssert(mastercard.valid($0) == true, "\($0) should be valid")
        }

        let failsLuhn = "5454545454545453"
        XCTAssert(mastercard.prefixValid(failsLuhn) == true, "invalid mastercard should still match mastercard prefix")
        XCTAssert(mastercard.valid(failsLuhn) == false, "invalid mastercard should fail luhn check")
    }

//MARK: - Visa
    func testVisa() {
        let visa: CardType = .visa

        XCTAssert(visa.cvvLength == 3, "expected CVV length of 3, got \(visa.cvvLength)")
        XCTAssert(visa.prefixValid("4") == true, "4 is a valid Visa prefix")
        XCTAssert(visa.prefixValid("3") == false, "3 is not a valid Visa prefix")

        let testNumbers = ["4444333322221111",
                           "4111111111111111",
                           "4012888888881881",
                           "4222222222222"]

        testNumbers.forEach {
            XCTAssert(visa.prefixValid($0) == true, "\($0) should be a valid prefix")
            XCTAssert(visa.valid($0) == true, "\($0) should be valid")
        }


        let failsLuhn = "4444333322221112"
        XCTAssert(visa.prefixValid(failsLuhn) == true, "invalid Visa still matches Visa prefix")
        XCTAssert(visa.valid(failsLuhn) == false, "invalid Visa should fail luhn check")

        let tooLong = "41111111111111111111"
        XCTAssert(visa.prefixValid(tooLong) == true, "invalid Visa still matches Visa prefix")
        XCTAssert(visa.valid(tooLong) == false, "invalid Visa should fail luhn check")
    }

}
