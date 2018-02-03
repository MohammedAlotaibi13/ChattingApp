//
//  ChattingRoomViewController.swift
//  ChattingApp
//
//  Created by محمد عايض العتيبي on 5/10/1439 AH.
//  Copyright © 1439 code schoole. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController
class ChattingRoomViewController: JSQMessagesViewController {
    var ref : DatabaseReference!
    var messages = [JSQMessage]()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = "1"
        self.senderDisplayName = "mohammed"
        ref = Database.database().reference()
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        print("hi")
    }
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("hi again")
    }
    @IBAction func logOutButton(_ sender: Any) {
        //switch to LogIn page
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let logInController = storyBoard.instantiateViewController(withIdentifier: "LogInViewController") as! LogInViewController
        // access to windo in AppDelgate
        let appDelgate = UIApplication.shared.delegate as! AppDelegate
        appDelgate.window?.rootViewController = logInController
    }
    
    
  
 
    

}

