//
//  EmailFormatter.swift
//  Raizlabs
//
//  Created by Jason Clark on 4/19/17.
//
//

import Foundation

enum EmailFormatterError: Error {
    case invalidEmail
}

public struct EmailFormatter: TextFieldFormatter {

    public func validate(_ text: String) -> ValidationResult {
        if text.isEmail {
            return .valid
        }
        else {
            return .invalid(validationError: EmailFormatterError.invalidEmail)
        }
    }

    public init() {}

}

extension String {

    /// https://github.com/goktugyil/EZSwiftExtensions/blob/master/Sources/StringExtensions.swift
    public var isEmail: Bool {
        let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let firstMatch = dataDetector?.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: 0, length: characters.count))
        return (firstMatch?.range.location != NSNotFound && firstMatch?.url?.scheme == "mailto")
    }

}
