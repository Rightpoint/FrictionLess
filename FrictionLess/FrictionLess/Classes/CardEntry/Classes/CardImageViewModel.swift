//
//  CardImageViewModel.swift
//  FrictionLess
//
//  Created by Jason Clark on 4/5/17.
//
//

import UIKit

struct CardImageViewModel {

    var imageState: CardImageState

    init(imageState: CardImageState) {
        self.imageState = imageState
    }

    func transition(from oldState: CardImageState, to newState: CardImageState) -> UIViewAnimationOptions {
        var transition = UIViewAnimationOptions.transitionCrossDissolve
        switch (oldState, newState) {

        //transition between two accepted or ambiguous card states
        case (.card(let old), .card(let new)) where old.isAccepted && new.isAccepted:
            switch (old.state, new.state) {

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
            switch newCard.state.cvvLocation {

            //card to front cvv, no flip
            case .front: transition = .transitionCrossDissolve

            //card to rear cvv, flip from right
            case .back: transition = .transitionFlipFromRight
            }

        //transition between cvv and card
        case (.cvv(let oldCard), .card):
            switch oldCard.state.cvvLocation {

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

enum CardImageState: Equatable {
    case card(creditCard: CreditEntryViewModel)
    case cvv(creditCard: CreditEntryViewModel)

    var image: UIImage {
        switch self {
        case .card(let card):
            return card.isAccepted ? card.state.image : UIImage()//Asset.Payment.CreditCard.notAccepted.image
        case .cvv(let card): return card.state.cvvImage
        }
    }
}

func == (lhs: CardImageState, rhs: CardImageState) -> Bool {
    switch (lhs, rhs) {
    case (.card(let card1), .card(let card2)):
        return (card1.state == card2.state) && (card1.isAccepted == card2.isAccepted)
    case (.cvv(let card1), .cvv(let card2)):
        return (card1.state == card2.state) && (card1.isAccepted == card2.isAccepted)
    default: return false
    }
}

private extension CardState {

    var image: UIImage {
        switch self {
        case .identified(let cardType): return cardType.image
        case .invalid:                  return UIImage()//Asset.Payment.CreditCard.notAccepted.image
        case .indeterminate:            return UIImage()//Asset.Payment.CreditCard.placeholder.image
        }
    }

    var cvvImage: UIImage {
        switch self {
        case .identified(let cardType): return cardType.cvvImage
        default: return UIImage()//Asset.Payment.CreditCard.Cvv.back.image
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
        case .visa:         return UIImage()//Asset.Payment.CreditCard.visa.image
        case .masterCard:   return UIImage()//Asset.Payment.CreditCard.mastercard.image
        case .amex:         return UIImage()//Asset.Payment.CreditCard.americanexpress.image
        case .discover:     return UIImage()//Asset.Payment.CreditCard.discover.image
        case .diners:       return UIImage()//Asset.Payment.CreditCard.diners.image
        case .jcb:          return UIImage()//Asset.Payment.CreditCard.jcb.image
        }
    }

    var cvvImage: UIImage {
        switch self {
        case .amex:     return UIImage()//Asset.Payment.CreditCard.Cvv.front.image
        default:        return UIImage()//Asset.Payment.CreditCard.Cvv.back.image
        }
    }

    var cvvLocation: CVVLocation {
        switch self {
        case .amex:     return .front
        default:        return .back
        }
    }

}
