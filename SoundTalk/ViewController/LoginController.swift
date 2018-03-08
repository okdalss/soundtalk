//
//  LoginController.swift
//  SoundTalk
//
//  Created by 신진욱 on 27/02/2018.
//  Copyright © 2018 신진욱. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleLogin(_ sender: Any) {
        guard let email = emailTextField.text, let passwd = passwordTextField.text else {
            print("email or password is not valid")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: passwd) { (user, error) in
            if let error = error {
                print(error)
                return
            }
            //successfully logged in our user
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newviewcont = storyboard.instantiateViewController(withIdentifier: "maintabbar")
            self.present(newviewcont, animated: true, completion: {
                print("handleLogin.present.completion")
            })
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
