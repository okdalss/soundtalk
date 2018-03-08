//
//  WelcomeController.swift
//  SoundTalk
//
//  Created by 신진욱 on 27/02/2018.
//  Copyright © 2018 신진욱. All rights reserved.
//

import UIKit
import Firebase

class WelcomeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let auth = Auth.auth().currentUser?.uid
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if auth == nil {
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "login view cont")
            self.present(loginViewController, animated: true, completion: nil)
        } else {
            let newviewcont = storyboard.instantiateViewController(withIdentifier: "maintabbar")
            self.present(newviewcont, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
