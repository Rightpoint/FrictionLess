//
//  FormattableTextField.swift
//  Raizlabs
//
//  Created by Jason Clark on 3/24/17.
//
//

import UIKit

// MARK: - Errors
public enum FormattableTextFieldError: Error {
    case invalidInput
}

// MARK: - FormattableTextField
open class FormattableTextField: UITextField {

    // MARK: Appearance
    public dynamic var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    public dynamic var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    public dynamic var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    // MARK: Initialization
    fileprivate let delegateProxy: DelegateProxy

    public init(formatter: TextFieldFormatter? = nil) {
        self.delegateProxy = DelegateProxy()
        super.init(frame: .zero)
        self.formatter = formatter
        self.delegate = self.delegateProxy
        addTarget(delegateProxy, action: #selector(DelegateProxy.editingChanged(textField:)), for: .editingChanged)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: Accessors
extension FormattableTextField {

    public var isValid: Bool {
        if case ValidationResult.valid = validation {
            return true
        }
        else {
            return false
        }
    }

    public var isComplete: Bool {
        return formatter?.isComplete(unformattedText) ?? true
    }

    public var validation: ValidationResult {
        return formatter?.validate(unformattedText) ?? .valid
    }

    public var unformattedText: String {
        guard let text = text else { return "" }
        return formatter?.removeFormatting(text) ?? text
    }

    public var formatter: TextFieldFormatter? {
        get {
            return delegateProxy.formatter
        }
        set {
            delegateProxy.formatter = newValue
        }
    }

    override weak open var delegate: UITextFieldDelegate? {
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
public extension FormattableTextField {

    /// Programmatically set text and format. Forgo the delegate and validation responder train.
    public func setTextAndFormat(text: String) {
        guard let formatter = formatter else {
            self.text = text
            return
        }

        let event = EditingEvent(oldValue: self.text ?? "",
                                 editRange: self.textRange,
                                 selectedTextRange: self.selectedRange,
                                 editString: text,
                                 newValue: text,
                                 newCursorPosition: text.characters.count)
        let formatted = formatter.format(editingEvent: event)
        if case .valid(let formattingResult) = formatted {
            let formattedText: String
            if let result = formattingResult {
                switch result {
                case .text(let string): formattedText = string
                case .textAndCursor(let string, _): formattedText = string
                }
            }
            else {
                formattedText = text
            }

            self.text = formattedText
        }
    }

    /// Simulate the manual entry of text in an optional subrange. Format, validate, and report up the responder chain.
    public func simulateInput(text: String, range: NSRange? = nil) {
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
        var formatter: TextFieldFormatter?

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

        let delegateResponse = delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true

        guard let formatter = formatter, delegateResponse == true else {
            return delegateResponse
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
            let value = formatter.removeFormatting(adjustedEdit.newValue)
            adjustedEdit.newCursorPosition = adjustedEdit.cursorPosition(inFormattedText: value, withinSet: formatter.inputCharacterSet)
            adjustedEdit.newValue = value

            //then hand the edit to the formatter
            let result =  formatter.format(editingEvent: adjustedEdit)
            let formattedText: String
            let cursorPosition: Int

            switch result {
            case .valid(let formattingResult):
                switch formattingResult {
                case .none:
                    formattedText = adjustedEdit.newValue
                    cursorPosition = adjustedEdit.newCursorPosition
                case .some(.text(let string)):
                    formattedText = string
                    cursorPosition = adjustedEdit.cursorPosition(inFormattedText: string, withinSet: formatter.inputCharacterSet)
                case .some(.textAndCursor(let string, let cursor)):
                    formattedText = string
                    cursorPosition = cursor
                }
                textField.text = formattedText
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
