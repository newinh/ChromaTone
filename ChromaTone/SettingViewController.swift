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
import AudioKit

class SettingViewController : UITableViewController{
    
    
    @IBOutlet weak var toneInstrumentControl : UISegmentedControl!
    @IBOutlet weak var toneDetailControl : UISegmentedControl!
    
    @IBOutlet weak var dynamicCell : UITableViewCell!
    @IBOutlet weak var playModeControl : UISegmentedControl!
    @IBOutlet weak var bpmSlider : AKPropertySlider!
    @IBOutlet weak var timeSlider : AKPropertySlider!
    @IBOutlet weak var noteCountSlider : AKPropertySlider!
    
    override func viewDidLoad() {
        
    }
    
}
