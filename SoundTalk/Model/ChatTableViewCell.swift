//
//  ChatTableViewCell.swift
//  SoundTalk
//
//  Created by 신진욱 on 09/03/2018.
//  Copyright © 2018 신진욱. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class ChatTableViewCell: UITableViewCell, AVAudioPlayerDelegate {
    
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var hostLable: UILabel!
    @IBOutlet weak var welcomeVoiceButton: UIButton!
    @IBOutlet weak var chatImg: UIImageView!
    
    var chatCode: String?
    var player: AVPlayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        welcomeVoiceButton.isEnabled = false
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        chatImg.isUserInteractionEnabled = true
        chatImg.addGestureRecognizer(tapGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
//        let tappedImage = tapGestureRecognizer.view as! UIImageView
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popupimageviewid") as! PopUpImageViewController
        popOverVC.imageCode = chatCode
//        popOverVC.view.frame = self.frame
        self.superview?.addSubview(popOverVC.view)
    }

    func cellSetting(chat: Chat) {
        titleLable.text = chat.name
        hostLable.text = chat.host
        // welcomeVoice set
        if chat.welcomeVoice == true {
            welcomeVoiceButton.isEnabled = true
        }
        // chatImg set
        if chat.chatImage == true {
            getChatImage(code: chat.code!)
        }
        chatCode = chat.code
    }
    
    func getChatImage(code: String) {
        let chatImgChild = Storage.storage().reference().child("chatroom_img").child(code)
        chatImgChild.downloadURL { (url, error) in
            if url != nil {
                self.chatImg.downloadedFrom(url: url!)
            }
            if error != nil {
                print(error as Any)
            }
        }
    }
    
    func streamVoice(code: String) {
        let welcomeVoice = Storage.storage().reference().child("/welcome_voice").child(code)
        welcomeVoice.downloadURL { (url, error) in
            let url = URL(string: (url?.relativeString)!)
            let playerItem: AVPlayerItem = AVPlayerItem(url: url!)
            self.player = AVPlayer(playerItem: playerItem)
            self.player?.play()
        }
    }
    
    @IBAction func playWV(_ sender: UIButton) {
        streamVoice(code: chatCode!)
    }
    
    
    
}
