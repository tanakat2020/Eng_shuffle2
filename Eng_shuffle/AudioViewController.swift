//
//  AudioViewController.swift
//  Eng_shuffle
//
//  Created by tanakat on 2017/08/12.
//  Copyright © 2017年 tanakat2020. All rights reserved.
//

import UIKit
import AVFoundation   //音声読み上げ
import Speech         //音声認識

class AudioViewController: UIViewController {
  
  @IBOutlet weak var EngtextLabel: UILabel!

  @IBOutlet weak var MicInputTextView: UITextView!
  
  @IBOutlet weak var audioButton: UIButton!
 
  @IBOutlet weak var RecordButton: UIButton!
  
  @IBOutlet weak var PlayButton: UIButton!
  
  @IBOutlet weak var musicplayButton: UIButton!
  
  //音声読み上げ
  let synthesizer = AVSpeechSynthesizer()
  
  //音声認識
  // "ja-JP"を指定すると日本語になります。
  private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  private let audioEngine = AVAudioEngine()
  private var recognitionResult: SFSpeechRecognitionResult?
  
  //音声の録音・再生
  var audioRecorder: AVAudioRecorder?
  var audioPlayer: AVAudioPlayer?
  var player:AVAudioPlayer?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()

    
    
    // Do any additional setup after loading the view.
    
    // 音声認識初期化
    speechRecognizer.delegate = self as? SFSpeechRecognizerDelegate
    //speechRecognizer.delegate = self
    //speechRecognizer.delegate = self
    self.requestRecognizerAuthorization()
    audioButton.isEnabled = false
    
    MicInputTextView.isSelectable = false
    MicInputTextView.isUserInteractionEnabled = true
    MicInputTextView.isEditable = false
    
    EngtextLabel.text = Bookarray[ItemNo].SentenceArray[SentenceNo].Eng
    
    var fontsize = 30
    EngtextLabel.font = UIFont.systemFont(ofSize: CGFloat(fontsize) )
    
    for i in 1...10 {
      let size = EngtextLabel.sizeThatFits(EngtextLabel.frame.size)
      //print("size1    : ", size)
      
      if size.height > 179.5 {
        fontsize = 30 - i
        EngtextLabel.font = UIFont.systemFont(ofSize: CGFloat(fontsize) )
      }
      else{
        break
      }
    }
    
    
    //音声の再生
    
    //録音設定
    self.setupAudioRecorder()
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    requestRecognizerAuthorization()
  }
  
  private func requestRecognizerAuthorization() {
    // 認証処理
    SFSpeechRecognizer.requestAuthorization { authStatus in
      // メインスレッドで処理したい内容のため、OperationQueue.main.addOperationを使う
      OperationQueue.main.addOperation { [weak self] in
        guard let `self` = self else { return }
        
        switch authStatus {
        case .authorized:
          self.audioButton.isEnabled = true
          
        case .denied:
          self.audioButton.isEnabled = false
          self.audioButton.setTitle("音声認識へのアクセスが拒否されています。", for: .disabled)
          
        case .restricted:
          self.audioButton.isEnabled = false
          self.audioButton.setTitle("この端末で音声認識はできません。", for: .disabled)
          
        case .notDetermined:
          self.audioButton.isEnabled = false
          self.audioButton.setTitle("音声認識はまだ許可されていません。", for: .disabled)
        @unknown default:
          fatalError()
        }
      }
    }
  }
  
  
  
  private func startRecording() throws {
    refreshTask()
    
    let audioSession = AVAudioSession.sharedInstance()
    // 録音用のカテゴリをセット
    try audioSession.setCategory(AVAudioSession.Category.record)
//    try audioSession.setMode(AVAudioSessionModeMeasurement)
    try audioSession.setMode(AVAudioSession.Mode.measurement)
//    try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
    try audioSession.setActive(true)
    
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    
    //guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
    let inputNode = audioEngine.inputNode
    guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
    
    // 録音が完了する前のリクエストを作るかどうかのフラグ。
    // trueだと現在-1回目のリクエスト結果が返ってくる模様。falseだとボタンをオフにしたときに音声認識の結果が返ってくる設定。
    recognitionRequest.shouldReportPartialResults = true
    
    recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
      guard let `self` = self else { return }
      
      var isFinal = false
      
      if let result = result {
        self.MicInputTextView.text = result.bestTranscription.formattedString
        self.scrollToButtom()
        isFinal = result.isFinal
      }
      
      // エラーがある、もしくは最後の認識結果だった場合の処理
      if error != nil || isFinal {
        self.audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = nil
        self.recognitionTask = nil
        
        self.audioButton.isEnabled = true
        self.audioButton.setTitle("音声認識スタート", for: [])
        
      }
    }
    
    
    
    // マイクから取得した音声バッファをリクエストに渡す
    let recordingFormat = inputNode.outputFormat(forBus: 0)
    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
      self.recognitionRequest?.append(buffer)
    }
    
    try startAudioEngine()
  }
  
  func scrollToButtom() {
    MicInputTextView.selectedRange = NSRange(location: MicInputTextView.text.count, length: 0)
    MicInputTextView.isScrollEnabled = true
    
    let scrollY = MicInputTextView.contentSize.height - MicInputTextView.bounds.height
    let scrollPoint = CGPoint(x: 0, y: scrollY > 0 ? scrollY : 0)
    MicInputTextView.setContentOffset(scrollPoint, animated: true)
  }
  
  private func refreshTask() {
    if let recognitionTask = recognitionTask {
      recognitionTask.cancel()
      self.recognitionTask = nil
    }
  }
  
  private func startAudioEngine() throws {
    // startの前にリソースを確保しておく。
    audioEngine.prepare()
    
    try audioEngine.start()
    
    MicInputTextView.text = "どうぞ喋ってください。"
  }
  
  // 録音するために必要な設定を行う
  // viewDidLoad時に行う
  func setupAudioRecorder() {
    let session = AVAudioSession.sharedInstance()
    // 再生と録音機能をアクティブにする
    try! session.setCategory(AVAudioSession.Category.record)
    try! session.setActive(true)
    
    let recordSetting : [String : AnyObject] = [
      AVEncoderAudioQualityKey : AVAudioQuality.min.rawValue as AnyObject,
      AVEncoderBitRateKey : 16 as AnyObject,
      AVNumberOfChannelsKey: 1 as AnyObject,
      AVSampleRateKey: 44100.0 as AnyObject
    ]
    do {
      try audioRecorder = AVAudioRecorder(url: self.documentFilePath() as URL, settings: recordSetting)
      audioRecorder?.prepareToRecord()
    } catch {
      print("初期設定でerror出たよ(-_-;)")
    }
  }
  /*
  // 再生
  func play() {
    do {
      try audioPlayer = AVAudioPlayer(contentsOf: self.documentFilePath() as URL)
      audioPlayer?.prepareToPlay()
    } catch {
      print("再生時にerror出たよ(´・ω・｀)")
    }
    //audioPlayer?.play()
    
  }
  */
  // 録音するファイルのパスを取得(録音時、再生時に参照)
  func documentFilePath()-> NSURL {
    /*
    let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as [NSURL]
    let dirURL = urls[0]
    return dirURL.URLByAppendingPathComponent(fileName)
    */
    //let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
    //let filePath = NSURL(fileURLWithPath: documentDir + "/sample.caf")
    
    let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    let filePath = documentDir?.appendingPathComponent("sample.caf")
    return filePath! as NSURL
  }
  
  /*
  //音声の録音
  func record() {
    do {
      
      //test
      let audioSession = AVAudioSession.sharedInstance()
      // 録音用のカテゴリをセット
      try audioSession.setCategory(AVAudioSessionCategoryRecord)
      //try audioSession.setMode(AVAudioSessionModeMeasurement)
      //try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
      
      
      // 保存する場所: 今回はDocumentディレクトリにファイル名"sample.caf"で保存
      let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
      let filePath = NSURL(fileURLWithPath: documentDir + "/sample.caf")
      print("filePath: ", filePath)
      
      // オーディオフォーマット
      let format = AVAudioFormat(commonFormat: .pcmFormatFloat32  , sampleRate: 44100, channels: 1 , interleaved: true)
      // オーディオファイル
      let audioFile = try AVAudioFile(forWriting: filePath as URL, settings: format.settings)
      // inputNodeの出力バス(インデックス0)にタップをインストール
      // installTapOnBusの引数formatにnilを指定するとタップをインストールしたノードの出力バスのフォーマットを使用する
      // (この例だとフォーマットに inputNode.outputFormatForBus(0) を指定するのと同じ)
      // tapBlockはメインスレッドで実行されるとは限らないので注意
      //let inputNode = audioEngine2.inputNode!  // 端末にマイクがあると仮定する
      
      print("log00100 record")
      
      guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
      
      print("log00101 record")
      
      inputNode.installTap(onBus: 0, bufferSize: 4096, format: nil) { (buffer, when) in
        do {
          // audioFileにバッファを書き込む
          try audioFile.write(from: buffer)
        } catch let error {
          print("audioFile.writeFromBuffer error:", error)
        }
      }
      
      print("log00102 record")
      
      do {
        // エンジンを開始
        try audioEngine.start()
      } catch let error {
        print("engine.start() error:", error)
      }
    } catch let error {
      print("AVAudioFile error:", error)
    }
  }
  
  //音声の再生
  
  func play() {
    
    let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    let filePath = NSURL(fileURLWithPath: documentDir + "/sample.caf")
    
//    if let url = filePath {
      do {
        // オーディオファイルの取得
        let audioFile = try AVAudioFile(forReading: filePath as URL)
        
        // エンジンにノードをアタッチ
        audioEngine.attach(player)
        // メインミキサの取得
        let mixer = audioEngine.mainMixerNode
        // Playerノードとメインミキサーを接続
        audioEngine.connect(player,
                            to: mixer,
                            format: nil)
                            //format: audioFile.processingFormat)
        // プレイヤのスケジュール
        player.scheduleFile(audioFile, at: nil) {
          print("complete")
        }
        // エンジンの開始
        try audioEngine.start()
        // オーディオの再生
        player.play()
      } catch let error {
        print(error)
      }
    /*
    } else {
      print("File not found")
    }
    */
  }
  */

  //閉じるボタン
  @IBAction func CloseButton(_ sender: Any) {
    /*
    let data = "閉じるボタン押下"
    
    // handlerに関数がセットされているか確認
    if let handler = self.resultHandler {
      handler(data)
    }
    */
    
    let audioSession = AVAudioSession.sharedInstance()
//  setCategory swift5でエラーになった。 20190503
//    try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
//    try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
    try! audioSession.setCategory(AVAudioSession.Category.playAndRecord)
    try! audioSession.setActive(true)
    
    // AVSessionのカAVAudioSession.Category.ambientoSession = AVAudioSession.sharedInstance()
    try! audioSession.setCategory(AVAudioSession.Category.ambient)
    
    //画面を閉じる
    dismiss(animated: true, completion: nil)
  }
  
  //音声認識ボタン
  @IBAction func audioButton(_ sender: Any) {
    
      //読み上げ中であれば停止
      /*
      if synthesizer.isSpeaking == true {
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
      }
      */
    
      if audioEngine.isRunning {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioButton.isEnabled = false
        audioButton.setTitle("音声認識を再開", for: .disabled)
      } else {
        try! startRecording()
        audioButton.setTitle("音声認識を中止", for: [])
     }
    
  }
  
  //音声読み上げボタン
  @IBAction func SpeechButton(_ sender: Any) {
    
    //読み上げ中であれば停止
    if synthesizer.isSpeaking == true {
      synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
    }
    
    var audioSession = AVAudioSession.sharedInstance()
    try! audioSession.setCategory(AVAudioSession.Category.playAndRecord)
    try! audioSession.setActive(true)
    
    // AVSessionのカテゴリを変更
    audioSession = AVAudioSession.sharedInstance()
    try! audioSession.setCategory(AVAudioSession.Category.ambient)
    
    let utterance = AVSpeechUtterance(string: Bookarray[ItemNo].SentenceArray[SentenceNo].Eng)
    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    synthesizer.speak(utterance)
  }
  
  //録音ボタン
  @IBAction func RecordButton(_ sender: Any) {
    //読み上げ中であれば停止
    /*
    if synthesizer.isSpeaking == true {
      synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
    }
    */

    let session = AVAudioSession.sharedInstance()
    try! session.setCategory(AVAudioSession.Category.record)
    //AVAudioSessionCategoryRecord
    //AVAudioSessionCategoryPlayAndRecord
    try! session.setActive(true)
    
    if audioRecorder?.isRecording == true {
      audioRecorder?.stop()
      PlayButton.isEnabled = true
      RecordButton.setTitle("録音", for: [])
    }
    else{
      audioRecorder?.record()
      PlayButton.isEnabled = false
      RecordButton.setTitle("停止", for: [])
    }
    
    
  }
  
  
  //再生ボタン
  @IBAction func PlayButton(_ sender: Any) {
    
    var audioSession = AVAudioSession.sharedInstance()
    try! audioSession.setCategory(AVAudioSession.Category.playAndRecord)
    try! audioSession.setActive(true)
    
    // AVSessionのカテゴリを変更
    audioSession = AVAudioSession.sharedInstance()
    try! audioSession.setCategory(AVAudioSession.Category.ambient)
    //try! audioSession.setActive(true)
    
    //play()
    
    audioPlayer?.stop()
    //audioPlayer?.currentTime = 0
    
    do {
      try audioPlayer = AVAudioPlayer(contentsOf: self.documentFilePath() as URL)
      //audioPlayer?.prepareToPlay()
    } catch {
      print("再生時にerror出たよ(´・ω・｀)")
    }
    
    audioPlayer?.volume = 7
    audioPlayer?.numberOfLoops = 0 // 1回再生。-1で無限ループ
    audioPlayer?.play()
    
    /*
    if ( audioPlayer?.isPlaying )!{
      audioPlayer?.stop()
      PlayButton.setTitle("再生", for: UIControlState())
    }
    else{
      audioPlayer?.play()
      PlayButton.setTitle("停止", for: UIControlState())
    }
    */
    
    
    
    /*
    if player.isPlaying {
    //if audioEngine2.isRunning {
      player.stop()
      //RecordButton.isEnabled = false
      PlayButton.setTitle("再生", for: [])
    } else {
      play()
      PlayButton.setTitle("停止", for: [])
    }
    */
    
  }
  
  
  
  @IBAction func musicplayButton(_ sender: Any) {
    
    //読み上げ中であれば停止
    if synthesizer.isSpeaking == true {
      synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
    }
    
    var audioSession = AVAudioSession.sharedInstance()
    try! audioSession.setCategory(AVAudioSession.Category.playAndRecord)
    try! audioSession.setActive(true)
    
    //AVAudioSession.Category.ambient更
    audioSession = AVAudioSession.sharedInstance()
    try! audioSession.setCategory(AVAudioSession.Category.ambient)
    
    //test
    //設定画面へ遷移
    //    self.performSegue(withIdentifier: "goAudio", sender: nil)
    
    // 再生する音声ファイルを指定する
    if ItemNo == 0 {
      let musicNo = "DUO3.0_" + String(format: "%03d", SentenceNo+1)
      print(musicNo)
      
      let soundURL = Bundle.main.url(forResource: musicNo, withExtension: "mp3")
      
      do {
        // 効果音を鳴らす
        player = try AVAudioPlayer(contentsOf: soundURL!)
        player?.play()
      } catch {
        print("error...")
      }
    }
    
  }
  
  
  //テストボタン
  @IBAction func TestButton(_ sender: Any) {
    
    //ファイルを他のアプリに送る
    
    // Documentディレクトリ
    let documentDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true).last!
    
    // 送信するファイル名
    let filename = "sample.caf"
    
    // 送信ファイルのパス
    let targetDirPath = "\(documentDir)/\(filename)"
    
    let documentInteraction = UIDocumentInteractionController(url: URL(fileURLWithPath: targetDirPath))
    
    if !documentInteraction.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true) {
      // 送信できるアプリが見つからなかった時の処理
      let alert = UIAlertController(title: "送信失敗", message: "ファイルを送れるアプリが見つかりません", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
    
  }
  
  
}

extension ViewController: SFSpeechRecognizerDelegate {
  // 音声認識の可否が変更したときに呼ばれるdelegate
  func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    if available {
      audioButton.isEnabled = true
      audioButton.setTitle("音声認識スタート", for: [])
    } else {
      audioButton.isEnabled = false
      audioButton.setTitle("音声認識ストップ", for: .disabled)
    }
  }
}
