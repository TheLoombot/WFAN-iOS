//
//  CustomUITextField.swift
//  WFAN
//
//  Created by Usman Mughal on 22/08/2017.
//  Copyright © 2017 Usman Mughal. All rights reserved.
//

import UIKit

@objc protocol CustomTextFieldDelegate {
    @objc optional func keyboardDoneButtonTap()
    @objc optional func textFieldClearButtonTap()
}

class CustomUITextField: UITextField,UITextFieldDelegate {
    var clearButton: UIButton!
    var customDelegate:CustomTextFieldDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        addClearIcon()
    }
    required override init(frame: CGRect) {
        super.init(frame: frame)
        addClearIcon()
    }
    func addSearchIcon()
    {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "search")
        self.leftView = imageView
        self.leftViewMode = .always
    }
    func addClearIcon()
    {
        clearButton  = UIButton(type: .custom)
        clearButton.setImage(UIImage(named: "cross"), for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        clearButton.addTarget(self, action: #selector(clear(sender:)), for: .touchUpInside)
        self.rightView = clearButton
        self.rightViewMode = .whileEditing
        
        clearButton.isHidden = true
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.leftView = leftView
        self.leftViewMode = .always
        
        delegate = self
    }
    
    @objc func clear(sender : UIButton) {
        self.text = ""
        sender.isHidden = true
        customDelegate?.textFieldClearButtonTap?()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            
            if txtAfterUpdate == "" {
                clearButton.isHidden = true
            }
            else
            {
                clearButton.isHidden = false
            }
        }
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.text != ""
        {
            clearButton.isHidden = false
            
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        clearButton.isHidden = true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        customDelegate?.keyboardDoneButtonTap?()
        
        return true
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
    }
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= 10;
        return rect;
    }
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += 5;
        return rect;
    }
    
}
