//
//  ChattingRoomViewController.swift
//  ChattingApp
//
//  Created by محمد عايض العتيبي on 5/10/1439 AH.
//  Copyright © 1439 code schoole. All rights reserved.
//

import UIKit
import Firebase

class ChattingRoomViewController: UIViewController {
    var ref : DatabaseReference!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
    }

  
 
    

}

