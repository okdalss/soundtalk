//
//  MainChatController.swift
//  SoundTalk
//
//  Created by 신진욱 on 28/02/2018.
//  Copyright © 2018 신진욱. All rights reserved.
//

import UIKit
import Firebase

class MainChatController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var chatTableView: UITableView!
    var chats = [Chat]()
    var userName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getUserName()
        chatTableView.dataSource = self
        chatTableView.delegate = self
        loadChats(loadNum: 10)
        //for test
//        let chatRef = Database.database().reference().child("chats")
//        chatRef.observe(DataEventType.childAdded) { (snap) in
//            print("print go")
//            print(snap.key)
//        }
    }
    
    func getUserName() {
        let userRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
        userRef.child("name").observeSingleEvent(of: .value) { (snap) in
            if let name = snap.value as? String {
                self.userName = name
                self.navigationItem.title = name
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var returnCell: UITableViewCell?
        if indexPath.row != (chats.count) {
            var cell: ChatTableViewCell?
            cell = chatTableView.dequeueReusableCell(withIdentifier: "Chat Cell", for: indexPath) as? ChatTableViewCell
            cell?.cellSetting(chat: chats[indexPath.row])
            returnCell = cell
        } else {
            returnCell = chatTableView.dequeueReusableCell(withIdentifier: "LoadMoreCell", for: indexPath) as? LoadMoreChatsTableViewCell
        }
        return returnCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == chats.count {
            loadChats(loadNum: 2)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    var firstUpdate = true
    var lastChild: String?
    
    func loadChats(loadNum: UInt) {
        let chatRef = Database.database().reference().child("chats")
        if firstUpdate {
            let query = chatRef.queryLimited(toFirst: loadNum)
            var firstSnap = true
            query.observe(.childAdded, with: { (snap) in
                self.addToChatsArray(snapshot: snap, firstUpdate: self.firstUpdate, firstSnap: firstSnap)
                self.lastChild = snap.key
                DispatchQueue.main.async(execute: {
                    self.chatTableView.reloadData()
                })
                if firstSnap ==  true {
                    firstSnap = false
                }
                else {
                    self.firstUpdate = false
                }
                query.removeAllObservers()
            })
        } else {
            let query = chatRef.queryOrderedByKey().queryStarting(atValue: lastChild!).queryLimited(toFirst: loadNum)
            var firstSnap = true
            query.observe(.childAdded, with: { (snap) in
                self.addToChatsArray(snapshot: snap, firstUpdate: self.firstUpdate, firstSnap: firstSnap)
                self.lastChild = snap.key
                DispatchQueue.main.async(execute: {
                    print(self.chats.count+1)
                    self.chatTableView.reloadData()
                })
                firstSnap = false
                query.removeAllObservers()
                
            })
        }
    }
    
    func addToChatsArray(snapshot: DataSnapshot, firstUpdate: Bool, firstSnap: Bool) {
        let code = snapshot.key
        if firstUpdate {
            let dic = snapshot.value as? [String: Any]
            let chat = Chat(code: code)
            chat.chatSetting(dic: dic)
            chats.append(chat)
        } else {
            if firstSnap == false {
                let dic = snapshot.value as? [String: Any]
                let chat = Chat(code: code)
                chat.chatSetting(dic: dic)
                chats.append(chat)
            }
        }

    }
    
//    @IBAction func fortestChatsToCreate(_ sender: Any) {
//        let numOfChats = 2
//        for _ in 1...numOfChats {
//            let chatRef: DatabaseReference? = Database.database().reference().child("chats")
//            if let ref = chatRef?.childByAutoId() {
//                let values = ["chat name": randomString(length: 7), "host": randomString(length: 4)]
//                ref.setValue(values)
//            }
//        }
//    }
    
//    func randomString(length: Int) -> String {
//        
//        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
//        let len = UInt32(letters.length)
//        
//        var randomString = ""
//        
//        for _ in 0 ..< length {
//            let rand = arc4random_uniform(len)
//            var nextChar = letters.character(at: Int(rand))
//            randomString += NSString(characters: &nextChar, length: 1) as String
//        }
//        
//        return randomString
//    }
    
    @IBAction func logoutForTEST(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let loginViewController = storyboard?.instantiateViewController(withIdentifier: "login view cont")
        self.dismiss(animated: true, completion: nil)
        self.present(loginViewController!, animated: false, completion: nil)
    }
    
}

class LoadMoreChatsTableViewCell: UITableViewCell {
    @IBOutlet weak var loadTextLable: UILabel!
}

