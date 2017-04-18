//
//  ChatViewController.swift
//  GoChat
//
//  Created by Lewis Rashe on 4/13/17.
//  Copyright © 2017 Lewis Rashe. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

//Changed UI view from UIViewController to JSQMessagesViewController
class ChatViewController: JSQMessagesViewController {
    
    //Encodes inputs into message objects
    var messages = [JSQMessage]()
    
    var messageRef = FIRDatabase.database().reference().child("messages")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Chat view needs senderId and senderDisplayName to work
        self.senderId = "1"
        self.senderDisplayName = "lewis831"

        // Do any additional setup after loading the view.
        
        //Checks if data is being sent into database
        //messageRef.childByAutoId().setValue("first message")
        //messageRef.childByAutoId().setValue("second message")
        
        //Retrieves data from Firebase database
        //messageRef.observe(FIRDataEventType.value) { (snapshot: FIRDataSnapshot) in
        //    print("text")
        //    if let dict = snapshot.value as? NSDictionary {
        //        print(dict)
        //    }
        //}
        observeMessages()
    }
    
    //Function to push and pull data from and to Firebase database
    func observeMessages() {
        messageRef.observe(.childAdded, with: { snapshot in
            //print(snapshot.value as Any)
            if let dict = snapshot.value as? [String: AnyObject] {
                let MediaType = dict["MediaType"] as! String
                let senderId = dict["senderId"] as! String
                let senderName = dict["senderName"] as! String
                
                print(dict)
                
                if let text = dict["text"] as? String {
                self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                } else {
                    //Picture media data in Firebase
                    let fileURL = dict["fileURL"] as! String
                    let data = NSData(contentsOf: URL(string: fileURL)!)
                    let picture = UIImage(data: data! as Data)
                    let photo = JSQPhotoMediaItem(image: picture)
                    self.messages.append(JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: photo))
                }
                
                self.collectionView.reloadData()
            }
        })
    }
    
    //Function for Send button functionality
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        
        
        //messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        //collectionView.reloadData()
        //print(messages)
        
        let newMessage = messageRef.childByAutoId()
        let messageData = ["text": text, "senderId": senderId, "senderName": senderDisplayName, "MediaType": "TEXT"]
        newMessage.setValue(messageData)
    }
    
    //Function for attachment button functionality
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("didPressAccessoryButton")
        
        //Feature selects media to be sent
        let sheet = UIAlertController(title: "Media Message", message: "Please select a media", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alert: UIAlertAction) in
            
        }
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default) { (alert: UIAlertAction) in
            //Check getMediaFrom() function to understand what this line does
            self.getMediaFrom(type: kUTTypeImage)
        }
        
        let videoLibrary = UIAlertAction(title: "Video Library", style: UIAlertActionStyle.default) { (alert: UIAlertAction) in
            //Check getMediaFrom() function to understand what this line does
            self.getMediaFrom(type: kUTTypeMovie)
        }
        
        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        self.present(sheet, animated: true, completion: nil)
        
        
        //Sending photos feature
        //let imagePicker = UIImagePickerController()
        //To get this line to work I added to ChatViewController at the bottom UINavigationControllerDelegate
        //imagePicker.delegate = self
        //Fixed line: http://stackoverflow.com/questions/38449014/cannot-call-value-of-non-function-type-uiviewcontroller
        //Note to get the image picker to work I went to file Info.plist and added Key Privacy - Photo Library Usage Description as Type string
        //self.present(imagePicker, animated: true, completion: nil)
    }
    
    //Get media from function to pull media data to be sent
    func getMediaFrom(type: CFString) {
        print(type)
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    //Small note NSIndexPath is now just IndexPath in Swift 3
    //Link explaining this change: https://www.codeschool.com/blog/2016/09/14/evolving-to-swift-3/
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    //Function to display message bubbles 
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        //Style the messages text box bubble color I used was blue
        return bubbleFactory?.outgoingMessagesBubbleImage(with: .blue)
    }
    
    //This displays little circle for user avatar that appears next to message text box bubble
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    //To find line use hold command button and click on: JSQMessagesViewController -> JSQMessagesCollectionViewDataSource -> UICollectionViewDataSource
    //This line specifies the number of items that will be displayed in the collectionView
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //The number of items that will be displayed is simply the number of messages returned by the count property of array messages this array contains all messages sent by users
        print("number of items:\(messages.count)")
        return messages.count
    }
    
    //To find line use hold command button and click on: JSQMessagesViewController -> JSQMessagesCollectionViewDataSource -> UICollectionViewDataSource
    //This collectionView cell is used to create cells to display messages
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //UICollectionViewCell as JSQMessagesCollectionViewCell
        //Fixed line: http://stackoverflow.com/questions/38536636/cannot-call-value-of-non-function-type
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    //Checks whether it's a video or picture message so it can be played
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        print("didTapMessageBubbleAt: \(indexPath.item)")
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            if let mediaItem = message.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: mediaItem.fileURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true, completion: nil)
            }
        }
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutDidTapped(_ sender: Any) {
        //Important note of what this code does: Anonymously log user out and switch view to login page
        
        //Create a main storyboard instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //From main storyboard instantiate a navigation controller
        //To connect this code go to Main.storyboard -> LoginViewController -> identity inspector -> Storyboard ID -> enter value: "LoginVC"
        let LogInVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        
        //Get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //Set LoginIn View Controller as root view controller
        appDelegate.window?.rootViewController = LogInVC

    }

    //Handles sending media whether picture or video
    //Stores this media data such as picture or video in Firebase storage
    func sendMedia(picture: UIImage?, video: URL?) {
        print(picture as Any)
        print(FIRStorage.storage().reference())
        if let picture = picture {
            let filePath = "\(FIRAuth.auth()!.currentUser!)/\(Date.timeIntervalSinceReferenceDate)"
            print(filePath)
            //Compresses picture file to 0.1 or 10% of original file size
            let data = UIImageJPEGRepresentation(picture, 0.1)
            let metadata = FIRStorageMetadata()
            //Image file type will be uploaded as jpg
            metadata.contentType = "image/jpg"
            print(FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata, completion: { (metadata, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                    return
                }
                let fileURL = metadata!.downloadURLs![0].absoluteString
                
                let newMessage = self.messageRef.childByAutoId()
                let messageData = ["fileURL": fileURL, "senderId": self.senderId, "senderName": self.senderDisplayName, "MediaType": "PHOTO"]
                newMessage.setValue(messageData)
                
            }))
        } else if let video = video {
            let filePath = "\(FIRAuth.auth()!.currentUser!)/\(Date.timeIntervalSinceReferenceDate)"
            print(filePath)
            //Compresses picture file to 0.1 or 10% of original file size
            let data = NSData(contentsOf: video)
            let metadata = FIRStorageMetadata()
            //Video file type will be uploaded as mp4
            metadata.contentType = "video/mp4"
            print(FIRStorage.storage().reference().child(filePath).put(data! as Data, metadata: metadata, completion: { (metadata, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                    return
                }
                let fileURL = metadata!.downloadURLs![0].absoluteString
                
                let newMessage = self.messageRef.childByAutoId()
                let messageData = ["fileURL": fileURL, "senderId": self.senderId, "senderName": self.senderDisplayName, "MediaType": "VIDEO"]
                newMessage.setValue(messageData)
            }))
        }
    }
}

//This extension handles the sending of the photo and video attachments
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did finish picking")
        //Get the image
        print(info)
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
        let photo = JSQPhotoMediaItem(image: picture)
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
            sendMedia(picture: picture, video: nil)
        }
        else if let video = info[UIImagePickerControllerMediaURL] as? URL {
            let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
            messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: videoItem))
            sendMedia(picture: nil, video: video)
        }
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
        
    }
}
