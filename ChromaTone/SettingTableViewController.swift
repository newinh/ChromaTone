//
//  SettingTableViewController.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 23..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import UIKit
import AudioKit

class SettingTableViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView : UITableView!
    
    
    var titles : [String] = []
    var selectedInxdexPath : IndexPath!
    var nowValue : String = ""
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Constants.options.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Constants.options[section].key
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.options[section].value.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(indexPath)
        selectedInxdexPath = indexPath
        
        let any = Constants.options[indexPath.section].value[indexPath.row].value
        
        print (type(of: any))
        
        
        var every : [String] = []
        
        if let values = any as? [Bool] {
            for i in values {
                every.append("\(i)")
                
            }
        }else if let values = any as? CountableClosedRange<Int> {
            for i in values {
                every.append("\(i)")
            }
        }else if let _ = any as? ImagePlayer.Option.PlayMode {
            for i in Constants.playMode {
                every.append("\(i)")
            }
        }else if let values = any as? [String] {
            for i in values {
                every.append(i)
            }
        }
        
        titles = every
        
        let rect = CGRect(x: self.view.frame.minX, y: 500 , width: self.view.frame.width, height: 150)
        let a = UIPickerView(frame: rect)
        
        a.delegate = self
        a.dataSource = self
        
        a.showsSelectionIndicator = true
        
        a.backgroundColor = UIColor.white
//        a.bounds = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.view.addSubview(a)
//        a.frame = CGRect(x: self.view.center.x, y: self.view.center.y, width: 0, height: 0)
        
        UIView.animate(withDuration: 0.2) {
            a.frame = rect
        }
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        
        let title = Constants.options[indexPath.section].value[indexPath.row].key
        let detailKey = Constants.keys[title]!
        let detailOptional = UserDefaults.standard.value(forKey: detailKey)
        
        if let detail = detailOptional as? String {
            cell.detailTextLabel?.text = detail
        }else if let detail = detailOptional as? Int {
            cell.detailTextLabel?.text = "\(detail)"
        }else if let detail = detailOptional as? Double {
            cell.detailTextLabel?.text = "\(detail)"
        }else if let detail = detailOptional as? Bool {
            cell.detailTextLabel?.text = "\(detail)"
        }
        
        cell.textLabel?.text = title
        return cell
        
    }
    
}



extension SettingTableViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return titles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return titles[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // 설정 셋
        let keyPath = Constants.options[selectedInxdexPath.section].value[selectedInxdexPath.row].key
        let key = Constants.keys[keyPath]!
        UserDefaults.standard.set(titles[row], forKey: key)
        print(titles[row])
        
        let indexPathes : [IndexPath] = [selectedInxdexPath]
        tableView.reloadRows(at: indexPathes, with: .automatic)
        
//        let instrumentKey = Constants.keys["Instrument"]!
//        let detailKey = Constants.keys["Detail"]!
//        let instrumentRawValue : String = UserDefaults.standard.string(forKey: instrumentKey)!
//        let detailTypeRawValue : String = UserDefaults.standard.string(forKey: detailKey)!
//        
//        let type = ToneController.Instrument(rawValue: instrumentRawValue)!
//        let detailType = ToneController.Instrument.DetailType(rawValue: detailTypeRawValue)!
        
//        AudioKit.stop()
//        AudioKit.init()
//        ToneController.sharedInstance().type = type
//        ToneController.sharedInstance().secretDetailType = detailType
//
//        AudioKit.start()
        
//        let option = ImagePlayer.getOption()
    }
    
}
