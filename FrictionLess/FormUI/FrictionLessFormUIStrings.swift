// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable file_length
// swiftlint:disable line_length

// swiftlint:disable type_body_length
// swiftlint:disable nesting
// swiftlint:disable variable_name
// swiftlint:disable valid_docs
// swiftlint:disable type_name

enum FrictionLessFormUIStrings {

  enum Frictionless {

    enum Formui {

      enum Validation {
        /// %@ Invalid
        static func invalid(_ p1: String) -> String {
          return FrictionLessFormUIStrings.tr("FrictionLess.FormUI.Validation.Invalid", p1)
        }
        /// %@ Required
        static func `required`(_ p1: String) -> String {
          return FrictionLessFormUIStrings.tr("FrictionLess.FormUI.Validation.Required", p1)
        }
      }
    }
  }
}

extension FrictionLessFormUIStrings {
    fileprivate static func tr(_ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, tableName: "FormUI", bundle: Bundle(for: BundleToken.self), comment: "")
        return String(format: format, locale: Locale.current, arguments: args)
    }
}

private final class BundleToken {}

// swiftlint:enable type_body_length
// swiftlint:enable nesting
// swiftlint:enable variable_name
// swiftlint:enable valid_docs
