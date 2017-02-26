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
    
    @IBOutlet weak var bpmCell : UITableViewCell!
    @IBOutlet weak var timeCell : UITableViewCell!
    @IBOutlet weak var noteCountCell : UITableViewCell!
    
    var selectedIndexPath : IndexPath!
    var selectedRow : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.headerView(forSection: 0)?.textLabel?.font.withSize(60)
        self.tableView.headerView(forSection: 1)?.textLabel?.font.withSize(60)
        
        self.tableView.headerView(forSection: 0)?.textLabel?.textColor = UIColor.black
        self.tableView.headerView(forSection: 1)?.textLabel?.textColor = UIColor.black
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let instrument = UserDefaults.standard.string(forKey: Constants.keys["Instrument"]!)!
        let detail = UserDefaults.standard.string(forKey: Constants.keys["Detail"]!)!
        
        let staccato = UserDefaults.standard.bool(forKey: Constants.keys["Staccato"]!)
        let playMode = UserDefaults.standard.string(forKey: Constants.keys["Play Mode"]!)!
        let bpm = UserDefaults.standard.double(forKey: Constants.keys["BPM"]!)
        let time = UserDefaults.standard.integer(forKey: Constants.keys["Time"]!)
        let noteCount = UserDefaults.standard.integer(forKey: Constants.keys["Note Count"]!)
        

        switch instrument {
        case Constants.instrument[0]:
            toneInstrumentControl.selectedSegmentIndex = 0
            toneDetailControl.isEnabled = true
        case Constants.instrument[1]:
            toneInstrumentControl.selectedSegmentIndex = 1
            toneDetailControl.isEnabled = false
        default:
            print("setting instrument error")
        }
        
        switch detail {
        case Constants.detail[0]:
            toneDetailControl.selectedSegmentIndex = 0
        case Constants.detail[1]:
            toneDetailControl.selectedSegmentIndex = 1
        case Constants.detail[2]:
            toneDetailControl.selectedSegmentIndex = 2
        case Constants.detail[3]:
            toneDetailControl.selectedSegmentIndex = 3
        default:
            print("setting detail error")
        }
        
        switch playMode {
        case Constants.playMode[0]:
            playModeControl.selectedSegmentIndex = 0
        case Constants.playMode[1]:
            playModeControl.selectedSegmentIndex = 1
        case Constants.playMode[2]:
            playModeControl.selectedSegmentIndex = 2
        default:
            print("setting detail error")
        }
        
        if staccato {
            dynamicCell.accessoryType = .checkmark
        }else {
            dynamicCell.accessoryType = .none
        }
        
        bpmCell.detailTextLabel?.text = String(format: "%.0f", bpm)
        timeCell.detailTextLabel?.text = "\(time)"
        noteCountCell.detailTextLabel?.text = "\(noteCount)"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let instrumentRawValue = Constants.instrument[toneInstrumentControl.selectedSegmentIndex]
        UserDefaults.standard.set(instrumentRawValue, forKey: Constants.keys["Instrument"]!)
        
        let detailIndex = toneDetailControl.selectedSegmentIndex
        let detailRawValue = Constants.detail[detailIndex]
        UserDefaults.standard.set(detailRawValue, forKey: Constants.keys["Detail"]!)
        
        
        let type = ToneController.Instrument(rawValue: instrumentRawValue)!
        let detail = AKTableType(rawValue: detailRawValue)!
        
        ToneController.sharedInstance().type = type
        ToneController.sharedInstance().detailType = detail
        
        ///////////////////
        
        let staccato = dynamicCell.accessoryType == .checkmark ? true : false
        UserDefaults.standard.set(staccato, forKey: Constants.keys["Staccato"]!)
        
        let playMode = Constants.playMode[playModeControl.selectedSegmentIndex]
        UserDefaults.standard.set(playMode, forKey: Constants.keys["Play Mode"]!)
        
        let bpm = Double((bpmCell.detailTextLabel?.text)!)
        UserDefaults.standard.set(bpm, forKey: Constants.keys["BPM"]!)
        let time = Int((timeCell.detailTextLabel?.text)!)
        UserDefaults.standard.set(time, forKey: Constants.keys["Time"]!)
        let noteCount = Int((noteCountCell.detailTextLabel?.text)!)
        UserDefaults.standard.set(noteCount, forKey: Constants.keys["Note Count"]!)
        
        
        /////
        let colorView = self.tabBarController?.viewControllers?[0] as! ColorViewController
        colorView.imagePlayer = colorView.prepareImagePlayer()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndexPath = indexPath
        
        if indexPath.section == 0 {
            return
        }else if indexPath.row == 0{
            if dynamicCell.accessoryType == .checkmark {
                dynamicCell.accessoryType = .none
            }else {
                dynamicCell.accessoryType = .checkmark
            }
            return
        }else if indexPath.row == 1{
            return
        }
        
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        
        var data = 0
        
        if selectedIndexPath.row == 2{
            data = Int((bpmCell.detailTextLabel?.text)!)! - (Constants.imagePlayer["BPM"] as! [Int])[0]
        }else if selectedIndexPath.row == 3{
            data = Int((timeCell.detailTextLabel?.text)!)! - (Constants.imagePlayer["Time"] as! [Int])[0]
        }else if selectedIndexPath.row == 4{
            data = Int((noteCountCell.detailTextLabel?.text)!)! -  (Constants.imagePlayer["Note Count"] as! [Int])[0]
        }
        
        picker.selectRow(data, inComponent: 0, animated: true)

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: {action in
            self.dismiss(animated: true, completion: nil)
            self.selectedRow = picker.selectedRow(inComponent: 0)
            self.update()
        }))
        
        let height = NSLayoutConstraint(item: alertController.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.view.frame.height/3)
        let center = NSLayoutConstraint(item: picker, attribute: .centerX, relatedBy: .equal, toItem: alertController.view, attribute: .centerXWithinMargins, multiplier: 1, constant: -10)
        
        alertController.view.addSubview(picker)
        alertController.view.addConstraint(height)
        alertController.view.addConstraint(center)
        
        picker.frame = CGRect(x: 0, y: 0, width: alertController.view.frame.width, height: 150)
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func update() {
        if selectedIndexPath.row == 2{
            bpmCell.detailTextLabel?.text = "\((Constants.imagePlayer["BPM"] as! [Int])[0] + selectedRow!)"
        }else if selectedIndexPath.row == 3{
            timeCell.detailTextLabel?.text = "\((Constants.imagePlayer["Time"] as! [Int])[0] + selectedRow!)"
        }else if selectedIndexPath.row == 4{
            noteCountCell.detailTextLabel?.text = "\((Constants.imagePlayer["Note Count"] as! [Int])[0] + selectedRow!)"
        }
        self.tableView.reloadData()
    }
    
    @IBAction func instrumentSelected(_ sender : UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            toneDetailControl.isEnabled = true
        default:
            toneDetailControl.isEnabled = false
        }
    }
}


extension SettingViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if selectedIndexPath.row == 2 {
            let data = (Constants.imagePlayer["BPM"] as! [Int])
            return data[1] - data[0] + 1
            
        }else if selectedIndexPath.row == 3 {
            let data = (Constants.imagePlayer["Time"] as! [Int])
            return data[1] - data[0] + 1
            
        }else if selectedIndexPath.row == 4 {
            let data = (Constants.imagePlayer["Note Count"] as! [Int])
            return data[1] - data[0] + 1
        }
        return 0
    }
    
//    "BPM" : 50...150,
//    "Time" : 2...4,
//    "Note Count" : 10...80,
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if selectedIndexPath.row == 2 {
            
            return " \((Constants.imagePlayer["BPM"] as! [Int])[0] + row)"
        }else if selectedIndexPath.row == 3 {
            return " \((Constants.imagePlayer["Time"] as! [Int])[0] + row)"
            
        }else if selectedIndexPath.row == 4 {
            return " \((Constants.imagePlayer["Note Count"] as! [Int])[0] + row)"
        }
        return "error"
    }
}
