//
//  ChatViewController.swift
//  GoChat
//
//  Created by Lewis Rashe on 4/13/17.
//  Copyright © 2017 Lewis Rashe. All rights reserved.
//

import UIKit
import JSQMessagesViewController

//Changed UI view from UIViewController to JSQMessagesViewController
class ChatViewController: JSQMessagesViewController {
    
    //Encodes inputs into message objects
    var messages = [JSQMessage]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Chat view needs senderId and senderDisplayName to work
        self.senderId = "1"
        self.senderDisplayName = "lewis831"

        // Do any additional setup after loading the view.
    }
    
    //Function for Send button functionality
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        print("didPressSendButton")
        print("\(text)")
        print(senderId)
        print(senderDisplayName)
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        collectionView.reloadData()
        print(messages)
    }
    
    //Function for attachment button functionality
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("didPressAccessoryButton")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
