//
//  FinishRegistrationViewController.swift
//  ChatApp
//
//  Created by Luis Calvillo on 4/5/19.
//  Copyright © 2019 Luis Calvillo. All rights reserved.
//

import UIKit

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

    }
    
    // MARK: IBActions
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
    }
    

    @IBAction func doneButtonPressed(_ sender: Any) {
    }
    

}
