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

class CreatChatViewController: UIViewController, AVAudioPlayerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let audioSessionRecorder = AudioSessionandRecord()
    @IBOutlet weak var chatNameTextField: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var chatRoomImgView: UIImageView!
    var avAudioPlayer: AVAudioPlayer?
    var hasWelcomeVoice = false
    let uiImagePicker = UIImagePickerController()
    var hasChatImage = false
    
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
        uiImagePicker.delegate = self
        // for test
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
//            self.dismiss(animated: false, completion: nil)
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
            hasWelcomeVoice = false
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
            } catch { print("can not play") }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.isEnabled = true
    }
    
    @IBAction func imgToggled(_ sender: UISwitch) {
        showImgActionSheet()
    }
    
    func showImgActionSheet() {
        let actionSheet = UIAlertController(title: "Select Source", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let photoLibrary = UIAlertAction(title: "From Photo Library", style: .default) { [weak self] action in
            self?.uiImagePicker.allowsEditing = false                                     // this should be true later.
            self?.uiImagePicker.sourceType = .photoLibrary
            self?.uiImagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            self?.present((self?.uiImagePicker)!, animated: true, completion: nil)
        }
        actionSheet.addAction(photoLibrary)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let resizedImage = chosenImage.resizeWithWidth(width: 300)
        chatRoomImgView.contentMode = .scaleAspectFit
        chatRoomImgView.image = resizedImage
        dismiss(animated: true, completion: nil)
    }
    
    func googleUpload(image: UIImage, chatCode: String) {
        let chatRoomImgRef = Storage.storage().reference().child("/chatroom_img").child(chatCode)
        let imgData = UIImagePNGRepresentation(image) as Data?
//        let compressData = UIImageJPEGRepresentation(imgData, 0.5) //max value is 1.0 and minimum is 0.0
//        let compressedImage = UIImage(data: compressData!)
        if let data = imgData {
            chatRoomImgRef.putData(data, metadata: nil, completion: { (meta, error) in
                print("upload completed.")
            })
        }
    }
    
    func creatChatRoom(chatName: String) {
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        var name: Any?
        let userReference = ref.child("users")
        userReference.child(uid!).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
            name = snapshot.value // get user name
            if let name = name {
                let chatsReference = ref.child("chats").childByAutoId() // create new chats child by autoID
                
                // add imge to storage
                if let img = self.chatRoomImgView.image {
                    self.hasChatImage = true
                    self.googleUpload(image: img, chatCode: chatsReference.key)
                }
                // add welcomeVoice to storage
                if self.audioSessionRecorder.audioFile != nil {
                    self.hasWelcomeVoice = true
                    self.addWelcomeVoiceToStorage(chatCode: chatsReference.key)
                }
                // add chat to chats
                let values = ["chat name": chatName, "host": name, "welcome voice": self.hasWelcomeVoice, "chat image": self.hasChatImage]
                chatsReference.setValue(values) // set chat name and host to this child
                

                // add to mychats in user reference
                userReference.child(uid!).child("mychats").observeSingleEvent(of: .value) { (snapshot) in
                    var chats = snapshot.value as? [String]
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
    
    func addWelcomeVoiceToStorage(chatCode: String) {
        let storageRef = Storage.storage().reference()
        let welcomeVoice = storageRef.child("/welcome_voice").child(chatCode)
        welcomeVoice.putFile(from: audioSessionRecorder.audioFile!) //later,, add completion delete file..really need this???..i don't think so..hmm...
    }
}
