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
    var welcomeVoice: URL?
    
    init(code: String) {
        self.code = code
    }
}
