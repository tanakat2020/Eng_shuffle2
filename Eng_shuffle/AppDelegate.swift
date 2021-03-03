//
//  AppDelegate.swift
//  Eng_shuffle
//
//  Created by tanakat on 2017/06/06.
//  Copyright © 2017年 tanakat2020. All rights reserved.
//

import UIKit
import WatchConnectivity
import AVFoundation
import MediaPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    
    // Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details.
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("The session has completed activation.")
    }
    
    // Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed.
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        print("The session has got into inactivation.")
    }
    
    // Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession.
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
        print("The session has deactivated")
    }
    
    var window: UIWindow?
    
    let wcSession = WCSession.default
    
    /// iCloudなど他のアプリから渡されたテキストファイルをアプリ内に保存   iOSでファイル共有の仕組みが変わった？ 共有のファイルアプリを使うようにする！？
    //func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        //URLの確認なので無くてもOK
        print("url: ", url)
        print("url.scheme: ", url.scheme!)
        print("url.description: ", url.description)
        
        if url.description == "Engshuffle2-app://" {
            return true
        }
        
        
        
        if url.scheme! != "file" {
            // print(url.host!)
            print(url.path)
            //  print(url.query as Any)
            
            //リクエストされたURLの中からhostの値を取得して変数に代入
            //let urlHost : String = url.host as String!
            let urlHost = url.host
            
            //遷移させたいViewControllerが格納されているStoryBoardファイルを指定
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            //urlHostにnextが入っていた場合はmainstoryboard内のSetting2ViewControllerのviewを表示する
            if(urlHost == "next"){
                
                ItemNo = 3
                SentenceNo = 0
                actionExtensionflag = true
                
                print(url)
                
                let resultVC: Setting2ViewController = mainStoryboard.instantiateViewController(withIdentifier: "Setting2ViewController") as! Setting2ViewController
                self.window?.rootViewController = resultVC
                
                self.window?.makeKeyAndVisible()
                return true
                
            }
            else{
                return true
            }
        }
        
        print("openURL:" + url.description)
        
        let textFileName = url.lastPathComponent
        //let textFileName = "result.txt"
        
        if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            
            
            let targetTextFilePath = documentDirectoryFileURL.appendingPathComponent(textFileName)
            
            
            print("targetTextFilePath: ", targetTextFilePath)
            
            do {
                let text = try String(contentsOf: url, encoding: String.Encoding.utf8)
                print(text)
                
                try text.write(to: targetTextFilePath, atomically: true, encoding: String.Encoding.utf8)
                
            } catch let error as NSError {
                print("failed to read: \(error)")
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        //audio バックグラウンド再生
        //    do {
        ////      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        //      try AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default)
        //      try AVAudioSession.sharedInstance().setActive(true)
        //    } catch {
        //      print(error)
        //    }
        
        //apple watch
        if WCSession.isSupported() {
            wcSession.delegate = self
            wcSession.activate()
            print("session activate")
            
        }
        else{
            print("session error")
            
        }
        
        
        return true
    }
    
    // get message from watch
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void){
        
        print("get message from watch")
        
        //audio バックグラウンド再生設定
        do {
            // バックグラウンド再生有効(サイレントモードでも音が鳴る)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            // バックグラウンド再生無効(サイレントモードで音鳴らない)
            //      try AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("バックグラウンド再生有効")
        } catch {
            print(error)
        }
        
        // watchからのメッセージを受け取り
        if let watchMessage = message["toParent"] as? String {
            if watchMessage == "Next" {
                // 想定するメッセージ
                print("try to send message to watch")
                
                DispatchQueue.main.async {
                    let vc = self.window?.rootViewController as! ViewController
                    vc.answercountup()
                    vc.changeCard()
                    vc.sendapplewatchmessage()
                }
                
                //      ホーム画面を更新
                DispatchQueue.main.async{
                    let vc = self.window?.rootViewController as! ViewController
                    vc.setmp3()
                    vc.setHyperLink()
                    vc.setcommandcenter2()
                }
                
            }
            else if watchMessage == "Back" {
                print("try to send message to watch 2")
                let vc = self.window?.rootViewController as! ViewController
                vc.answercountup()
                
                if SentenceNo == 0 {
                    SentenceNo = Bookarray[ItemNo].SentenceArray.count - 1
                }
                else{
                    SentenceNo = SentenceNo - 1
                }
                
                vc.sendapplewatchmessage()
                
                DispatchQueue.main.async{
                    let vc = self.window?.rootViewController as! ViewController
                    vc.setmp3()
                    vc.setHyperLink()
                    vc.setcommandcenter2()
                }
            }
            else if watchMessage == "NothingtoDo" {
                // 問題文を変更しない。そのままApple Watchに送信する
                // 想定するメッセージ
                print("try to send message to watch NothingtoDo")
                
                DispatchQueue.main.async {
                    let vc = self.window?.rootViewController as! ViewController
                    vc.sendapplewatchmessage()
                }
                
                //      ホーム画面を更新
                DispatchQueue.main.async{
                    let vc = self.window?.rootViewController as! ViewController
                    vc.setmp3()
                    vc.setHyperLink()
                    vc.setcommandcenter2()
                }
                
            }
            else if watchMessage == "Playback" {
                DispatchQueue.main.async{
                    let vc = self.window?.rootViewController as! ViewController
                    vc.answercountup()
                    vc.playback()
                    vc.setHyperLink()
                    vc.setcommandcenter2()
                }
            }
            else if watchMessage == "Good" {
                // 想定するメッセージ
                print("try to send message to watch 3")
                
                let vc = self.window?.rootViewController as! ViewController
                vc.answercountup()
                vc.memorized()
                vc.changeCard()
                vc.sendapplewatchmessage()
                
                //ホーム画面を更新
                DispatchQueue.main.async{
                    let vc = self.window?.rootViewController as! ViewController
                    vc.setmp3()
                    vc.setHyperLink()
                    vc.setcommandcenter2()
                }
            }
            else if watchMessage == "Volup" {
                DispatchQueue.main.async{
                    let vc = self.window?.rootViewController as! ViewController
                    vc.volup_func()
                    
                }
            }
            else if watchMessage == "Voldown" {
                DispatchQueue.main.async{
                    let vc = self.window?.rootViewController as! ViewController
                    vc.voldown_func()
                }
            }
            
        }
        else{
            print("error: session receive")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

