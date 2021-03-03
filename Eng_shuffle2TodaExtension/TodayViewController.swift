//
//  TodayViewController.swift
//  Eng_shuffle2TodaExtension
//
//  Created by tanakat on 2017/07/11.
//  Copyright © 2017年 tanakat2020. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UIGestureRecognizerDelegate  {
  
  // App Groups
  let suiteName: String = "group.com.swift.tanakat2020.Eng-shuffle2"
  let keyName: String = "shareData"
  
  var height = 0

  @IBOutlet weak var Label1: UILabel!
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
      // NCWidgetDisplayModeをexpandedにしておく
      self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
      
      // シングルタップ
      let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TodayViewController.tap(_:)))
      
      
      // デリゲートをセット
      tapGesture.delegate = self;
      
      // Viewに追加.
      self.view.addGestureRecognizer(tapGesture)
      
      /*
      // Labelのタップを定義
      let firstTap = UITapGestureRecognizer(target: self, action: #selector(self.tapText(tap:)))
      Label1.addGestureRecognizer(firstTap)
      */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
      
      let sharedDefaults: UserDefaults = UserDefaults(suiteName: self.suiteName)!
      
      sharedDefaults.register(defaults: [self.keyName : 0])
      let test = sharedDefaults.string(forKey: self.keyName)!
      print("test: ", test)
      Label1.text = test
      
      let size = Label1.sizeThatFits(Label1.frame.size)
      height = Int(size.height)
      print("size    : ", size)
      
      //Label1.text = String(size.height)
      
        completionHandler(NCUpdateResult.newData)
    }
  
  // 高さの調整
  func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
    if activeDisplayMode == NCWidgetDisplayMode.compact {
      //compact
      self.preferredContentSize = maxSize
    } else {
      //extended(CGSizeで高さ指定)
      //self.preferredContentSize = CGSize(width: 0, height: 200)
      self.preferredContentSize = CGSize(width: 0, height: height)
    }
  }
  
  func tapText(tap: UITapGestureRecognizer) {
    // URLスキームでアプリを起動
    if let appURL = NSURL(string: "Engshuffle2-app://") {
      self.extensionContext?.open(appURL as URL, completionHandler: nil)
    }
  }
  
  // タップイベント.
  @objc func tap(_ sender: UITapGestureRecognizer){
    print("タップ")
    // URLスキームでアプリを起動
    if let appURL = NSURL(string: "Engshuffle2-app://") {
      self.extensionContext?.open(appURL as URL, completionHandler: nil)
    }
  }
  
  /*  @IBAction func Button(_ sender: Any) {
    // URLスキームでアプリを起動
    if let appURL = NSURL(string: "Engshuffle2-app://") {
      self.extensionContext?.open(appURL as URL, completionHandler: nil)
    }
  }
  
  @IBAction func viewDidTap(sender: AnyObject) {
    // URLスキームでアプリを起動
    if let appURL = NSURL(string: "Engshuffle2-app://") {
      self.extensionContext?.open(appURL as URL, completionHandler: nil)
    }
  }
 */
  
}
