// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable file_length
// swiftlint:disable line_length

// swiftlint:disable type_body_length
// swiftlint:disable nesting
// swiftlint:disable variable_name
// swiftlint:disable valid_docs
// swiftlint:disable type_name

enum Strings {

  enum Frictionless {

    enum Cardentry {

      enum Cardnumber {
        /// 0000 0000 0000 0000
        static let placeholder = Strings.tr("FrictionLess.CardEntry.CardNumber.Placeholder")
        /// Credit Card Number
        static let title = Strings.tr("FrictionLess.CardEntry.CardNumber.Title")
      }

      enum Cardtype {
        /// American Express
        static let amex = Strings.tr("FrictionLess.CardEntry.CardType.Amex")
        /// Diners Club
        static let diners = Strings.tr("FrictionLess.CardEntry.CardType.Diners")
        /// Discover
        static let discover = Strings.tr("FrictionLess.CardEntry.CardType.Discover")
        /// JCB
        static let jcb = Strings.tr("FrictionLess.CardEntry.CardType.JCB")
        /// MasterCard
        static let masterCard = Strings.tr("FrictionLess.CardEntry.CardType.MasterCard")
        /// Visa
        static let visa = Strings.tr("FrictionLess.CardEntry.CardType.Visa")
      }

      enum Cvv {
        /// 1234
        static let amexPlaceholder = Strings.tr("FrictionLess.CardEntry.CVV.AmexPlaceholder")
        /// 123
        static let placeholder = Strings.tr("FrictionLess.CardEntry.CVV.Placeholder")
        /// CVV
        static let title = Strings.tr("FrictionLess.CardEntry.CVV.Title")
      }

      enum Expiration {
        /// MM/YY
        static let placeholder = Strings.tr("FrictionLess.CardEntry.Expiration.Placeholder")
        /// Expiration
        static let title = Strings.tr("FrictionLess.CardEntry.Expiration.Title")
      }

      enum Validation {
        /// Card Number Invalid
        static let cardNumberInvalid = Strings.tr("FrictionLess.CardEntry.Validation.CardNumberInvalid")
        /// Invalid
        static let cvvInvalid = Strings.tr("FrictionLess.CardEntry.Validation.CVVInvalid")
        /// Date Invalid or Expired
        static let expirationInvalid = Strings.tr("FrictionLess.CardEntry.Validation.ExpirationInvalid")
        /// Date Expired
        static let expired = Strings.tr("FrictionLess.CardEntry.Validation.Expired")
        /// %@ Not Accepted
        static func notAccepted(_ p1: String) -> String {
          return Strings.tr("FrictionLess.CardEntry.Validation.NotAccepted", p1)
        }

        enum Notaccepted {
          /// Not Accepted
          static let generic = Strings.tr("FrictionLess.CardEntry.Validation.NotAccepted.Generic")
        }
      }
    }
  }
}

extension Strings {
  fileprivate static func tr(_ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: "CardEntry", bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}

// swiftlint:enable type_body_length
// swiftlint:enable nesting
// swiftlint:enable variable_name
// swiftlint:enable valid_docs
