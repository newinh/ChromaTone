//
//  SettingViewController.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 25..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation
import UIKit
import FontAwesome_swift

class SettingViewController : UIViewController{
    
    @IBOutlet weak var button1 : UIButton!
    
//    button.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)
//    button.setTitle(String.fontAwesomeIcon(name: .github), for: .normal)
    
    override func viewDidLoad() {
        button1.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)
        button1.setTitle(String.fontAwesomeIcon(name: .pause), for: .normal)
    }
    
}
