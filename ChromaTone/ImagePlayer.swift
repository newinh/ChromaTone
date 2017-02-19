//
//  ImagePlayer.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 19..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

public class ImagePlayer {
    
    var image : UIImage?
    
    // pixel 넣어서 MainUI update 할것 : 해당하는 픽셀 없어진것처럼 표현
    var playHandler : ( (CGRect)  -> Void )?
    
    
    /*
     
     
 */
    
    
    public func play() {
        
        /*
         step1. Image 에서 픽셀location 가져오기
         step2. pixel을 색 정보 가져오기
         step3. 얻어온 색정보로 소리 재생
         
         step4 현란하게 재생...
         */
        
    }
    
    public func stop() {
        // 흠.. 큐의 suspend를 써서 멈추자.
    }
    
    public func getPixelLocation() {
        
    }
    
}
