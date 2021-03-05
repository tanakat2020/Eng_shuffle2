//
//  ViewController.swift
//  Eng_shuffle
//
//  Created by tanakat on 2017/06/06.
//  Copyright © 2017年 tanakat2020. All rights reserved.
//

import UIKit
import AVFoundation   //音声読み上げ
import WatchConnectivity  //apple watch
import MediaPlayer

var ItemNo = 0
var SentenceNo = 0
var old_SentenceNo = 0
var old_trydate = "2001-01-01"
var MaximumSentenceNo = 0
let Bookarray = [TextBook(filename: "Textbook1.txt"), TextBook(filename: "Textbook2.txt"), TextBook(filename: "Textbook3.txt"), TextBook(filename: "Textbook4.txt"), TextBook(filename: "Textbook5.txt")] // letでOK
var actionExtensionflag = false

var testString11 = ""

final class SampleBarViewController: UIViewController {
    
}

class ViewController: UIViewController, WCSessionDelegate {
    
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
    
    //ステータスバー(時計)の文字の色（ダークモードとかの影響で白文字化して見えなくなったりした）
    override var preferredStatusBarStyle: UIStatusBarStyle {
        //return .darkContent
        return traitCollection.userInterfaceStyle == .dark ? .lightContent : .darkContent
    }
    
    
    // App Groups
    let suiteName: String = "group.com.swift.tanakat2020.Eng-shuffle2"
    let keyName: String = "shareData"
    
    @IBOutlet weak var selectButton: UIButton!
    
    @IBOutlet weak var moveButton: UIButton!
    
    @IBOutlet weak var resultButton: UIButton!
    
    @IBOutlet weak var speechButton: UIButton!
    
    @IBOutlet weak var back2Button: UIButton!
    
    @IBOutlet weak var audioButton: UIButton!
    
    @IBOutlet weak var musicplayButton: UIButton!
    
    @IBOutlet weak var answerButton: UIButton!
    
    @IBOutlet weak var SentenceNo_label: UILabel!

    
    @IBOutlet weak var repeat2Button: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var JptextView: UITextView!
    
    @IBOutlet weak var EngTextViewHeightConstraint: NSLayoutConstraint!
    
    //apple watch
    let wcSession = WCSession.default
    var counter:Int = 0
    
    
    var firstRange: NSRange = NSRange()
    
    var matchnumber = 0
    
    var answerbuttonflag = false    //解答ボタンのフラグ true:解答表示状態、false:解答非表示状態
    
    var attributedString = NSMutableAttributedString()
    
    //日付
    var TodaysAnswerDate = ""
    
    //設定
    var swipemode = 0
    var changecolor = 0
    var Jpdisplayflag = true
    var Jp2displayflag = true
    var Jp3displayflag = true
    var Engspeechflag = false
    var Eng2speechflag = false
    var SentenceNoLearningflag = true
    var Darkmodeflag = true
    
    var repeatflag = false            //trueならリピート再生中 現状使っていない
    var repeat2Buttonflag = false     //trueならリピート再生中（card変更後も連続再生する）
    
    var resultFlag = true             //結果表示のフラグ
    
    let settings = UserDefaults.standard
    
    let synthesizer = AVSpeechSynthesizer()
    
    var player = AVAudioPlayer()
    
//    var testplayer:MPMusicPlayerController!
    
    let volumeControl = MPVolumeView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
    
    override func viewDidLoad() {
        
        self.view.addSubview(volumeControl)
        
        volumeControl.showsRouteButton = false
        
        let lst = volumeControl.subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}
        let slider = lst.first as? UISlider
//        let routebutton = lst.first as? UIButton
        //スライダーの白丸を消去
        slider!.setThumbImage(UIImage(), for: .normal)
//        routebutton!.setRoutePickerButtonColor(UIColor.red)
        
        //コントロールセンター
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        
        var currentdate = ""
        currentdate = getNowClockString2()
        var textString = ""
        textString = currentdate
        makeTextFile(textFileName: "log.txt", textString: textString)
        
        super.viewDidLoad()
        
        //apple watch
        // check supported
        if WCSession.isSupported() {
            // set delegate
            //      wcSession.delegate = self
            
            // activate session
            wcSession.activate()
            
        }
        
        
        //  アプリ間共有のためのフォルダとデータを作成
        let fm = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        //let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsPath + "/myfile.txt"
        if !fm.fileExists(atPath: filePath) {
            fm.createFile(atPath: filePath, contents: nil, attributes: [:])
        }
        
        // レフトスワイプを定義　次の文へ移動
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.leftSwipeView(sender:)))
        // レフトスワイプのみ反応するようにする
        leftSwipe.direction = .left
        // viewにジェスチャーを登録
        self.view.addGestureRecognizer(leftSwipe)
        
        // ライトスワイプを定義　前の文へ移動
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.rightSwipeView(sender:)))
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(rightSwipe)
        
        // アップスワイプを定義　チェックの付いた次の文へ移動
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.upSwipeView(sender:)))
        upSwipe.direction = .up
        self.view.addGestureRecognizer(upSwipe)
        
        // ダウンスワイプを定義　正解数0の次の文へ移動
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.downSwipeView(sender:)))
        downSwipe.direction = .down
        self.view.addGestureRecognizer(downSwipe)
        
        // TextViewのタップを定義
        let firstTap = UITapGestureRecognizer(target: self, action: #selector(self.tapText(tap:)))
        textView.addGestureRecognizer(firstTap)
        
        //2本指でアップスワイプ アップスワイプと同じ（長い文章用）
        let upSwipe2 = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.upSwipe2View(sender:)))
        upSwipe2.direction = .up
        upSwipe2.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(upSwipe2)
        
        // Labelのタップを定義
        //let LabelTap = UITapGestureRecognizer(target: self, action: #selector(self.tapLable(tap:)))
        //let LabelTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.SentenceNo_label.tapLable(tap:)))
        //let myTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.changeColor(_ :)))
        let LabelTap = UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(tap:)))
        self.SentenceNo_label.addGestureRecognizer(LabelTap)
        //SentenceNo_label.addGestureRecognizer(LabelTap)
        //let myTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.changeColor(_ :)))
        
        settings.register(defaults: ["ItemNo_value" : 0])
        settings.register(defaults: ["changecolor_value" : 0])
        settings.register(defaults: ["swipemode_value" : 0])
        settings.register(defaults: ["TodaysAnswerDate_value" : 0])
        settings.register(defaults: ["Jpdisplayflag_value" : 0])
        settings.register(defaults: ["Jp2displayflag_value" : 0])
        settings.register(defaults: ["Jp3displayflag_value" : 0])
        settings.register(defaults: ["Engspeechflag_value" : 0])
        settings.register(defaults: ["Eng2speechflag_value" : 0])
        settings.register(defaults: ["SentenceNoLearningflag_value" : 0])
        settings.register(defaults: ["Darkmodeflag_value" : 0])
        
        ItemNo = settings.integer(forKey: "ItemNo_value")
        changecolor = settings.integer(forKey: "changecolor_value")
        swipemode = settings.integer(forKey: "swipemode_value")
        TodaysAnswerDate = settings.string(forKey: "TodaysAnswerDate_value")!
        Jpdisplayflag = settings.bool(forKey: "Jpdisplayflag_value")
        Jp2displayflag = settings.bool(forKey: "Jp2displayflag_value")
        Jp3displayflag = settings.bool(forKey: "Jp3displayflag_value")
        Engspeechflag = settings.bool(forKey: "Engspeechflag_value")
        Eng2speechflag = settings.bool(forKey: "Eng2speechflag_value")
        SentenceNoLearningflag = settings.bool(forKey: "SentenceNoLearningflag_value")
        Darkmodeflag = settings.bool(forKey: "Darkmodeflag_value")
                
        if Darkmodeflag == true {
            overrideUserInterfaceStyle = .dark
//            UIApplication.shared.statusBarStyle = .lightContent
        }
        else{
            overrideUserInterfaceStyle = .light
//            UIApplication.shared.statusBarStyle = .darkContent
        }
        
        
        //swipemodeの設定
        if swipemode == 0 {
            SentenceNo_label.textColor = UIColor.label
        }
        else if swipemode == 1 {
            SentenceNo_label.textColor = UIColor.red
        }
        else if swipemode == 2 {
            SentenceNo_label.textColor = UIColor.orange
        }
        else if swipemode == 3 {
            SentenceNo_label.textColor = UIColor.green
        }
        else if swipemode == 4 {
            SentenceNo_label.textColor = UIColor.purple
        }
        else if swipemode == 5 {
            SentenceNo_label.textColor = UIColor.green
        }
        else if swipemode == 6 {
            SentenceNo_label.textColor = UIColor.purple
        }
        
        //初期値の設定
        SentenceNo = Bookarray[ItemNo].SentenceNo
        MaximumSentenceNo = Bookarray[ItemNo].SentenceArray.count
        
        noSlider.minimumValue = 1
        noSlider.maximumValue = Float(MaximumSentenceNo)
        noSlider.value = Float(SentenceNo + 1)
        
        JptextView.isSelectable = false
        JptextView.isUserInteractionEnabled = true
        JptextView.isEditable = false
        
        textView.isSelectable = false
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        
        //    makeTextFile(textFileName: "log.txt", textString: "log4")
        old_trydate = Bookarray[ItemNo].SentenceArray[SentenceNo].trydate
        
        //mp3の設定
        setmp3()
        
        //音楽をバッファに読み込んでおく
        player.prepareToPlay()
        
        //デリゲート先に自分を設定する。
        player.delegate = self as? AVAudioPlayerDelegate
        
        //testplayer = MPMusicPlayerController.applicationMusicPlayer
        
        setHyperLink()
        
        setcommandcenter()
        
        //ステータスバー（時計表示の文字の色）
        //    UIApplication.shared.statusBarStyle = .darkContent
        
    }
    
    override func viewDidLayoutSubviews() {
        //volumeControl.frame = CGRect(x: -120, y: -120, width: 100, height: 100);
        //volumeControl.frame = CGRect(x: 0, y: -8, width: 100, height: 100);
        volumeControl.frame = CGRect(x: 0, y: -8, width: 100, height: 10);
    }
    
    func setVolume(_ volume: Float) {
        let lst = volumeControl.subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}
        let slider = lst.first as? UISlider
        
//        let thumbImage = UIColor.white.circleImage(width: 5, height: 5) // 白い16x16の丸
//        slider.setThumbImage(thumbImage, for: .normal)
                slider!.setThumbImage(UIImage(), for: .normal)

        print("slider.value: ", slider?.value as Any)
        slider?.setValue(volume, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Storyboardで遷移時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //print("segue.destination", segue.destination)
        
        if segue.identifier == "goSetting" {
            
            // 遷移先のコントローラを取得
            let controller = segue.destination as! SettingViewController
            
            // 遷移先で処理を終えた後の処理をここで書く
            controller.resultHandler = { data_ in
                print(data_) // 閉じるボタン押下
                
                self.viewdidappear_process()

            }
        }
        
        //コントロールセンターテスト用
        //    override func remoteControlReceivedWithEvent(event: UIEvent) {
        //      switch event.subtype {
        //      case .RemoteControlPlay:  // 再生ボタン
        //        player.play()
        //      case .RemoteControlPause:  // 停止ボタン
        //        player.pause()
        //      case .RemoteControlNextTrack:  // 次へボタン
        //      // ▶▶ 押下時の処理
        //      case .RemoteControlPreviousTrack:  // 前へボタン
        //      // ◀◀ 押下時の処理
        //      default:
        //        break
        //      }
        //    }
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        presentingViewController?.beginAppearanceTransition(false, animated: animated)
        super.viewWillAppear(animated)
        //        print("viewWillAppear1")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentingViewController?.endAppearanceTransition()
        //        print("viewDidAppear1")
        
//        self.Darkmodeflag = self.settings.bool(forKey: "Darkmodeflag_value")
//        if self.Darkmodeflag == true {
//            self.overrideUserInterfaceStyle = .dark
//        }
//        else{
//            self.overrideUserInterfaceStyle = .light
//        }
        
        viewdidappear_process()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.beginAppearanceTransition(true, animated: animated)
        presentingViewController?.endAppearanceTransition()
        //        print("viewWillDisappear1")
    }
    
    func viewdidappear_process(){
        
        //ダークモード設定
        self.Darkmodeflag = self.settings.bool(forKey: "Darkmodeflag_value")
        if self.Darkmodeflag == true {
            self.overrideUserInterfaceStyle = .dark
        }
        else{
            self.overrideUserInterfaceStyle = .light
        }
        
        //和文表示
        jptextview_update()

        
        
        
        self.SentenceNoLearningflag = self.settings.bool(forKey: "SentenceNoLearningflag_value")
        //print("SentenceNoLearningflag: ", self.SentenceNoLearningflag)
        
        //右上のSentenceNoLearningラベルの更新
        self.SentenceNoLearning_update()
        
        //設定ボタンの色設定
        self.Engspeechflag = self.settings.bool(forKey: "Engspeechflag_value")
        self.Eng2speechflag = self.settings.bool(forKey: "Eng2speechflag_value")
        if self.Engspeechflag || self.Eng2speechflag {
            self.back2Button.backgroundColor = UIColor.brown
        }
        else{
            self.back2Button.backgroundColor = UIColor.systemBackground
        }
       

    }
        
    @IBOutlet weak var jpSentence: UILabel!
    
    @IBOutlet weak var AnswerNo_label: UILabel!
    
    @IBOutlet weak var SentenceNoLearning_label: UILabel!
    
    @IBOutlet weak var noSlider: UISlider!
    
    @IBAction func changeSlider(_ sender: Any) {
        
        noSlider.maximumValue = Float(MaximumSentenceNo)
        
        SentenceNo = Int(noSlider.value)-1
        
        if repeat2Buttonflag {
            setcommandcenter2()
        }
        
        //mp3の設定
        setmp3()
        
        sendapplewatchmessage()
        
        setHyperLink()
        
    }
    
    /// レフトスワイプ時に実行される
    @objc func leftSwipeView(sender: UISwipeGestureRecognizer) {
        
        if repeat2Buttonflag {
            //スワイプしたらカウントアップ
            answercountup()
        }
        
        //print("left Swipe")
        changeCard()
        
        //    if repeat2Buttonflag {
        setcommandcenter2()
        //    }
        
        //mp3の設定
        setmp3()
        
        //apple watchへデータ転送
        sendapplewatchmessage()
        
        setHyperLink()
    }
    
    /// ライトスワイプ時に実行される
    @objc func rightSwipeView(sender: UISwipeGestureRecognizer) {
        //print("right Swipe")
        
        if repeat2Buttonflag {
            //スワイプしたらカウントアップ
            answercountup()
        }
        if SentenceNo == 0 {
            SentenceNo = MaximumSentenceNo-1
        }
        else{
            SentenceNo = SentenceNo - 1
        }
        
        answerbuttonflag_false()
        
        if repeat2Buttonflag {
            setcommandcenter2()
        }
        
        //mp3の設定
        setmp3()
        
        sendapplewatchmessage()
        
        setHyperLink()
    }
    
    /// アップスワイプ時に実行される
    @objc func upSwipeView(sender: UISwipeGestureRecognizer) {
        //print("Up Swipe")
        
        answercountup()
        
        memorized()
        
        changeCard()
        
        if repeat2Buttonflag {
            setcommandcenter2()
        }
        
        //mp3の設定
        setmp3()
        
        //apple watchへデータ転送
        sendapplewatchmessage()
        
        setHyperLink()
    }
    
    /// アップスワイプ時に実行される
    @objc func upSwipe2View(sender: UISwipeGestureRecognizer) {
        print("Up Swipe2")
        
        answercountup()
        
        memorized()
        
        changeCard()
        
        if repeat2Buttonflag {
            setcommandcenter2()
        }
        
        //mp3の設定
        setmp3()
        
        //apple watchへデータ転送
        sendapplewatchmessage()
        
        setHyperLink()
    }
    
    //ちゃんと覚えた
    func memorized(){
        
        Bookarray[ItemNo].SentenceArray[SentenceNo].answercount += 1
        Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsInt(
            value: Bookarray[ItemNo].SentenceArray[SentenceNo].answercount,
            filename: Bookarray[ItemNo].filename,
            SentenceNo: SentenceNo,
            key: "answercountKey")
        
        Bookarray[ItemNo].SentenceArray[SentenceNo].answerCheck += 1
        if Bookarray[ItemNo].SentenceArray[SentenceNo].answerCheck >= 1 {
            Bookarray[ItemNo].SentenceArray[SentenceNo].answerCheck = 1
        }
        
        Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsInt(
            value: Bookarray[ItemNo].SentenceArray[SentenceNo].answerCheck,
            filename: Bookarray[ItemNo].filename,
            SentenceNo: SentenceNo,
            key: "answerCheckKey")
       
        //swipemode6用
        //現SentenceNoのflagをfalseにする
        if Bookarray[ItemNo].SentenceArray[SentenceNo].learning_flag == true {
            Bookarray[ItemNo].SentenceArray[SentenceNo].learning_flag = false
            Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsBool(
                flag: Bookarray[ItemNo].SentenceArray[SentenceNo].learning_flag,
                filename: Bookarray[ItemNo].filename,
                SentenceNo: SentenceNo,
                key: "learning_flagKey")
            
            
            var learning_flag_count = 0
            var answer_count_array: [Int] = []
            
            for i in 0...MaximumSentenceNo - 1 {
                if Bookarray[ItemNo].SentenceArray[i].learning_flag == true {
                    learning_flag_count = learning_flag_count + 1
                }
            }
            
            if learning_flag_count < 20 {
               
                //バケツソート answerカウントの少ないSentenceNo 20個を選択
                //二次元配列の初期化
                var bucket = [[Int]](repeating: [Int](), count: 500)
                for i in 0...MaximumSentenceNo - 1{
                    bucket[Bookarray[ItemNo].SentenceArray[i].answercount].append(i)
                }
                               
//                print("bucket: ", bucket)
//                print("bucket.count: ", bucket.count)
//                print("bucket[0].count: ", bucket[0].count)
//                print("bucket[1].count: ", bucket[1].count)
//                print("bucket[2].count: ", bucket[2].count)
                
                
                for i in 0...bucket.count - 1 {

                    while(bucket[i].count > 0){
                        answer_count_array.append(bucket[i][0])
                        bucket[i].remove(at:0)
                    }
                    
                }
                
//                print("answer_count_array: ", answer_count_array)
//                print("answer_count_array.count: ", answer_count_array.count)
//
                for i in 0...19{
                    Bookarray[ItemNo].SentenceArray[answer_count_array[i]].learning_flag = true
                    Bookarray[ItemNo].SentenceArray[answer_count_array[i]].saveUserDefaultsBool(
                    flag: Bookarray[ItemNo].SentenceArray[answer_count_array[i]].learning_flag,
                    filename: Bookarray[ItemNo].filename,
                    SentenceNo: answer_count_array[i],
                    key: "learning_flagKey")
                }
                
            }

                

        }
    }
    
    /// ダウンスワイプ時に実行される
    @objc func downSwipeView(sender: UISwipeGestureRecognizer) {
        //print("down Swipe")
        
        answercountup()
        
        Bookarray[ItemNo].SentenceArray[SentenceNo].answercount += 1
        Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsInt(
            value: Bookarray[ItemNo].SentenceArray[SentenceNo].answercount,
            filename: Bookarray[ItemNo].filename,
            SentenceNo: SentenceNo,
            key: "answercountKey")
        
        //超しっかり覚えた
        Bookarray[ItemNo].SentenceArray[SentenceNo].answerCheck += 3
        
        Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsInt(
            value: Bookarray[ItemNo].SentenceArray[SentenceNo].answerCheck,
            filename: Bookarray[ItemNo].filename,
            SentenceNo: SentenceNo,
            key: "answerCheckKey")
        
        changeCard()
        
        if repeat2Buttonflag {
            setcommandcenter2()
        }
        
        //mp3の設定
        setmp3()
        
        //apple watchへデータ転送
        sendapplewatchmessage()
        
        setHyperLink()
    }
    
    @IBAction func nextButton(_ sender: Any) {
        
        old_SentenceNo = -1
        Bookarray[ItemNo].SentenceNo = SentenceNo
        
        if ItemNo == 0{
            ItemNo = 1
        }
        else if ItemNo == 1 {
            ItemNo = 2
        }
        else if ItemNo == 2 {
            ItemNo = 3
        }
        else if ItemNo == 3 {
            ItemNo = 4
        }
        else {
            ItemNo = 0
        }
        
        SentenceNo = Bookarray[ItemNo].SentenceNo
        MaximumSentenceNo = Bookarray[ItemNo].SentenceArray.count
        
        noSlider.maximumValue = Float(MaximumSentenceNo)
        
        //解答フラグをfalse
        answerbuttonflag_false()
        
        repeat2Buttonflag = false
        repeat2Button.setTitle("連再", for: [])
        
        //mp3の設定
        setmp3()
        
        //apple watchへデータ転送
        sendapplewatchmessage()
        
        setHyperLink()
    }
    
    
    @IBAction func next2Button(_ sender: Any) {
        
        old_SentenceNo = -1
        Bookarray[ItemNo].SentenceNo = SentenceNo
        
        if ItemNo == 0{
            ItemNo = 4
        }
        else if ItemNo == 1 {
            ItemNo = 0
        }
        else if ItemNo == 2 {
            ItemNo = 1
        }
        else if ItemNo == 3 {
            ItemNo = 2
        }
        else {
            ItemNo = 0
        }
        
        SentenceNo = Bookarray[ItemNo].SentenceNo
        MaximumSentenceNo = Bookarray[ItemNo].SentenceArray.count
        
        noSlider.maximumValue = Float(MaximumSentenceNo)
        
        //解答フラグをfalse
        answerbuttonflag_false()
        
        repeat2Buttonflag = false
        repeat2Button.setTitle("連再", for: [])
        
        //mp3の設定
        setmp3()
        
        //apple watchへデータ転送
        sendapplewatchmessage()
        
        setHyperLink()
        
    }
    
    @IBAction func back2Button(_ sender: Any) {
        
        //設定画面へ遷移
        self.performSegue(withIdentifier: "goSetting", sender: nil)
        
    }
    
    
    func jptextview_update(){
        
        //和文表示 JptextView 表示
        
        Jpdisplayflag = settings.bool(forKey: "Jpdisplayflag_value")
        Jp2displayflag = settings.bool(forKey: "Jp2displayflag_value")
        if Jpdisplayflag == true {
            JptextView.text = Bookarray[ItemNo].SentenceArray[SentenceNo].Jpn
        }
        else if Jp2displayflag == true {
            JptextView.text = Bookarray[ItemNo].SentenceArray[SentenceNo].Jpn
        }
        else{
            JptextView.text = ""
        }
        
        var fontsize = 30
        JptextView.font = UIFont.systemFont(ofSize: CGFloat(fontsize) )
        
        JptextView.backgroundColor = UIColor.clear
        JptextView.textAlignment = .left
        JptextView.frame.size.height = 169
        
        //    print("JptextView: ", JptextView.text!)
        
        for i in 1...8 {
            let size = JptextView.sizeThatFits(JptextView.frame.size)
            //      print("size: ", size)
            //      print("size.height: ", size.height)
            
            if size.height > 169 {
                fontsize = 30 - i
                JptextView.font = UIFont.systemFont(ofSize: CGFloat(fontsize) )
                
                if i == 8 {
                    //右線のCALayerを作成
                    let rightBorder = CALayer()
                    rightBorder.frame = CGRect(x: JptextView.frame.width-1, y: 15, width: 1.0, height:size.height-30)
                    rightBorder.backgroundColor = UIColor.lightGray.cgColor
                    //作成したViewに線を追加
                    JptextView.layer.addSublayer(rightBorder)
                    print("線を描画 JptextView.frame.width:", JptextView.frame.width, "JptextView.frame.height:", JptextView.frame.height)
                }
                
            }
            else{
                //右線のCALayerを作成
                let rightBorder = CALayer()
                rightBorder.frame = CGRect(x: JptextView.frame.width-1, y: 15, width: 1.0, height:10000)
                //rightBorder.backgroundColor = UIColor.white.cgColor
                //常にdarkになる rightBorder.backgroundColor = UIColor.setDynamicColor(light: .red, dark: .black).cgColor
                
                if traitCollection.userInterfaceStyle == .dark {
                    rightBorder.backgroundColor = UIColor.black.cgColor
                }
                else{
                    rightBorder.backgroundColor = UIColor.white.cgColor
                }
                
                //NG rightBorder.backgroundColor = UIColor.label.cgColor
                
                JptextView.layer.addSublayer(rightBorder)
                
                break
            }
        }
        
    }
    
    
    @IBAction func answerButton(_ sender: Any) {
        
        //和文表示 JptextView 表示
        jptextview_update()
        
        //textView の設定、表示設定
        
        //文字列の一部をtzzzzzで置換
        var moji = Bookarray[ItemNo].SentenceArray[SentenceNo].Eng.replacingOccurrences(of: " ", with: "zzzzz", options: NSString.CompareOptions.literal, range: nil)
        moji = moji.replacingOccurrences(of: "\r\n", with: "zzzzz", options: NSString.CompareOptions.literal, range: nil)
        //区切りでデータを分割して配列に格納する。
        let array = moji.components(separatedBy: "zzzzz")
        let answerStr = textView.text! //英文
        let answerStr2 = Bookarray[ItemNo].SentenceArray[SentenceNo].Eng //英文
        
        
        textView.backgroundColor = UIColor.clear
        textView.textAlignment = .left
        
        let nsTex = answerStr as NSString
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.left
        attributedString = NSMutableAttributedString(string: nsTex as String, attributes: [ NSAttributedString.Key.paragraphStyle: style ])
        var boldFontAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)]
        
        if answerStr2.count >= 200 {
            boldFontAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28)]
        }
        
        attributedString.addAttributes(boldFontAttribute, range: NSMakeRange(0, nsTex.length))
        
        // all text colour
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.label, range: NSMakeRange(0, nsTex.length))
        
        textView.attributedText = attributedString
        
        //tap設定後のtextview表示設定
//        let deleteWordColor = [NSAttributedString.Key.foregroundColor: UIColor.red]
        let deleteWordColor = [NSAttributedString.Key.foregroundColor: UIColor.setDynamicColor(light: .red, dark: .red)]

        
        var matchRangeA = NSRange()
        var stringbitcount = 0
        
        let arrayStr3 = Bookarray[ItemNo].SentenceArray[SentenceNo].Eng.replacingOccurrences(of: "\r\n", with: "\r\n\r\n ", options: NSString.CompareOptions.literal, range: nil)
        let array3 = arrayStr3.components(separatedBy: " ")
        
        for i in 0...(array.count - 1){
            
            var stringbit = 0
            stringbit = Bookarray[ItemNo].SentenceArray[SentenceNo].correctbits[i]
            
            if (stringbit & 1) == 1 {
                matchRangeA = NSMakeRange(stringbitcount, array[i].count)  //fff
                attributedString.addAttributes(deleteWordColor, range: matchRangeA)
                textView.attributedText = attributedString
            }
            stringbitcount = stringbitcount + array3[i].count + 3    //スペース３文字分を追加
            
        }
        
        //解答ボタンを押したらカウントアップ
        answercountup()
        
        // mp3の設定
        //    setmp3()
        
        if answerbuttonflag == false{
            answerbuttonflag = true
            
            if !repeat2Buttonflag && !repeatflag {
                
                if ItemNo == 4 || ItemNo == 99 {
                    //英文読み上げ
                    Eng2speechflag = settings.bool(forKey: "Eng2speechflag_value")
                    
                    if Eng2speechflag == true {
                        let utterance = AVSpeechUtterance(string: Bookarray[ItemNo].SentenceArray[SentenceNo].Eng)
                        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                        synthesizer.speak(utterance)
                    }
                }
                else{
                    //音が再生中の場合は停止する。
                    if player.isPlaying {
                        player.stop()
                        player.currentTime = 0
                    }
                    
                    player.numberOfLoops = 0
                    player.play()
                }
            }
            //answerButton.setTitleColor(UIColor.red, for: .normal)
            //answerButton.setTitleColor(UIColorFromRGB("F21B3F"), for: .Normal)
            //answerButton.titleColor() = UIColor.init(red:0.71, green: 1.0, blue: 0.95, alpha: 1)
            answerButton.setTitleColor(UIColor.red, for: .normal)
            
            
        }
        else{
            answerbuttonflag_false()
            
            setHyperLink()
        }
    }
    

    
    func answerbuttonflag_false(){
        answerbuttonflag = false
        answerButton.setTitleColor(UIColor.init(red:0, green: 122/255, blue: 255/255, alpha: 1), for: .normal)
    }
    
    
    @IBAction func SettingButton(_ sender: Any) {
        
        /*
         if changecolor == 0 {
         changecolor = 1
         }
         else if changecolor == 1{
         changecolor = 2
         }
         else{
         changecolor = 0
         }
         */
        
        //swipemodeの変更
        //    if swipemode == 0 {
        //      swipemode = 1
        //      SentenceNo_label.textColor = UIColor.red
        //    }
        //    else if swipemode == 1 {
        //      swipemode = 2
        //      SentenceNo_label.textColor = UIColor.orange
        //    }
        //    else if swipemode == 2 {
        //      swipemode = 3
        //      SentenceNo_label.textColor = UIColor.green
        //    }
        //    else {
        //      swipemode = 0
        //      SentenceNo_label.textColor = UIColor.black
        //    }
        if swipemode == 0 {
            swipemode = 2
            SentenceNo_label.textColor = UIColor.orange
        }
        else if swipemode == 2 {
            swipemode = 6
            SentenceNo_label.textColor = UIColor.purple
        }
        else if swipemode == 6 {
            swipemode = 0
            SentenceNo_label.textColor = UIColor.label
        }
        else {
            swipemode = 0
            SentenceNo_label.textColor = UIColor.label
        }
        
        settings.set(changecolor, forKey: "changecolor_value")
        settings.set(swipemode, forKey: "swipemode_value")
        settings.synchronize()
        
    }
    
    @IBAction func resultButton(_ sender: Any) {
        
        if resultFlag == true {
            
            var resultA = ""
            var result1 = 0
            var result2 = 0
            var result3 = 0
            var result4 = 0
            var result4A = 0
            var result5 = 0
            var result6 = 0
            var result7 = 0
            var result8 = 0
            var result9 = 0
            
            var TextString = ""
            var TextString2 = ""
            
            for i in 0...MaximumSentenceNo - 1 {
                if Bookarray[ItemNo].SentenceArray[i].answercount == 0 {
                    result1 = result1 + 1
                }
                if Bookarray[ItemNo].SentenceArray[i].answerCheck >= 1 {
                    result2 = result2 + 1
                }
                if Bookarray[ItemNo].SentenceArray[i].answerCheck == 0 {
                    result3 = result3 + 1
                }
                if Bookarray[ItemNo].SentenceArray[i].answerCheck <= -1 {
                    result4 = result4 + 1
                }
                if Bookarray[ItemNo].SentenceArray[i].learning_flag == true {
                    result4A = result4A + 1
                }
            }
            
            resultA = Bookarray[ItemNo].BookTitle
            result5 = Bookarray[0].SentenceNoInit
            result6 = Bookarray[1].SentenceNoInit
            result7 = Bookarray[2].SentenceNoInit
            result8 = Bookarray[3].SentenceNoInit
            result9 = Bookarray[4].SentenceNoInit
            
            TextString = getNowClockString() + "\n"
            TextString = TextString + "今日の解答数1: " + String(Bookarray[0].TodaysAnswer)
            TextString = TextString + "   (" + String(Bookarray[0].SumAnswer) + ")   " + String(result5) + "\n"
            TextString = TextString + "今日の解答数2: " + String(Bookarray[1].TodaysAnswer)
            TextString = TextString + "   (" + String(Bookarray[1].SumAnswer) + ")   " + String(result6) + "\n"
            TextString = TextString + "今日の解答数3: " + String(Bookarray[2].TodaysAnswer)
            TextString = TextString + "   (" + String(Bookarray[2].SumAnswer) + ")   " + String(result7) + "\n"
            TextString = TextString + "今日の解答数4: " + String(Bookarray[3].TodaysAnswer)
            TextString = TextString + "   (" + String(Bookarray[3].SumAnswer) + ")   " + String(result8) + "\n"
            TextString = TextString + "今日の解答数5: " + String(Bookarray[4].TodaysAnswer)
            TextString = TextString + "   (" + String(Bookarray[4].SumAnswer) + ")   " + String(result9) + "\n\n"
            
            TextString2 = TextString2 + resultA + "\n"
            
            TextString2 = TextString2 + "Check  1: " + String(result2)
            TextString2 = TextString2 + "  0: " + String(result3)
            TextString2 = TextString2 + "  -1: " + String(result4) + "\n"
            TextString2 = TextString2 + "learning_flag: " + String(result4A) + "\n"
            
            //最も古いtrydateと数を表示
            var old_getIntervalDays = 0
            var oldest_trydate = "2000-01-01"
            var oldest_cnt = 0
            for i in 0...MaximumSentenceNo-1{
                //文字列 → 日付へ変換
                let dateFormater = DateFormatter()
                dateFormater.locale = Locale(identifier: "ja_JP")
                dateFormater.dateFormat = "yyyy-MM-dd"
                let daten = dateFormater.date(from: Bookarray[ItemNo].SentenceArray[i].trydate)
                let dateo = dateFormater.date(from: Bookarray[ItemNo].SentenceArray[0].trydate)
                let now_getIntervalDays = getIntervalDays(date: daten, anotherDay: dateo)
                //          print("date2: ", now_getIntervalDays, "   SentenceNo + i: ", SentenceNo + i)
                
                //SetenceNo 0を基準にして一番古い日付を探す
                if old_getIntervalDays > now_getIntervalDays {
                    old_getIntervalDays = now_getIntervalDays
                    oldest_cnt = 1
                    oldest_trydate = String(Bookarray[ItemNo].SentenceArray[i].trydate)
                }
                else if old_getIntervalDays == now_getIntervalDays {
                    oldest_cnt += 1
                    oldest_trydate = String(Bookarray[ItemNo].SentenceArray[i].trydate)
                }
            }
            TextString2 = TextString2 + "oldest_trydate: " + oldest_trydate + "  " + String(oldest_cnt) + "\n"
            
            //30日前の数をカウント
            var oldest_cnt2 = 0
            let now = Date()
            for i in 0...MaximumSentenceNo-1{
                //文字列 → 日付へ変換
                let dateFormater = DateFormatter()
                dateFormater.locale = Locale(identifier: "ja_JP")
                dateFormater.dateFormat = "yyyy-MM-dd"
                let daten = dateFormater.date(from: Bookarray[ItemNo].SentenceArray[i].trydate)
                let dateo = Date(timeInterval: -60*60*24*30, since: now as Date)
                //30日前の日付とtrydateと比較
                let now_getIntervalDays2 = getIntervalDays(date: daten, anotherDay: dateo)
                if now_getIntervalDays2 <= 0 {
                    oldest_cnt2 = oldest_cnt2 + 1
                }
            }
            TextString2 = TextString2 + "30日以前のtrydate数: " + String(oldest_cnt2) + "\n"
            
            //2週間前までのtrydate数をカウント
            oldest_cnt2 = 0
            for i in 0...MaximumSentenceNo-1{
                //文字列 → 日付へ変換
                let dateFormater = DateFormatter()
                dateFormater.locale = Locale(identifier: "ja_JP")
                dateFormater.dateFormat = "yyyy-MM-dd"
                let daten = dateFormater.date(from: Bookarray[ItemNo].SentenceArray[i].trydate)
                let dateo = Date(timeInterval: -60*60*24*14, since: now as Date)
                //1週間前の日付とtrydateと比較
                let now_getIntervalDays2 = getIntervalDays(date: daten, anotherDay: dateo)
                if now_getIntervalDays2 >= 0 {
                    oldest_cnt2 = oldest_cnt2 + 1
                }
            }
            TextString2 = TextString2 + "2週間前までのtrydate数: " + String(oldest_cnt2) + "\n"

            //1週間前までのtrydate数をカウント
            oldest_cnt2 = 0
            for i in 0...MaximumSentenceNo-1{
                //文字列 → 日付へ変換
                let dateFormater = DateFormatter()
                dateFormater.locale = Locale(identifier: "ja_JP")
                dateFormater.dateFormat = "yyyy-MM-dd"
                let daten = dateFormater.date(from: Bookarray[ItemNo].SentenceArray[i].trydate)
                let dateo = Date(timeInterval: -60*60*24*7, since: now as Date)
                //1週間前の日付とtrydateと比較
                let now_getIntervalDays2 = getIntervalDays(date: daten, anotherDay: dateo)
                if now_getIntervalDays2 >= 0 {
                    oldest_cnt2 = oldest_cnt2 + 1
                }
            }
            TextString2 = TextString2 + "1週間前までのtrydate数: " + String(oldest_cnt2) + "\n"
            
            //3日前までのtrydate数をカウント
            oldest_cnt2 = 0
            for i in 0...MaximumSentenceNo-1{
                //文字列 → 日付へ変換
                let dateFormater = DateFormatter()
                dateFormater.locale = Locale(identifier: "ja_JP")
                dateFormater.dateFormat = "yyyy-MM-dd"
                let daten = dateFormater.date(from: Bookarray[ItemNo].SentenceArray[i].trydate)
                let dateo = Date(timeInterval: -60*60*24*3, since: now as Date)
                //3日前の日付とtrydateと比較
                let now_getIntervalDays2 = getIntervalDays(date: daten, anotherDay: dateo)
                if now_getIntervalDays2 >= 0 {
                    oldest_cnt2 = oldest_cnt2 + 1
                }
            }
            TextString2 = TextString2 + "3日前までのtrydate数: " + String(oldest_cnt2) + "\n"
            
            //1日前までのtrydate数をカウント
            oldest_cnt2 = 0
            for i in 0...MaximumSentenceNo-1{
                //文字列 → 日付へ変換
                let dateFormater = DateFormatter()
                dateFormater.locale = Locale(identifier: "ja_JP")
                dateFormater.dateFormat = "yyyy-MM-dd"
                let daten = dateFormater.date(from: Bookarray[ItemNo].SentenceArray[i].trydate)
                let dateo = Date(timeInterval: -60*60*24*1, since: now as Date)
                //3日前の日付とtrydateと比較
                let now_getIntervalDays2 = getIntervalDays(date: daten, anotherDay: dateo)
                if now_getIntervalDays2 >= 0 {
                    oldest_cnt2 = oldest_cnt2 + 1
                }
            }
            TextString2 = TextString2 + "1日前までのtrydate数: " + String(oldest_cnt2) + "\n\n"
            
            for i in 0...MaximumSentenceNo-1 {
                if Bookarray[ItemNo].SentenceArray[i].todaytryflag {
                    
                    if i == 37 {
                        print("Bookarray[ItemNo].SentenceArray[i].todaytryflag:", Bookarray[ItemNo].SentenceArray[i].todaytryflag)
                        print("Bookarray[ItemNo].SentenceArray[i].Eng: ", Bookarray[ItemNo].SentenceArray[i].Eng)
                    }
                    
                    let array = Bookarray[ItemNo].SentenceArray[i].Eng.components(separatedBy: " ")
                    if array.count == 1 {
                        TextString2 = TextString2 + String(i+1) + " " +  String(Bookarray[ItemNo].SentenceArray[i].answerCheck) + " " + array[0] + "\n"
                    }
                    else if array.count == 2 {
                        TextString2 = TextString2 + String(i+1) + " " + String(Bookarray[ItemNo].SentenceArray[i].answerCheck) + " " + array[0] + " " + array[1] + "\n"
                    }
                    else{
                        TextString2 = TextString2 + String(i+1) + " " + String(Bookarray[ItemNo].SentenceArray[i].answerCheck) + " " + array[0] + " " + array[1] + " " + array[2] + "\n"
                    }
                }
            }
            
            TextString2 = TextString2 + "\n"
            TextString2 = TextString2 + "No.  ansCheck  ansCnt  tryCnt  learning  tryDate\n"
            
            for i in 0...Bookarray[ItemNo].SentenceArray.count-1 {
                TextString2 = TextString2 + String(i + 1) + "  "
                TextString2 = TextString2 + String(Bookarray[ItemNo].SentenceArray[i].answerCheck) + "  "
                TextString2 = TextString2 + String(Bookarray[ItemNo].SentenceArray[i].answercount) + "  "
                TextString2 = TextString2 + String(Bookarray[ItemNo].SentenceArray[i].trycount) + "  "
                TextString2 = TextString2 + String(Bookarray[ItemNo].SentenceArray[i].learning_flag) + "  "
                TextString2 = TextString2 + String(Bookarray[ItemNo].SentenceArray[i].trydate) + "\n"
            }
                        
            JptextView.font = UIFont.systemFont(ofSize: 24)
            JptextView.text = TextString
            
            textView.font = UIFont.systemFont(ofSize: 24)
            textView.text = TextString2
            
            resultFlag = false
        }
        else{
            setHyperLink()
            resultFlag = true
        }
        
        //読み上げ中であれば停止
        if synthesizer.isSpeaking == true {
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        
    }
    
    @IBAction func selectButton(_ sender: Any) {
        
        SentenceNoLearningflag = settings.bool(forKey: "SentenceNoLearningflag_value")
        Bookarray[ItemNo].SentenceNoCorrect = 0

        Bookarray[ItemNo].SentenceNoLearning = SentenceNo
        Bookarray[ItemNo].saveSentenceNoLearning(SentenceNoLearning: Bookarray[ItemNo].SentenceNoLearning)
        
        //右上のSentenceNoLearningラベルの更新
        SentenceNoLearning_update()

        if SentenceNoLearningflag == true {
            
            Bookarray[ItemNo].SentenceArray[SentenceNo].learning_flag = true
            Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsBool(
                flag: Bookarray[ItemNo].SentenceArray[SentenceNo].learning_flag,
                filename: Bookarray[ItemNo].filename,
                SentenceNo: SentenceNo,
                key: "learning_flagKey")
            
            //テスト用に残しておく 2020/05/04
            if swipemode == 6 {

                Bookarray[ItemNo].SentenceArray[SentenceNo].learning_flag = true
                                    Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsBool(
                                    flag: Bookarray[ItemNo].SentenceArray[SentenceNo].learning_flag,
                                    filename: Bookarray[ItemNo].filename,
                                    SentenceNo: SentenceNo,
                                    key: "learning_flagKey")
            }
        }
        
        
        
    }
    
    
    
    @IBAction func moveButton(_ sender: Any) {
        
        old_SentenceNo = SentenceNo
        
        SentenceNo = Bookarray[ItemNo].SentenceNoLearning
        
        answerbuttonflag_false()
        
        //mp3の設定
        setmp3()
        
        setHyperLink()
    }
    
    func speechstart(){
        
        //読み上げ中であれば停止
        if synthesizer.isSpeaking == true {
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        
        //音が再生中の場合は停止する。
        if player.isPlaying {
            player.stop()
            player.currentTime = 0
            repeatflag = false
            repeat2Buttonflag = false
            repeat2Button.setTitle("連再", for: [])
        }
        
        let utterance = AVSpeechUtterance(string: Bookarray[ItemNo].SentenceArray[SentenceNo].Eng)
        //let utterance = AVSpeechUtterance(string: "こんにちは")
        //utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
        
    }
    
    @IBAction func speechButton(_ sender: Any) {
        
        speechstart()
        
        //tapしたらカウントアップ
        answercountup()
    }
    
    //apple watchにsendMessage
    func sendapplewatchmessage(){
        
        let settings = UserDefaults.standard
        var Jp3displayflag = true
        //    Jp2displayflag = settings.bool(forKey: "Jp2displayflag_value")
        Jp3displayflag = settings.bool(forKey: "Jp3displayflag_value")
        var textstring = ""
        
        //learning_flagをカウント 今日、練習した数
//        var result1 = 0
//        for i in 0...MaximumSentenceNo - 1 {
//            if Bookarray[ItemNo].SentenceArray[i].learning_flag == true {
//                result1 = result1 + 1
//            }
//        }
        
        //todaytryflagの数をカウント
        var result1 = 0
        for i in 0...MaximumSentenceNo - 1 {
            if Bookarray[ItemNo].SentenceArray[i].todaytryflag == true {
                result1 = result1 + 1
            }
        }
        
        if Jp3displayflag {
            textstring = Bookarray[ItemNo].SentenceArray[SentenceNo].Eng + "\n" + " " + "\n" + Bookarray[ItemNo].SentenceArray[SentenceNo].Jpn + "\n" + " " + "\n" + String(format: "%03d", SentenceNo+1) + "-" + String(format: "%02d", result1)
        }
        else{
            textstring = Bookarray[ItemNo].SentenceArray[SentenceNo].Eng + "\n" + " " + "\n" + String(format: "%03d", SentenceNo+1)
        }
        
        print("apple watch textstring: ", textstring)
        
        //updateApplicationContextを使うのでiPhoneアプリからsendMessageによる送信はしない
        //sendMessage to apple watch
        //    let message = [ "Parent": textstring]
        //    wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })
        
        //updateApplicationContext
        let item: Dictionary<String, String> = [
            "message": "AppleWatchからのメッセージ"
            , "date": textstring]
        
        do {
            try wcSession.updateApplicationContext(item)
        } catch {
            print("Something went wrong")
        }
        
        //update complication
        if   wcSession.isWatchAppInstalled   {
            wcSession.transferCurrentComplicationUserInfo(item)
        }
    }
    
    //右上のSentenceNoLearningラベルの更新
    func SentenceNoLearning_update(){
        if self.SentenceNoLearningflag == true {
            
            //          Bookarray[ItemNo].SentenceNoLearning = SentenceNo
            
            //todaytryflagの数をカウント
            var result1 = 0
            for i in 0...MaximumSentenceNo - 1 {
                if Bookarray[ItemNo].SentenceArray[i].todaytryflag == true {
                    result1 = result1 + 1
                }
            }

            //SentenceNoLearning_label の3番目に最大sentenceNoを表示 ccc
            var result2 = 0
            for i in 0...MaximumSentenceNo - 1 {
                if Bookarray[ItemNo].SentenceArray[i].answerCheck >= 1 {
                    result2 = result2 + 1
                }
            }
            
            self.SentenceNoLearning_label.text = String(Bookarray[ItemNo].SentenceNoLearning + 1) + " " + String(result1) + " " + String(ItemNo + 1) + "\n" + String(result2)  + " / " + String(MaximumSentenceNo)
        }
        else{
            self.SentenceNoLearning_label.text = ""
        }
    }
    
    func answercountup(){
        if SentenceNo != old_SentenceNo {
            Bookarray[ItemNo].TodaysAnswer += 1
            Bookarray[ItemNo].saveTodaysAnswer(TodaysAnswer: Bookarray[ItemNo].TodaysAnswer)
            
            Bookarray[ItemNo].SentenceArray[SentenceNo].trycount += 1
            Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsInt(
                value: Bookarray[ItemNo].SentenceArray[SentenceNo].trycount,
                filename: Bookarray[ItemNo].filename,
                SentenceNo: SentenceNo,
                key: "trycountKey")
            
            //      print("Bookarray[ItemNo].trycounthistory[SentenceNo] : ",  Bookarray[ItemNo].trycounthistory[SentenceNo] )
            
            Bookarray[ItemNo].SentenceArray[SentenceNo].todaytryflag = true
            Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsBool(
                flag: Bookarray[ItemNo].SentenceArray[SentenceNo].todaytryflag,
                filename: Bookarray[ItemNo].filename,
                SentenceNo: SentenceNo,
                key: "todaytryflagKey")
            
            Bookarray[ItemNo].SumAnswer = Bookarray[ItemNo].SumAnswer + 1
            Bookarray[ItemNo].saveSumAnswer(SumAnswer: Bookarray[ItemNo].SumAnswer)
            
            let currentdate = getNowClockString()
            //      var textString = ""
            //      textString = currentdate
            Bookarray[ItemNo].SentenceArray[SentenceNo].trydate = currentdate
            Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsString(
                Text: Bookarray[ItemNo].SentenceArray[SentenceNo].trydate,
                filename: Bookarray[ItemNo].filename,
                SentenceNo: SentenceNo,
                key: "trydateKey")
            old_trydate = Bookarray[ItemNo].SentenceArray[SentenceNo].trydate
            
        }
        old_SentenceNo = SentenceNo
        
        DispatchQueue.main.async {
            self.AnswerNo_label.text = String(Bookarray[ItemNo].SentenceArray[SentenceNo].answercount) + "\n" + String(Bookarray[ItemNo].SentenceArray[SentenceNo].trycount)
        }
        
        var result1 = 0
        var result2 = 0
        for i in 0...MaximumSentenceNo - 1 {
            if Bookarray[ItemNo].SentenceArray[i].todaytryflag == true {
                result1 = result1 + 1
            }
            if Bookarray[ItemNo].SentenceArray[i].answerCheck >= 1 {
                result2 = result2 + 1
            }
        }
        
        SentenceNoLearning_label.text = String(Bookarray[ItemNo].SentenceNoLearning + 1) + " " + String(result1) + "\n" + String(result2)  + " / " + String(MaximumSentenceNo)
    }
    
    
    @IBOutlet weak var myLabel1: UILabel!
    
    @IBAction func TestButton(_ sender: Any) {
  
        //音量UP
        volup_func()
        
        //voldown_func()
        
        //setVolume(0.5)
        
        //volumeは使えない MPVolumeViewを使えとなる
        //testplay.volume = testplay.volume + 0.1
        //print("test volume: ", testplay.volume)
        
//        answercountup()
//
//        Bookarray[ItemNo].SentenceArray[SentenceNo].answerCheck +=  -1
//        if Bookarray[ItemNo].SentenceArray[SentenceNo].answerCheck <= -1 {
//            Bookarray[ItemNo].SentenceArray[SentenceNo].answerCheck = -1
//        }
//
//        Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsInt(
//            value: Bookarray[ItemNo].SentenceArray[SentenceNo].answerCheck,
//            filename: Bookarray[ItemNo].filename,
//            SentenceNo: SentenceNo,
//            key: "answerCheckKey")
//
//        changeCard()
//
//        if repeat2Buttonflag {
//            setcommandcenter2()
//        }
//
//        //mp3の設定
//        setmp3()
//
//        //apple watchへデータ転送
//        sendapplewatchmessage()
//
//        setHyperLink()`
        
    }
    
    
    
    // カードの移動
    func changeCard(){
        
        old_SentenceNo = SentenceNo
        
        DispatchQueue.main.async {
            self.noSlider.maximumValue = Float(MaximumSentenceNo)
        }
        if swipemode == 0 { //黒 順番に変わる
            if SentenceNo == MaximumSentenceNo-1 {
                SentenceNo = 0
                //print("SentenceNo 1: ", SentenceNo)
            }
            else{
                SentenceNo = SentenceNo + 1
                //print("SentenceNo 2: ", SentenceNo)
            }
        }
        else if swipemode == 1 { //スキップ
            for i in 1...MaximumSentenceNo - 1{
                if (SentenceNo + i) <= MaximumSentenceNo - 1 {
                    if Bookarray[ItemNo].SentenceArray[SentenceNo + i].answerCheck <= -1 {
                        SentenceNo = SentenceNo + i
                        break
                    }
                }
                else{
                    if Bookarray[ItemNo].SentenceArray[SentenceNo + i - MaximumSentenceNo].answerCheck <= -1 {
                        SentenceNo = SentenceNo + i - MaximumSentenceNo
                        break
                    }
                }
            }
        }
        else if swipemode == 2 { //オレンジ アンサーチェックが0以下
            for i in 1...MaximumSentenceNo - 1{
                if (SentenceNo + i) <= MaximumSentenceNo - 1 {
                    if Bookarray[ItemNo].SentenceArray[SentenceNo + i].answerCheck <= 0 {
                        SentenceNo = SentenceNo + i
                        break
                    }
                }
                else{
                    if Bookarray[ItemNo].SentenceArray[SentenceNo + i - MaximumSentenceNo].answerCheck <= 0 {
                        SentenceNo = SentenceNo + i - MaximumSentenceNo
                        break
                    }
                }
            }
        }
        else if swipemode == 3 { //スキップ
            first:for j in 0...1000{
                second:for i in 1...MaximumSentenceNo - 1{
                    if (SentenceNo + i) <= MaximumSentenceNo - 1 {
                        //          if Bookarray[ItemNo].answerhistory[SentenceNo + i] == j {
                        if Bookarray[ItemNo].SentenceArray[SentenceNo + i].answercount == j {
                            SentenceNo = SentenceNo + i
                            break first
                        }
                    }
                    else{
                        //           if Bookarray[ItemNo].answerhistory[SentenceNo + i - MaximumSentenceNo] == j {
                        if Bookarray[ItemNo].SentenceArray[SentenceNo + i - MaximumSentenceNo].answercount == j {
                            SentenceNo = SentenceNo + i - MaximumSentenceNo
                            break first
                        }
                    }
                }
            }
        }
        else if swipemode == 4 { //紫 一番古い日付を選ぶ
            var checkSentenceNo = SentenceNo
            var checkSentenceNo2 = SentenceNo
            var old_getIntervalDays = 0
            var flag_checkSentenceNo = false
            
            print("old_trydate: ", old_trydate)
            
            for i in 1...MaximumSentenceNo - 1{
                if (SentenceNo + i) <= MaximumSentenceNo - 1 {
                    
                    //文字列 → 日付へ変換
                    let dateFormater = DateFormatter()
                    dateFormater.locale = Locale(identifier: "ja_JP")
                    dateFormater.dateFormat = "yyyy-MM-dd"
                    let daten = dateFormater.date(from: Bookarray[ItemNo].SentenceArray[SentenceNo + i].trydate)
                    let dateo = dateFormater.date(from: old_trydate)
                    //print(date.description ?? "nilですよ")
                    //          print("date: ", date!)
                    let now_getIntervalDays = getIntervalDays(date: daten, anotherDay: dateo)
                    //          print("date2: ", now_getIntervalDays, "   SentenceNo + i: ", SentenceNo + i)
                    
                    if old_getIntervalDays > now_getIntervalDays {
                        checkSentenceNo = SentenceNo + i
                        old_getIntervalDays = now_getIntervalDays
                    }
                    else if ( now_getIntervalDays == 0 && flag_checkSentenceNo == false){
                        flag_checkSentenceNo = true
                        checkSentenceNo2 = SentenceNo + i
                    }
                    
                    //          print("checkSentenceNo: ", checkSentenceNo)
                    
                    //          if Bookarray[ItemNo].SentenceArray[SentenceNo + i].trydate == "test" {
                    //            SentenceNo = SentenceNo + i
                    //            break
                    //          }
                    
                }
                else{
                    //          if Bookarray[ItemNo].SentenceArray[SentenceNo + i - MaximumSentenceNo].trydate == "test" {
                    //            SentenceNo = SentenceNo + i - MaximumSentenceNo
                    //            break
                    //          }
                    //文字列 → 日付へ変換
                    let dateFormater = DateFormatter()
                    dateFormater.locale = Locale(identifier: "ja_JP")
                    dateFormater.dateFormat = "yyyy-MM-dd"
                    let daten = dateFormater.date(from: Bookarray[ItemNo].SentenceArray[SentenceNo + i - MaximumSentenceNo].trydate)
                    let dateo = dateFormater.date(from: old_trydate)
                    //print(date.description ?? "nilですよ")
                    //          print("date: ", date!)
                    let now_getIntervalDays = getIntervalDays(date: daten, anotherDay: dateo)
                    //          print("date3: ", now_getIntervalDays, "   SentenceNo + i: ", SentenceNo + i - MaximumSentenceNo)
                    
                    if old_getIntervalDays > now_getIntervalDays {
                        checkSentenceNo = SentenceNo + i - MaximumSentenceNo
                        old_getIntervalDays = now_getIntervalDays
                    }
                    else if ( now_getIntervalDays == 0 && flag_checkSentenceNo == false){
                        flag_checkSentenceNo = true
                        checkSentenceNo2 = SentenceNo + i - MaximumSentenceNo
                    }
                    
                    //          print("checkSentenceNo: ", checkSentenceNo)
                }
                
                if old_getIntervalDays != 0 {
                    SentenceNo = checkSentenceNo
                }
                else{
                    SentenceNo = checkSentenceNo2
                }
            } // for
        }
        else if swipemode == 6 { //紫色 learning_flagがtrueを表示
            for i in 1...MaximumSentenceNo - 1{
                if (SentenceNo + i) <= MaximumSentenceNo - 1 {
                    if Bookarray[ItemNo].SentenceArray[SentenceNo + i].learning_flag == true {
                        SentenceNo = SentenceNo + i
                        break
                    }
                }
                else{
                    if Bookarray[ItemNo].SentenceArray[SentenceNo + i - MaximumSentenceNo].learning_flag == true {
                        SentenceNo = SentenceNo + i - MaximumSentenceNo
                        break
                    }
                }
            }
        }
        else {  //swipemode  == 5 //緑 answerCheckが0以下で一番古い日付を選ぶ
            var checkSentenceNo = SentenceNo
            var checkSentenceNo2 = SentenceNo
            var old_getIntervalDays = 0
            var flag_checkSentenceNo = false
            
            print("old_trydate: ", old_trydate)
            
            for i in 1...MaximumSentenceNo - 1{
                
                if (SentenceNo + i) <= MaximumSentenceNo - 1 {
                    
                    if Bookarray[ItemNo].SentenceArray[SentenceNo + i].answerCheck <= 0 {
                        
                        //文字列 → 日付へ変換
                        let dateFormater = DateFormatter()
                        dateFormater.locale = Locale(identifier: "ja_JP")
                        dateFormater.dateFormat = "yyyy-MM-dd"
                        let daten = dateFormater.date(from: Bookarray[ItemNo].SentenceArray[SentenceNo + i].trydate)
                        let dateo = dateFormater.date(from: old_trydate)
                        //print(date.description ?? "nilですよ")
                        //          print("date: ", date!)
                        let now_getIntervalDays = getIntervalDays(date: daten, anotherDay: dateo)
                        //          print("date2: ", now_getIntervalDays, "   SentenceNo + i: ", SentenceNo + i)
                        
                        if old_getIntervalDays > now_getIntervalDays {
                            checkSentenceNo = SentenceNo + i
                            old_getIntervalDays = now_getIntervalDays
                        }
                        else if ( now_getIntervalDays == 0 && flag_checkSentenceNo == false){
                            flag_checkSentenceNo = true
                            checkSentenceNo2 = SentenceNo + i
                        }
                        
                        //          print("checkSentenceNo: ", checkSentenceNo)
                        
                        //          if Bookarray[ItemNo].SentenceArray[SentenceNo + i].trydate == "test" {
                        //            SentenceNo = SentenceNo + i
                        //            break
                        //          }
                        
                        
                    }
                    
                }
                else{
                    //          if Bookarray[ItemNo].SentenceArray[SentenceNo + i - MaximumSentenceNo].trydate == "test" {
                    //            SentenceNo = SentenceNo + i - MaximumSentenceNo
                    //            break
                    //          }
                    
                    if Bookarray[ItemNo].SentenceArray[SentenceNo + i - MaximumSentenceNo].answerCheck <= 0 {
                        
                        //文字列 → 日付へ変換
                        let dateFormater = DateFormatter()
                        dateFormater.locale = Locale(identifier: "ja_JP")
                        dateFormater.dateFormat = "yyyy-MM-dd"
                        let daten = dateFormater.date(from: Bookarray[ItemNo].SentenceArray[SentenceNo + i - MaximumSentenceNo].trydate)
                        let dateo = dateFormater.date(from: old_trydate)
                        //print(date.description ?? "nilですよ")
                        //          print("date: ", date!)
                        let now_getIntervalDays = getIntervalDays(date: daten, anotherDay: dateo)
                        //          print("date3: ", now_getIntervalDays, "   SentenceNo + i: ", SentenceNo + i - MaximumSentenceNo)
                        
                        if old_getIntervalDays > now_getIntervalDays {
                            checkSentenceNo = SentenceNo + i - MaximumSentenceNo
                            old_getIntervalDays = now_getIntervalDays
                        }
                        else if ( now_getIntervalDays == 0 && flag_checkSentenceNo == false){
                            flag_checkSentenceNo = true
                            checkSentenceNo2 = SentenceNo + i - MaximumSentenceNo
                        }
                        
                        //          print("checkSentenceNo: ", checkSentenceNo)
                    }
                }
                
                if old_getIntervalDays != 0 {
                    SentenceNo = checkSentenceNo
                }
                else{
                    SentenceNo = checkSentenceNo2
                }
                
                
                
                
            } // for
        }
        
        //解答の非表示
        answerbuttonflag_false()
        
    }
    
    // mp3の設定
    func setmp3(){
        
        //読み上げ中であれば停止
        if synthesizer.isSpeaking == true {
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        
        //mp3の設定
        // 再生する音声ファイルを指定する
        var musicNo = ""
        var musicNoA = ""
        
        if ItemNo == 0 {
            musicNo = "DUO3.0_" + String(format: "%03d", SentenceNo+1)
            musicNoA = "material/mp3/DUO3.0/" + musicNo + ".mp3"
        }
        else if ItemNo == 1 {
            musicNo = "TOEIC-Key_" + String(format: "%03d", SentenceNo+1)
            musicNoA = "material/mp3/TOEIC-Key/" + musicNo + ".mp3"
        }
        else if ItemNo == 2{
            musicNo = "dragon" + String(format: "%03d", SentenceNo+1)
            musicNoA = "material/mp3/DragonEnglish/" + musicNo + ".mp3"
        }
        else if ItemNo == 3 {
            musicNo = "Textbook4_" + String(format: "%03d", SentenceNo+1)
            musicNoA = "material/mp3/Textbook4/" + musicNo + ".mp3"
        }
        else{
            musicNo = "silence"
            musicNoA = "material/mp3/" + musicNo + ".mp3"
        }
        
        //tanaka20191116
        if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            
            let targetTextFilePath = documentDirectoryFileURL.appendingPathComponent(musicNoA)
            print("targetTextFilePath: ", targetTextFilePath)
            
            let urlString: String = targetTextFilePath.path
            if FileManager.default.fileExists(atPath: urlString) {
                print("setup ファイルあり ", urlString)
                let soundURL = targetTextFilePath
                
                //Xcodeに登録したファイルのURL設定
                //let soundURL = Bundle.main.url(forResource: musicNo, withExtension: "mp3")
                print("soundURL: ", soundURL)
                
                do {
                    player = try AVAudioPlayer(contentsOf: soundURL)
                    
                } catch {
                    print("error...")
                }
            }
            else{
                print("ファイルなし")
                
                musicNo = "silence"
                musicNoA = "material/mp3/" + musicNo + ".mp3"
                
                let soundURL2 = documentDirectoryFileURL.appendingPathComponent(musicNoA)
                
                //Xcodeに登録したファイルのURL設定
                //let soundURL = Bundle.main.url(forResource: musicNo, withExtension: "mp3")
                print("soundURL2: ", soundURL2)
                
                do {
                    player = try AVAudioPlayer(contentsOf: soundURL2)
                    
                } catch {
                    print("error...")
                }
            }
        }
        
        repeatflag = false
        
        if repeat2Buttonflag {
            
            if ItemNo == 10 {
                speechstart()
            }
            else{
                player.numberOfLoops = -1
                player.play()
            }
            repeat2Button.setTitle("停止", for: [])
        }
        
    }
    
    // Hyper Link
    func setHyperLink(){
        
        //trydateの表示
        myLabel1.text = Bookarray[ItemNo].SentenceArray[SentenceNo].trydate
        
        
        //スライダーの表示
        noSlider.value = Float(SentenceNo + 1)
        
        //debug aaa2
        //if ItemNo == 3 {
        //  SentenceNo = 0
        //}
        
        if SentenceNo >= MaximumSentenceNo {
            SentenceNo = 1
        }
        
        let answerStr = Bookarray[ItemNo].SentenceArray[SentenceNo].Eng //英文
        
        if (MaximumSentenceNo - 1) <= SentenceNo {
            SentenceNo = MaximumSentenceNo - 1
        }
        
        //和文、英文の設定
        Bookarray[ItemNo].SentenceNo = SentenceNo
        
        //Today Extensionで表示
        var textString = ""
        //    textString = answerStr
        textString = answerStr + "\n" + Bookarray[ItemNo].SentenceArray[SentenceNo].Jpn
        let sharedDefaults: UserDefaults = UserDefaults(suiteName: suiteName)!
        sharedDefaults.set(textString, forKey: keyName)
        sharedDefaults.synchronize()
        
        //    print("share textString:", textString)
        
        let array = answerStr.components(separatedBy: " ")
        
        //ユーザー設定の保存
        settings.set(ItemNo, forKey: "ItemNo_value")
        Bookarray[ItemNo].saveSentenceNo(SentenceNo: Bookarray[ItemNo].SentenceNo)
        //    Bookarray[ItemNo].saveSentenceNoLearning(SentenceNoLearning: Bookarray[ItemNo].SentenceNoLearning)
        settings.synchronize()
        
        //SentenceNoLearning_labelの表示
        SentenceNoLearningflag = settings.bool(forKey: "SentenceNoLearningflag_value")
        //print("SentenceNoLearningflag: ", SentenceNoLearningflag)
        
        //正解した時、いまは使っていないので見直し必要
        //Bookarray[ItemNo].SentenceNoCorrect = Bookarray[ItemNo].SentenceNoCorrect + 1
        
        //右上のSentenceNoLearningラベルの更新
        SentenceNoLearning_update()
        
        //JptextView 表示
        jptextview_update()
        
        //英文読み上げ
        Engspeechflag = settings.bool(forKey: "Engspeechflag_value")
        Eng2speechflag = settings.bool(forKey: "Eng2speechflag_value")
        
        if Engspeechflag == true {
            let utterance = AVSpeechUtterance(string: answerStr)
            //let utterance = AVSpeechUtterance(string: "こんにちは")
            //utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            synthesizer.speak(utterance)
        }
        
        if Engspeechflag || Eng2speechflag {
            back2Button.backgroundColor = UIColor.brown
        }
        else{
            back2Button.backgroundColor = UIColor.white
        }
        
        //SentenceNo_label 英文番号の表示
        SentenceNo_label.text = String(SentenceNo+1)
        
        //AnswerNo_label 過去の正解数の表示
        if Bookarray[ItemNo].SentenceArray[SentenceNo].answerCheck == 0 {
            AnswerNo_label.textColor = UIColor.label
        }
        else if Bookarray[ItemNo].SentenceArray[SentenceNo].answerCheck == 1 {
            AnswerNo_label.textColor = UIColor.blue
        }
        else if Bookarray[ItemNo].SentenceArray[SentenceNo].answerCheck >= 2 {
            AnswerNo_label.textColor = UIColor.purple
        }
        else {
            AnswerNo_label.textColor = UIColor.red
        }
        
        AnswerNo_label.text = String(Bookarray[ItemNo].SentenceArray[SentenceNo].answercount) + "\n" + String(Bookarray[ItemNo].SentenceArray[SentenceNo].trycount)
        
        //    print("AnswerNo_label.text: ", AnswerNo_label.text!)
        
        Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsArrayInt(
            arrayvalue: Bookarray[ItemNo].SentenceArray[SentenceNo].correctbits,
            filename: Bookarray[ItemNo].filename,
            SentenceNo: SentenceNo,
            key: "correctbitsKey")
        
        //正解数の保存
        var currentdate = ""
        currentdate = getNowClockString()
        TodaysAnswerDate = settings.string(forKey: "TodaysAnswerDate_value")!
        //TodaysAnswerDate = "2017-06-25"
        
        //    print("currentdate:", currentdate)
        //    print("TodaysAnswerDate:", TodaysAnswerDate)
        
        if currentdate != TodaysAnswerDate {
            
            //正解数の結果をテキストファイルの保存
            var textString = "date,1,2,3,4,1,2,3,4\n"
            textString = TodaysAnswerDate + "," + String(Bookarray[0].TodaysAnswer) + "," + String(Bookarray[1].TodaysAnswer) + "," + String(Bookarray[2].TodaysAnswer) + "," + String(Bookarray[3].TodaysAnswer) + "," + String(Bookarray[0].SumAnswer) + "," + String(Bookarray[1].SumAnswer) + "," + String(Bookarray[2].SumAnswer) + "," + String(Bookarray[3].SumAnswer)
            
            makeTextFile(textFileName: "result.txt", textString: textString)
            
            textString = getNowClockString() + "\n"
            for i in 0...2 {
                
                if i == 0 {
                    textString = textString + "DUO3.0\n"
                }
                else if i == 1 {
                    textString = textString + "TOIEC\n"
                }
                else if i == 2 {
                    textString = textString + "Dragon English\n"
                }
                textString = textString + String(Bookarray[i].SentenceNoInit) + "\n"
                
                for j in 0...Bookarray[i].SentenceArray.count-1 {
                    textString = textString + String(j + 1) + ","
                    textString = textString + String(Bookarray[i].SentenceArray[j].answercount) + ","
                    textString = textString + String(Bookarray[i].SentenceArray[j].answerCheck) + "\n"
                }
            }
            //      print("textString: ", textString)
            
            makeTextFile(textFileName: "resultB.txt", textString: textString)
            
            for i in 0...4 {
                Bookarray[i].TodaysAnswer = 0
                Bookarray[i].saveTodaysAnswer(TodaysAnswer: Bookarray[i].TodaysAnswer)
            }
            
            for i in 0...4 {
                for j in 0...Bookarray[i].SentenceArray.count-1 {
                    Bookarray[i].SentenceArray[j].todaytryflag = false
                    Bookarray[i].SentenceArray[j].saveUserDefaultsBool(
                        flag: Bookarray[i].SentenceArray[j].todaytryflag,
                        filename: Bookarray[i].filename,
                        SentenceNo: j,
                        key: "todaytryflagKey")
                }
            }
            
            TodaysAnswerDate = currentdate
            settings.set(TodaysAnswerDate, forKey: "TodaysAnswerDate_value")
            
        }
        
        
        
        
        //textView の設定、表示設定
        var arrayStr2 = ""
        //英単語の間にスペース挿入
        for i in 0...array.count-1 {
            arrayStr2 = arrayStr2 + array[i] + "   "
        }
        //TextBook4の改行をスペース付き改行に置換
        arrayStr2 = arrayStr2.replacingOccurrences(of: "\r\n", with: "   \r\n", options: NSString.CompareOptions.literal, range: nil)
        
        textView.backgroundColor = UIColor.clear
        textView.textAlignment = .left
        
        let nsTex = arrayStr2 as NSString
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.left
        attributedString = NSMutableAttributedString(string: nsTex as String, attributes: [ NSAttributedString.Key.paragraphStyle: style ])
        
        var boldFontAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)]
        if answerStr.count >= 200 {
            boldFontAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28)]
        }
        attributedString.addAttributes(boldFontAttribute, range: NSMakeRange(0, nsTex.length))
        
        // all text colour
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.label, range: NSMakeRange(0, nsTex.length))
        
        textView.attributedText = attributedString
        
        let size = textView.sizeThatFits(textView.frame.size)
        if size.height > 386 {
            //右線のCALayerを作成
            let rightBorder = CALayer()
            rightBorder.frame = CGRect(x: textView.frame.width-1, y: 15, width: 1.0, height:size.height-30)
            rightBorder.backgroundColor = UIColor.lightGray.cgColor
//            if traitCollection.userInterfaceStyle == .dark {
//                rightBorder.backgroundColor = UIColor.lightGray.cgColor
//            }
//            else{
//                rightBorder.backgroundColor = UIColor.lightGray.cgColor
//            }
            textView.layer.addSublayer(rightBorder)
        }
        else{
            let rightBorder = CALayer()
            rightBorder.frame = CGRect(x: textView.frame.width-1, y: 15, width: 1.0, height:10000)
            //rightBorder.backgroundColor = UIColor.white.cgColor
            if traitCollection.userInterfaceStyle == .dark {
                rightBorder.backgroundColor = UIColor.black.cgColor
            }
            else{
                rightBorder.backgroundColor = UIColor.white.cgColor
            }
            textView.layer.addSublayer(rightBorder)
        }
        
        #if DEBUG
        //print("DEBUG true")
        #else
        //print("DEBUG false")
        #endif
        
        //tap設定後のtextview表示設定
        //let deleteWordColor = [NSAttributedString.Key.foregroundColor: UIColor.white]
        //    let normalWordColor = [NSAttributedStringKey.foregroundColor: UIColor.black]
        let deleteWordColor = [NSAttributedString.Key.foregroundColor: UIColor.setDynamicColor(light: .white, dark: .black)]
        
        var matchRangeA = NSRange()
        var stringbitcount = 0
        
        let arrayStr3 = answerStr.replacingOccurrences(of: "\r\n", with: "\r\n\r\n ", options: NSString.CompareOptions.literal, range: nil)
        let array3 = arrayStr3.components(separatedBy: " ")
        //    print("array3: ", array3)
        
        for i in 0...(array3.count - 1){
            
            var stringbit = 0
            stringbit = Bookarray[ItemNo].SentenceArray[SentenceNo].correctbits[i]
            
            if (stringbit & 1) == 1 {
                matchRangeA = NSMakeRange(stringbitcount, array3[i].count)  //fff
                attributedString.addAttributes(deleteWordColor, range: matchRangeA)
                textView.attributedText = attributedString
            }
            stringbitcount = stringbitcount + array3[i].count + 3    //スペース３文字分を追加
            
        }
        
        //ステータスバー（時計表示の文字の色）
        //    UIApplication.shared.statusBarStyle = .darkContent
        
    }
    
    
    @objc func tapLabel(tap: UITapGestureRecognizer) {
        if swipemode == 0 {
            swipemode = 2
            SentenceNo_label.textColor = UIColor.orange
        }
        else if swipemode == 2 {
            swipemode = 6
            SentenceNo_label.textColor = UIColor.purple
        }
        else if swipemode == 6 {
            swipemode = 0
            SentenceNo_label.textColor = UIColor.label
        }
        else {
            swipemode = 0
            SentenceNo_label.textColor = UIColor.label
        }
        
        print("tapLabel")
        
        settings.set(changecolor, forKey: "changecolor_value")
        settings.set(swipemode, forKey: "swipemode_value")
        settings.synchronize()
    }
    
    //TextView tap時の動作
    @objc func tapText(tap: UITapGestureRecognizer) {
        
        let location = tap.location(in: textView)
        let textPosition = textView.closestPosition(to: location)
        let selectedPosition = textView.offset(from: textView.beginningOfDocument, to: textPosition!)
        
        let answerStr = textView.text! //英文
        //      print("answerStr: " ,answerStr)
        
        //文字列の一部をtzzzzzで置換
        var moji = Bookarray[ItemNo].SentenceArray[SentenceNo].Eng.replacingOccurrences(of: " ", with: "zzzzz", options: NSString.CompareOptions.literal, range: nil)
        moji = moji.replacingOccurrences(of: "\r\n", with: "zzzzz", options: NSString.CompareOptions.literal, range: nil)
        //        print(moji)
        
        //区切りでデータを分割して配列に格納する。
        let array = moji.components(separatedBy: "zzzzz")
        //      print("array: ",array)
        
        let arrayStr3 = Bookarray[ItemNo].SentenceArray[SentenceNo].Eng.replacingOccurrences(of: "\r\n", with: "\r\n\r\n ", options: NSString.CompareOptions.literal, range: nil)
        let array3 = arrayStr3.components(separatedBy: " ")
        
        
        
        var stringbitcount = 0
        
        
        
        for i in 0...(array.count - 1){
            
            var matchRangeA = NSRange()
            var matchpattern = ""
            var arrayStr = array[i]
            //print("arrayStr: ",arrayStr)
            var currentIndex = arrayStr.endIndex
            currentIndex = arrayStr.index(before:currentIndex)
            
            if arrayStr.prefix(1) == "$" {
                let arrayStr1 = arrayStr[arrayStr.index(arrayStr.startIndex, offsetBy: 1)..<arrayStr.endIndex]
                matchpattern = "\\$" + arrayStr1 + "   "
            }
            else if arrayStr.prefix(1) == "\"" {
                let arrayStr1 = arrayStr[arrayStr.index(arrayStr.startIndex, offsetBy: 1)..<arrayStr.endIndex]
                matchpattern = "\\" + arrayStr.prefix(1) + arrayStr1 + "   "
            }
            else if arrayStr.prefix(1) == "(" {
                let arrayStr1 = arrayStr[arrayStr.index(arrayStr.startIndex, offsetBy: 1)..<arrayStr.endIndex]
                matchpattern = "\\(" + arrayStr1 + "   "
                
                if arrayStr.suffix(2) == ")." {
                    var startIndexA = arrayStr.index(arrayStr.startIndex, offsetBy: arrayStr.count-1)
                    arrayStr.remove(at: startIndexA)
                    startIndexA = arrayStr.index(arrayStr.startIndex, offsetBy: arrayStr.count-1)
                    arrayStr.remove(at: startIndexA)
                    matchpattern = "\\" + arrayStr + "\\)." + "   "
                    print("matchpattern2: ", matchpattern)
                }
            }
            else if arrayStr[currentIndex] == ")" {
                let startIndexA = arrayStr.index(arrayStr.startIndex, offsetBy: arrayStr.count-1)
                arrayStr.remove(at: startIndexA)
                matchpattern = "\\b" + arrayStr + "\\)" + "   "
            }
            else if arrayStr.suffix(1) == "?" {
                let startIndexA = arrayStr.index(arrayStr.startIndex, offsetBy: arrayStr.count-1)
                arrayStr.remove(at: startIndexA)
                matchpattern = "\\b" + arrayStr + "\\?" + "   "
            }
            else if arrayStr.suffix(2) == "?\"" {
                var startIndexA = arrayStr.index(arrayStr.startIndex, offsetBy: arrayStr.count-1)
                arrayStr.remove(at: startIndexA)
                startIndexA = arrayStr.index(arrayStr.startIndex, offsetBy: arrayStr.count-1)
                arrayStr.remove(at: startIndexA)
                matchpattern = "\\b" + arrayStr + "\\?" + "\"" + "   "
                print("matchpattern2: ", matchpattern)
            }
            else if arrayStr.suffix(2) == ")." {
                var startIndexA = arrayStr.index(arrayStr.startIndex, offsetBy: arrayStr.count-1)
                arrayStr.remove(at: startIndexA)
                startIndexA = arrayStr.index(arrayStr.startIndex, offsetBy: arrayStr.count-1)
                arrayStr.remove(at: startIndexA)
                matchpattern = "\\b" + arrayStr + "\\)." + "   "
                print("matchpattern3: ", matchpattern)
            }
            else{
                matchpattern = "\\b" + array[i] + "   "
            }
            
            print("matchpattern: ", matchpattern)
            
            do {
                
                let regex = try NSRegularExpression(pattern: matchpattern, options: [])
                let targetStringRange = NSRange(location: 0, length: (answerStr as NSString).length)
                
                let matches = regex.matches(in: answerStr as String, options: [], range: targetStringRange)
                
                for match in matches {
                    // rangeAtIndexに0を渡すとマッチ全体が、1以降を渡すと括弧でグループにした部分マッチが返される
                    let range = match.range(at: 0)
                    
                    if range.location == stringbitcount {
                        matchRangeA = range
                    }
                    //            print("array[", i, "]: ", array[i], "range.location: ", range.location, "range.length: ", range.length, "stringbitcount: ", stringbitcount)//ggg
                }
                
            } catch {
                //print("error: getMatchStrings")
            }
            
            stringbitcount = stringbitcount + array3[i].count + 3
            
            
            if NSLocationInRange(selectedPosition, matchRangeA) {
                
                if answerbuttonflag == false{
                    
                    if (Bookarray[ItemNo].SentenceArray[SentenceNo].correctbits[i] == 1){
                        Bookarray[ItemNo].SentenceArray[SentenceNo].correctbits[i] = 0
                    }
                    else{
                        Bookarray[ItemNo].SentenceArray[SentenceNo].correctbits[i] = 1 //bit反転
                    }
                    //                print("match: ", array[i], "i: ", i, "mask: ", String(format: "%x", mask), "correctbitshistory2: ", Bookarray[ItemNo].correctbitshistory2[SentenceNo] )
                    //              }
                    
                    setHyperLink()
                    break
                }
                else {  //解答表示中は、タップして辞書を起動
                    if NSLocationInRange(selectedPosition, matchRangeA) {
                        
                        // Add your action. For Example, navigating to another page
                        print("match: ", array[i])
                        
                        var arrayStr = array[i]
                        if arrayStr.prefix(1) == "\"" {
                            arrayStr = String(arrayStr[arrayStr.index(arrayStr.startIndex, offsetBy: 1)..<arrayStr.endIndex])
                        }
                        
                        if arrayStr.suffix(1) == "\"" {
                            let startIndexB = arrayStr.index(arrayStr.startIndex, offsetBy: arrayStr.count-1)
                            arrayStr.remove(at: startIndexB)
                        }
                        
                        if arrayStr.suffix(1) == "." {
                            let startIndexC = arrayStr.index(arrayStr.startIndex, offsetBy: arrayStr.count-1)
                            arrayStr.remove(at: startIndexC)
                        }
                        
                        if arrayStr.suffix(1) == "?" {
                            let startIndexC = arrayStr.index(arrayStr.startIndex, offsetBy: arrayStr.count-1)
                            arrayStr.remove(at: startIndexC)
                        }
                        
                        if arrayStr.suffix(1) == "!" {
                            let startIndexC = arrayStr.index(arrayStr.startIndex, offsetBy: arrayStr.count-1)
                            arrayStr.remove(at: startIndexC)
                        }
                        
                        print("arrayStr: ", arrayStr)
                        
                        //let dicWord = "mkccad:///search?text=" + arrayStr
                        let dicWord = "mkdictionaries://?text=" + arrayStr
                        let url = NSURL(string: dicWord)
                        print("dicWord: ", dicWord)
                        print("url: ", url as Any)
                        UIApplication.shared.open(url! as URL)
                        //if UIApplication.shared.canOpenURL(url! as URL){
                        //  print("url: ", url)
                        //  UIApplication.shared.open(url! as URL)
                        //}
                    }
                }
            }
        }
    }
    
    
    
    
    
    @IBAction func audioButton(_ sender: Any) {
        
        //読み上げ中であれば停止
        if synthesizer.isSpeaking == true {
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        
        //設定画面へ遷移
        self.performSegue(withIdentifier: "goAudio", sender: nil)
        
    }
    
    
    @IBAction func musicplayButton(_ sender: Any) {
        
        repeat2Buttonflag = false
        repeat2Button.setTitle("連再", for: [])
        
        //mp3の設定
        setmp3()
        
        player.numberOfLoops = 0
        player.play()
        
        //tapしたらカウントアップ
        answercountup()
    }
    
    
    func volup_func(){
        //アプリの音量調整
        //play.volume = play.volume + 0.1
        //print("volume: ", play.volume)
        
        let lst = volumeControl.subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}
        let slider = lst.first as? UISlider
        
//        let thumbImage = circleImage(width: 5, height: 5) // 白い16x16の丸
//        slider.setThumbImage(thumbImage, for: .normal)
        slider!.setThumbImage(UIImage(), for: .normal)
        
        print("slider.value: ", slider?.value as Any)
        var volume = slider!.value
        volume = volume + 0.1
        
        slider?.setValue(volume, animated: false)
    }
    
    func voldown_func(){
        //アプリの音量調整
        //play.volume = play.volume - 0.1
        //print("volume: ", play.volume)
        
        let lst = volumeControl.subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}
        let slider = lst.first as? UISlider
        
//        let thumbImage = UIColor.white.circleImage(width: 5, height: 5) // 白い16x16の丸
//        slider.setThumbImage(thumbImage, for: .normal)
                slider!.setThumbImage(UIImage(), for: .normal)
        
        print("slider.value: ", slider?.value as Any)
        var volume = slider!.value
        volume = volume - 0.1
        
        slider?.setValue(volume, animated: false)
    }
    
    func playback(){
        
        //読み上げ中であれば停止
        if synthesizer.isSpeaking == true {
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        
        //    print("isPlaying: ", play.isPlaying)
        //    print("repeat2Buttonflag: ", repeat2Buttonflag)
        
        var textstring = ""
        
        if repeat2Buttonflag {
            //音が再生中の場合は停止する。
            player.stop()
            player.currentTime = 0
            
            repeatflag = false
            repeat2Buttonflag = false
            repeat2Button.setTitle("連再", for: [])
            textstring = "Playback"
        }
        else{
            
            if ItemNo == 10 { //ItemNo == 10 はないので必ずFalse
                speechstart()
            }
            else{
                //print("not isPlaying")
                player.numberOfLoops = -1
                //      play.stop()
                //      play.currentTime = 0
                //        play.play(atTime: (play.deviceCurrentTime)! + 3)
                player.play()
                
            }
            
            repeatflag = true
            repeat2Buttonflag = true
            repeat2Button.setTitle("停止", for: [])
            textstring = "Stop"
            
        }
        
        //連再ステータスをapple watchに伝える
        let item2: Dictionary<String, String> = [
            "message5": "AppleWatchからのメッセージ"
            , "status": textstring]
        
        do {
            try wcSession.updateApplicationContext(item2)
        } catch {
            print("log00100 Something went wrong")
        }
        
    }
    
    //コントロールセンターの設定
    func setcommandcenter(){
        
        let commandCenter = MPRemoteCommandCenter.shared();
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget {event in
            print("playCommand")
            self.repeat2Buttonflag = true
            self.player.play()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget {event in
            print("pauseCommand")
            self.player.pause()
            return .success
        }
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget {event in
            //      self.play.pause()
            print("nextTrackCommand")
            
            //左スワイプと同じ
            if self.repeat2Buttonflag {
                //スワイプしたらカウントアップ
                self.answercountup()
            }
            self.changeCard()
            self.setmp3()
            self.sendapplewatchmessage()
            self.setHyperLink()
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyTitle: SentenceNo+1,
                MPMediaItemPropertyArtist : Bookarray[ItemNo].SentenceArray[SentenceNo].Eng,
            ]
            
            return .success
        }
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget {event in
            print("previousTrackCommand")
            
            print("log0010 SentenceNo+1: ", SentenceNo+1)
            //右スワイプと同じ
            if self.repeat2Buttonflag {
                //スワイプしたらカウントアップ
                self.answercountup()
            }
            
            print("log0011 SentenceNo+1: ", SentenceNo+1)
            
            if SentenceNo == 0 {
                SentenceNo = MaximumSentenceNo-1
            }
            else{
                SentenceNo = SentenceNo - 1
            }
            
            print("log0012 SentenceNo+1: ", SentenceNo+1)
            
            self.answerbuttonflag = false   //changeCard()には含まれる
            
            self.setmp3()
            print("log0013 SentenceNo+1: ", SentenceNo+1)
            self.sendapplewatchmessage()
            print("log0014 SentenceNo+1: ", SentenceNo+1)
            self.setHyperLink()
            print("log0015 SentenceNo+1: ", SentenceNo+1)
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyTitle: SentenceNo+1,
                MPMediaItemPropertyArtist : Bookarray[ItemNo].SentenceArray[SentenceNo].Eng,
            ]
            
            return .success
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: SentenceNo+1,
            MPMediaItemPropertyArtist : Bookarray[ItemNo].SentenceArray[SentenceNo].Eng,
        ]
        
    }
    
    //コントロールセンターのタイトルのみ更新
    func setcommandcenter2(){
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: SentenceNo+1,
            MPMediaItemPropertyArtist : Bookarray[ItemNo].SentenceArray[SentenceNo].Eng,
        ]
        
    }
    
    
    @IBAction func repeat2Button(_ sender: Any) {
        
        //audio バックグラウンド再生設定
        do {
            // バックグラウンド再生有効(サイレントモードでも音が鳴る)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            print("バックグラウンド再生有効")
            // バックグラウンド再生無効(サイレントモードで音鳴らない)
            //      try AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default)
            //      print("バックグラウンド再生無効")
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        playback()
        answercountup()
    }
    
}



//現在時刻の取得
func getNowClockString() -> String {
    let formatter = DateFormatter()
    //formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
    formatter.dateFormat = "yyyy-MM-dd"
    let now = Date()
    return formatter.string(from: now)
}

func getNowClockString2() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
    //formatter.dateFormat = "yyyy-MM-dd"
    let now = Date()
    return formatter.string(from: now)
}

/**
 　　　　２つの日付の差(n日)を取得
 
 - parameter date: 日付
 - parameter anotherDay: 日付（オプション）。未指定時は当日が適用される
 - returns: 算出後の日付
 */
func getIntervalDays(date:Date?,anotherDay:Date? = nil) -> Int {
    
    var retInterval:Double!
    
    if anotherDay == nil {
        retInterval = date?.timeIntervalSinceNow
    } else {
        retInterval = date?.timeIntervalSince(anotherDay!)
    }
    
    let ret = retInterval/86400
    
    return Int(ret)  // n日
}

//result.txtファイル作成
func makeTextFile(textFileName: String, textString: String){
    //let textFileName = "result.txt"
    //let textString1 = getNowClockString()
    let textString1 = ""
    //var textString = ""
    
    if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
        
        let targetTextFilePath = documentDirectoryFileURL.appendingPathComponent(textFileName)
        
        print("targetTextFilePath: ", targetTextFilePath)
        
        let urlString: String = targetTextFilePath.path
        if FileManager.default.fileExists(atPath: urlString) {
            print("makeTextFile ファイルあり")
        }
        else{
            print("makeTextFile ファイルなし")
            
            //初回のファイル作成
            do {
                try textString1.write(to: targetTextFilePath, atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("failed to write: \(error)")
            }
        }
        
        //textString = TodaysAnswerDate
        //aaa 要検討 classを呼び出すとエラー
        //    textString = TodaysAnswerDate + "," + String(Bookarray[0].TodaysAnswer) + "," + String(Bookarray[1].TodaysAnswer) + "," + String(Bookarray[2].TodaysAnswer) + "," + String(Bookarray[0].SumAnswer) + "," + String(Bookarray[1].SumAnswer) + "," + String(Bookarray[2].SumAnswer)
        
        appendText(fileURL: targetTextFilePath, string: textString)
        
        readTextFile(fileURL: targetTextFilePath)
        
        //deleteTextFile(filePATH: urlString)
        
    }
}

func deleteTextFile(textFileName: String){
    
    if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
        
        let targetTextFilePath = documentDirectoryFileURL.appendingPathComponent(textFileName)
        
        print("targetTextFilePath: ", targetTextFilePath)
        
        let urlString: String = targetTextFilePath.path
        if FileManager.default.fileExists(atPath: urlString) {
            print("ファイルあり、削除する")
            deleteTextFile(filePATH: urlString)
        }
        else{
            print("ファイルなし")
        }
    }
}

// テキストを追記するメソッド
func appendText(fileURL: URL, string: String) {
    
    do {
        let fileHandle = try FileHandle(forWritingTo: fileURL)
        
        // 改行を入れる
        let stringToWrite = "\n" + string
        
        // ファイルの最後に追記
        fileHandle.seekToEndOfFile()
        fileHandle.write(stringToWrite.data(using: String.Encoding.utf8)!)
        
    } catch let error as NSError {
        print("failed to append: \(error)")
    }
}

// テキストを読み込むメソッド
func readTextFile(fileURL: URL) {
    //  do {
    //    let text = try String(contentsOf: fileURL, encoding: String.Encoding.utf8)
    //    print(text)
    //  } catch let error as NSError {
    //    print("failed to read: \(error)")
    //  }
}

func deleteTextFile(filePATH: String){
    // 削除処理
    do {
        try FileManager.default.removeItem(atPath: filePATH)
    } catch let error as NSError {
        print("failed to delete: \(error)")
    }
}

class TextBook {
    
    //インナークラス
    class SentenceClass {
        var Jpn = ""
        var Eng = ""
        
        var answerCheck = 0         //覚えたら1、忘れていたら-1、初期値0
        var todaytryflag = false    //今日、問題に取り組んだかのチェック
        var answercount = 0         //正解数
        var trycount = 0            //問題に取り組んだ回数
        var learning_flag = false   //覚えたかどうかのフラグ
        var correctbits: Array<Int> = [] //消去単語の位置  ToDO IntではなくBool?
        var trydate = ""
        
        init(Jpn:String, Eng:String, filename:String, SentenceNo:Int){
            self.Jpn = Jpn
            self.Eng = Eng
            
            //時間がかかり過ぎる 見直し必要
            let todaytryflagKey = "todaytryflagKey" + "_" + String(SentenceNo) + "_" + filename
            //      UserDefaults.standard.register(defaults: [todaytryflagKey : false]) //これを入れると時間がかかる registerがない場合、初期値は0またはfalse
            todaytryflag = UserDefaults.standard.bool(forKey: todaytryflagKey)
            
            let answercountKey = "answercountKey" + "_" + String(SentenceNo) + "_" + filename
            answercount = UserDefaults.standard.integer(forKey: answercountKey)
            
            let trycountKey = "trycountKey" + "_" + String(SentenceNo) + "_" + filename
            trycount = UserDefaults.standard.integer(forKey: trycountKey)
            
            let answerCheckKey = "answerCheckKey" + "_" + String(SentenceNo) + "_" + filename
            answerCheck = UserDefaults.standard.integer(forKey: answerCheckKey)
            
            let learning_flagKey = "learning_flagKey" + "_" + String(SentenceNo) + "_" + filename
            learning_flag = UserDefaults.standard.bool(forKey: learning_flagKey)
            //print("load SentenceNo: ", SentenceNo, "   learning_flag: ", learning_flag)
            
            let correctbitsKey = "correctbitsKey" + "_" + String(SentenceNo) + "_" + filename
            if let defArr1 = UserDefaults.standard.array(forKey: correctbitsKey) as? [Int] {
                
                //        if SentenceNo == 19 {
                //          print("defArr1.count: ", defArr1.count)
                //          print("Eng: ", Eng)
                //        }
                //defArr1.remove(at: 11)
                //settings.set(answerCheck, forKey: answerCheckKey)
                
                
                //要確認
                let answerStr1 = Eng
                let answerStr2 = answerStr1.replacingOccurrences(of: "\r\n", with: " ", options: NSString.CompareOptions.literal, range: nil)
                let array = answerStr2.components(separatedBy: " ")
                
                //        if SentenceNo == 19 {
                //          print("array.count: ", array.count)
                //        }
                
                if defArr1.count == array.count{
                    correctbits = defArr1
                }
                else if defArr1.count > array.count {
                    correctbits = defArr1
                }
                else{
                    correctbits = defArr1
                    for _ in 0...array.count - defArr1.count - 1 {
                        correctbits.append(0)
                    }
                }
            } else {
                
                let answerStr = Eng
                let array = answerStr.components(separatedBy: " ")
                
                for _ in 0...array.count-1 {
                    correctbits.append(0)
                }
                
                UserDefaults.standard.set(correctbits, forKey: correctbitsKey)
            }
            
            
            //      if SentenceNo == 19 {
            ////      print("todaytryflagKey: ", todaytryflagKey, "   todaytryflag: ", todaytryflag)
            ////      print("answercountKey: ", answercountKey, "   answercount: ", answercount)
            ////      print("trycountKey: ", trycountKey, "   trycount: ", trycount)
            ////        print("answerCheckKey: ", answerCheckKey, "   answerCheck: ", answerCheck)
            //
            //
            //        print("correctbits.count: ", correctbits.count)
            //        print("correctbits: ", correctbits)
            //
            //      }
            
            let trydateKey = "trydateKey" + "_" + String(SentenceNo) + "_" + filename
            //      UserDefaults.standard.register(defaults: [trydateKey : "test"])
            //      UserDefaults.standard.set("test", forKey: trydateKey)
            if UserDefaults.standard.object(forKey: trydateKey) != nil {
                trydate = UserDefaults.standard.string(forKey: trydateKey)!
                
                //trydateKeyがtestの時、2001-01-01に書き換え
                //        if ItemNo == 1 {
                //
                //          print("trydateKey: ", trydate, "   SentenceNo: ", SentenceNo)
                //
                //          if trydate == "test" {
                //            trydate = "2000-01-01"
                //            UserDefaults.standard.set(trydate, forKey: trydateKey)
                //          }
                //        }
                
            }
            else{
                UserDefaults.standard.set("2000-01-01", forKey: trydateKey)
            }
            
            
        }
        
        func saveUserDefaultsBool(flag: Bool, filename:String, SentenceNo:Int, key: String){
            let keyA = key + "_" + String(SentenceNo) + "_" + filename
            UserDefaults.standard.set(flag, forKey: keyA)
            //      print("saveUserDefaultsBool flag: ", flag, "   forKey: ", keyA)
        }
        
        func saveUserDefaultsInt(value:Int, filename:String, SentenceNo:Int, key: String){
            let keyA = key + "_" + String(SentenceNo) + "_" + filename
            UserDefaults.standard.set(value, forKey: keyA)
            //      print("saveUserDefaultsInt value: ", value, "   forKey: ", keyA)
        }
        
        func saveUserDefaultsArrayInt(arrayvalue:[Int], filename:String, SentenceNo:Int, key: String){
            let keyA = key + "_" + String(SentenceNo) + "_" + filename
            UserDefaults.standard.set(arrayvalue, forKey: keyA)
            //      print("saveUserDefaultsArrayInt arrayvalue: ", arrayvalue, "   forKey: ", keyA)
        }
        
        func saveUserDefaultsString(Text:String, filename:String, SentenceNo:Int, key: String){
            let keyA = key + "_" + String(SentenceNo) + "_" + filename
            UserDefaults.standard.set(Text, forKey: keyA)
            print("saveUserDefaultsString String: ", Text, "   forKey: ", keyA)
        }
        
    }
    var SentenceArray = [SentenceClass]()
    
    var BookTitle = ""
    var filename = ""
    
    //UserDefaults用
    var SentenceNo = 0
    var SentenceNoLearning = 0           //select buttonで位置を記憶、move buttonでジャンプ
    var SentenceNoCorrect = 0            //select buttonで設定してからの正解数、これのみUserDefaults使用せず
    var SentenceNoInit = 0               //初期化の回数
    var TodaysAnswer = 0
    var SumAnswer = 0
    
    //UserDefaults Key用
    let settings = UserDefaults.standard
    var SentenceNoKey = ""
    var SentenceNoLearningKey = ""
    var SentenceNoInitKey = ""
    var TodaysAnswerKey = ""
    var SumAnswerKey = ""
    
    init(filename:String){
        
        //    print("TextBook ItemNo: ", ItemNo)
        
        var dataList:[String] = []
        self.filename = filename

        let fileManager = FileManager()
        var path1 = Bundle.main.path(forResource: filename, ofType: "txt")

        do {
            
            var filenameWithoutExt = filename
            if let range = filenameWithoutExt.range(of: ".txt") {
                filenameWithoutExt.removeSubrange(range)
            }
            
            if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
                let targetTextFilePath = documentDirectoryFileURL.appendingPathComponent("material/text/" + filename)
//                print("log0015b targetTextFilePath: ", targetTextFilePath)
                let urlString: String = targetTextFilePath.path
            
                if(fileManager.fileExists(atPath: urlString) == false){
                    //ユーザーが保存したCSVファイルが無い場合は、初期CSVファイルから読み込む。
                    path1 = Bundle.main.path(forResource: filenameWithoutExt, ofType: "txt")!
                    //print("初期ファイル")
                    print("log0015c path1: " + String(path1!))
                }
                else{
                    path1 = urlString
                    print("log0015d path1: " + String(path1!))
                }
            
            
            }

            //CSVファイルのデータを取得する。
            let csvData = try String(contentsOfFile:path1!, encoding:String.Encoding.utf8)
            //print("csvData: ", csvData)
            
            if filename != "Textbook4.txt" {
                //改行区切りでデータを分割して配列に格納する。
                dataList = csvData.components(separatedBy: "\n")
                dataList.removeLast()
                
                //CSVファイルの出力先を確認する。
                //print("userPath: ", userPath)
                //print("dataList: ", dataList)
                
                for i in 0...dataList.count - 1 {
                    let dataDetail = dataList[i].components(separatedBy: "\t")  // \t 水平タブ
                    //print("dataDetail[", i, "]: ", dataDetail)
                    
                    if i == 0 {
                        self.BookTitle = dataDetail[0]
                    }
                    else {
                        SentenceArray.append(SentenceClass(Jpn: dataDetail[1].trimmingCharacters(in: .whitespacesAndNewlines), Eng: dataDetail[2].trimmingCharacters(in: .whitespacesAndNewlines), filename: self.filename, SentenceNo: i-1))
                    }
                    
                    
                }
            }
            else{
                
                //文字列の一部をtzzzzzで置換
                var moji = csvData.replacingOccurrences(of: "No:", with: "zzzzz", options: NSString.CompareOptions.literal, range: nil)
                moji = moji.replacingOccurrences(of: "Jptext:\r\n", with: "zzzzz", options: NSString.CompareOptions.literal, range: nil)
                moji = moji.replacingOccurrences(of: "Engtext:\r\n", with: "zzzzz", options: NSString.CompareOptions.literal, range: nil)
                //        print(moji)
                
                //区切りでデータを分割して配列に格納する。
                dataList = moji.components(separatedBy: "zzzzz")
                //        print(dataList)
                
                //CSVファイルの出力先を確認する。
                //print("userPath: ", userPath)
                //print("dataList: ", dataList)
                
                
                for i in 0...dataList.count - 1 {
                    //let dataDetail = dataList[i].components(separatedBy: "aaaa")
                    //print("dataDetail[", i, "]: ", dataDetail)
                    
                    if i == 0 {
                        self.BookTitle = dataList[i]
                    }
                    else if i % 3 == 0 {
                        SentenceArray.append(SentenceClass(Jpn: dataList[i-1].trimmingCharacters(in: .whitespacesAndNewlines), Eng: dataList[i].trimmingCharacters(in: .whitespacesAndNewlines), filename: self.filename, SentenceNo: i/3 - 1))
                    }
                }
            }
            
        } catch {
            print(error)
        }
        
        self.SentenceNoKey = "SentenceNoKey" + filename
        settings.register(defaults: [self.SentenceNoKey : 0])
        self.SentenceNo = settings.integer(forKey: self.SentenceNoKey)
        
        self.SentenceNoLearningKey = "SentenceNoLearningKey" + filename
        settings.register(defaults: [self.SentenceNoLearningKey : 0])
        self.SentenceNoLearning = settings.integer(forKey: self.SentenceNoLearningKey)
        
        self.SentenceNoInitKey = "SentenceNoInitKey" + filename
        settings.register(defaults: [self.SentenceNoInitKey : 0])
        self.SentenceNoInit = settings.integer(forKey: self.SentenceNoInitKey)
        
        self.TodaysAnswerKey = "TodaysAnswerKey" + filename
        settings.register(defaults: [self.TodaysAnswerKey : 0])
        self.TodaysAnswer = settings.integer(forKey: self.TodaysAnswerKey)
        
        self.SumAnswerKey = "SumAnswerKey" + filename
        settings.register(defaults: [self.SumAnswerKey : 0])
        self.SumAnswer = settings.integer(forKey: self.SumAnswerKey)
        
    }
    
    //CSVファイル保存メソッド
    func SaveText() {
        
        //CSVファイルの保存先
        var userPath:String!
        
        let fileManager = FileManager()
        
        //ユーザーが保存したCSVファイルのパス
        userPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/" + filename
        
        var textString = ""
        textString = BookTitle + "\n"
        
        for i in 0...SentenceArray.count - 1 {
            if ItemNo != 3 {
                textString = textString + String(i+1) + "\t" + SentenceArray[i].Jpn + "\t" + SentenceArray[i].Eng
                textString = textString + "\n"
            }
            else{
                textString = textString + "No:" + String(i+1) + "\r\n" + "Jptext:\r\n" + SentenceArray[i].Jpn + "\r\n" + "Engtext:\r\n" + SentenceArray[i].Eng + "\r\n"
                textString = textString + "\n"
            }
        }
        
        
        do {
            if(textString == "\n") {
                //空の場合はユーザーが保存したファイルを削除する。
                try fileManager.removeItem(atPath: userPath)
            } else {
                //ファイルを出力する。
                try textString.write(toFile: userPath, atomically: false, encoding: String.Encoding.utf8 )
                //print("save userPath: ", userPath)
                //print("textString: ", textString)
            }
        } catch {
            print(error)
        }
    }
    
    func SaveResultBtxt (filename:String){
        
        //    var textString = ""
        //    for i in 0...answerhistory.count-1 {
        //      textString = textString + String(Bookarray[0].answerhistory[i]) + "\n"
        //    }
        
        let textString = "test SaveResultBtxt"
        makeTextFile(textFileName: filename, textString: textString)
        
    }
    
    func LoadResultBtxt (filename:String){
        
        var dataList:[String] = []
        
        //CSVファイルの保存先
        var userPath:String!
        
        do {
            
            //ユーザーが保存したCSVファイルのパス
            userPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/" + filename
            
            let path = userPath
            
            //CSVファイルのデータを取得する。
            let csvData = try String(contentsOfFile:path!, encoding:String.Encoding.utf8)
            //print("csvData: ", csvData)
            
            //改行区切りでデータを分割して配列に格納する。
            dataList = csvData.components(separatedBy: "\n")
            dataList.removeLast()
            
            //CSVファイルの出力先を確認する。
            //print("userPath: ", userPath)
            //print("dataList: ", dataList)
            
            //      for i in 0...SentenceArray.count - 1 {
            //        let dataDetail = dataList[i].components(separatedBy: ",")
            //        //print("dataDetail[", i, "]: ", dataDetail)
            //
            ////        self.answerhistory[i] = Int(dataDetail[0])!
            ////        self.answerCheck[i] = Int(dataDetail[1])!
            //
            //      }
            
        } catch {
            print(error)
        }
    }
    
    
    func Allreset(){
        TodaysAnswer = 0
        SumAnswer = 0
        SentenceNoInit = 0
        for i in 0...SentenceArray.count - 1 {
            //      answerhistory[i] = 0
            //      answerCheck[i] = 0
            SentenceArray[i].answercount = 0
            SentenceArray[i].answerCheck = 0
            SentenceArray[i].learning_flag = false
        }
    }
    
    func Addtext(textString1: String, textString2: String){
        var dataList1:[String] = []
        var dataList2:[String] = []
        
        if ItemNo != 3 {
            dataList1 = textString1.components(separatedBy: "\n")
            //dataList.removeLast()
            
            print("dataList1: ", dataList1)
            
            dataList2 = textString2.components(separatedBy: "\n")
            //dataList.removeLast()
            
            print("dataList2: ", dataList2)
            
            for i in 0...dataList2.count - 1 {
                
                if dataList1[0] != "" {
                    //          JpnArray.append(dataList1[0].trimmingCharacters(in: .whitespacesAndNewlines))
                    //          EngArray.append(dataList2[0].trimmingCharacters(in: .whitespacesAndNewlines))
                    //          answerCheck.append(0)
                    //          answerhistory.append(0)
                    //          trycounthistory.append(0)
                    //          todaytrycounthistory.append(0)
                    //          correctbitshistory.append(0)
                    break
                }
                else if dataList2[i] != "" {
                    //          JpnArray.append("")
                    //          EngArray.append(dataList2[i].trimmingCharacters(in: .whitespacesAndNewlines))
                    //          answerCheck.append(0)
                    //          answerhistory.append(0)
                    //          trycounthistory.append(0)
                    //          todaytrycounthistory.append(0)
                    //          correctbitshistory.append(0)
                }
            }
        }
        else{
            
            //Textbook4.txtをreadして追加して、保存する
            var userPath:String!
            let filename = "Textbook4.txt"
            let fileManager = FileManager()
            
            //ユーザーが保存したCSVファイルのパス
            userPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/" + filename
            
            var filenameWithoutExt = filename
            if let range = filenameWithoutExt.range(of: ".txt") {
                filenameWithoutExt.removeSubrange(range)
            }
            
            var path = userPath
            if(fileManager.fileExists(atPath: path!) == false){
                print("初期ファイル")
                //ユーザーが保存したCSVファイルが無い場合は、初期CSVファイルから読み込む。
                path = Bundle.main.path(forResource: filenameWithoutExt, ofType: "txt")!
            }
            else{
                print("保存ファイル")
            }
            
            do {
                
                var textString = try String(contentsOfFile:path!, encoding:String.Encoding.utf8)
                var textString1 = textString1.replacingOccurrences(of: "\r\n", with: "zzzzz", options: NSString.CompareOptions.literal, range: nil)
                textString1 = textString1.replacingOccurrences(of: "\n", with: "\r\n", options: NSString.CompareOptions.literal, range: nil)
                textString1 = textString1.replacingOccurrences(of: "zzzzz", with: "\r\n", options: NSString.CompareOptions.literal, range: nil)
                
                var textString2 = textString2.replacingOccurrences(of: "\r\n", with: "zzzzz", options: NSString.CompareOptions.literal, range: nil)
                textString2 = textString2.replacingOccurrences(of: "\n", with: "\r\n", options: NSString.CompareOptions.literal, range: nil)
                textString2 = textString2.replacingOccurrences(of: "zzzzz", with: "\r\n", options: NSString.CompareOptions.literal, range: nil)
                
                textString = textString + "No:" + String(999) + "\r\n" + "Jptext:\r\n" + textString1 + "\r\n" + "Engtext:\r\n" + textString2 + "\r\n"
                //      textString = textString + "\n"
                try textString.write(toFile: path!, atomically: false, encoding: String.Encoding.utf8 )
                
            } catch {
                print(error)
            }
            
            
            
        }
    }
    
    func saveSentenceNo(SentenceNo: Int){
        settings.set(SentenceNo, forKey: SentenceNoKey)
    }
    
    func saveSentenceNoLearning(SentenceNoLearning: Int){
        settings.set(SentenceNoLearning, forKey: SentenceNoLearningKey)
    }
    
    func saveSentenceNoInit(SentenceNoInit: Int){
        settings.set(SentenceNoInit, forKey: SentenceNoInitKey)
    }
    
    func saveTodaysAnswer(TodaysAnswer: Int){
        settings.set(TodaysAnswer, forKey: TodaysAnswerKey)
    }
    
    func saveSumAnswer(SumAnswer: Int){
        settings.set(SumAnswer, forKey: SumAnswerKey)
    }
    
}

//https://qiita.com/MilanistaDev/items/e755b42e0737119a4a72
extension UIColor {

    /// ライトモード時のColorとダークモード時のColorを受けて端末のuserInterfaceStyleの値で適切な方の色を返却
    public class func setDynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection) -> UIColor in
                return traitCollection.userInterfaceStyle == .dark ? dark: light
            }
        }
        // iOS 13 未満はライトモード用のColorを返却
        return light
    }
}

// 2017/06/06 テスト版完成
// 2017/06/12 UserDefaults を使って設定の保存、読み込みを実装
// 2017/06/13 スライドバーを動かす
// 2017/06/17 正確なtap位置、位置ズレしない 正規表現検索と複数のrange設定を使った。
// 2017/06/17 英文テキストを別のswiftファイルにした。
// 2017/06/17 ドラゴンイングリッシュの追加
// 2017/06/18 正解数をユーザー設定保存
// 2017/06/19 上スワイプでチェックありまでスキップ
// 2017/06/19 下スワイプで次の正解数0までスキップ
// 2017/06/19 チェックをボタンに変更
// 2017/06/23 設定で正解数の低いもののみ表示
// 2017/06/23 結果の一覧表示
// 2017/06/24 ボタンで移動
// 2017/06/24 正解数の保存と表示
// 2017/06/24 ボタン押下で英文読み上げ
// 2017/06/25 設定ボタン追加、和文非表示
// 2017/06/25 正解後に和文表示、英文読み上げ機能追加
// 2017/06/26 カード移動を記憶するボタン(selectButton)を追加
// 2017/06/27 結果をtxt保存 attributeの警告？が出ているが。。。使えてはいる
// 2017/06/27 保存したtxtの表示
// 2017/06/27 設定にチェックの初期化を追加。結果に初期化数を表示
// 2017/06/27 ファイルを他のアプリに送る機能を追加
// 2017/06/28 ファイルを他のアプリから受け取ってコピーする機能を追加
// 2017/06/28 カード変更で読み上げ停止
// 2017/07/01 和文、英文、TextViewのフォントサイズ自動調整
// 2017/07/01 チェック初期化ボタンは全てチェックした時のみ押せる
// 2017/07/01 正解数をtxt保存
// 2017/07/02 Eng_shuffle2に名前のみ変更
// 2017/07/02 クリップボードからエイブン英文貼り付け
// 2017/07/04 英和文をタブ付きテキストから読み込み、class導入
// 2017/07/07 編集機能、保存機能を追加
//            日本語がない場合、位置をずらす
//            TextViewの位置調整
// 2017/07/09 各結果をテキスト保存
//            設定データを全てテキストに書き出して保存。保存ファイルを元に復元
// 2017/07/10 action extensionを受けて文章追加
// 2017/07/11 SentenceNoLearning_labelを追加
// 2017/07/11 カンマやピリオドを非表示
// 2017/07/11 他のアプリからコピペを反映
// 2017/07/14 Today Extensionに対応
// 2017/07/16 英文表示をTextViewに変更し、単語を長押しで辞書で調べられるようにした。
// 2017/07/17 変数名を変更などコードのメンテナンス
// 2017/07/29 初期化の表示位置変更、resultB.txtの保存内容追加、起動ログを残す
// 2017/07/29 Todayextension高さの調整
// 2017/08/12 コウビルドで単語検索できるようにした。
// 2018/08    英単語の順番並び変えから単語を消していく方式に変更
// 2018/10/20 mp3再生対応
// 2018/12/02 apple watch対応（Eng_shuffle5）
// 2018/12/02 apple watchでnext、back移動対応
// 2018/12/24 Textbook4の表示の高速化
// 2019/01/05 todaytrycounthistoryを導入
// 2019/01/14 trydateを導入
// 2019/01/16 ドラゴンイングリッシュmp3追加
// 2019/05/03 Swift5用に変更
// 2019/06/08 autolayoutの警告が出ないように修正
// 2019/06/09 apple watch で連再のステータス表示
// 2019/06/15 apple watch スワイプやタップ操作を入れる
// 2019/06/16 コントロールセンターで操作できるようにした
// 2019/11/17 mp3のデータをXcodeに登録したファイルではなく、iPhone内のデータを使用するように変更。installの速度アップ
// 2020/05/03 回答の文字を赤色になるように変更
// 2020/05/03 apple watch playbackとgoodの表示を変更
// 2020/05/03 ステータスバーが表示できるようにした
// 2020/05/04 Apple watchでボタンをグループ化、数字を表示できるように変更
// 2020/05/05 swipemode 6 の追加。正解数の少ない20個を抽出
// 2020/05/17 TOECIキーフレーズのmp3を追加
// 2020/05/24 apple watch Complication を変更。選択のバグ修正、左上のSentenceNo_labelをタップできるようにした
// 2020/05/25 解答の赤字などバグ修正
// 2020/05/25 ダークモード対応 （Eng_shuffle10）
// 2020/05/26 ダークモードの細かなバグを修正 長い文章の線の色とかセグエ遷移、モーダル画面（ios13）で閉じたときの反映とか
// 2020/05/30 システムボリュームを変更できるようした
// 2021/02/20 watchOS7に対応。文字盤が更新できるように修正した。0:00に文字盤の問題取り組み数が0にリセットされるはず。
// 2021/02/20 メモ todayExtension は deprecated（非推奨）になった。WidgetKit を使うことが推奨になるようだ。
// 2021/03/02 GitHubにアップロードするように変更
// 2021/03/06 load_resultC_Button resultCを読み込んで、userDefaultsに保存するようにした

//Eng_shuffle1にする時の変更点
//Display Name (本体)
//Bundle Identifier (本体)
//url (本体)
//Action ExtensionとToday ExtensionのTargetを消してしまえば以下は不要
//Display Name (Extension)
//Bundle Identifier (Extension)
//ActionViewController.swiftのurl

// ToDo
// CoreDataを使ってみる
