//
//  LogInViewController.swift
//  ChattingApp
//
//  Created by محمد عايض العتيبي on 5/11/1439 AH.
//  Copyright © 1439 code schoole. All rights reserved.
//

import UIKit

class  LogInViewController: UIViewController {

    @IBOutlet weak var anonymousButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // design border of anonymously login
        anonymousButton.layer.borderWidth = 2.0
        anonymousButton.layer.borderColor = UIColor.white.cgColor

    }

    @IBAction func loginAnonmously(_ sender: Any) {
    }
    
    
    @IBAction func googleLogin(_ sender: Any) {
    }
    
}
