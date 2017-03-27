//
//  ColorViewController+UIImagePickerDelegate.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 3. 27..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation
import UIKit

extension ColorViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            self.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
