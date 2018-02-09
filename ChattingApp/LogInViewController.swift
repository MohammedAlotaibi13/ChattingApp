//
//  LogInViewController.swift
//  ChattingApp
//
//  Created by محمد عايض العتيبي on 5/11/1439 AH.
//  Copyright © 1439 code schoole. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
class  LogInViewController: UIViewController , GIDSignInUIDelegate , GIDSignInDelegate {

    @IBOutlet weak var anonymousButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // design border of anonymously login
        anonymousButton.layer.borderWidth = 2.0
        anonymousButton.layer.borderColor = UIColor.white.cgColor
        // google SignIn
        GIDSignIn.sharedInstance().uiDelegate = self
         GIDSignIn.sharedInstance().delegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(Auth.auth().currentUser)
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                print(user)
                Helper.helper.switchToChatController()
            } else {
                print("no user found")
            }
        }
    }

    @IBAction func loginAnonmously(_ sender: Any) {
        // log in anonymously
        Helper.helper.loginAnonmously()
    }
    
    
    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        } else {
            Helper.helper.signInWithGoogle(authentication: user.authentication)
        }
    }
    
    
}
