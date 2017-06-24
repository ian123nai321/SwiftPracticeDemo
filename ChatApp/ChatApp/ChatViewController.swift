//
//  ChatViewController.swift
//  ChatApp
//
//  Created by 吳政緯 on 2017/6/15.
//  Copyright © 2017年 吳政緯. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseAuth



class ChatViewController: JSQMessagesViewController {
    
    // 房間ID用來讀取該房間的訊息
    var roomID: String!
    // 房間名稱
    var roomName: String!
    // 訊息資料
    var messages = [[String: Any]]()
    // 訊息記錄節點
    var messageRef: DatabaseReference!
    
    lazy var incomingBubbleImage: JSQMessageBubbleImageDataSource = {[unowned self] in
        let factory = JSQMessagesBubbleImageFactory()
        return factory.incomingMessagesBubbleImage(with: UIColor.darkGray)
        }()
    
    lazy var outgoingBubbleImage: JSQMessageBubbleImageDataSource = {[unowned self] in
        let factory = JSQMessagesBubbleImageFactory()
        return factory.outgoingMessagesBubbleImage(with: UIColor.lightGray)
        }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //取得roomID內的所有聊天內容
        messageRef = Database.database().reference().child("messages/\(roomID!)")
        
        //依照日期排序聊天內容
        messageRef.queryOrdered(byChild: "date").observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
            
            if !snapshot.hasChildren() { return }
            
            // messages 架構為
            // messageId1
            // |- messageData1
            // messageId2
            // |- messageData2
            snapshot.children.forEach { (child) in
                
                guard let childSnap = child as? DataSnapshot else { return }
                
                guard let msgData = childSnap.value as? [String: Any] else { return }
                
                let msgId = childSnap.key
                var message = msgData
                message["id"] = msgId
                self?.messages.append(message)
            }
            
            self?.collectionView?.reloadData()
            
            guard let interval = self?.messages.last?["date"] as? TimeInterval else { return }
            
            //取得最新訊息
            self?.messageRef.queryOrdered(byChild: "date").queryStarting(atValue: interval + 0.001).observe(.childAdded, with: {[weak self] (snapshot) in
                
                guard let msgData = snapshot.value as? [String: Any], let senderId = msgData["senderId"] as? String else {
                    return
                }
                
                // 如果是自己傳的訊息就跳過 (因為之前傳送訊息時就有加入dataSource了)
                if senderId == self?.senderId() {
                    return
                }
                
                var message = msgData
                message["id"] = snapshot.key
                
                self?.messages.append(message)
                self?.finishReceivingMessage()
            })
        })
        
        //聊天泡泡兩邊多餘的空白移除，空白是預設給大頭照用。
        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        
        //隱藏附加檔案按鈕
        inputToolbar.contentView?.leftBarButtonItem = nil
        
    }

    override func senderId() -> String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    override func senderDisplayName() -> String {
        return Auth.auth().currentUser?.displayName ?? Auth.auth().currentUser?.email ?? ""
    }
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        // 實作傳送訊息
        let messageNode = messageRef.childByAutoId()
        let message = [
            "senderId": senderId,
            "senderDisplayName": senderDisplayName,
            "date": date.timeIntervalSince1970,
            "text": text
            ] as [String : Any];
        
        self.messages.append(message)
        
        messageNode.setValue(message) {[weak self] (error, _) in
            self?.finishSendingMessage()
        }
    }
    
    deinit {
        messageRef.removeAllObservers()
    }


}


extension ChatViewController {
    // 訊息數量
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    // 將訊息資料轉換成JSQ指定的Model
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        let message = messages[indexPath.item]
        
        guard let text = message["text"] as? String,
            let senderId = message["senderId"] as? String,
            let senderDisplayName = message["senderDisplayName"] as? String,
            let interval = message["date"] as? TimeInterval
            else { fatalError("data format exception") }
        
        let date = Date(timeIntervalSince1970: interval)
        
        return JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
    }
    
    
    // 泡泡框
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource? {
        let message = messages[indexPath.item]
        
        if message["senderId"] as? String == self.senderId() {
            return outgoingBubbleImage
        } else {
            return incomingBubbleImage
        }
    }
    
    // 頭像 - 可設置大頭照
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    //對話框間距
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    //對話框上方加入辨識Label，以辯別訊息來源
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        
        let message = messages[indexPath.item]
        
        if message["senderId"] as? String == self.senderId() {
            return nil
        }
        
        guard let displayName = message["senderDisplayName"] as? String else {
            return NSAttributedString(string: "未知")
        }
        
        return NSAttributedString(string: displayName)
    }
    
    
    
    
}
