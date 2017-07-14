//
//  FormattableTextField.swift
//  Raizlabs
//
//  Created by Jason Clark on 3/24/17.
//
//

import UIKit

// MARK: - Errors
enum FormattableTextFieldError: Error {
    case invalidInput
}

// MARK: - FormattableTextField
open class FormattableTextField: UITextField {
    fileprivate let delegateProxy: DelegateProxy

    init(formatter: TextFieldFormatter) {
        self.delegateProxy = DelegateProxy(formatter: formatter)
        super.init(frame: .zero)

        self.delegate = self.delegateProxy
        addTarget(delegateProxy, action: #selector(DelegateProxy.editingChanged(textField:)), for: .editingChanged)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Accessors
extension FormattableTextField {

    var isValid: Bool {
        if case ValidationResult.valid = validation {
            return true
        }
        else {
            return false
        }
    }

    var isComplete: Bool {
        return formatter.isComplete(unformattedText)
    }

    var validation: ValidationResult {
        return formatter.validate(unformattedText)
    }

    var unformattedText: String {
        guard let text = text else { return "" }
        return formatter.removeFormatting(text)
    }

    var formatter: TextFieldFormatter {
        get {
            return delegateProxy.formatter
        }
        set {
            delegateProxy.formatter = newValue
        }
    }

    override open var delegate: UITextFieldDelegate? {
        get {
            return delegateProxy.delegate
        }
        set {
            super.delegate = delegateProxy
            if !(newValue is DelegateProxy) {
                delegateProxy.delegate = newValue
            }
        }
    }

}

// MARK: Methods
extension FormattableTextField {

    /// Programmatically set text and format. Forgo the delegate and validation responder train.
    func setTextAndFormat(text: String) {
        let event = EditingEvent(oldValue: self.text ?? "",
                                 editRange: self.textRange,
                                 selectedTextRange: self.selectedRange,
                                 editString: text,
                                 newValue: text,
                                 newCursorPosition: text.characters.count)
        let formatted = formatter.format(editingEvent: event)
        if case .valid(let formattingResult) = formatted {
            self.text = formattingResult.formattedString
        }
    }

    /// Simulate the manual entry of text in an optional subrange. Format, validate, and report up the responder chain.
    func simulateInput(text: String, range: NSRange? = nil) {
        let editRange = range ?? self.textRange
        _ = delegateProxy.textField(self, shouldChangeCharactersIn: editRange, replacementString: text)
    }

}

// MARK: Overrides
extension FormattableTextField {

    override open func deleteBackward() {
        super.deleteBackward()

        if text?.characters.count == 0 {
            (delegate as? FormattableTextFieldDelegate)?.textFieldShouldNavigateBackwards(self)
        }
    }

}

// MARK: Delegate Proxy Private Implementation
fileprivate extension FormattableTextField {

    class DelegateProxy: NSObject, UITextFieldDelegate {

        weak var delegate: UITextFieldDelegate?
        var formatter: TextFieldFormatter

        init(formatter: TextFieldFormatter) {
            self.formatter = formatter
            super.init()
        }

    }
}

extension FormattableTextField.DelegateProxy {

    @objc func editingChanged(textField: UITextField) {
        guard let textField = textField as? FormattableTextField else {
            fatalError("")
        }
        (delegate as? FormattableTextFieldDelegate)?.editingChanged(textField: textField)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true else {
            return false
        }

        guard let textField = textField as? FormattableTextField else {
            fatalError("")
        }

        guard formatter.containsValidChars(text: string) else {
            (delegate as? FormattableTextFieldDelegate)?.textField(textField, invalidInput: FormattableTextFieldError.invalidInput)
            return false
        }

        //if user is inserting text at the end of a complete text field, alert delegate to potentially forward the input
        if range.location == textField.text?.characters.count && string.characters.count > 0 {
            if formatter.isComplete(textField.unformattedText) {
                (delegate as? FormattableTextFieldDelegate)?.textField(textField, didOverflowInput: string)
                return false
            }
        }

        if let indexRange = textField.text?.range(fromNSRange: range) {
            let newText = textField.text?.replacingCharacters(in: indexRange, with: string)
            let newRange = range.location + string.characters.count

            let event = EditingEvent(oldValue: textField.text ?? "",
                                     editRange: range,
                                     selectedTextRange: textField.selectedRange,
                                     editString: string,
                                     newValue: newText ?? "",
                                     newCursorPosition: newRange)

            //Adjust the editing event for
            //  1. deleting a single formatting charaacter
            var adjustedEdit = formatter.handleDeletionOfFormatting(editingEvent: event)
            //  2. optionally removing all characters trailing a delte
            adjustedEdit = formatter.removeCharactersTrailingDelete(textField: textField, editingEvent: adjustedEdit)
            adjustedEdit.newValue = formatter.removeFormatting(adjustedEdit.newValue, cursorPosition: &adjustedEdit.newCursorPosition)

            //then hand the edit to the formatter
            let result =  formatter.format(editingEvent: adjustedEdit)
            switch result {
            case .valid(let string, let cursorPosition):
                textField.text = string
                textField.selectedTextRange = textField.textRange(cursorOffset: cursorPosition)
                textField.sendActions(for: .editingChanged)
            case .invalid(let error):
                (delegate as? FormattableTextFieldDelegate)?.textField(textField, invalidInput: error)
                return false
            }
        }
        return false
    }

}

// MARK: Delegate Proxy Forwarding
extension FormattableTextField.DelegateProxy {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldBeginEditing?(textField) ?? true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldDidBeginEditing?(textField)
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldEndEditing?(textField) ?? true
    }

    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        guard let delegate = delegate else { return }
        if delegate.responds(to: #selector(UITextFieldDelegate.textFieldDidEndEditing(_:reason:))) {
            delegate.textFieldDidEndEditing?(textField, reason: reason)
        }
        else {
            delegate.textFieldDidEndEditing?(textField)
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldClear?(textField) ?? true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldReturn?(textField) ?? true
    }
    
}
