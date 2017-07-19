// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  typealias Image = UIImage
#elseif os(OSX)
  import AppKit.NSImage
  typealias Image = NSImage
#endif

// swiftlint:disable file_length
// swiftlint:disable line_length
// swiftlint:disable nesting

struct ImagesType: ExpressibleByStringLiteral {
  fileprivate var value: String

  var image: Image {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = Image(named: value, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: value)
    #elseif os(watchOS)
    let image = Image(named: value)
    #endif
    guard let result = image else { fatalError("Unable to load image \(value).") }
    return result
  }

  init(stringLiteral value: String) {
    self.value = value
  }

  init(extendedGraphemeClusterLiteral value: String) {
    self.init(stringLiteral: value)
  }

  init(unicodeScalarLiteral value: String) {
    self.init(stringLiteral: value)
  }
}

// swiftlint:disable type_body_length
enum Images {
  static let cameraScan: ImagesType = "CameraScan"
  enum CreditCard {
    static let americanexpress: ImagesType = "americanexpress"
    enum Cvv {
      static let back: ImagesType = "back"
      static let front: ImagesType = "front"
    }
    static let diners: ImagesType = "diners"
    static let discover: ImagesType = "discover"
    static let jcb: ImagesType = "jcb"
    static let mastercard: ImagesType = "mastercard"
    static let notAccepted: ImagesType = "notAccepted"
    static let placeholder: ImagesType = "placeholder"
    static let visa: ImagesType = "visa"
  }
}
// swiftlint:enable type_body_length

extension Image {
  convenience init!(asset: ImagesType) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.value, in: bundle, compatibleWith: nil)
    #elseif os(OSX) || os(watchOS)
    self.init(named: asset.value)
    #endif
  }
}

private final class BundleToken {}
