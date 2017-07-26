//
//  CardEntryView.swift
//  FrictionLess
//
//  Created by Jason Clark on 7/19/17.
//
//

import Anchorage

open class CardEntryView: UIView {

    public var creditCard: FrictionLessFormComponent = {
        let component = FrictionLessFormComponent()
        component.textField.formatter = CreditCardFormatter()
        component.textField.keyboardType = .numberPad
        component.placeholder = Strings.Frictionless.Cardentry.Cardnumber.placeholder
        component.title = Strings.Frictionless.Cardentry.Cardnumber.title
        return component
    }()

    public var expiration: FrictionLessFormComponent = {
        let component = FrictionLessFormComponent()
        component.textField.keyboardType = .numberPad
        component.textField.formatter = ExpirationDateFormatter()
        component.placeholder = Strings.Frictionless.Cardentry.Expiration.placeholder
        component.title = Strings.Frictionless.Cardentry.Expiration.title
        return component
    }()

    public var cvv: FrictionLessFormComponent = {
        let component = FrictionLessFormComponent()
        component.textField.keyboardType = .numberPad
        component.textField.formatter = CVVFormatter()
        component.placeholder = Strings.Frictionless.Cardentry.Cvv.placeholder
        component.title = Strings.Frictionless.Cardentry.Cvv.title
        return component
    }()

    public var cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    public var animationDuration: TimeInterval = 0.3

    var components: [FrictionLessFormComponent] {
        return [creditCard, expiration, cvv]
    }

    fileprivate var layout = Constraints()
    fileprivate let outerStackView = UIStackView()
    fileprivate let bottomRowStackView = UIStackView()

    init() {
        super.init(frame: .zero)
        configureView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func changeImage(to image: UIImage, transition: UIViewAnimationOptions) {
        guard image != cardImageView.image else {
            return
        }
        UIView.transition(with: cardImageView, duration: animationDuration, options: transition, animations: {
            self.cardImageView.image = image
        }, completion: nil)
    }

    open override func resignFirstResponder() -> Bool {
        return components.first(where: { $0.isFirstResponder })?.resignFirstResponder() ?? super.resignFirstResponder()
    }

}

// MARK: Appearance
extension CardEntryView {

    public struct Constraints {
        var card = Card()

        struct Card {
            var width: NSLayoutConstraint? = nil
            var padding = Padding()

            struct Padding {
                var top: NSLayoutConstraint? = nil
                var left: NSLayoutConstraint? = nil
                var bottom: NSLayoutConstraint? = nil
                var right: NSLayoutConstraint? = nil
            }
        }
        
    }

    fileprivate enum Default {
        static let verticalSpacing = CGFloat(15)
        static let horizontalSpacing = CGFloat(30)
        static let cardImageWidth = CGFloat(40)
        static let cardImagePadding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    public dynamic var verticalSpacing: CGFloat {
        set { outerStackView.spacing = newValue }
        get { return outerStackView.spacing }
    }

    public dynamic var horizontalSpacing: CGFloat {
        set { bottomRowStackView.spacing = newValue }
        get { return bottomRowStackView.spacing }
    }

    public dynamic var cardImageWidth: CGFloat {
        set {
            layout.card.width?.constant = newValue
            updateCardInsets()
        }
        get { return layout.card.width?.constant ?? Default.cardImageWidth }
    }

    public dynamic var cardImageInsets: UIEdgeInsets {
        set {
            layout.card.padding.top?.constant = newValue.top
            layout.card.padding.left?.constant = newValue.left
            layout.card.padding.bottom?.constant = newValue.bottom
            layout.card.padding.right?.constant = newValue.right
            updateCardInsets()
        }
        get {
            return UIEdgeInsets(
                top: layout.card.padding.top?.constant ?? Default.cardImagePadding.top,
                left: layout.card.padding.left?.constant ?? Default.cardImagePadding.left,
                bottom: layout.card.padding.bottom?.constant ?? Default.cardImagePadding.bottom,
                right: layout.card.padding.right?.constant ?? Default.cardImagePadding.right
            )
        }
    }

    fileprivate func updateCardInsets() {
        //The inset of the credit card text field accounts for the card image.
        var layoutMargins = creditCard.textField.layoutMargins
        let leadingCardNumberInset = cardImageWidth + cardImageInsets.left + cardImageInsets.right
        layoutMargins.left = leadingCardNumberInset
        creditCard.textField.layoutMargins = layoutMargins
    }
}

extension CardEntryView {

    func configureView() {
        layout.card.width =
            cardImageView.widthAnchor == cardImageWidth
        creditCard.textField.leftView = {
            let view = UIView()
            view.addSubview(cardImageView)
            layout.card.padding.top =
                cardImageView.topAnchor >= view.topAnchor + cardImageInsets.top
            layout.card.padding.left =
                cardImageView.leadingAnchor == view.leadingAnchor + cardImageInsets.left
            layout.card.padding.bottom =
                view.bottomAnchor >= cardImageView.bottomAnchor + cardImageInsets.bottom
            layout.card.padding.right =
                view.trailingAnchor == cardImageView.trailingAnchor + cardImageInsets.right
            return view
        }()

        creditCard.textField.leftViewMode = .always
        updateCardInsets()

        bottomRowStackView.addArrangedSubview(expiration)
        bottomRowStackView.addArrangedSubview(cvv)
        bottomRowStackView.axis = .horizontal
        bottomRowStackView.distribution = .fillEqually
        bottomRowStackView.spacing = Default.horizontalSpacing

        outerStackView.addArrangedSubview(creditCard)
        outerStackView.addArrangedSubview(bottomRowStackView)
        outerStackView.axis = .vertical
        outerStackView.spacing = Default.verticalSpacing
        addSubview(outerStackView)

        outerStackView.edgeAnchors == layoutMarginsGuide.edgeAnchors
    }

}

extension CardEntryView {

    func field(after field: FormattableTextField) -> FormattableTextField? {
        let textFields = components.flatMap { $0.textField }
        guard let idx = textFields.index(of: field), field != textFields.last else { return nil }
        return textFields[idx + 1]
    }

    func field(before field: FormattableTextField) -> FormattableTextField? {
        let textFields = components.flatMap { $0.textField }
        guard let idx = textFields.index(of: field), idx > textFields.startIndex else { return nil }
        return textFields[idx - 1]
    }

}
