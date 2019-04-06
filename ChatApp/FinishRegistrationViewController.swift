//
//  FinishRegistrationViewController.swift
//  ChatApp
//
//  Created by Luis Calvillo on 4/5/19.
//  Copyright © 2019 Luis Calvillo. All rights reserved.
//

import UIKit
import ProgressHUD

class FinishRegistrationViewController: UIViewController {
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var email: String!
    var password: String!
    var avatarImage: UIImage?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(email, password)
    }
    
    // MARK: IBActions
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        cleanTextFields()
        dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func doneButtonPressed(_ sender: Any) {
        
        dismissKeyboard()
        ProgressHUD.show("Registering")
        
        if nameTextField.text != "" && lastNameTextField.text != "" && countryTextField.text != "" && cityTextField.text != ""
            && phoneTextField.text != "" {
            
            FUser.registerUserWith(email: email, password: password, firstName: nameTextField.text!, lastName: lastNameTextField.text!) { (error) in
                
                if error != nil {
                    ProgressHUD.dismiss()
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                
                self.registerUser()
            }
        } else {
            ProgressHUD.showError("All fields are required!")
        }
    }
    // MARK: Helpers
    
    func registerUser() {
        let fullName = nameTextField.text! + " " + lastNameTextField.text!
        
        var tempDictionary : Dictionary = [kFIRSTNAME : nameTextField.text!, kLASTNAME : lastNameTextField.text!, kFULLNAME : fullName, kCOUNTRY : countryTextField.text!, kCITY : cityTextField.text!, kPHONE : phoneTextField.text!] as [String : Any]
        
        if avatarImage == nil {
            imageFromInitials(firstName: nameTextField.text!, lastName: lastNameTextField.text!) { (avatarInitials) in
                
                let avatarIMG = avatarInitials.jpegData(compressionQuality: 0.7)
                let avatar = avatarIMG!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                tempDictionary[kAVATAR] = avatar
                
                self.finishRegistration(withValues: tempDictionary)
            }
            
            
            
        } else {
            
            let avatarData = avatarImage?.jpegData(compressionQuality: 0.7)
            let avatar = avatarData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            tempDictionary[kAVATAR] = avatar

            self.finishRegistration(withValues: tempDictionary)

            
            
        }
    }
    
    
    func finishRegistration(withValues: [String : Any]) {
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    ProgressHUD.showError(error!.localizedDescription)
                    print(error!.localizedDescription)
                }
                
                return
            }
            
            ProgressHUD.dismiss()
            self.goToApp()
        }
    }
    
    func goToApp() {
        cleanTextFields()
        dismissKeyboard()
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        
        self.present(mainView, animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    func cleanTextFields() {
        nameTextField.text = ""
        lastNameTextField.text = ""
        countryTextField.text = ""
        cityTextField.text = ""
        phoneTextField.text = ""
    }

}
