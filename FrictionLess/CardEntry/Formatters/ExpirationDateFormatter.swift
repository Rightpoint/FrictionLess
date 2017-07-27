//
//  ExpirationDateFormatter.swift
//  FrictionLess
//
//  Created by Jason Clark on 11/21/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import Foundation

enum ExpirationDateFormatterError: Error {
    case maxLength
    case minLength
    case invalidMonth
    case invalidYear
    case expired
}

public struct ExpirationDateFormatter: TextFieldFormatter {

    let requiredLength = 4
    let validFutureExpYearRange = 30

    public var inputCharacterSet: CharacterSet = .decimalDigits
    public var formattingCharacterSet = CharacterSet(charactersIn: "/")
    public var deletingShouldRemoveTrailingCharacters = true

    public func validate(_ string: String) -> ValidationResult {
        let unformatted = removeFormatting(string)
        let length = unformatted.characters.count
        if length < requiredLength {
            return .invalid(validationError: ExpirationDateFormatterError.minLength)
        }
        else if length > requiredLength {
            return .invalid(validationError: ExpirationDateFormatterError.maxLength)
        }

        return validate(expDate: unformatted)
    }

    public func format(editingEvent: EditingEvent) -> FormattingResult {
        var newExpirationDate = editingEvent.newValue
        guard newExpirationDate.characters.count <= requiredLength else {
            return .invalid(formattingError: ExpirationDateFormatterError.maxLength)
        }

        //If user manually enters formatting character after a 1, pad with a leading 0
        if editingEvent.editRange.location == 1 && editingEvent.editString == "/" {
            newExpirationDate.insert("0", at: newExpirationDate.startIndex)
        }

        let formatted = formatString(newExpirationDate)

        switch validate(expDate: removeFormatting(formatted)) {
        case .valid:
            return .valid(.text(formatted))
        case .invalid(let error):
            return .invalid(formattingError: error)
        }
    }

    public func isComplete(_ text: String) -> Bool {
        return validate(text) == .valid
    }

    public init() {}

}

private extension ExpirationDateFormatter {

    func formatString(_ text: String) -> String {
        var formattedString = String()

        for (index, character) in text.characters.enumerated() {
            if index == 0 && text.characters.count == 1 && "2"..."9" ~= character {
                formattedString.append("0\(character)/")
            }
            else if index == 1 && text.characters.count == 2 && text.characters.first == "1"
                && !("1"..."2" ~= character) && validYearRanges.contains(where: { $0.hasCommonPrefix(with: String(character)) }) {
                //digit after leading 1 is not a valid month but is the start of a valid year.
                formattedString.insert("0", at: formattedString.startIndex)
                formattedString.append("/\(character)")
            }
            else {
                formattedString.append(character)
                if index == 1 {
                    formattedString.append("/")
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

    func validate(expDate: String) -> ValidationResult {
        guard expDate.characters.count > 0 else {
            return .valid
        }
        let monthsRange = "01"..."12"
        guard monthsRange.hasCommonPrefix(with: expDate) else {
            return .invalid(validationError: ExpirationDateFormatterError.invalidMonth)
        }
        //months valid, check year
        guard expDate.characters.count > 2 else {
            return .valid
        }
        let separatorIndex = expDate.characters.index(expDate.startIndex, offsetBy: 2)
        let monthString = expDate.substring(to: separatorIndex)
        let yearSuffixString = expDate.substring(from: separatorIndex)
        guard validYearRanges.contains(where: { $0.hasCommonPrefix(with: yearSuffixString) }) else {
            if yearSuffixString < String(currentYearSuffix) {
                return .invalid(validationError: ExpirationDateFormatterError.expired)
            }
            else {
                return .invalid(validationError: ExpirationDateFormatterError.invalidYear)
            }
        }
        //year valid, check month year combo
        guard String(currentYearSuffix).hasCommonPrefix(with: yearSuffixString) else {
            //If a future year, we don't have to check month
            return .valid
        }
        guard !(yearSuffixString.characters.count == 1 && String(currentYearSuffix + 1).hasCommonPrefix(with: yearSuffixString)) else {
            //year is incomplete and can potentially be a future year
            return .valid
        }

        if String(currentMonth) < monthString {
            return .invalid(validationError: ExpirationDateFormatterError.expired)
        }

        return .valid
    }

}
