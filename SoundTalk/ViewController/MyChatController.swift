//
//  MyChatController.swift
//  SoundTalk
//
//  Created by 신진욱 on 06/03/2018.
//  Copyright © 2018 신진욱. All rights reserved.
//

import UIKit
import Firebase

class MyChatController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myChatTableView: UITableView!
    var mychats = [Chat]()
    var userRef: DatabaseReference?
    var chatRef: DatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
        chatRef = Database.database().reference().child("chats")
        myChatTableView.dataSource = self
        myChatTableView.delegate = self
        getMyChats()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMyChats() {
        userRef?.child("mychats").observe(.childAdded, with: { (snap) in
            if let chatId = snap.value as? String {
                let mychat = Chat(code: chatId)
                self.chatRef?.child(chatId).observeSingleEvent(of: .value, with: { (snap) in
                    let dic = snap.value as? [String: Any]
                    mychat.chatSetting(dic: dic)
                    self.mychats.append(mychat)
                    DispatchQueue.main.async(execute: {
                        self.myChatTableView.reloadData()
                    })
                })
            }
        }, withCancel: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mychats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ChatTableViewCell?
        cell = tableView.dequeueReusableCell(withIdentifier: "Chat Cell", for: indexPath) as? ChatTableViewCell
//        cell?.cellSetting(chat: mychats[indexPath.row])
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    

}
