//
//  SettingViewController.swift
//  Eng_shuffle
//
//  Created by tanakat on 2017/06/24.
//  Copyright © 2017年 tanakat2020. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    
    let settings = UserDefaults.standard
    var Jpdisplayflag = true
    var Jp2displayflag = true
    var Jp3displayflag = true
    var Engspeechflag = false
    var Eng2speechflag = false
    var DisplayResultBflag = true
    var SentenceNoLearningflag = true
    var Darkmodeflag = true
    
    var resultHandler: ((String) -> Void)?
    
    @IBOutlet weak var JpSwitch: UISwitch!
    
    @IBOutlet weak var Jp2Switch: UISwitch!
    
    @IBOutlet weak var Jp3Switch: UISwitch!
    
    @IBOutlet weak var EnSwitch: UISwitch!
    
    @IBOutlet weak var En2Switch: UISwitch!
    
    @IBOutlet weak var SentenceNoLeaningSwitch: UISwitch!
    
    @IBOutlet weak var DarkmodeSwitch: UISwitch!
    
    
    @IBOutlet weak var InitializeCheck: UIButton!
    
    @IBOutlet weak var TestButton: UIButton!
    
    @IBOutlet weak var ResultBtextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        Jpdisplayflag = settings.bool(forKey: "Jpdisplayflag_value")
        Jp2displayflag = settings.bool(forKey: "Jp2displayflag_value")
        Jp3displayflag = settings.bool(forKey: "Jp3displayflag_value")
        Engspeechflag = settings.bool(forKey: "Engspeechflag_value")
        Eng2speechflag = settings.bool(forKey: "Eng2speechflag_value")
        SentenceNoLearningflag = settings.bool(forKey: "SentenceNoLearningflag_value")
        Darkmodeflag = settings.bool(forKey: "Darkmodeflag_value")
        
        JpSwitch.isOn = Jpdisplayflag
        Jp2Switch.isOn = Jp2displayflag
        Jp3Switch.isOn = Jp3displayflag
        EnSwitch.isOn = Engspeechflag
        En2Switch.isOn = Eng2speechflag
        SentenceNoLeaningSwitch.isOn = SentenceNoLearningflag
        DarkmodeSwitch.isOn = Darkmodeflag
        
        if Jpdisplayflag == true {
            Jp2Switch.isEnabled = false
        }
        else{
            Jp2Switch.isEnabled = true
        }
        
        if Darkmodeflag == true {
            overrideUserInterfaceStyle = .dark
        }
        else{
            overrideUserInterfaceStyle = .light
        }
        
        var result2 = 0
        
        for i in 0...Bookarray[ItemNo].SentenceArray.count - 1 {
            if Bookarray[ItemNo].SentenceArray[i].answerCheck >= 1 {
                result2 = result2 + 1
            }
        }
        
        //print("answerCheck.count: ", Bookarray[ItemNo].answerCheck.count )
        //      if result2 == Bookarray[ItemNo].answerCheck.count {
        //        InitializeCheck.isEnabled = true
        //      }
        //      else{
        //        InitializeCheck.isEnabled = false
        //      }
        InitializeCheck.isEnabled = true
        
        ResultBtextView.isSelectable = false
        ResultBtextView.isUserInteractionEnabled = true
        ResultBtextView.isEditable = false
        //ResultBtextView.text = ""
        ResultBtextView.text = getNowClockString()
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        presentingViewController?.beginAppearanceTransition(false, animated: animated)
        super.viewWillAppear(animated)
//        print("viewWillAppear2")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentingViewController?.endAppearanceTransition()
//        print("viewDidAppear2")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.beginAppearanceTransition(true, animated: animated)
        presentingViewController?.endAppearanceTransition()
//        print("viewWillDisappear2")
    }
    
    @IBAction func JpSwitch(_ sender: UISwitch) {
        
        Jpdisplayflag = sender.isOn
        if Jpdisplayflag == true {
            Jp2Switch.isEnabled = false
        }
        else{
            Jp2Switch.isEnabled = true
        }
        
        settings.set(Jpdisplayflag, forKey: "Jpdisplayflag_value")
        //print("1 Jp2Switch.isEnabled: ", Jp2Switch.isEnabled)
    }
    
    
    @IBAction func DarkmodeSwitch(_ sender: UISwitch) {
        Darkmodeflag = sender.isOn
        settings.set(Darkmodeflag, forKey: "Darkmodeflag_value")
        
        if Darkmodeflag == true {
            overrideUserInterfaceStyle = .dark
        }
        else{
            overrideUserInterfaceStyle = .light
        }
        
    }
    
    
    @IBAction func Jp2Switch(_ sender: UISwitch) {
        Jp2displayflag = sender.isOn
        settings.set(Jp2displayflag, forKey: "Jp2displayflag_value")
        //print("2 Jp2Switch.isEnabled: ", Jp2Switch.isEnabled)
    }
    
    @IBAction func Jp3Switch(_ sender: UISwitch) {
        Jp3displayflag = sender.isOn
        settings.set(Jp3displayflag, forKey: "Jp3displayflag_value")
    }
    
    @IBAction func EnSwitch(_ sender: UISwitch) {
        Engspeechflag = sender.isOn
        settings.set(Engspeechflag, forKey: "Engspeechflag_value")
    }
    
    @IBAction func En2Switch(_ sender: UISwitch) {
        Eng2speechflag = sender.isOn
        settings.set(Eng2speechflag, forKey: "Eng2speechflag_value")
    }
    
    @IBAction func SentenceNoLeaningSwitch(_ sender: UISwitch) {
        SentenceNoLearningflag = sender.isOn
        settings.set(SentenceNoLearningflag, forKey: "SentenceNoLearningflag_value")
    }
    
    
    @IBAction func InitializeCheck(_ sender: Any) {
        
        for i in 0...Bookarray[ItemNo].SentenceArray.count-1 {
            
            Bookarray[ItemNo].SentenceArray[i].answerCheck -= 1
            if Bookarray[ItemNo].SentenceArray[SentenceNo].answerCheck <= -1 {
                Bookarray[ItemNo].SentenceArray[SentenceNo].answerCheck = 0
            }
            
            Bookarray[ItemNo].SentenceArray[i].saveUserDefaultsInt(
                value: Bookarray[ItemNo].SentenceArray[i].answerCheck,
                filename: Bookarray[ItemNo].filename,
                SentenceNo: i,
                key: "answerCheckKey")
        }
        Bookarray[ItemNo].SentenceNoInit = Bookarray[ItemNo].SentenceNoInit + 1
        Bookarray[ItemNo].saveSentenceNoInit(SentenceNoInit: Bookarray[ItemNo].SentenceNoInit)
        
        InitializeCheck.isEnabled = true
    }
    
    @IBAction func DisplayResultTxt(_ sender: Any) {
        
        if DisplayResultBflag == true {
            
            //ラベルを最前面に移動
            self.view.bringSubviewToFront(ResultBtextView)
            
            let textFileName = "result.txt"
            
            if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
                
                let targetTextFilePath = documentDirectoryFileURL.appendingPathComponent(textFileName)
                
                print("targetTextFilePath: ", targetTextFilePath)
                
                let urlString: String = targetTextFilePath.path
                if FileManager.default.fileExists(atPath: urlString) {
                    print("ファイルあり")
                }
                else{
                    print("ファイルなし")
                }
                
                //readTextFile
                do {
                    let text = try String(contentsOf: targetTextFilePath, encoding: String.Encoding.utf8)
                    print(text)
                    
                    ResultBtextView.text = text
                    
                } catch let error as NSError {
                    print("failed to read: \(error)")
                }
                
            }
            DisplayResultBflag = false
        }
        else{
            self.view.sendSubviewToBack(ResultBtextView)
            //ResultBtextView.text = ""
            ResultBtextView.text = getNowClockString()
            DisplayResultBflag = true
        }
    }
    
    @IBAction func SendButton(_ sender: Any) {
        
        //ファイルを他のアプリに送る
        
        // Documentディレクトリ
        let documentDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true).last!
        
        // 送信するファイル名
        let filename = "result.txt"
        
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
    
    //resultB.txt作成
    @IBAction func Makefile2Button(_ sender: Any) {
        
        deleteTextFile(textFileName: "resultB.txt")
        
        var textString = ""
        textString = getNowClockString() + "\n"
        
        for h in 0...3 {
            
            if h == 0 {
                textString = textString + "DUO3.0\n"
            }
            else if h == 1 {
                textString = textString + "TOIEC\n"
            }
            else if h == 2 {
                textString = textString + "Dragon English\n"
            }
            else if h == 3 {
                textString = textString + "Textbook4\n"
            }
            
            textString = textString + String(Bookarray[h].SentenceNoInit) + "\n"
            
            print("Bookarray[h].answerhistory.count: ", Bookarray[h].SentenceArray.count)
            
            for i in 0...Bookarray[h].SentenceArray.count-1 {
                textString = textString + String(i + 1) + ","
                textString = textString + String(Bookarray[h].SentenceArray[i].answercount) + ","
                textString = textString + String(Bookarray[h].SentenceArray[i].answerCheck) + ","
                textString = textString + String(Bookarray[h].SentenceArray[i].trycount) + ","
                
                for j in 0...Bookarray[h].SentenceArray[i].correctbits.count-1 {
                    textString = textString + String(Bookarray[h].SentenceArray[i].correctbits[j])
                }
                textString = textString + "\n"
            }
        }
        
        makeTextFile(textFileName: "resultB.txt", textString: textString)
    }
    
    @IBAction func initialize_correctbits(_ sender: Any) {
        
        for h in 0...3 {
            for i in 0...Bookarray[h].SentenceArray.count-1 {
                
                //        print("Bookarray[",h,"].SentenceArray[",i,"] ")
                
                for j in 0...Bookarray[h].SentenceArray[i].correctbits.count-1 {
                    Bookarray[h].SentenceArray[i].correctbits[j] = 0
                }
                
                Bookarray[h].SentenceArray[i].saveUserDefaultsArrayInt(
                    arrayvalue: Bookarray[h].SentenceArray[i].correctbits,
                    filename: Bookarray[h].filename,
                    SentenceNo: i,
                    key: "correctbitsKey")
                
            }
        }
    }
    
    
    
    @IBAction func makefile3Button(_ sender: Any) {
        deleteTextFile(textFileName: "resultC.txt")
        
        var textString = ""
        textString = getNowClockString() + "\n"
        textString = textString + "No, anshis, ansCheck, trycounthis\n"
        
        for h in 0...3 {
            
            if h == 0 {
                textString = textString + "DUO3.0\n"
            }
            else if h == 1 {
                textString = textString + "TOIEC\n"
            }
            else if h == 2 {
                textString = textString + "Dragon English\n"
            }
            else if h == 3 {
                textString = textString + "Textbook4\n"
            }
            
            textString = textString + String(Bookarray[h].SentenceNoInit) + "\n"
            for i in 0...Bookarray[h].SentenceArray.count-1 {
                textString = textString + String(i + 1) + ","
                textString = textString + String(Bookarray[h].SentenceArray[i].answercount) + ","
                textString = textString + String(Bookarray[h].SentenceArray[i].answerCheck) + ","
                textString = textString + String(Bookarray[h].SentenceArray[i].trycount) + ","
                textString = textString + String(Bookarray[h].SentenceArray[i].trydate) + "\n"
                //textString = textString + String(Bookarray[0].correctbitshistory[i]) + "\n"
                
                //        for j in 0...Bookarray[h].correctbitshistory2[i].count-1 {
                //          textString = textString + String(Bookarray[h].correctbitshistory2[i][j])
                //        }
                //        textString = textString + "\n"
            }
        }
        makeTextFile(textFileName: "resultC.txt", textString: textString)
    }
    
    
    @IBAction func load_resultC_Button(_ sender: Any) {
        
        let filename = "resultC.txt"
        
        var dataList:[String] = []
        var dataList2:[String] = []
        
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
            
            //TextBook1
            var ItemNo = 0
//            print("itemNo: ", itemNo)
//
//            print("dataList[3]: ", dataList[4])
            Bookarray[ItemNo].saveSentenceNoInit(SentenceNoInit: Int(dataList[4])!)
            
//            print("load resultC.txt")
//            for i in 0...10 {
//                print(dataList[i])
//            }
            
            for i in 1+4...560+4 {
                dataList2 = dataList[i].components(separatedBy: ",")
                
                let SentenceNo = Int(dataList2[0])! - 1
//                print("dataList2[0]:", dataList2[0])
//                print("dataList2[1]:", dataList2[1])
//                print("dataList2[2]:", dataList2[2])
                    
                Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsInt(
                    value: Int(dataList2[1])!,
                    filename: Bookarray[ItemNo].filename,
                    SentenceNo: SentenceNo,
                    key: "answercountKey")
                
                Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsInt(
                    value: Int(dataList2[2])!,
                    filename: Bookarray[ItemNo].filename,
                    SentenceNo: SentenceNo,
                    key: "answerCheckKey")
                
                Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsInt(
                    value: Int(dataList2[3])!,
                    filename: Bookarray[ItemNo].filename,
                    SentenceNo: SentenceNo,
                    key: "trycountKey")
                
                Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsString(
                    Text: dataList2[4],
                    filename: Bookarray[ItemNo].filename,
                    SentenceNo: SentenceNo,
                    key: "trydateKey")
                
            }
            
            //TextBook2
            ItemNo = 1
            Bookarray[ItemNo].saveSentenceNoInit(SentenceNoInit: Int(dataList[560+4+2])!)
            
            print("Bookarray[0].filename: ", Bookarray[0].filename)
            print("Bookarray[1].filename: ", Bookarray[1].filename)
            
            for i in 1+566...410+566 {
                dataList2 = dataList[i].components(separatedBy: ",")
                
                let SentenceNo = Int(dataList2[0])! - 1
//                print("dataList2[0]:", dataList2[0])
//                print("dataList2[1]:", dataList2[1])
//                print("dataList2[2]:", dataList2[2])
                    
                Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsInt(
                    value: Int(dataList2[1])!,
                    filename: Bookarray[ItemNo].filename,
                    SentenceNo: SentenceNo,
                    key: "answercountKey")
                
                Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsInt(
                    value: Int(dataList2[2])!,
                    filename: Bookarray[ItemNo].filename,
                    SentenceNo: SentenceNo,
                    key: "answerCheckKey")
                
                Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsInt(
                    value: Int(dataList2[3])!,
                    filename: Bookarray[ItemNo].filename,
                    SentenceNo: SentenceNo,
                    key: "trycountKey")
                
                Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsString(
                    Text: dataList2[4],
                    filename: Bookarray[ItemNo].filename,
                    SentenceNo: SentenceNo,
                    key: "trydateKey")
                
            }

            //TextBook3
            ItemNo = 2
            Bookarray[ItemNo].saveSentenceNoInit(SentenceNoInit: Int(dataList[410+566+2])!)
            
            for i in 1+410+566+2...100+410+566+2 {
                dataList2 = dataList[i].components(separatedBy: ",")
                
                let SentenceNo = Int(dataList2[0])! - 1
//                print("dataList2[0]:", dataList2[0])
//                print("dataList2[1]:", dataList2[1])
//                print("dataList2[2]:", dataList2[2])
                    
                Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsInt(
                    value: Int(dataList2[1])!,
                    filename: Bookarray[ItemNo].filename,
                    SentenceNo: SentenceNo,
                    key: "answercountKey")
                
                Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsInt(
                    value: Int(dataList2[2])!,
                    filename: Bookarray[ItemNo].filename,
                    SentenceNo: SentenceNo,
                    key: "answerCheckKey")
                
                Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsInt(
                    value: Int(dataList2[3])!,
                    filename: Bookarray[ItemNo].filename,
                    SentenceNo: SentenceNo,
                    key: "trycountKey")
                
                Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsString(
                    Text: dataList2[4],
                    filename: Bookarray[ItemNo].filename,
                    SentenceNo: SentenceNo,
                    key: "trydateKey")
                
            }
            
            //TextBook4
            ItemNo = 3
            Bookarray[ItemNo].saveSentenceNoInit(SentenceNoInit: Int(dataList[100+410+566+2+2])!)
            
            for i in 1+100+410+566+2+2...22+100+410+566+2+2 {
                dataList2 = dataList[i].components(separatedBy: ",")
                
                let SentenceNo = Int(dataList2[0])! - 1
//                print("dataList2[0]:", dataList2[0])
//                print("dataList2[1]:", dataList2[1])
//                print("dataList2[2]:", dataList2[2])
                    
                Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsInt(
                    value: Int(dataList2[1])!,
                    filename: Bookarray[ItemNo].filename,
                    SentenceNo: SentenceNo,
                    key: "answercountKey")
                
                Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsInt(
                    value: Int(dataList2[2])!,
                    filename: Bookarray[ItemNo].filename,
                    SentenceNo: SentenceNo,
                    key: "answerCheckKey")
                
                Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsInt(
                    value: Int(dataList2[3])!,
                    filename: Bookarray[ItemNo].filename,
                    SentenceNo: SentenceNo,
                    key: "trycountKey")
                
                Bookarray[ItemNo].SentenceArray[SentenceNo].saveUserDefaultsString(
                    Text: dataList2[4],
                    filename: Bookarray[ItemNo].filename,
                    SentenceNo: SentenceNo,
                    key: "trydateKey")
                
            }
            
        } catch {
            print(error)
        }
        
        
        
    }
    
    //resultB.txt表示
    @IBAction func DisplayresultBtext(_ sender: Any) {
        
        if DisplayResultBflag == true {
            
            //ラベルを最前面に移動
            self.view.bringSubviewToFront(ResultBtextView)
            
            let textFileName = "resultB.txt"
            
            if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
                
                let targetTextFilePath = documentDirectoryFileURL.appendingPathComponent(textFileName)
                
                print("targetTextFilePath: ", targetTextFilePath)
                
                let urlString: String = targetTextFilePath.path
                if FileManager.default.fileExists(atPath: urlString) {
                    print("ファイルあり")
                }
                else{
                    print("ファイルなし")
                }
                
                //readTextFile
                do {
                    let text = try String(contentsOf: targetTextFilePath, encoding: String.Encoding.utf8)
                    print(text)
                    
                    ResultBtextView.text = text
                    
                } catch let error as NSError {
                    print("failed to read: \(error)")
                }
                
            }
            DisplayResultBflag = false
        }
        else{
            self.view.sendSubviewToBack(ResultBtextView)
            //ResultBtextView.text = ""
            ResultBtextView.text = getNowClockString()
            DisplayResultBflag = true
        }
        
    }
    
    @IBAction func DisplayResultCButton(_ sender: Any) {
        if DisplayResultBflag == true {
            
            //ラベルを最前面に移動
            self.view.bringSubviewToFront(ResultBtextView)
            
            let textFileName = "resultC.txt"
            
            if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
                
                let targetTextFilePath = documentDirectoryFileURL.appendingPathComponent(textFileName)
                
                print("targetTextFilePath: ", targetTextFilePath)
                
                let urlString: String = targetTextFilePath.path
                if FileManager.default.fileExists(atPath: urlString) {
                    print("ファイルあり")
                }
                else{
                    print("ファイルなし")
                }
                
                //readTextFile
                do {
                    let text = try String(contentsOf: targetTextFilePath, encoding: String.Encoding.utf8)
                    print(text)
                    
                    ResultBtextView.text = text
                    
                } catch let error as NSError {
                    print("failed to read: \(error)")
                }
                
            }
            DisplayResultBflag = false
        }
        else{
            self.view.sendSubviewToBack(ResultBtextView)
            //ResultBtextView.text = ""
            ResultBtextView.text = getNowClockString()
            DisplayResultBflag = true
        }
    }
    
    
    //ログ表示
    @IBAction func Displaylog(_ sender: Any) {
        if DisplayResultBflag == true {
            
            //ラベルを最前面に移動
            self.view.bringSubviewToFront(ResultBtextView)
            
            let textFileName = "log.txt"
            
            if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
                
                let targetTextFilePath = documentDirectoryFileURL.appendingPathComponent(textFileName)
                
                print("targetTextFilePath: ", targetTextFilePath)
                
                let urlString: String = targetTextFilePath.path
                if FileManager.default.fileExists(atPath: urlString) {
                    print("ファイルあり")
                }
                else{
                    print("ファイルなし")
                }
                
                //readTextFile
                do {
                    let text = try String(contentsOf: targetTextFilePath, encoding: String.Encoding.utf8)
                    print(text)
                    
                    ResultBtextView.text = text
                    
                } catch let error as NSError {
                    print("failed to read: \(error)")
                }
                
            }
            DisplayResultBflag = false
        }
        else{
            self.view.sendSubviewToBack(ResultBtextView)
            //ResultBtextView.text = ""
            ResultBtextView.text = getNowClockString()
            DisplayResultBflag = true
        }
    }
    
    //log.txt消去
    @IBAction func Deletelog(_ sender: Any) {
        deleteTextFile(textFileName: "log.txt")
    }
    
    
    @IBAction func SaveResultBtxtButton(_ sender: Any) {
        Bookarray[0].SaveResultBtxt(filename: "resultB1.txt")
        Bookarray[1].SaveResultBtxt(filename: "resultB2.txt")
        Bookarray[2].SaveResultBtxt(filename: "resultB3.txt")
        Bookarray[3].SaveResultBtxt(filename: "resultB4.txt")
    }
    
    @IBAction func LoadResultBtxtButton(_ sender: Any) {
        Bookarray[0].LoadResultBtxt(filename: "resultB1.txt")
        Bookarray[1].LoadResultBtxt(filename: "resultB2.txt")
        Bookarray[2].LoadResultBtxt(filename: "resultB3.txt")
    }
    
    @IBAction func Send2Button(_ sender: Any) {
        SendTextFile(filename: "resultB.txt")
        
        //連続でファイルは送信できない
        //SendTextFile(filename: "resultB1.txt")
        //SendTextFile(filename: "resultB2.txt")
        //SendTextFile(filename: "resultB3.txt")
        //SendTextFile(filename: "resultB4.txt")
    }
    
    @IBAction func EditButton(_ sender: Any) {
        //設定画面へ遷移
        performSegue(withIdentifier: "goSetting2", sender: nil)
    }
    
    
    @IBAction func Send3Button(_ sender: Any) {
        SendTextFile(filename: "log.txt")
    }
    
    @IBAction func CloseButton(_ sender: Any) {
        
        let data = "閉じるボタン押下"
        
        // handlerに関数がセットされているか確認
        if let handler = self.resultHandler {
            handler(data)
        }
        
        //画面を閉じる
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func TestButton(_ sender: Any) {
        

        //初期化
//        for i in 0...3 {
//            Bookarray[i].Allreset()
//        }
        
        //値をロードする
        //TestButton.isEnabled = false
        
        /*
         Bookarray[0].LoadResultBtxt(filename: "resultB1.txt")
         Bookarray[1].LoadResultBtxt(filename: "resultB2.txt")
         Bookarray[2].LoadResultBtxt(filename: "resultB3.txt")
         
         Bookarray[0].TodaysAnswer = 0
         Bookarray[0].SumAnswer = 472 + 27
         Bookarray[0].SentenceNoInit = 1
         Bookarray[1].TodaysAnswer = 0
         Bookarray[1].SumAnswer = 423 + 20
         Bookarray[1].SentenceNoInit = 1
         Bookarray[2].TodaysAnswer = 0
         Bookarray[2].SumAnswer = 79
         Bookarray[2].SentenceNoInit = 1
         Bookarray[3].TodaysAnswer = 0
         Bookarray[3].SumAnswer = 21
         Bookarray[3].SentenceNoInit = 0
         
         for i in 0...3 {
         Bookarray[i].saveTodaysAnswer(TodaysAnswer: Bookarray[i].TodaysAnswer)
         Bookarray[i].saveSentenceNoInit(SentenceNoInit: Bookarray[i].SentenceNoInit)
         Bookarray[i].saveSumAnswer(SumAnswer: Bookarray[i].SumAnswer)
         Bookarray[i].saveanswerCheck(answerCheck: Bookarray[i].answerCheck)
         Bookarray[i].saveanswerhistory(answerhistory: Bookarray[i].answerhistory)
         }
         */
    }
    
    func SendTextFile(filename:String){
        //ファイルを他のアプリに送る
        
        // Documentディレクトリ
        let documentDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true).last!
        
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
