//
//  LoginViewController.swift
//  SoundTalk
//
//  Created by 신진욱 on 23/01/2018.
//  Copyright © 2018 신진욱. All rights reserved.
//

import UIKit
import Firebase
class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginSubView.isHidden = true
        logoutButton.isHidden = true
        
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout))
        }
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        loginStatus.text = "Login : X"
        logoutButton.isHidden = true
        loginRegisterSegmentedControl.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var loginStatus: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginRegisterSegmentedControl: UISegmentedControl! {
        didSet {
            self.loginRegisterSegmentedControl.selectedSegmentIndex = 1
            self.loginRegisterSegmentedControl.addTarget(self, action: #selector(handleLoginRegisterSegContChange), for: .valueChanged)
        }
    }
    
    @IBOutlet weak var registerSubView: UIView!
    @IBOutlet weak var loginSubView: UIView!
    
    @objc func handleLoginRegisterSegContChange() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            registerSubView.isHidden = true
            loginSubView.isHidden = false
        } else {
            registerSubView.isHidden = false
            loginSubView.isHidden = true
        }
    }
    
    @IBOutlet weak var registerButton: UIButton! {
        didSet {
            registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var emailTextFieldLogin: UITextField!
    @IBOutlet weak var passwdTextFieldLogin: UITextField!
    @IBOutlet weak var logoutButton: UIButton! {
        didSet {
            logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        }
    }
    
    @objc func handleLogin() {
        guard let email = emailTextFieldLogin.text, let passwd = passwdTextFieldLogin.text else {
            print("email or password is not valid")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: passwd) { (user, error) in
            if let error = error {
                print(error)
                return
            }
            //successfully logged in our user
            self.loginStatus.text = "Login : O"
            self.loginSubView.isHidden = true
            self.loginRegisterSegmentedControl.isHidden = true
            self.logoutButton.isHidden = false
            
//            self.dismiss(animated: true, completion: nil) should i need this?
            
//            let newViewController = MainTabBarController()
//            self.present(newViewController, animated: true, completion: nil)
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "maintabbar") 
            self.present(newViewController, animated: true, completion: nil)
        }
    }
    
    @objc func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("email or password or name is not valid")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            // successfully authenticated user
            let ref = Database.database().reference()
            let usersReference = ref.child("users").child(uid)
            let values = ["name": name, "email": email, "mychats": ""] as [String : Any]
            usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err)
                    return
                }
            })
        }
    }


    


}
