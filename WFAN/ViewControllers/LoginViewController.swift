//
//  LoginViewController.swift
//  WFAN
//
//  Created by Usman Mughal on 22/08/2017.
//  Copyright © 2017 Usman Mughal. All rights reserved.
//

import UIKit
import StoreKit
import MediaPlayer

class LoginViewController: UIViewController,CustomTextFieldDelegate,SKCloudServiceSetupViewControllerDelegate{
    
    @IBOutlet weak var dJNameTextField: CustomUITextField!
    
    /// The instance of `AuthorizationManager` which is responsible for managing authorization for the application.
    lazy var authorizationManager: AuthorizationManager = {
        return AuthorizationManager(appleMusicManager: self.appleMusicManager)
    }()
    var appleMusicManager = AppleMusicManager()
    /// A boolean value representing if a `SKCloudServiceSetupViewController` was presented while the application was running.
    var didPresentCloudServiceSetup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dJNameTextField.customDelegate = self
        
        // Add the notification observers needed to respond to events from the `AuthorizationManager` and `UIApplication`.
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAuthorizationManagerDidUpdateNotification),
                                       name: AuthorizationManager.cloudServiceDidUpdateNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAuthorizationManagerDidUpdateNotification),
                                       name: AuthorizationManager.authorizationDidUpdateNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAuthorizationManagerDidUpdateNotification),
                                       name: .UIApplicationWillEnterForeground,
                                       object: nil)
        
        handleAuthorizationManagerDidUpdateNotification()
    }
    
    deinit {
        // Remove all notification observers.
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self,
                                          name: AuthorizationManager.cloudServiceDidUpdateNotification,
                                          object: nil)
        notificationCenter.removeObserver(self,
                                          name: AuthorizationManager.authorizationDidUpdateNotification,
                                          object: nil)
        notificationCenter.removeObserver(self,
                                          name: .UIApplicationWillEnterForeground,
                                          object: nil)
    }
    @objc func handleAuthorizationManagerDidUpdateNotification() {
       
        DispatchQueue.main.async {
            if SKCloudServiceController.authorizationStatus() == .notDetermined || MPMediaLibrary.authorizationStatus() == .notDetermined {
                
                self.authorizationManager.requestCloudServiceAuthorization()
                self.authorizationManager.requestMediaLibraryAuthorization()
                
            } else if SKCloudServiceController.authorizationStatus() == .denied || MPMediaLibrary.authorizationStatus() == .denied{
                
                UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
                
            }else {
           
                
                if self.authorizationManager.cloudServiceCapabilities.contains(SKCloudServiceCapability.musicCatalogPlayback) {
               
                    self.authorizationManager.requestStorefrontCountryCode()
                    self.dJNameTextField.isUserInteractionEnabled = true
                    self.dJNameTextField.becomeFirstResponder()
                    
                }
                else
                {
                    if self.authorizationManager.cloudServiceCapabilities.contains(.musicCatalogSubscriptionEligible) &&
                        !self.authorizationManager.cloudServiceCapabilities.contains(.musicCatalogPlayback) {
                        
                        self.presentCloudServiceSetup()
                        
                    }
                }

            }

        }
    }
    // MARK: SKCloudServiceSetupViewController Method
    
    func presentCloudServiceSetup() {
        
        guard didPresentCloudServiceSetup == false else {
            return
        }
        
        /*
         If the current `SKCloudServiceCapability` includes `.musicCatalogSubscriptionEligible`, this means that the currently signed in iTunes Store
         account is elgible for an Apple Music Trial Subscription.  To provide the user with an option to sign up for a free trial, your application
         can present the `SKCloudServiceSetupViewController` as demonstrated below.
         */
        
        let cloudServiceSetupViewController = SKCloudServiceSetupViewController()
        cloudServiceSetupViewController.delegate = self
        
        cloudServiceSetupViewController.load(options: [.action: SKCloudServiceSetupAction.subscribe]) { [weak self] (result, error) in
         
            guard error == nil else {
                fatalError("An Error occurred: \(error!.localizedDescription)")
            }
            
            if result {
                self?.present(cloudServiceSetupViewController, animated: true, completion: nil)
                self?.didPresentCloudServiceSetup = true
            }
        }
    }
    func cloudServiceSetupViewControllerDidDismiss(_ cloudServiceSetupViewController: SKCloudServiceSetupViewController) {
        
        self.handleAuthorizationManagerDidUpdateNotification()
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func keyboardDoneButtonTap() {
        
        if dJNameTextField.text == ""
        {
            return
        }
        
        self.view.endEditing(true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mainScreenViewController  = storyboard.instantiateViewController(withIdentifier: "MainScreenViewController") as! MainScreenViewController
        
        mainScreenViewController.currentDJName = dJNameTextField.text
        
        mainScreenViewController.authorizationManager = self.authorizationManager
        
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
