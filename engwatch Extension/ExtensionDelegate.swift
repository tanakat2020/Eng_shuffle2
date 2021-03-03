//
//  ExtensionDelegate.swift
//  engwatch Extension
//
//  Created by tanakat on 2018/11/26.
//  Copyright © 2018年 tanakat2020. All rights reserved.
//

import WatchKit
import WatchConnectivity
import ClockKit

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    
    // Call when the app goes to the background.
    func applicationDidEnterBackground() {
        // Schedule a background refresh task to update the complications.
        scheduleBackgroundRefreshTasks()
    }
    
    // Download updates from HealthKit whenever the app enters the foreground.
//    func applicationWillEnterForeground() {
//        
//        // Make sure the app has requested authorization.
//        let model = CoffeeData.shared
//        model.healthKitController.requestAuthorization { (success) in
//            
//            // Check for errors.
//            if !success { fatalError("*** Unable to authenticate HealthKit ***") }
//            
//            // check for updates from HealthKit
//            model.healthKitController.loadNewDataFromHealthKit {}
//        }
//    }

    
  //application contextの受信時の処理で受信できるので sendMessageを受信しなくても動作する
//    // get message from parent
//    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
//
//      // iPhoneからのデータを受け取る
//      print("didReceiveMessage2")
//
//      if let parentMessage = message["Parent"] as? String {
//
//        print("parentMessage: ", parentMessage)
//        // ラベルに表示
//        myLabel1.setText(parentMessage)
//
//      }
//    }

    //  @objc dynamic var messages = [String]()
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
      print("receive::activationDidCompleteWith")
        reloadComplications()
    }
  
    let wcSession = WCSession.default
  
  // comlication用
    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {

//      print("userInfo: ", userInfo)

      if let message = userInfo["date"]{
        print("complication didReceiveUserInfo message:", message)

        let userDefaults = UserDefaults.standard
        userDefaults.set(message, forKey: "message3")
        userDefaults.synchronize()

        // reload complication data
        reloadComplications()
      }

  }
  
  func reloadComplications() {
    
    print("log0300 reloadComplications")
    
    // Update any complications on active watch faces.
    let server = CLKComplicationServer.sharedInstance()
    for complication in server.activeComplications ?? [] {
        server.reloadTimeline(for: complication)
    }
    
    print("log0301 reloadComplications")
    CLKComplicationServer.sharedInstance().reloadComplicationDescriptors()
    
  }
  
  // application contextの受信時の処理
  public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    
//      //dictionary型のテスト これがないとなぜかapplicationContextも上手く動かなかった
//      var airport = ["YYZ": "Toronto Pearson", "DUB": "Dublin"]
//      if let yyz = airport["YYZ"]{
//        print(yyz)//Toronto Pearson
//      }
    
      print("receive application context::\(applicationContext)")
    
      if let message = applicationContext["date"]{
  //      print(message)
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(message, forKey: "message3")
        userDefaults.synchronize()
      
      }
      else{
        print("no message3 ExtensionDelegate")
      }
    
      if let message5 = applicationContext["status"]{
        print(message5)
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(message5, forKey: "message5")
        userDefaults.synchronize()
        
      }
      else{
//        print("no message5 ExtensionDelegate")
      }
      
    }
  
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
      if WCSession.isSupported() {
        wcSession.delegate = self
        wcSession.activate()
        print("session activate apple watch")
        
      }
      else{
        print("session error")
        
      }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                
                self.scheduleBackgroundRefreshTasks()
                
                backgroundTask.setTaskCompletedWithSnapshot(true)
                
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    //https://jjworkshop.com/blog/archives/2021/01/applewatchcompl.html
    // MARK: - Private Methods
    // Schedule the next background refresh task.
    func scheduleBackgroundRefreshTasks() {
        
        // Get the shared extension object.
        let watchExtension = WKExtension.shared()
        
        // If there is a complication on the watch face, the app should get at least four
        // updates an hour. So calculate a target date 15 minutes in the future.
        let targetDate = Date().addingTimeInterval(15.0 * 60.0)
        
        // Schedule the background refresh task.
        watchExtension.scheduleBackgroundRefresh(withPreferredDate: targetDate, userInfo: nil) { (error) in
            
            // Check for errors.
            if let error = error {
                print("*** An background refresh error occurred: \(error.localizedDescription) ***")
                return
            }
            
            print("*** Background Task Completed Successfully! ***")
        }
        
        //https://stackoverflow.com/questions/45862501/wkrefreshbackgroundtask-error-attempting-to-reach-file-bktasksnapshot-null
        WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: targetDate, userInfo: nil) { error in
                if (error == nil) {
                    print("successfully scheduled snapshot.  All background work completed.")
                }
            }
        
        // コンプリケーションデータを更新
        reloadComplications()
    }
}
