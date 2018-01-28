//
//  ViewController.swift
//  ChattingApp
//
//  Created by محمد عايض العتيبي on 5/10/1439 AH.
//  Copyright © 1439 code schoole. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    var ref : DatabaseReference!

    @IBOutlet weak var nameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        logIn()
        ref = Database.database().reference()
    }

  
    func logIn(){
        Auth.auth().signInAnonymously { (user, error) in
            if error != nil {
                print("Cant log in")
            } else {
                print("User id \(user?.uid)")
            }
        }
    }
    @IBAction func sendButton(_ sender: Any) {
        var dic : [String:Any] = ["text" : nameTextField.text! , "name" : "Mohammed" , "postDate" : ServerValue.timestamp() ]
        self.ref.child("chat").childByAutoId().setValue(dic)
    }
    

}

