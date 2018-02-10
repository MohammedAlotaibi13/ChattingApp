//
//  Helper.swift
//  ChattingApp
//
//  Created by محمد عايض العتيبي on 16/05/1439 AH.
//  Copyright © 1439 code schoole. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseDatabase
class Helper {
    static let helper = Helper()
    
    func loginAnonmously() {
        // log in anonymously
        Auth.auth().signInAnonymously { (user, error) in
            if error == nil {
                print(user?.uid)
                let newUser = Database.database().reference().child("Users").child(user!.uid)
                newUser.setValue(["DisplayName" : "Anonymous" , "id" : "\(user!.uid)" , "photoUrl" : ""])
                //switch to chat room
               self.switchToChatController()
            } else {
                print(error?.localizedDescription)
                return
            }
        }
        
    }
    
    func signInWithGoogle(authentication: GIDAuthentication){
      
    
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                let newUser = Database.database().reference().child("Users").child(user!.uid)
                newUser.setValue(["DisplayName" : "\(user!.displayName!)" , "id" : "\(user!.uid)" , "photoUrl" : "\(user!.photoURL!)"])
                self.switchToChatController()
            }
        }
    }
    
    func switchToChatController(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let navigationC = storyBoard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
        // access to windo in AppDelgate
        let appDelgate = UIApplication.shared.delegate as! AppDelegate
        appDelgate.window?.rootViewController = navigationC
    }
        

}
    

