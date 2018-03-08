//
//  AudioSessionandRecord.swift
//  SoundTalk
//
//  Created by 신진욱 on 16/01/2018.
//  Copyright © 2018 신진욱. All rights reserved.
//

import AVFoundation

class AudioSessionandRecord {
    
    var audioRecorder: AVAudioRecorder!
    var audioFile: URL?
    
    func activatingAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            // 1) Configure your audio session category, options, and mode
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            // 2) Activate your audio session to enable your custom configuration
            try session.setActive(true)
            
            print(session.currentRoute)
            print(session.sampleRate)
        } catch let error as NSError {
            print("Unable to activate audio session:  \(error.localizedDescription)")
        }
    }
    
    func startRecording() {
        audioFile = getDocumentsDirectory().appendingPathComponent("recording.mp4")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFile!, settings: settings)
//            audioRecorder.delegate = self
            audioRecorder.record()
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            print("Recording success")
        } else {
            print("Recording fail")
            // recording failed :(
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func fileManage() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print("File Location:", paths.path)
        
        if FileManager.default.fileExists(atPath: paths.path) {
            print("file found and ready to play")
        } else {
            print("no file")
        }
    }
    
}
