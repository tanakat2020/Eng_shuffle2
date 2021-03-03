//
//  InterfaceController.swift
//  engwatch Extension
//
//  Created by tanakat on 2018/11/26.
//  Copyright © 2018年 tanakat2020. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import AVFoundation
import ClockKit

class InterfaceController: WKInterfaceController, WCSessionDelegate  {
    
    // Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details.
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        print("The session has completed activation.")
        
    }
    
    
    
    @IBOutlet weak var goodButton: WKInterfaceButton!
    
    @IBOutlet weak var myLabel1: WKInterfaceLabel!
    
    @IBOutlet weak var myButton1: WKInterfaceButton!
    
    @IBOutlet weak var myButton2: WKInterfaceButton!
    
    @IBOutlet weak var myButton3: WKInterfaceButton!
    
    var timer: Timer!
    
    var wcSession = WCSession.default
    
    
    var counter:Int = 0
    
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var audioFile: AVAudioFile!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        //  check supported
        if WCSession.isSupported() {
            //  get default session
            //      wcSession = WCSession.default
            
            //  set delegate
            //      wcSession.delegate = self これをしないとInterfaceController.swiftでreceiveできない？
            
            //  activate session
            wcSession.activate()
            
        } else {
            print("Not support WCSession")
        }
        
        guard let path = Bundle.main.path(forResource: "DUO3.0_001", ofType: "mp3") else {
            return
        }
        
        audioEngine = AVAudioEngine() // (1)
        audioPlayerNode = AVAudioPlayerNode() // (2)
        let audioPath = URL(fileURLWithPath: path)
        audioFile = try! AVAudioFile(forReading: audioPath) // (3)
        audioEngine.attach(audioPlayerNode) // (4)
        audioEngine.connect(audioPlayerNode,
                            to: audioEngine.mainMixerNode,
                            format: audioFile.processingFormat) // (5)
        audioEngine.prepare() // (6)
        try! audioEngine.start() // (7)
        
        
        
//        print("reloadComplications1")
//
//        // Update any complications on active watch faces.
//        let server = CLKComplicationServer.sharedInstance()
//        for complication in server.activeComplications ?? [] {
//            server.reloadTimeline(for: complication)
//        }
        
    }
    
    
    @IBAction func musicplay() {
        
        audioPlayerNode.scheduleFile(audioFile, at: nil) { () -> Void in // (8)
            print("complete")
        }
        audioPlayerNode.play() // (9)
    }
    
    
    
    @IBAction func leftSwipe(_ sender: Any) {
        print("leftSwipe")
        if wcSession.isReachable {
            sendMessageToParent(textString: "Next")
        }
    }
    
    @IBAction func rightSwipe(_ sender: Any) {
        print("rightSwipe")
        if wcSession.isReachable {
            sendMessageToParent(textString: "Back")
        }
    }
    
    @IBAction func tapRecognized(_ sender: Any) {
        print("tapRecognized")
        if wcSession.isReachable {
            sendMessageToParent(textString: "Next")
        }
    }
    
    //受信動作はExtensionDelegateで動作
    // get message from parent
    //  func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
    //
    //    // iPhoneからのデータを受け取る
    //    print("didReceiveMessage")
    //
    //    if let parentMessage = message["Parent"] as? String {
    //
    //      print("parentMessage: ", parentMessage)
    //      // ラベルに表示
    //      myLabel1.setText(parentMessage)
    //
    //    }
    //  }
    
    //Good タップ
    @IBAction func tapmyButton1() {
        
        if wcSession.isReachable {
            print("reachable")
            // reachableであればメッセージを送る
            sendMessageToParent(textString: "Good")
            
        }
        else{
            print("not reachable")
        }
        
    }
    
    //back　タップ
    @IBAction func tapmyButton2() {
        if wcSession.isReachable {
            print("reachable2")
            // reachableであればメッセージを送る
            sendMessageToParent(textString: "Back")
        }
        else{
            print("not reachable2")
        }
        
    }
    
    //テスト用
    @IBAction func tapmyButton3() {
        if wcSession.isReachable {
            print("reachable3")
            // reachableであればメッセージを送る
            sendMessageToParent(textString: "Playback")
        }
        else{
            print("not reachable3")
        }
    }
    
    @IBAction func volupButton() {
        if wcSession.isReachable {
            print("reachable4")
            // reachableであればメッセージを送る
            sendMessageToParent(textString: "Volup")
        }
        else{
            print("not reachable4")
        }
    }
    
    @IBAction func VoldownButton() {
        if wcSession.isReachable {
            print("reachable5")
            // reachableであればメッセージを送る
            sendMessageToParent(textString: "Voldown")
        }
        else{
            print("not reachable5")
        }
        
    }
        
    // send message to parent
    func sendMessageToParent(textString:String){
        print("sendMessageToParent()")
        
        let message = [ "toParent" : textString ]
        
        wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })
        
    }
    
    @objc func refreshTimer(){
        
        //設定したタイマーごとに画面を更新する 0.5秒ごととか
        
        let userDefaults = UserDefaults.standard
        if let messageA3 = userDefaults.string(forKey: "message3") {
            //      print("messageA: " + messageA)
            
            //改行区切りでデータを分割して配列に格納する。
            var dataList:[String] = []
            dataList = messageA3.components(separatedBy: "\n")
            //        print("dataList.count: " + String(dataList.count))
            
            if dataList.count == 5 {
                let textString = "Good: " + dataList[4]
                //    print("textString: ", textString)
                goodButton.setTitle(textString)
            }
            
            myLabel1.setText(messageA3)
            //      print("messageA3 refreshTimer")
        }
        else{
            //      print("No messageA3 refreshTimer")
        }
        
        if let messageA5 = userDefaults.string(forKey: "message5") {
            myButton3.setTitle(messageA5)
            //      print("messageA5 refreshTimer")
        }
        else{
            //      print("No messageA5 refreshTimer")
        }
        
        
    }
    
    
    //scheduleBackgroundRefreshTasksで定期的に呼び出される？
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        //      timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: Selector(("refreshTimer")), userInfo: nil, repeats: false)
        
        timer = Timer.scheduledTimer(
            timeInterval: 0.5,          //timeInterval: 0.5,
            target: self,
            selector: #selector(self.refreshTimer),
            userInfo: nil,
            repeats: true)
        
        let userDefaults = UserDefaults.standard
        userDefaults.register(defaults: ["olddate_value" : "2021-02-16"])
        
        if var messageA3 = userDefaults.string(forKey: "message3") {
            
            //改行区切りでデータを分割して配列に格納する。
            var dataList:[String] = []
            dataList = messageA3.components(separatedBy: "\n")
            print("log0100 dataList.count: " + String(dataList.count))
            print("messageA3: " + messageA3)
            
            
            if dataList.count == 5 {
                let textString = "Good: " + dataList[4]
                //    print("textString: ", textString)
                goodButton.setTitle(textString)
                myLabel1.setText(messageA3)
                
                var currentdate = ""
                currentdate = getNowClockString()
                //currentdate = "2021-03-01"
                
                //var olddate = userDefaults.string(forKey: "olddate_value")!
                //olddate = "2021-02-25"
                
                let olddate = userDefaults.string(forKey: "olddate_value")!
                
                //TodaysAnswerDate = "2017-06-25"
                print("currentdate: ", currentdate, "   olddate: ", olddate)
                
                //UserDefaultsがうまく動いていない？ 20210216
                if currentdate != olddate {
                    userDefaults.set(currentdate, forKey: "olddate_value")
                    //userDefaults.set(olddate, forKey: "olddate_value")

                    var dataList2:[String] = []
                    dataList2 = dataList[4].components(separatedBy: "-")
                    dataList2[1] = "999"
                    
                    messageA3 = dataList[0] + "\n" + " " + "\n" + dataList[2] + "\n" + " " + "\n" + dataList2[0] + "-" + dataList2[1]
                    userDefaults.set(messageA3, forKey: "message3")
                    print("messageA3-2: " + messageA3)
                    
                    //同期
                    userDefaults.synchronize()
                    
                    print("willActivate: dataList2[1] 999   and reloadTimeline(for: complication)")
                    
                    // Update any complications on active watch faces.
                    let server = CLKComplicationServer.sharedInstance()
                    for complication in server.activeComplications ?? [] {
                        server.reloadTimeline(for: complication)
                    }
                }
            }
        }
        else{
            print("No messageA, sendMessage NothingtoDo")
            sendMessageToParent(textString: "NothingtoDo")
        }
        
        if let messageA5 = userDefaults.string(forKey: "message5") {
            myButton3.setTitle(messageA5)
        }
        else{
//            print("No messageA5")
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    //現在時刻の取得
    func getNowClockString() -> String {
        let formatter = DateFormatter()
        //formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        formatter.dateFormat = "yyyy-MM-dd"
        //formatter.dateFormat = "yyyy-MM-dd　HH:mm"
        
        let now = Date()
        return formatter.string(from: now)
    }
}
