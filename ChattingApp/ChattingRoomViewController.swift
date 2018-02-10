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
import MobileCoreServices
import AVKit
import FirebaseStorage
import FirebaseAuth
class ChattingRoomViewController: JSQMessagesViewController {
  //  var ref : DatabaseReference!
    var messages = [JSQMessage]()
    var avatarDic = [String : JSQMessagesAvatarImage]()
    var messageRef = Database.database().reference().child("messages")
   
    override func viewDidLoad() {
        super.viewDidLoad()
        if  let current = Auth.auth().currentUser{
        self.senderId = current.uid
            if current.isAnonymous == true {
                self.senderDisplayName = "Anonymous"
            } else {
        self.senderDisplayName = "\(current.displayName!)"
        }
        }
        observerMessages()
    }
    func observeUser(id : String){
        Database.database().reference().child("Users").child(id).observe(DataEventType.value) { (snapShot) in
            if let dic = snapShot.value as? [String : AnyObject] {
                let avatarUrl = dic["photoUrl"] as! String
                self.setAvatar(avatarUrl , messageId : id)
            }
        }
    }
    func setAvatar(_ url: String, messageId : String){
        if url != "" {
            let fileUrl = URL(string: url)
            let data = NSData(contentsOf: fileUrl!)
            let image = UIImage(data: data! as Data)
            let userPic = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
            avatarDic[messageId] = userPic
        } else {
            avatarDic[messageId] = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profileImage"), diameter: 30)
        }
        collectionView.reloadData()
    }
    func observerMessages(){
        messageRef.observe(DataEventType.childAdded) { (snapShot) in
            if let dic = snapShot.value as? [String : AnyObject] {
                let mediaType = dic["Media"] as! String
                let senderId = dic["senderId"] as! String
                let displayName = dic["senderDisplayName"] as? String
                self.observeUser(id:senderId)
                
                switch mediaType {
                case "TEXT" :
                    let text = dic["text"] as? String
                    self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, text: text))
                case "PHOTO":
                let fileUrl = dic["fileUrl"] as? String
                let data = NSData(contentsOf: URL(string: fileUrl!)!)
                let picture = UIImage(data: data! as Data)
                let photo = JSQPhotoMediaItem(image: picture)
                self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, media: photo))
                if self.senderId == senderId {
                    photo?.appliesMediaViewMaskAsOutgoing = true
                } else {
                    photo?.appliesMediaViewMaskAsOutgoing = false 
                    }
                case "Video":
                let fileUrl = dic["fileUrl"] as? String
                let data = URL(string: fileUrl!)
                let video = JSQVideoMediaItem(fileURL: data, isReadyToPlay: true)
                self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, media: video))
                if self.senderId == senderId {
                    video?.appliesMediaViewMaskAsOutgoing = true
                } else {
                    video?.appliesMediaViewMaskAsOutgoing = false
                    }
                default:
                    print("no mediaType found")
                }
                
                self.collectionView.reloadData()
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        if message.senderId == self.senderId {
        return bubbleFactory?.outgoingMessagesBubbleImage(with: .black)
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: .blue)
        }
    }
        
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        return avatarDic[message.senderId]
    }
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let newmessages = messageRef.childByAutoId()
        let messageData = ["text" : text , "senderId" : senderId , "senderDisplayName" : senderDisplayName , "Media" : "TEXT"]
        newmessages.setValue(messageData)
        self.finishSendingMessage()
      
    }
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let sheet = UIAlertController(title: "Medai", message: "Please Select a Media", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let photo = UIAlertAction(title: "Photo Library", style: .default) { (UIAlertAction) in
            self.getMediaFrom(kUTTypeImage)
        }
        let video = UIAlertAction(title: "Vide Library", style: .default) { (UIAlertAction) in
             self.getMediaFrom(kUTTypeMovie)
        }
        sheet.addAction(cancel)
        sheet.addAction(video)
        sheet.addAction(photo)
        self.present(sheet, animated: true, completion: nil)
    }
    
    func getMediaFrom(_ type: CFString) {
        print(type)
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            if let mediaItem = message.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: mediaItem.fileURL)
                let playerVC = AVPlayerViewController()
                playerVC.player = player
                self.present(playerVC, animated: true, completion: nil)
            }
        }
    }
    @IBAction func logOutButton(_ sender: Any) {
        //switch to LogIn page
        do {
           try   Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        print(Auth.auth().currentUser)
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let logInController = storyBoard.instantiateViewController(withIdentifier: "LogInViewController") as! LogInViewController
        // access to windo in AppDelgate
        let appDelgate = UIApplication.shared.delegate as! AppDelegate
        appDelgate.window?.rootViewController = logInController
    }
    
    func sendMedia(picture: UIImage? , video : URL?){
        if let picture = picture {
        let filePath = "\(Auth.auth().currentUser!.uid)/\(NSDate.timeIntervalSinceReferenceDate)"
        print(filePath)
        let data = UIImageJPEGRepresentation(picture, 0.1)
        let metadata = StorageMetadata()
        metadata.contentType = "Image/jpg"
        Storage.storage().reference().child(filePath).putData(data!, metadata: metadata) { (mediaData, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
          let fileUrl = mediaData!.downloadURLs![0].absoluteString
            let newMessage = self.messageRef.childByAutoId()
            let messageData = ["fileUrl" : fileUrl , "senderId" : self.senderId , "senderDisplayName" : self.senderDisplayName , "Media" : "PHOTO"]
            newMessage.setValue(messageData)
        }
        } else if let video = video {
            let filePath = "\(Auth.auth().currentUser?.uid)/\(NSDate.timeIntervalSinceReferenceDate)"
            print(filePath)
            let data = NSData(contentsOf: video)
            let metadata = StorageMetadata()
            metadata.contentType = "Video"
            Storage.storage().reference().child(filePath).putData(data! as Data, metadata: metadata) { (mediaData, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                let fileUrl = mediaData!.downloadURLs![0].absoluteString
                let newMessage = self.messageRef.childByAutoId()
                let messageData = ["fileUrl" : fileUrl , "senderId" : self.senderId , "senderDisplayName" : self.senderDisplayName , "Media" : "Video"]
                newMessage.setValue(messageData)
            }
        }
    }
    
}
extension ChattingRoomViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did finish picking media eith info ")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            sendMedia(picture: image, video: nil)
        } else if let video = info[UIImagePickerControllerMediaURL] as? URL {
            sendMedia(picture: nil, video: video)
        }
        dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
}

