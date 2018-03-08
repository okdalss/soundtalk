//
//  CreatChatViewController.swift
//  SoundTalk
//
//  Created by 신진욱 on 12/02/2018.
//  Copyright © 2018 신진욱. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class CreatChatViewController: UIViewController, AVAudioPlayerDelegate {
    
    let audioSessionRecorder = AudioSessionandRecord()
    @IBOutlet weak var chatNameTextField: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    var avAudioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let button = UIBarButtonItem()
        button.title = "Done"
        button.target = self
        button.action = #selector(doneAction)
        self.navigationItem.rightBarButtonItem = button
        recordButton.isEnabled = false
        playButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func doneAction() {
        if chatNameTextField.text?.count == 0 {
            print("chat name is unvalid")
            return
        } else {
            creatChatRoom(chatName: chatNameTextField.text!)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func welcomeVoiceToggled(_ sender: UISwitch) {
        if sender.isOn {
            recordButton.isEnabled = true
            playButton.isEnabled = true
            audioSessionRecorder.activatingAudioSession()
        } else {
            recordButton.isEnabled = false
            playButton.isEnabled = false
        }
    }
    
    @IBAction func recordAction(_ sender: UIButton) {
        if sender.title(for: .normal) == "record" {
            audioSessionRecorder.startRecording()
            recordButton.setTitle("pause", for: .normal)
        } else {
            audioSessionRecorder.finishRecording(success: true)
            audioSessionRecorder.fileManage()
            recordButton.setTitle("record", for: .normal)
        }
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        if let voiceFile = audioSessionRecorder.audioFile {
            do {
                avAudioPlayer = try AVAudioPlayer(contentsOf: voiceFile)
                avAudioPlayer?.delegate = self
                avAudioPlayer?.prepareToPlay()
                avAudioPlayer?.play()
                if (avAudioPlayer?.isPlaying)! {
                    playButton.isEnabled = false
                }
            } catch {
                print("can not play")
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.isEnabled = true
    }
    
    func creatChatRoom(chatName: String) {
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        var name: Any?
        let userReference = ref.child("users")
        userReference.child(uid!).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
            name = snapshot.value
            if let name = name {
                let chatsReference = ref.child("chats").childByAutoId()
                let values = ["chat name": chatName, "host": name]
                chatsReference.setValue(values)
                
                userReference.child(uid!).observeSingleEvent(of: .value) { (snapshot) in
                    let dic = (snapshot.value as? [String: Any])!
                    var chats = dic["mychats"] as? [String]
                    
                    if (chats == nil) {
                        chats = [chatsReference.key]
                    }
                    else {
                        chats?.append(chatsReference.key)
                    }

                    let values = ["mychats": chats!]
                    userReference.child(uid!).updateChildValues(values)
                    chats?.removeAll()
                }
            }
        })
    }
}
