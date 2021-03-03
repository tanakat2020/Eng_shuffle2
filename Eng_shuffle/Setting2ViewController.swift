//
//  Setting2ViewController.swift
//  Eng_shuffle
//
//  Created by tanakat on 2017/07/05.
//  Copyright © 2017年 tanakat2020. All rights reserved.
//

import UIKit

class Setting2ViewController: UIViewController, UITextFieldDelegate  {

 
  @IBOutlet weak var JpnTextView: UITextView!
  
  @IBOutlet weak var EngTextView: UITextView!
 
  @IBOutlet weak var ItemNoLabel: UILabel!

  var documentInteraction: UIDocumentInteractionController!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      ItemNoLabel.text = String(ItemNo + 1) + "-" + String(SentenceNo + 1)
      
      // 仮のサイズでツールバー生成
      let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
      kbToolBar.barStyle = UIBarStyle.default  // スタイルを設定
      
      kbToolBar.sizeToFit()  // 画面幅に合わせてサイズを変更
      
      // スペーサー
//      let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItemmItem.flexibleSpace, target: self, action: nil)
      let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
      
      // 閉じるボタン
//      let commitButton = UIBarButtonItem(barButtonSystemIUIBarButtonItem.SystemItemSystemItem.done, target: self, action: #selector(Setting2ViewController.commitButtonTapped))
      let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(Setting2ViewController.commitButtonTapped))
      
      kbToolBar.items = [spacer, commitButton]
      
      
      JpnTextView.inputAccessoryView = kbToolBar
      EngTextView.inputAccessoryView = kbToolBar

        // Do any additional setup after loading the view.
      
      JpnTextView.text = Bookarray[ItemNo].SentenceArray[SentenceNo].Jpn
      EngTextView.text = Bookarray[ItemNo].SentenceArray[SentenceNo].Eng
      
      //Action Extension からの入力の場合
      if actionExtensionflag == true {
        //クリップボードから値取得
        let pb = UIPasteboard.general
        pb.value(forPasteboardType: "public.text")
        
        var pbStr = pb.string!
        
        pbStr = pbStr.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("pbStr", pbStr)
        
        JpnTextView.text = ""
        EngTextView.text = pbStr
        actionExtensionflag = false
      }
      
      
    }

  @objc func commitButtonTapped (){
    self.view.endEditing(true)
  }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

  
  @IBAction func CopyPasteButton(_ sender: Any) {
    //クリップボードから値取得
    let pb = UIPasteboard.general
    pb.value(forPasteboardType: "public.text")
    
    var pbStr = pb.string!
    
    pbStr = pbStr.trimmingCharacters(in: .whitespacesAndNewlines)
    
    print("pbStr", pbStr)
    
    JpnTextView.text = ""
    EngTextView.text = pbStr
  }
  
  @IBAction func Textbook4txtDeleteButton(_ sender: Any) {
    
    var userPath:String!
    let filename = "Textbook4.txt"
    let fileManager = FileManager()
    
    //ユーザーが保存したCSVファイルのパス
    userPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/" + filename
    
    var filenameWithoutExt = filename
    if let range = filenameWithoutExt.range(of: ".txt") {
      filenameWithoutExt.removeSubrange(range)
    }
    
    let path = userPath
    if(fileManager.fileExists(atPath: path!) == false){
      print("Textbook4.txtは存在しない")
      return
    }
    else{
      print("Textbook4.txtを削除する")
    }
    
    do {

      try FileManager.default.removeItem( atPath: path! )
      
    } catch {
      print(error)
    }
    
    
    
    
  }
  
  @IBAction func test(_ sender: Any) {
    
    print("test")
    
    // App Groups
    let suiteName: String = "group.com.swift.tanakat2020.Eng-shuffle2"
    let keyName: String = "shareData"
//
//    var textString = ""
//        let sharedDefaults: UserDefaults = UserDefaults(suiteName: suiteName)!
//        sharedDefaults.set(textString, forKey: keyName)
//        sharedDefaults.synchronize()

    // --------------------
    // データの読み込み（text）
    // --------------------
    
//    do {
    
      let sharedDefaults: UserDefaults = UserDefaults(suiteName: suiteName)!
  //    let sharedData = sharedDefaults.object(forKey: keyName)
  //    print("sharedData:", sharedData)
      
      if let url = sharedDefaults.object(forKey: keyName) as? String {
        print("url:", url)
        
        SaveText(textString: url, filename: "Textbook5.txt")
        
//        print("URL:", URL(string: url)!)
//
//        let textString = try String(contentsOf: URL(string: url)!)
//        print("textString: ", textString)
//
//        JpnTextView.text = url
//        EngTextView.text = textString
//
//        print("Textbook4.txtに保存")
//        SaveText(textString: textString)
      }
    
//    JpnTextView.text = sharedData as! String
//      JpnTextView.text = textString

//    } catch {
//      print(error)
//    }
    
//        if let sharedData = sharedDefaults.object(forKey: keyName) {
//      let image: UIImage = UIImage(data: sharedData as! Data)!
//      self.imageView.image = image
//      // データの削除
//      sharedDefaults.removeObject(forKey: self.keyName)
//    }
  
        //print("share textString:", textString)
  
  }


  
  @IBAction func UploadButton(_ sender: Any) {
    
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
      //ユーザーが保存したCSVファイルが無い場合は、初期CSVファイルから読み込む。
      path = Bundle.main.path(forResource: filenameWithoutExt, ofType: "txt")!
      print("初期ファイル path: ", path!)
    }
    else{
      //上手く動かないので下記を挿入 20180930
      //path = Bundle.main.path(forResource: filenameWithoutExt, ofType: "txt")!
      print("保存ファイル path: ", path!)
    }
    
    do {
      //CSVファイルのデータを取得する。
      let textString = try String(contentsOfFile:path!, encoding:String.Encoding.utf8)
      
      print("textString: ", textString)
      
      //try textString.write(toFile: userPath, atomically: false, encoding: String.Encoding.utf8 )
      
      SaveText(textString: textString, filename: "Textbook5.txt")
      
      //Upload
      SendTextFile()
    
    } catch {
      print(error)
    }

    
    
  }
  
  
  @IBAction func SaveButton(_ sender: Any) {
    
    var textString = JpnTextView.text
    textString = textString!.replacingOccurrences(of: "\r\n", with: "zzzzz", options: NSString.CompareOptions.literal, range: nil)
    textString = textString!.replacingOccurrences(of: "\n", with: "\r\n", options: NSString.CompareOptions.literal, range: nil)
    textString = textString!.replacingOccurrences(of: "zzzzz", with: "\r\n", options: NSString.CompareOptions.literal, range: nil)
    Bookarray[ItemNo].SentenceArray[SentenceNo].Jpn = textString!
    
    textString = EngTextView.text
    textString = textString!.replacingOccurrences(of: "\r\n", with: "zzzzz", options: NSString.CompareOptions.literal, range: nil)
    textString = textString!.replacingOccurrences(of: "\n", with: "\r\n", options: NSString.CompareOptions.literal, range: nil)
    textString = textString!.replacingOccurrences(of: "zzzzz", with: "\r\n", options: NSString.CompareOptions.literal, range: nil)
    Bookarray[ItemNo].SentenceArray[SentenceNo].Eng = textString!
    
    Bookarray[ItemNo].SaveText()
  }
  
  @IBAction func DeleteTextButton(_ sender: Any) {
    JpnTextView.text = ""
    EngTextView.text = ""
  }
  
  @IBAction func AddButton(_ sender: Any) {
    /*
    Bookarray[ItemNo].JpnArray.append(JpnTextView.text)
    Bookarray[ItemNo].EngArray.append(EngTextView.text)
    Bookarray[ItemNo].answerCheck.append(0)
    Bookarray[ItemNo].answerhistory.append(0)
    Bookarray[ItemNo].SaveText()*/
    
    Bookarray[ItemNo].Addtext(textString1: JpnTextView.text, textString2: EngTextView.text) //Textbook4.txtについて、Addtextにsaveも加えた
    //Bookarray[ItemNo].SaveText()
    
  }

  @IBAction func DeleteButton(_ sender: Any) {
//    Bookarray[ItemNo].JpnArray.remove(at: SentenceNo)
//    Bookarray[ItemNo].EngArray.remove(at: SentenceNo)
//    Bookarray[ItemNo].answerCheck.remove(at: SentenceNo)
//    Bookarray[ItemNo].answerhistory.remove(at: SentenceNo)
    Bookarray[ItemNo].SaveText()
//    Bookarray[ItemNo].saveanswerCheck(answerCheck: Bookarray[ItemNo].answerCheck)
//    Bookarray[ItemNo].saveanswerhistory(answerhistory: Bookarray[ItemNo].answerhistory)
    MaximumSentenceNo = Bookarray[ItemNo].SentenceArray.count
    //error noSlider.maximumValue = Float(MaximumSentenceNo)
  }

  
  
  @IBAction func CloseButton(_ sender: Any) {
    //画面を閉じる
    //dismiss(animated: true, completion: nil)
    //performSegue(withIdentifier: "goSetting", sender: nil)
   
    let gohome = storyboard!.instantiateViewController(withIdentifier: "ViewController")
    self.present(gohome,animated: true, completion: nil)
  }
  
  //ファイルを他のアプリに送る
  //  func SendTextFile(filename:String){
  func SendTextFile(){
    let filename = "Textbook4.txt"
    
    
    // Documentディレクトリ
    //let documentDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true).last!
    //let documentDir = userPath
    
    // 送信ファイルのパス
    //let targetDirPath = "\(documentDir)/\(filename)"
    //let targetDirPath = filename
    let targetDirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/" + filename
   
    do {
    
      let textString = try String(contentsOfFile:targetDirPath, encoding:String.Encoding.utf8)
      print("textString: ", textString)
    
    } catch {
    print(error)
    }
    
    //let documentInteraction = UIDocumentInteractionController(url: URL(fileURLWithPath: targetDirPath))
    self.documentInteraction = UIDocumentInteractionController(url: URL(fileURLWithPath: targetDirPath))
    
    if !self.documentInteraction.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true) {
      // 送信できるアプリが見つからなかった時の処理
      let alert = UIAlertController(title: "送信失敗", message: "ファイルを送れるアプリが見つかりません", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  //CSVファイル保存メソッド
  func SaveText(textString:String, filename:String) {
    
    //CSVファイルの保存先
    var userPath:String!
    let fileManager = FileManager()
    //let filename = "Textbook5.txt"
    
    //ユーザーが保存したCSVファイルのパス
    userPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/" + filename
    
    //let textString = "test"
    
    do {
      if(textString == "\n") {
        //空の場合はユーザーが保存したCSVファイルを削除する。
        try fileManager.removeItem(atPath: userPath)
      } else {
        //ファイルを出力する。
        try textString.write(toFile: userPath, atomically: false, encoding: String.Encoding.utf8 )
        print("Textbook5.txt 保存した")
        //print("save userPath: ", userPath)
        //print("textString: ", textString)
      }
    } catch {
      print(error)
    }
  }
  
}
