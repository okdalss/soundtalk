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
        welcomeVoiceButton.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        welcomeVoiceButton.isHidden = true
        chatImg.image = nil
    }
    
    func cellSetting(chat: Chat, imageView: UIImageView?) {
        titleLable.text = chat.name
        hostLable.text = chat.host
        
        // welcomeVoice setting
        if chat.welcomeVoice == true {
            welcomeVoiceButton.isHidden = false
            welcomeVoiceButton.isEnabled = true
        }
        // chatImg setting
        if chat.chatImage == true && imageView != nil {
            chatImg.image = imageView?.image
        }
        
        chatCode = chat.code
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
    
    @IBAction func playVoice(_ sender: UIButton) {
        streamVoice(code: chatCode!)
    }
    
    
}
