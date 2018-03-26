//
//  Chat.swift
//  SoundTalk
//
//  Created by 신진욱 on 14/02/2018.
//  Copyright © 2018 신진욱. All rights reserved.
//

import Foundation

class Chat: NSObject {
    var code: String?
    var name: String?
    var host: String?
    var welcomeVoice = false
    var chatImage = false
    
    init(code: String) {
        self.code = code
    }
    
    func chatSetting(dic: [String: Any]?) {
        name = dic?["chat name"] as? String
        host = dic?["host"] as? String
        if dic?["welcome voice"] as? Int == 1 {
            welcomeVoice = true
        }
        if dic?["chat image"] as? Int == 1 {
            chatImage = true
        }
    }
}
