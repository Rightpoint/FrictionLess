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

extension CardEntryView {

    enum Constant {
        static let verticalSpacing = CGFloat(15)
        static let horizontalSpacing = CGFloat(30)
        static let cardImageWidth = CGFloat(40)
        static let cardImagePadding: (left: CGFloat, right: CGFloat) = (10, 10)
    }

    func configureView() {
        creditCard.textField.leftView = cardImageView
        creditCard.textField.leftViewMode = .always
        cardImageView.widthAnchor == Constant.cardImageWidth

        //The inset of the credit card text field accounts for the card image.
        var layoutMargins = creditCard.textField.layoutMargins
        let leadingCardNumberInset = Constant.cardImageWidth + Constant.cardImagePadding.left
        layoutMargins.left = leadingCardNumberInset
        creditCard.textField.layoutMargins = layoutMargins

        let bottomRowStackView = UIStackView(arrangedSubviews: [expiration, cvv])
        bottomRowStackView.axis = .horizontal
        bottomRowStackView.distribution = .fillEqually
        bottomRowStackView.spacing = Constant.horizontalSpacing

        let outerStackView = UIStackView(arrangedSubviews: [creditCard, bottomRowStackView])
        outerStackView.axis = .vertical
        outerStackView.spacing = Constant.verticalSpacing
        addSubview(outerStackView)

        outerStackView.edgeAnchors == edgeAnchors
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
