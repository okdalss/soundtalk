//
//  MyChatController.swift
//  SoundTalk
//
//  Created by 신진욱 on 06/03/2018.
//  Copyright © 2018 신진욱. All rights reserved.
//

import UIKit
import Firebase

class MyChatController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var myChatTableView: UITableView!
    
    let cellId = "cellId"
    var mychats = [Chat]()
    var userRef: DatabaseReference?
    var chatRef: DatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
        chatRef = Database.database().reference().child("chats")
        myChatTableView.register(ChatCell.self, forCellReuseIdentifier: cellId)
        myChatTableView.dataSource = self
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
                    mychat.name = dic?["chat name"] as? String
                    mychat.host = dic?["host"] as? String
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
        var cell: UITableViewCell?
        cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let mychat = mychats[indexPath.row]
        cell?.textLabel?.text = mychat.name
        cell?.detailTextLabel?.text = mychat.host
        
        return cell!
    }
    

}
