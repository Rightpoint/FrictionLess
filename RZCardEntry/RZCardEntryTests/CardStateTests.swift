//
//  CardStateTests.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/21/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import XCTest
@testable import RZCardEntry

class CardStateTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEmptyStringIndeterminateState() {
        if case .indeterminate(let cards) = CardState(fromPrefix: ""),
            cards == CardType.allValues{
            XCTAssert(true)
        }
        else {
            XCTFail("Empty string should return all card types as potential matches")
        }
    }

    func testIndeterminate() {
        if case .indeterminate(let cards) = CardState(fromPrefix: "3"),
            cards.contains(.amex),
            cards.contains(.diners),
            cards.contains(.jcb)
        {
            XCTAssert(true)
        }
        else{
            XCTFail()
        }
    }

    func testCards() {
        //amex
        let amex = ["378282246310005",
                    "371449635398431",
                    "378734493671000"]
        amex.forEach {
            XCTAssert(CardState(fromPrefix: $0) == .identified(.amex))
            XCTAssert(CardState(fromNumber: $0) == .identified(.amex))
        }

        //diners
        let diners = ["30569309025904",
                      "38520000023237"]
        diners.forEach {
            XCTAssert(CardState(fromPrefix: $0) == .identified(.diners))
            XCTAssert(CardState(fromNumber: $0) == .identified(.diners))
        }

        //discover
        let discover =  ["6011111111111117",
                         "6011000990139424",
                         "6510000000000000"]
        discover.forEach {
            XCTAssert(CardState(fromPrefix: $0) == .identified(.discover))
            XCTAssert(CardState(fromNumber: $0) == .identified(.discover))
        }

        //jcb
        let jcb = ["3530111333300000",
                   "3566002020360505"]
        jcb.forEach {
            XCTAssert(CardState(fromPrefix: $0) == .identified(.jcb))
            XCTAssert(CardState(fromNumber: $0) == .identified(.jcb))
        }

        //mastercard
        let mastercard = ["5555555555554444",
                          "5105105105105100",
                          "5454545454545454",
                          "2221900000000000"]
        mastercard.forEach {
            XCTAssert(CardState(fromPrefix: $0) == .identified(.masterCard))
            XCTAssert(CardState(fromNumber: $0) == .identified(.masterCard))
        }

        //visa
        let visa =  ["4444333322221111",
                     "4111111111111111",
                     "4012888888881881",
                     "4222222222222"]
        visa.forEach {
            XCTAssert(CardState(fromPrefix: $0) == .identified(.visa))
            XCTAssert(CardState(fromNumber: $0) == .identified(.visa))
        }
    }

    func testInvalid() {
        XCTAssert(CardState(fromPrefix: "0") == .invalid)
        XCTAssert(CardState(fromNumber: "") == .invalid)
    }

}
