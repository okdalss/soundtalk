//
//  MapInfoViewController.swift
//  SoundTalk
//
//  Created by 신진욱 on 11/04/2018.
//  Copyright © 2018 신진욱. All rights reserved.
//

import UIKit

class MapInfoViewController: UIViewController {
    
    @IBOutlet weak var mapUserView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userStateLabel: UILabel!
    @IBOutlet weak var userOptMsgLabel: UILabel!
    
    @IBOutlet weak var mapAIView: UIView!
    @IBOutlet weak var aiMessageLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
