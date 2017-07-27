//
//  FormattableTextFieldExampleViewController.swift
//  FrictionLess
//
//  Created by Jason Clark on 7/27/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import FrictionLess
import Anchorage

final class FormattableTextFieldExampleViewController: UIViewController {

    let email: FrictionLessFormComponent = {
        let component = FrictionLessFormComponent()
        component.textField.formatter = EmailFormatter()
        component.textField.keyboardType = .emailAddress
        component.textField.autocorrectionType = .no
        component.textField.spellCheckingType = .no
        component.textField.autocapitalizationType = .none
        component.title = "Email"
        return component
    }()

    let phoneNumber: FrictionLessFormComponent = {
        let component = FrictionLessFormComponent()
        component.textField.formatter = PhoneFormatter()
        component.textField.keyboardType = .phonePad
        component.title = "Phone Number"
        return component
    }()

    let creditCard: FrictionLessFormComponent = {
        let component = FrictionLessFormComponent()
        component.textField.formatter = CreditCardFormatter()
        component.textField.keyboardType = .numberPad
        component.title = "Card Number"
        component.placeholder = "0000 0000 0000 0000"
        return component
    }()

    let expiration: FrictionLessFormComponent = {
        let component = FrictionLessFormComponent()
        component.textField.formatter = ExpirationDateFormatter()
        component.textField.keyboardType = .numberPad
        component.title = "Expiration"
        component.placeholder = "MM/YY"
        return component
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()

    var components: [FrictionLessFormComponent] {
        return [
            email,
            phoneNumber,
            creditCard,
            expiration
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "FormattableTextField"
        view.backgroundColor = #colorLiteral(red: 0.9228180647, green: 0.9228180647, blue: 0.9228180647, alpha: 1)

        components.forEach {
            $0.textField.delegate = self
            stackView.addArrangedSubview($0)
        }

        view.addSubview(stackView)
        stackView.topAnchor == view.topAnchor + 80
        stackView.horizontalAnchors == view.layoutMarginsGuide.horizontalAnchors
        stackView.bottomAnchor <= view.bottomAnchor

        style()
    }

}

private extension FormattableTextFieldExampleViewController {

    func style() {
        let fieldAppearance = FormattableTextField.appearance()
        fieldAppearance.backgroundColor = .white
        fieldAppearance.cornerRadius = 5

        let componentAppearance = FrictionLessFormComponent.appearance()
        componentAppearance.titleToTextFieldPadding = 3
    }
    
}

extension FormattableTextFieldExampleViewController: FormattableTextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let view = component(for: textField),
            case .inactive = view.state {
            view.state = .active
        }
    }

    func editingChanged(textField: FormattableTextField) {
        let component = self.component(for: textField)
        switch textField.validation {
        case .valid:
            component?.state = .valid
        case .invalid where textField.isFirstResponder:
            component?.state = .active
        case .invalid(_ /*let error*/) where !(textField.text?.isEmpty ?? true):
            let errorString = component?.genericErrorString
            component?.state = .invalid(errorString: errorString)
        default: break
        }
    }

    public func textField(_ textField: FormattableTextField, invalidInput error: Error) {
        if case FormattableTextFieldError.invalidInput = error {
            //input invalid digit. Shake, but do not outline.
            textField.shakeIfFirstResponder()
        }
        else {
            let errorMessage = component(for: textField)?.genericErrorString
            component(for: textField)?.state = .invalid(errorString: errorMessage)
            textField.shakeIfFirstResponder()
        }
    }

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let textField = textField as? FormattableTextField else {
            fatalError()
        }

        if case .invalid(_ /*let error*/) = textField.validation,
            let component = component(for: textField) {
            if textField.text?.isEmpty ?? true {
                component.state = .inactive
            }
            else {
                let errorMessage = component.genericErrorString
                component.state = .invalid(errorString: errorMessage)
                textField.shake()
            }
        }
        return true
    }

    public func textFieldShouldNavigateBackwards(_ textField: FormattableTextField) {
        guard let previous = field(before: textField) else { return }
        previous.becomeFirstResponder()
    }

    public func textField(_ textField: FormattableTextField, didOverflowInput string: String) {
        guard let next = field(after: textField), (next.text?.isEmpty ?? true) else { return }
        next.becomeFirstResponder()
        next.simulateInput(text: string)
    }

}

private extension FormattableTextFieldExampleViewController {

    func component(for textField: UITextField) -> FrictionLessFormComponent? {
        return components.first(where: {$0.textField == textField })
    }

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
