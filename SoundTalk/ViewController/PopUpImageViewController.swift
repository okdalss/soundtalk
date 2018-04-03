//
//  PopUpImageViewController.swift
//  SoundTalk
//
//  Created by 신진욱 on 22/03/2018.
//  Copyright © 2018 신진욱. All rights reserved.
//

import UIKit
import Firebase

class PopUpImageViewController: UIViewController {
    
    @IBOutlet weak var popUpImageView: UIImageView!
    var imageCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if imageCode != nil {
            getChatImage(code: imageCode!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getChatImage(code: String) {
        let chatImgChild = Storage.storage().reference().child("chatroom_img").child(code)
        chatImgChild.downloadURL { (url, error) in
            self.popUpImageView.downloadedFrom(url: url!)
            if error != nil {
                print(error as Any)
            }
        }
    }

    @IBAction func closePopup(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
}
