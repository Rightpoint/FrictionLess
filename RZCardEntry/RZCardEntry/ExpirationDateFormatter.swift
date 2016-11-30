//
//  ExpirationDateFormatter.swift
//  RZCardEntry
//
//  Created by Jason Clark on 11/21/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation

struct ExpirationDateFormatter: Formatter {

    var maxLength = 4
    let validFutureExpYearRange = 30

    var inputCharacterSet: CharacterSet {
        return .decimalDigits
    }

    var formattingCharacterSet: CharacterSet {
        return CharacterSet(charactersIn: "/")
    }

    var deletingShouldRemoveTrailingCharacters: Bool {
        return true
    }

    func valid(_ string: String) -> Bool {
        let unformatted = removeFormatting(string)
        return unformatted.characters.count == maxLength && expirationDateIsPossible(unformatted)
    }

    func validateAndFormat(editingEvent: EditingEvent) -> ValidationResult {
        var cursorPos = editingEvent.newCursorPosition
        var newExpirationDate = editingEvent.newValue
        guard newExpirationDate.characters.count <= maxLength else {
            return .invalid
        }

        //If user manually enters formatting character after a 1, pad with a leading 0
        if editingEvent.editRange.location == 1 && editingEvent.editString == "/" {
            newExpirationDate.insert("0", at: newExpirationDate.startIndex)
            cursorPos += 1
        }

        let formatted = formatString(newExpirationDate, cursorPosition: &cursorPos)
        guard expirationDateIsPossible(removeFormatting(formatted)) else {
            return .invalid
        }

        return .valid(formatted, cursorPos)
    }

}

private extension ExpirationDateFormatter {

    func formatString(_ text: String, cursorPosition: inout Int) -> String {
        let cursorPositionInFormattlessText = cursorPosition
        var formattedString = String()

        for (index, character) in text.characters.enumerated() {
            if index == 0 && text.characters.count == 1 && "2"..."9" ~= character {
                formattedString.append("0\(character)/")
                if index < cursorPositionInFormattlessText {
                    cursorPosition += 2
                }
            }
            else if index == 1 && text.characters.count == 2 && text.characters.first == "1"
                && !("1"..."2" ~= character) && validYearRanges.contains(where: { $0.hasCommonPrefix(String(character)) }) {
                //digit after leading 1 is not a valid month but is the start of a valid year.
                formattedString.insert("0", at: formattedString.startIndex)
                formattedString.append("/\(character)")
                if index < cursorPositionInFormattlessText {
                    cursorPosition += 2
                }
            }
            else {
                formattedString.append(character)
                if index == 1 {
                    formattedString.append("/")
                    if index < cursorPositionInFormattlessText {
                        cursorPosition += 1
                    }
                }
            }
        }

        return formattedString
    }

}

private extension ExpirationDateFormatter {

    var currentYearSuffix: Int {
        let fullYear = (Calendar.current as NSCalendar).component(.year, from: Date())
        return fullYear % 100
    }

    var currentMonth: Int {
        return (Calendar.current as NSCalendar).component(.month, from: Date())
    }

    var validYearRanges: [ClosedRange<String>] {
        let shortYear = currentYearSuffix
        var endYear = shortYear + validFutureExpYearRange
        if endYear < 100 {
            return [String(shortYear)...String(endYear)]
        }
        else {
            endYear = endYear % 100
            return [String(shortYear)..."99",
                    "00"...String(endYear)]
        }
    }

    func expirationDateIsPossible(_ expDate: String) -> Bool {
        guard expDate.characters.count > 0 else {
            return true
        }
        let monthsRange = "01"..."12"
        guard monthsRange.hasCommonPrefix(expDate) else {
            return false
        }
        //months valid, check year
        guard expDate.characters.count > 2 else {
            return true
        }
        let separatorIndex = expDate.characters.index(expDate.startIndex, offsetBy: 2)
        let monthString = expDate.substring(to: separatorIndex)
        let yearSuffixString = expDate.substring(from: separatorIndex)
        guard validYearRanges.contains(where: { $0.hasCommonPrefix(yearSuffixString) }) else {
            return false
        }
        //year valid, check month year combo
        guard String(currentYearSuffix).hasCommonPrefix(yearSuffixString) else {
            //If a future year, we don't have to check month
            return true
        }
        guard !(yearSuffixString.characters.count == 1 && String(currentYearSuffix + 1).hasCommonPrefix(yearSuffixString)) else {
            //year is incomplete and can potentially be a future year
            return true
        }

        return String(currentMonth) >= monthString
    }
    
}
