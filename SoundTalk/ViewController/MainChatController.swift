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
    var cacheImages = [String: UIImageView]()
    var willSetNum = 0
    var chats = [Chat]() {
        willSet(newVal) {
            if let last = newVal.last {
                getChatImage(code: last.code!, chatImgView: UIImageView())
            }
        }
    }
    
    func getChatImage(code: String, chatImgView: UIImageView) {
        let chatImgChild = Storage.storage().reference().child("chatroom_img").child(code)
        chatImgChild.downloadURL { (url, error) in
            if url != nil {
                chatImgView.downloadedFrom(url: url!, contentMode: .scaleAspectFit, completion: {
                    self.cacheImages[code] = chatImgView
                    self.chatTableView.reloadData()
                })
            }
            if error != nil {
//                print(error as Any)
            }
        }
    }
    
    var userName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getUserName()
        chatTableView.dataSource = self
        chatTableView.delegate = self
        //for test
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadChats(loadNum: 10)
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
            cell?.cellSetting(chat: chats[indexPath.row], imageView: cacheImages[chats[indexPath.row].code!])
            returnCell = cell
        } else {
            returnCell = chatTableView.dequeueReusableCell(withIdentifier: "LoadMoreCell", for: indexPath) as? LoadMoreChatsTableViewCell
        }
        return returnCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == chats.count {
            loadChats(loadNum: 5)
        } else {
            showPopupView(indexPath: indexPath)
        }
    }
    
    func showPopupView(indexPath: IndexPath) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popupimageviewid") as! PopUpImageViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
//        popOverVC.imageCode = chats[indexPath.row].code
        popOverVC.popUpImageView.image = cacheImages[chats[indexPath.row].code!]!.image
        
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
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

