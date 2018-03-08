//
//  SendVoiceMessageViewController.swift
//  SoundTalk
//
//  Created by 신진욱 on 15/01/2018.
//  Copyright © 2018 신진욱. All rights reserved.
//

import UIKit
import AVFoundation

class SendVoiceMessageViewController: UIViewController {

    let audioSesstionRecorder = AudioSessionandRecord()
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var DataStatusandPlayButton: UIButton!
    var avAudioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        audioSesstionRecorder.activatingAudioSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func recordVoiceMessage(_ sender: Any) {
        if (recordingButton.titleLabel?.text == "record voice message"){
            audioSesstionRecorder.startRecording()
            recordingButton.setTitle("Recording..", for: .normal)
        } else {
            audioSesstionRecorder.finishRecording(success: true)
            audioSesstionRecorder.fileManage()
            recordingButton.setTitle("record voice message", for: .normal)
        }
    }
    
    @IBAction func playVoiceMessage(_ sender: Any) {
        if let voiceFile = audioSesstionRecorder.audioFile {
            do {
                avAudioPlayer = try AVAudioPlayer(contentsOf: voiceFile)
                avAudioPlayer?.prepareToPlay()
                avAudioPlayer?.play()
                print("audio played")
            } catch {
                print("can not play...")
            }
            
        }
    }
    
    
}

