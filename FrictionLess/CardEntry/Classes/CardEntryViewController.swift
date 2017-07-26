//
//  CardEntryViewController.swift
//  Pods
//
//  Created by Jason Clark on 7/19/17.
//
//

import Anchorage

protocol CardEntryViewControllderDelegate: class {

    func cardEntryViewController(_ vc: CardEntryViewController, creditCardValid: Bool)

}

open class CardEntryViewController: UIViewController {

    weak var delegate: CardEntryViewControllderDelegate?
    public lazy var cardEntryView = CardEntryView()

    var cardImageViewState: CardImageViewState? {
        didSet {
            guard let oldState = oldValue?.imageState,
                  let newState = cardImageViewState?.imageState,
                  let transition = cardImageViewState?.transition(from: oldState, to: newState)
            else { return }
            cardEntryView.changeImage(to: newState.image, transition: transition)
        }
    }

    var cardEntryState: CardEntryViewState = CardEntryViewState() {
        didSet {
            updateCardImageState()
            updateForm()

            switch (oldValue.isAccepted, cardEntryState.isAccepted) {
            case (true, false):
                cardEntryView.creditCard.state = .invalid(errorString: "")// TODO creditCardState.notAcceptedErrorMessage)
                cardEntryView.creditCard.textField.shakeIfFirstResponder()
            case (false, false):
                cardEntryView.creditCard.state = .invalid(errorString: cardEntryState.notAcceptedErrorMessage)
                if cardEntryState.number.characters.count > oldValue.number.characters.count {
                    cardEntryView.creditCard.textField.shakeIfFirstResponder()
                }
            default: break
            }

            delegate?.cardEntryViewController(self, creditCardValid: creditCardValid)
        }
    }

    var creditCardValid: Bool {
        //TODO: DI these formatters
        if case .valid? = cardEntryView.creditCard.textField.formatter?.validate(cardEntryState.number),
            case .valid? = cardEntryView.expiration.textField.formatter?.validate(cardEntryState.expiration),
            case .valid? = cardEntryView.cvv.textField.formatter?.validate(cardEntryState.cvv) {
            return true
        }
        else {
            return false
        }
    }

    public init() {
        super.init(nibName: nil, bundle: nil)
        cardImageViewState = CardImageViewState(imageState: .card(creditCard: cardEntryState))
        updateForm()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        cardEntryView.components.forEach {
            $0.textField.delegate = self
        }
        updateCardImageState()
    }

    open override func loadView() {
        view = UIView()
        view.addSubview(cardEntryView)
        cardEntryView.edgeAnchors == view.edgeAnchors
    }

    override open func becomeFirstResponder() -> Bool {
        let form = cardEntryView.components.first(where: { !$0.textField.isValid })
        return form?.becomeFirstResponder() ?? false
    }

    /// force validation on all components and set to either invalid or valid
    func validate() {
        cardEntryView.components.flatMap({$0}).forEach { component in
            switch component.textField.validation {
            case .valid:
                component.state = .valid
            case .invalid(let error):
                let errorString = cardEntryState.errorString(forFormatter: component.textField.formatter, error: error) ??
                    component.genericErrorString
                component.state = .invalid(errorString: errorString)
                component.textField.shakeIfFirstResponder()
            }
        }
    }

}

fileprivate extension CardEntryViewController {

    func updateCardImageState() {
        let cvvActive = cardEntryView.cvv.textField.isFirstResponder
        let state: CardImageState = cvvActive ? .cvv(creditCard: cardEntryState) : .card(creditCard: cardEntryState)
        cardImageViewState?.imageState = state
    }

    func updateForm() {
        cardEntryView.creditCard.value = cardEntryState.number
        cardEntryView.expiration.value = cardEntryState.expiration
        cardEntryView.cvv.value = cardEntryState.cvv

        // TODO cardEntryView.cvvLength = cardEntryState.state.cvvLength

        cardEntryView.components.forEach { component in
            switch component.textField.validation {
            case .valid:
                component.state = .valid
            case .invalid where component.textField.isFirstResponder:
                component.state = .active
            case .invalid(let error) where !(component.textField.text?.isEmpty ?? true):
                let errorString = cardEntryState.errorString(forFormatter: component.textField.formatter, error: error)
                component.state = .invalid(errorString: errorString)
            default: break
            }
        }
    }
    
}

extension CardEntryViewController: FormattableTextFieldDelegate {

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        updateCardImageState()

        if let view = viewForTextField(textField) {
            if case .inactive = view.state {
                view.state = .active
            }
        }
    }

    public func editingChanged(textField: FormattableTextField) {
        let cardNumber = cardEntryView.creditCard.value
        let expiration = cardEntryView.expiration.value
        let cvv = cardEntryView.cvv.value

        cardEntryState.update(number: cardNumber, expiration: expiration, cvv: cvv)

        if textField.isComplete {
            if let next = cardEntryView.field(after: textField), next.text?.isEmpty ?? true {
                next.becomeFirstResponder()
            }
        }

        if creditCardValid {
            _ = cardEntryView.resignFirstResponder()
        }
    }

    public func textFieldShouldNavigateBackwards(_ textField: FormattableTextField) {
        guard let previous = cardEntryView.field(before: textField) else { return }
        previous.becomeFirstResponder()
    }

    public func textField(_ textField: FormattableTextField, didOverflowInput string: String) {
        guard let next = cardEntryView.field(after: textField), (next.text?.isEmpty ?? true) else { return }
        next.becomeFirstResponder()
        next.simulateInput(text: string)
    }

    public func textField(_ textField: FormattableTextField, invalidInput error: Error) {
        if case FormattableTextFieldError.invalidInput = error {
            //input invalid digit. Shake, but do not outline.
            textField.shakeIfFirstResponder()
        }
        else {
            let errorMessage = cardEntryState.errorString(forFormatter: textField.formatter, error: error)
            viewForTextField(textField)?.state = .invalid(errorString: errorMessage)
            textField.shakeIfFirstResponder()
        }
    }

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let textField = textField as? FormattableTextField else {
            fatalError()
        }

        if case .invalid(let error) = textField.validation,
            let component = viewForTextField(textField) {
            if textField.text?.isEmpty ?? true {
                component.state = .inactive
            }
            else {
                let errorMessage = cardEntryState.errorString(forFormatter: textField.formatter, error: error) ?? component.genericErrorString
                component.state = .invalid(errorString: errorMessage)
                textField.shake()
            }
        }
        return true
    }
    
}

private extension CardEntryViewController {

    func viewForTextField(_ textField: UITextField) -> FrictionLessFormComponent? {
        return cardEntryView.components.first(where: {$0.textField == textField })
    }
    
}
