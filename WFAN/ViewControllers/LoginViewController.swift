//
//  LoginViewController.swift
//  WFAN
//
//  Created by Usman Mughal on 22/08/2017.
//  Copyright © 2017 Usman Mughal. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,CustomTextFieldDelegate{
    
    @IBOutlet weak var dJNameTextField: CustomUITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dJNameTextField.customDelegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        dJNameTextField.becomeFirstResponder()
    }
    
    func keyboardGoButtonTap() {
        
        
        if dJNameTextField.text == ""
        {
            return
        }
        
        self.view.endEditing(true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mainScreenViewController  = storyboard.instantiateViewController(withIdentifier: "MainScreenViewController") as! MainScreenViewController
        
        mainScreenViewController.currentDJName = dJNameTextField.text
        
        self.present(mainScreenViewController, animated: true, completion: nil)
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
