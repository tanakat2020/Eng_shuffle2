//
//  ActionViewController.swift
//  TestmymemoActionExtension
//
//  Created by tanakat on 2017/07/08.
//  Copyright © 2017年 tanakat2020. All rights reserved.
//

import UIKit
import MobileCoreServices

var textString = ""

class ActionViewController: UIViewController {
  
  @IBOutlet weak var Label1: UILabel!
  @IBOutlet weak var TestButton: UIButton!
  
  override func viewDidLoad() {
    
    print("ActionViewController viewDidLoad")
    
    // App Groups
    let suiteName: String = "group.com.swift.tanakat2020.Eng-shuffle2"
    let keyName: String = "shareData"
    
    super.viewDidLoad()
    
    // Get the item[s] we're handling from the extension context.
    
//    let extensionItem: NSExtensionItem = self.extensionContext?.inputItems.first as! NSExtensionItem
//    let itemProvider = extensionItem.attachments?.first as! NSItemProvider
//    let itemProvider = extensionItem.attachments?.first as! NSItemProvider
    
    let extensionItem: NSExtensionItem = self.extensionContext?.inputItems.first as! NSExtensionItem
    let itemProvider = extensionItem.attachments?.first
    
    if (itemProvider?.hasItemConformingToTypeIdentifier(kUTTypeText as String))! {
      itemProvider!.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil, completionHandler: { (item, error) in
        
//        textString = text as! String
        print("item: ", item!)
        
//        let url = NSURL(string: "https://www.google.com/images/srpr/logo11w.png")
//        let data1 = NSData(contentsOfURL: url! as URL)
//
//        let data2 = NSData(conte)
        
        
//NG        let text = NSString(data: data! as! Data, encoding: String.Encoding.utf8.rawValue)
//        let text: String = NSString(data:data as! Data, encoding: String.Encoding.utf8.rawValue)! as String
  
        do {
          
            //ファイルを出力する。
            //try textString.write(toFile: data, atomically: false, encoding: String.Encoding.utf8 )
          //let text = try String(contentsOfFile:data! as! String , encoding:String.Encoding.utf8)
          let textString = try String(contentsOf: item as! URL)
          print("textString: ", textString)
          
          //ActionViewからは大元のファイルのドキュメントフォルダには直接アクセスできない。
//          //テキストファイルの保存先
//          var userPath:String!
//          let fileManager = FileManager()
//          let filename = "Textbook4.txt"
//
//          //ユーザーが保存したテキストファイルのパス
//          userPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/" + filename
//          print("userPath: ", userPath)
//
//          if(textString == "\n") {
//              //空の場合はユーザーが保存したテキストファイルを削除する。
//              try fileManager.removeItem(atPath: userPath)
//            } else {
//              //ファイルを出力する。
//              try textString.write(toFile: userPath, atomically: false, encoding: String.Encoding.utf8 )
//              print("Textbook4.txt 保存した")
//              //print("save userPath: ", userPath)
//              //print("textString: ", textString)
//            }
          
          
            let sharedDefaults: UserDefaults = UserDefaults(suiteName: suiteName)!
            //sharedDefaults.set(text!, forKey: keyName)  // そのページのテキストデータ保存
            sharedDefaults.set(textString, forKey: keyName)
            //sharedDefaults.set(userPath, forKey: keyName)
            sharedDefaults.synchronize()
          
        } catch {
          print(error)
        }


          
//        if let url: NSURL = item as? NSURL {
//
//        let sharedDefaults: UserDefaults = UserDefaults(suiteName: suiteName)!
//        //sharedDefaults.set(text!, forKey: keyName)  // そのページのテキストデータ保存
//        //sharedDefaults.set(textString, forKey: keyName)
//        sharedDefaults.set(url.absoluteString!, forKey: keyName)
//        sharedDefaults.synchronize()
//        }
          
        //self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        
        print("log0020 大元アプリに処理を返す。")  //デバッグ表示あり
        
          
          
      })
    }
    
    print("log0030")  //デバッグ表示なし。completeRequestsするから？
    
    //      Label1.text = textString
    Label1.text = ""
    TestButton.setTitle("", for: .normal)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      // 0.5秒後に実行したい処理

      let board = UIPasteboard.general
      board.string = textString

      let url = NSURL(string: "Engshuffle2-app://next")
      let context = NSExtensionContext()
      context.open(url! as URL, completionHandler: nil)

      var responder = self as UIResponder?
      let selector = sel_registerName("openURL:")

      while let r = responder, !r.responds(to: selector) {
        responder = r.next
      }
      _ = responder?.perform(selector, with: url)

      self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)

    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func done() {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    
    
    //let url = NSURL(string: "Engshuffle2-app://")
    let url = NSURL(string: "Engshuffle2-app://next")
    
    let context = NSExtensionContext()
    context.open(url! as URL, completionHandler: nil)
    
    var responder = self as UIResponder?
    let selector = sel_registerName("openURL:")
    
    while let r = responder, !r.responds(to: selector) {
      responder = r.next
    }
    _ = responder?.perform(selector, with: url)
    
    self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
  }
}
