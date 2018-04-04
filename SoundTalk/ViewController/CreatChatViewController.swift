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
            let alertController = UIAlertController(title: "Chat name is empty", message: "plz, give the chat name", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive) { (action: UIAlertAction) in
                return
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            creatChatRoom(chatName: chatNameTextField.text!, hasImg: hasChatImage, hasWV: hasWelcomeVoice)
//                        self.dismiss(animated: false, completion: nil)

        }
    }
    
    @IBAction func welcomeVoiceToggled(_ sender: UISwitch) {
        if sender.isOn {
            recordButton.isEnabled = true
            playButton.isEnabled = true
            audioSessionRecorder.activatingAudioSession()
            hasWelcomeVoice = true
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
        showImgActionSheet(sender: sender)
    }
    
    @IBOutlet weak var imageSwitch: UISwitch!
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.hasChatImage = false
            self.imageSwitch.isOn = false
        }
    }
    
    func showImgActionSheet(sender: UISwitch) {
        let actionSheet = UIAlertController(title: "Select Source", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
            sender.isOn = false
            self.hasChatImage = false
        }
        let photoLibrary = UIAlertAction(title: "From Photo Library", style: .default) { [weak self] action in
            self?.uiImagePicker.allowsEditing = false                                     // this should be true later.
            self?.uiImagePicker.sourceType = .photoLibrary
            self?.uiImagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            self?.present((self?.uiImagePicker)!, animated: true, completion: nil)
            self?.hasChatImage = true
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
                print("upload image completed.")
            })
        }
    }
    
    func creatChatRoom(chatName: String, hasImg: Bool, hasWV: Bool) {
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        var name: Any?
        let userReference = ref.child("users")
        userReference.child(uid!).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
            name = snapshot.value // get user name
            if let name = name {
                let chatsReference = ref.child("chats").childByAutoId() // create new chats child by autoID
                
                // add chat to chats
                func addToChats() {
                    print("add chat to chats stated.")
                    let values = ["chat name": chatName, "host": name, "welcome voice": self.hasWelcomeVoice, "chat image": self.hasChatImage]
                    //                chatsReference.setValue(values) // set chat name and host to this child
                    chatsReference.setValue(values, withCompletionBlock: { (error, ref) in
                        print("add chat to chats completed.")
                    })
                    self.dismiss(animated: true, completion: nil)
                }
                
                // add to mychats in user reference
                func addToMychats() {
                    print("add to mychats in user reference stated.")
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
                        userReference.child(uid!).updateChildValues(values, withCompletionBlock: { (error, ref) in
                            print("add to mychats in user refernce completed.")
                        })
                        chats?.removeAll()
                    }
                }
                
                // add welcomeVoice to storage
                func addWV() {
                    if hasWV {
                        if self.audioSessionRecorder.audioFile != nil {
                            self.addWelcomeVoiceToStorage(chatCode: chatsReference.key)
                            addToMychats()
                            addToChats()
                        } else {
                            let alertController = UIAlertController(title: "Create chat room without voice?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                            let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive) { (action: UIAlertAction) in
                                self.hasWelcomeVoice = false
                                addToMychats()
                                addToChats()
                            }
                            let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) { (action: UIAlertAction) in
                                return
                            }
                            alertController.addAction(yesAction)
                            alertController.addAction(noAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    } else {
                        addToMychats()
                        addToChats()
                    }
                }
                
                // add image to storage
                if hasImg {
                    if let img = self.chatRoomImgView.image {
                        self.googleUpload(image: img, chatCode: chatsReference.key)
                        addWV()
                    } else {
                        let alertController = UIAlertController(title: "Create chat room without images?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive) { (action: UIAlertAction) in
                            self.hasChatImage = false
                            addWV()
                        }
                        let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) { (action: UIAlertAction) in
                            
                            return
                        }
                        alertController.addAction(yesAction)
                        alertController.addAction(noAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                } else {
                    addWV()
                }
            }
        })
    }
    
    func addWelcomeVoiceToStorage(chatCode: String) {
        let storageRef = Storage.storage().reference()
        let welcomeVoice = storageRef.child("/welcome_voice").child(chatCode)
        welcomeVoice.putFile(from: audioSessionRecorder.audioFile!) //later,, add completion delete file..really need this???..i don't think so..hmm...
        welcomeVoice.putFile(from: audioSessionRecorder.audioFile!, metadata: nil) { (meta, error) in
            print("add welcomeVoice to storage completed.")
        }
    }
}
