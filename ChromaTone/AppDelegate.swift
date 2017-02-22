//
//  AppDelegate.swift
//  ChromaTone
//
//  Created by 신승훈 on 2017. 2. 7..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import UIKit
import AudioKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func checkIfFirstLaunch() {
        if UserDefaults.standard.bool(forKey: "firstLauch") {
            print("실행된 적 있음")
            
            
        } else {    // 첫실행
            print("첫실행")
            
            UserDefaults.standard.set(true, forKey: "firstLauch")

            // TonController
            UserDefaults.standard.set("piano", forKey: "Tone Instrument Type Key")
            UserDefaults.standard.set("sine", forKey: "Tone Instrument DetailType Key")
            
            UserDefaults.standard.set(Double(60.0), forKey: "ImagePlayer Option BPM Key")
            UserDefaults.standard.set(Int(4), forKey: "ImagePlayer Option TimerPerBeat Key")
            UserDefaults.standard.set(Int(40), forKey: "ImagePlayer Option NoteCount Key")
            UserDefaults.standard.set("verticalScanBar", forKey: "ImagePlayer Option PlayMode Key")
            UserDefaults.standard.set(Int(10), forKey: "ImagePlayer Option Scan Sample Number Key")
            
            UserDefaults.standard.synchronize()
        }
    }
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        checkIfFirstLaunch()
        
        // 싱글턴 생성요맨
        let _ = ToneController.sharedInstance()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        AudioKit.stop()
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        AudioKit.stop()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        AudioKit.start()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AudioKit.start()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        AudioKit.stop()
    }
}

