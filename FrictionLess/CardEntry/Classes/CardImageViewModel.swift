//
//  CardImageViewState.swift
//  FrictionLess
//
//  Created by Jason Clark on 4/5/17.
//
//

import UIKit

public struct CardImageViewState {

    var imageState: CardImageState

    public init(imageState: CardImageState) {
        self.imageState = imageState
    }

    func transition(from oldState: CardImageState, to newState: CardImageState) -> UIViewAnimationOptions {
        var transition = UIViewAnimationOptions.transitionCrossDissolve
        switch (oldState, newState) {

        //transition between two accepted or ambiguous card states
        case (.card(let old), .card(let new)) where old.isAccepted && new.isAccepted:
            switch (old.cardState, new.cardState) {

            //from unidentified to identfied
            case (.indeterminate, .identified): transition = .transitionFlipFromRight

            //from identified to unidentified
            case (.identified, .indeterminate): transition = .transitionFlipFromLeft
            default: break
            }

        //transition between card states where one is not accepted
        case (.card(let old), .card(let new)) where !(old.isAccepted && new.isAccepted):
            transition = .transitionCrossDissolve

        //transition between card and cvv
        case (.card, .cvv(let newCard)):
            switch newCard.cardState.cvvLocation {

            //card to front cvv, no flip
            case .front: transition = .transitionCrossDissolve

            //card to rear cvv, flip from right
            case .back: transition = .transitionFlipFromRight
            }

        //transition between cvv and card
        case (.cvv(let oldCard), .card):
            switch oldCard.cardState.cvvLocation {

            //front cvv to card, no flip
            case .front: transition = .transitionCrossDissolve

            //rear cvv to card, flip from left
            case .back: transition = .transitionFlipFromLeft
            }
        default:
            break
        }
        return transition
    }

}

public enum CardImageState {
    case card(creditCard: CardEntryViewState)
    case cvv(creditCard: CardEntryViewState)

    public var image: UIImage {
        switch self {
        case .card(let card):
            return card.isAccepted ? card.cardState.image : Images.CreditCard.notAccepted.image
        case .cvv(let card): return card.cardState.cvvImage
        }
    }
}

extension CardImageState: Equatable {
    public static func == (lhs: CardImageState, rhs: CardImageState) -> Bool {
        switch (lhs, rhs) {
        case (.card(let card1), .card(let card2)):
            return (card1.cardState == card2.cardState) && (card1.isAccepted == card2.isAccepted)
        case (.cvv(let card1), .cvv(let card2)):
            return (card1.cardState == card2.cardState) && (card1.isAccepted == card2.isAccepted)
        default: return false
        }
    }
}

private extension CardState {

    var image: UIImage {
        switch self {
        case .identified(let cardType): return cardType.image
        case .invalid:                  return Images.CreditCard.notAccepted.image
        case .indeterminate:            return Images.CreditCard.placeholder.image
        }
    }

    var cvvImage: UIImage {
        switch self {
        case .identified(let cardType): return cardType.cvvImage
        default: return Images.CreditCard.Cvv.back.image
        }
    }

    var cvvLocation: CVVLocation {
        switch self {
        case .identified(let cardType): return cardType.cvvLocation
        default: return .back
        }
    }

}

private enum CVVLocation {
    case front
    case back
}

private extension CardType {

    var image: UIImage {
        switch self {
        case .visa:         return Images.CreditCard.visa.image
        case .masterCard:   return Images.CreditCard.mastercard.image
        case .amex:         return Images.CreditCard.americanexpress.image
        case .discover:     return Images.CreditCard.discover.image
        case .diners:       return Images.CreditCard.diners.image
        case .jcb:          return Images.CreditCard.jcb.image
        }
    }

    var cvvImage: UIImage {
        switch self {
        case .amex:     return Images.CreditCard.Cvv.front.image
        default:        return Images.CreditCard.Cvv.back.image
        }
    }

    var cvvLocation: CVVLocation {
        switch self {
        case .amex:     return .front
        default:        return .back
        }
    }

}
