//
//  ColorViewController+PickerView.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 24..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation
import  UIKit

extension ColorViewController {
    func pickerSoundOn() {
        // Color Picked Completion Handler
        self.colorPickerImageView.pickedColor = { [unowned self] (newColor) in
            // 색 미리보기
            self.preview.backgroundColor = newColor
            ToneController.sharedInstance().playMelody(color: newColor)
        }
        self.colorPickerImageView.endedTouch = {
            ToneController.sharedInstance().stop()
        }
    }
    
    func pickerSoundOff() {
        // Color Picked Completion Handler
        self.colorPickerImageView.pickedColor = { [unowned self] (newColor) in
            // 색 미리보기
            self.preview.backgroundColor = newColor
        }
        self.colorPickerImageView.endedTouch = {
        }
    }
    
}
