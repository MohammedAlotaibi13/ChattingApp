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
    var messageRef = Database.database().reference().child("messages")
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = "1"
        self.senderDisplayName = "mohammed"

      //  observerMessages()
        
    }
    
    func observerMessages(){
        messageRef.observe(DataEventType.childAdded) { (snapShot) in
            if let dic = snapShot.value as? [String : AnyObject] {
                let mediaType = dic["Media"] as? String
                let senderId = dic["senderId"] as? String
                let displayName = dic["senderDisplayName"] as? String
                if let text = dic["text"] as? String {
                    self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, text: text))
                } else {
                    let fileUrl = dic["FileUrl"] as? String
                    let data = NSData(contentsOf: URL(string: fileUrl!)!)
                    let picture = UIImage(data: data! as Data)
                    let photo = JSQPhotoMediaItem(image: picture)
                    self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, media: photo))
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        return bubbleFactory?.outgoingMessagesBubbleImage(with: .black)
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let newmessages = messageRef.childByAutoId()
        let messageData = ["text" : text , "senderId" : senderId , "senderDisplayName" : senderDisplayName , "Media" : "TEXT"]
        newmessages.setValue(messageData)
      /*  print(senderId)
        print(senderDisplayName)
        print(text)
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        collectionView.reloadData()
        print(messages)*/
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
            let photo = JSQPhotoMediaItem(image: image)
            // get image
            messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo ))
            sendMedia(picture: image, video: nil)
        } else if let video = info[UIImagePickerControllerMediaURL] as? URL {
            let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
            messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: videoItem))
            sendMedia(picture: nil, video: video)
        }
        dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
}

