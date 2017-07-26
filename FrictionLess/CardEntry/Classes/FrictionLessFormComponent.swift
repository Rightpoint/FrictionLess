//
//  FrictionLessFormComponent.swift
//  FrictionLess
//
//  Created by Jason Clark on 7/19/17.
//
//

import Foundation
import Anchorage

public class FrictionLessFormTitleLabel: UILabel {}
public class FrictionLessFormValidationLabel: UILabel {}

open class FrictionLessFormComponent: UIView, FormComponent {

    public var state: FormComponentState = .inactive {
        didSet {
            validationLabel.text = state.errorMessage
        }
    }

    public var title: String? {
        set { titleLabel.text = newValue }
        get { return titleLabel.text }
    }

    public var placeholder: String? {
        set { textField.placeholder = newValue }
        get { return textField.placeholder }
    }

    public var isEnabled: Bool = true {
        didSet {
            alpha = isEnabled ? 1.0 : 0.3 //TODO param
            textField.isEnabled = isEnabled
            isUserInteractionEnabled = isEnabled
        }
    }

    public var textField = FormattableTextField()

    public let titleLabel: UILabel = {
        let label = FrictionLessFormTitleLabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
    }()

    public let validationLabel: UILabel = {
        let label = FrictionLessFormValidationLabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textColor = .red
        return label
    }()

    fileprivate var paddingConstraints: (
        titleToTextField: NSLayoutConstraint?,
        textFieldToValidation: NSLayoutConstraint?
    )

    public init() {
        super.init(frame: .zero)
        configureView()
        textField.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension FrictionLessFormComponent {

    var genericErrorString: String? {
        if let title = title, !textField.isValid {
            if textField.text?.isEmpty ?? true {
                return ""
                    // TODO Localized.Form.Validation.Generic.required(title)
            }
            else {
                return "" //TODO Localized.Form.Validation.Generic.invalid(title)
            }
        }
        return nil
    }

}

// MARK: - Appearance
extension FrictionLessFormComponent {

    fileprivate enum Default {
        static let titleToTextFieldPadding = CGFloat(3)
        static let textFieldToValidationPadding = CGFloat(4)
    }

    public dynamic var titleToTextFieldPadding: CGFloat {
        set { paddingConstraints.titleToTextField?.constant = newValue }
        get { return paddingConstraints.titleToTextField?.constant ?? Default.titleToTextFieldPadding }
    }

    public dynamic var textFieldToValidationPadding: CGFloat {
        set { paddingConstraints.textFieldToValidation?.constant = newValue }
        get { return paddingConstraints.textFieldToValidation?.constant ?? Default.textFieldToValidationPadding }
    }

}

extension FrictionLessFormComponent {

    func configureView() {
        addSubview(titleLabel)
        addSubview(textField)
        addSubview(validationLabel)

        titleLabel.topAnchor == layoutMarginsGuide.topAnchor
        titleLabel.horizontalAnchors == layoutMarginsGuide.horizontalAnchors

        paddingConstraints.titleToTextField =
            textField.topAnchor == titleLabel.bottomAnchor + titleToTextFieldPadding
        textField.horizontalAnchors == layoutMarginsGuide.horizontalAnchors

        paddingConstraints.textFieldToValidation =
            validationLabel.topAnchor == textField.bottomAnchor + textFieldToValidationPadding
        validationLabel.horizontalAnchors == layoutMarginsGuide.horizontalAnchors
        validationLabel.heightAnchor == validationLabel.font.pointSize
        validationLabel.bottomAnchor == layoutMarginsGuide.bottomAnchor
    }

}

extension FrictionLessFormComponent {

    @objc func editingDidBegin() {
        //TODO
    }

    @objc func editingDidEnd() {
        //TODO
    }

}

extension FrictionLessFormComponent {

    override open var isFirstResponder: Bool {
        return textField.isFirstResponder
    }

    override open var canBecomeFirstResponder: Bool {
        return textField.canBecomeFirstResponder
    }

    override open func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }

    override open func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }

}

extension UITextField {

    func shakeIfFirstResponder() {
        if isFirstResponder {
            shake()
        }
    }

    func shake() {
        let animationKey = "shake"
        layer.removeAnimation(forKey: animationKey)

        let shake: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.duration = 0.3
            animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0 ]
            return animation
        }()
        layer.add(shake, forKey: animationKey)
    }
    
}
