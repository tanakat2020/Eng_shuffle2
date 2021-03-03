import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration

    // Define whether the app can provide future data.
    func getSupportedTimeTravelDirections(for complication: CLKComplication,
                                          withHandler handler:@escaping (CLKComplicationTimeTravelDirections) -> Void) {
        // Indicate that the app can provide future timeline entries.
        handler([.forward])
    }
    
    // Define how far into the future the app can provide data.
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Indicate that the app can provide timeline entries for the next 24 hours.
        handler(Date().addingTimeInterval(24.0 * 60.0 * 60.0))
    }
    
    // Define whether the complication is visible when the watch is unlocked.
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // This is potentially sensitive data. Hide it on the lock screen.
        handler(.hideOnLockScreen)
    }
    
    // Return the current timeline entry.
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        print("log0210 getCurrentTimelineEntry")
        handler(createTimelineEntry(forComplication: complication, date: Date()))
    }
    
    // Return future timeline entries.
    func getTimelineEntries(for complication: CLKComplication,
                            after date: Date,
                            limit: Int,
                            withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        
//        handler(nil)
        
        let fiveMinutes = 5.0 * 60.0
        let twentyFourHours = 24.0 * 60.0 * 60.0
        
        // Create an array to hold the timeline entries.
        var entries = [CLKComplicationTimelineEntry]()
        
        // Calculate the start and end dates.
        var current = date.addingTimeInterval(fiveMinutes)
        let endDate = date.addingTimeInterval(twentyFourHours)
        
        
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy-MM-dd HH:mm:ss"

//        print(current)
//        print(endDate)
        
        print("date    : " + dateFormater.string(from: date))
        print("current : " + dateFormater.string(from: current))
        print("endDate : " + dateFormater.string(from: endDate))
        print("limit:    " + String(limit))
        
        // Create a timeline entry for every five minutes from the starting time.
        // Stop once you reach the limit or the end date.
        
//        var count = 0
        
        while (current.compare(endDate) == .orderedAscending) && (entries.count < limit) {
            entries.append(createTimelineEntry(forComplication: complication, date: current))
            //entries.append(createTimelineEntry(for: complication, date: current))
            current = current.addingTimeInterval(fiveMinutes)
            
//            print("count: " + String(count))
//            print("current2: " + dateFormater.string(from: current))
//            count = count + 1
        }
        
//        print("current2: " + dateFormater.string(from: current))
        current = date.addingTimeInterval(0)
//        print("current3: " + dateFormater.string(from: current))
        handler(entries)
    }
    
    //https://qiita.com/MilanistaDev/items/a2325ce916f625aa1d44
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        
        print("getComplicationDescriptors")
        
        let mySupportedFamilies = CLKComplicationFamily.allCases

            // Create the condition descriptor.
            let conditionDescriptor = CLKComplicationDescriptor(
                identifier: "complication_Identifier",
                displayName: "ENS-status",
                supportedFamilies: mySupportedFamilies)

        // Call the handler and pass an array of descriptors.
        handler([conditionDescriptor])
    }
    

    
    private func createTimelineEntry(forComplication complication: CLKComplication, date: Date) -> CLKComplicationTimelineEntry {
        
        
 //       let userDefaults = UserDefaults.standard
        
        //        if let messageA = userDefaults.string(forKey: "message3") {
//            //print("createTimelineEntry messageA: " + messageA)
//        }
//        else{
//            print("createTimelineEntry No messageA")
//        }
  
        
        let template = getComplicationTemplate(forComplication: complication, date: date)
        
        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        
//        if let template = getComplicationTemplate(for: complication, date: date) {
//            print("log0210 getCurrentTimelineEntry")
//            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
//            handler(entry)
//        } else {
//            handler(nil)
//        }
        
        
        // Get the correct template based on the complication.
//        let template = createTemplate(forComplication: complication, date: date)
        
        // Use the template and date to create a timeline entry.
//        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
    }
    
    func getComplicationTemplate(forComplication complication: CLKComplication, date: Date) -> CLKComplicationTemplate {
        switch complication.family {
        case .graphicCircular:
//            print("graphicCircular")
            return createGraphicCircleTemplate(forDate: date)
        case .graphicRectangular:
//            return CLKComplicationTemplateGraphicRectangularFullView(ContentView())
//            print("graphicRectangular")
            return createGraphicRectangularTemplate(forDate: date)
        case .modularSmall:
            return createModularSmallTemplate(forDate: date)
        case .modularLarge:
            return createModularLargeTemplate(forDate: date)
        case .utilitarianSmall:
            return createutilitarianSmallTemplate(forDate: date)
        case .utilitarianSmallFlat:
            return createutilitarianSmallTemplate(forDate: date)
        case .utilitarianLarge:
            return createutilitarianLargeTemplate(forDate: date)
        case .circularSmall:
            return createcircularSmallTemplate(forDate: date)
        case .extraLarge:
            return createextraLargeTemplate(forDate: date)
        case .graphicCorner:
            return creategraphicCornerTemplate(forDate: date)
        case .graphicBezel:
            return creategraphicBezelTemplate(forDate: date)
        case .graphicExtraLarge:
            return createGraphicExtraLargeTemplate(forDate: date)
        @unknown default:
            fatalError("*** Unknown Complication Family ***")
        }
    }
    
    //設定する時のプレ画面
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {

        let future = Date().addingTimeInterval(25.0 * 60.0 * 60.0)
        let template = getComplicationTemplate(forComplication: complication, date: future)
        handler(template)
    }
    
    private func creategraphicBezelTemplate(forDate date: Date) -> CLKComplicationTemplate {
        // Create the template using the providers.
        let circularTemplate = CLKComplicationTemplateGraphicCircularStackText(line1TextProvider: CLKSimpleTextProvider(text: "0.491"), line2TextProvider: CLKSimpleTextProvider(text: "0.491"))
        let template = CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: circularTemplate)
        return template
    }
    
    private func creategraphicCornerTemplate(forDate date: Date) -> CLKComplicationTemplate {
        // Create the template using the providers.
        let gaugeColor = UIColor(red: 0.0, green: 167.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        let template = CLKComplicationTemplateGraphicCornerGaugeText(gaugeProvider: CLKSimpleGaugeProvider(style: .fill,
                                                                                                           gaugeColor: gaugeColor,
                                                                                                           fillFraction: 0), outerTextProvider: CLKSimpleTextProvider(text: "0.491"))
        return template
    }
    
    
    private func createextraLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
        // Create the template using the providers.
        let template = CLKComplicationTemplateExtraLargeColumnsText(row1Column1TextProvider: CLKSimpleTextProvider(text: "11"), row1Column2TextProvider: CLKSimpleTextProvider(text: "11"), row2Column1TextProvider: CLKSimpleTextProvider(text: "11"), row2Column2TextProvider: CLKSimpleTextProvider(text: "11"))
        template.column2Alignment = .leading
        template.highlightColumn2 = false
        return template
    }

    private func createcircularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
        // Create the template using the providers.
        let template = CLKComplicationTemplateCircularSmallSimpleText(textProvider: CLKSimpleTextProvider(text: "001"))
        return template
    }
    
    private func createutilitarianLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
        // Create the template using the providers.
        let template = CLKComplicationTemplateUtilitarianLargeFlat(textProvider: CLKSimpleTextProvider(text: "001"))
        return template
    }
    
    private func createutilitarianSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
        // Create the template using the providers.
        let template = CLKComplicationTemplateUtilitarianSmallFlat(textProvider: CLKSimpleTextProvider(text: "001"))
        return template
    }
    
    private func createModularLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
        // Create the template using the providers.
       let template = CLKComplicationTemplateModularLargeTable(headerTextProvider: CLKSimpleTextProvider(text: "001"), row1Column1TextProvider: CLKSimpleTextProvider(text: "001"), row1Column2TextProvider: CLKSimpleTextProvider(text: "001"), row2Column1TextProvider: CLKSimpleTextProvider(text: "001"), row2Column2TextProvider: CLKSimpleTextProvider(text: "001"))
        return template
    }
    
    // Return a modular small template.
    private func createModularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
        // Create the data providers.
//        let mgCaffeineProvider = CLKSimpleTextProvider(text: "0.491")
//        let mgUnitProvider = CLKSimpleTextProvider(text: "mg Caffeine", shortText: "mg")
//
        // Create the template using the providers.
        //let template = CLKComplicationTemplateModularSmallStackText()
//        template.line1TextProvider = mgCaffeineProvider
//        template.line2TextProvider = mgUnitProvider

        let template = CLKComplicationTemplateModularSmallSimpleText(textProvider: CLKSimpleTextProvider(text: "001") )
        return template
    }
    
    
    
    // Return a graphic circle template.
    private func createGraphicCircleTemplate(forDate date: Date) -> CLKComplicationTemplate {
        // Create the data providers.
        let userDefaults = UserDefaults.standard
        //削除処理
        //UserDefaults.standard.removeObject(forKey: "olddate_value")
        userDefaults.register(defaults: ["olddate_value" : "2021-02-16"])
        
        //if (false) {
        //if let messageA = userDefaults.string(forKey: "message3") {
        if let messageA = userDefaults.string(forKey: "message3") {
//            print("createGraphicCircleTemplate messageA: " + messageA)

            
 
//            if dataList.count == 3 {
//                let textString = "Eng_shu: " + dataList[2]
//                //          print("textString: ", textString)
//                textTemplate.headerTextProvider = CLKSimpleTextProvider(text: textString )
//            }
//            else if dataList.count == 5 {
//                let textString = "Eng_shu: " + dataList[4]
//                //          print("textString: ", textString)
//                textTemplate.headerTextProvider = CLKSimpleTextProvider(text: textString )
//            }
//            else{
//                textTemplate.headerTextProvider = CLKSimpleTextProvider(text: "Eng_shu")
//            }
            
            
            //改行区切りでデータを分割して配列に格納する。
            var dataList:[String] = []
            dataList = messageA.components(separatedBy: "\n")
//            print("log0200 ComplicationController.swift dataList.count: " + String(dataList.count))
            
            // Infograph Modular, Infographのみ
            // circularTemplateの実装
            // gaugeProvider, centerTextProvider が必要
            
            //"-"区切りでデータを分割して配列に格納する。
            var dataList2:[String] = []
            if dataList.count == 5 {
                dataList2 = dataList[4].components(separatedBy: "-")
//                print("dataList2: ", dataList2[0], "   dataList2[1]: ", dataList2[1])
            }
            else{
                dataList2.append("")
                dataList2.append("")
                dataList2[0] = "000"
                dataList2[1] = "0"
//                print("dataList2: ")
//                print(dataList2)
            }

            // centerTextProviderの実装
            //                let centerText = CLKSimpleTextProvider(text: dataList[4])
            let centerText = CLKSimpleTextProvider(text: dataList2[0])
            centerText.tintColor = .white

            let bottomText = CLKSimpleTextProvider(text: "Ens")
            bottomText.tintColor = .white

            //dataList[4] = "999"
            var value:Int = Int(dataList2[1])!

            if value > 20 {
                value = 20
            }

            if dataList2[1] == "999" {
                value = 0
            }

//            var currentdate = ""
//            currentdate = getNowClockString()
//            //currentdate = "2021-03-01"
//            let olddate = userDefaults.string(forKey: "olddate_value")!
//            //TodaysAnswerDate = "2017-06-25"
//            print("currentdate: ", currentdate, "   olddate: ", olddate)
//
//            //UserDefaultsがうまく動いていない？ 20210216
//            if currentdate != olddate {
//                userDefaults.set(currentdate, forKey: "olddate_value")
//                //userDefaults.set(olddate, forKey: "olddate_value")
//                //同期
//                userDefaults.synchronize()
//                value = 0
//            }

            let value_f:Float = Float(Float(value)/20)
//            print("value: ", value, "   value_f: ", value_f)
            // gaugeProviderの実装
            //      let gaugeColor = UIColor(red: 255/255, green: 122/255.0, blue: 50/255.0, alpha: 1.0)
            let gaugeColor = UIColor(red: 0.0, green: 167.0/255.0, blue: 219.0/255.0, alpha: 1.0)
            let gaugeProvider =
                CLKSimpleGaugeProvider(style: .fill,
                                       gaugeColor: gaugeColor,
                                       fillFraction: value_f)

            let circularClosedGaugeTemplate = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText(gaugeProvider: gaugeProvider, bottomTextProvider: bottomText, centerTextProvider: centerText)
            return circularClosedGaugeTemplate


        }
        else{
            print("No messageA 1")
            
            // centerTextProviderの実装
            //                let centerText = CLKSimpleTextProvider(text: dataList[4])
            let centerText = CLKSimpleTextProvider(text: "000")
            centerText.tintColor = .white
            
            let bottomText = CLKSimpleTextProvider(text: "Ens")
            bottomText.tintColor = .white
            
            let value_f:Float = 0

            // gaugeProviderの実装
            //      let gaugeColor = UIColor(red: 255/255, green: 122/255.0, blue: 50/255.0, alpha: 1.0)
            let gaugeColor = UIColor(red: 0.0, green: 167.0/255.0, blue: 219.0/255.0, alpha: 1.0)
            let gaugeProvider =
                CLKSimpleGaugeProvider(style: .fill,
                                       gaugeColor: gaugeColor,
                                       fillFraction: value_f)
            
            let circularClosedGaugeTemplate = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText(gaugeProvider: gaugeProvider, bottomTextProvider: bottomText, centerTextProvider: centerText)
            return circularClosedGaugeTemplate
            
            
            
            //Coffee BreakのComplication
            //                // Create the data providers.
            //            let percentage = Float(0.0)
            //
            //                let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
            //                                                           gaugeColors: [.green, .yellow, .red],
            //                                                           gaugeColorLocations: [0.0, 300.0 / 500.0, 450.0 / 500.0] as [NSNumber],
            //                                                           fillFraction: percentage)
            //
            //                let mgCaffeineProvider = CLKSimpleTextProvider(text: "test")
            //                let mgUnitProvider = CLKSimpleTextProvider(text: "mg Caffeine", shortText: "mg")
            //        //        mgUnitProvider.tintColor = data.color(forCaffeineDose: data.mgCaffeine(atDate: date))
            //                mgUnitProvider.tintColor = .red
            //
            //                // Create the template using the providers.
            //                let template = CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText(gaugeProvider: gaugeProvider, bottomTextProvider: CLKSimpleTextProvider(text: "mg"), centerTextProvider: mgCaffeineProvider)
            //                return template
            
        }
        
    }

    
    // Return a large rectangular graphic template.
    private func createGraphicRectangularTemplate(forDate date: Date) -> CLKComplicationTemplate {
        

                    let userDefaults = UserDefaults.standard

                    //    if let messageA = userDefaults.object(forKey: "message3") as? String {
                    if let messageA = userDefaults.string(forKey: "message3") {
                        print("createGraphicRectangularTemplate messageA: " + messageA)

                        //改行区切りでデータを分割して配列に格納する。
                        var dataList:[String] = []
                        dataList = messageA.components(separatedBy: "\n")
                        //        dataList.removeLast()

                        //        for i in 0...dataList.count - 1 {
                        //          print("dataList: " + dataList[i] )
                        //        }
                        //        print("dataList.count: " + String(dataList.count))

                        var textString = ""
                        var textString2 = ""
                        if dataList.count == 3 {
                            textString = "Eng_shu: " + dataList[2]
                            //          print("textString: ", textString)
                        }
                        else if dataList.count == 5 {
                            textString = "Eng_shu: " + dataList[4]
                            //          print("textString: ", textString)
                            textString2 = dataList[2]
                        }
                        else{
                            textString = "Eng_shu"
                        }

                        let textTemplate = CLKComplicationTemplateGraphicRectangularStandardBody(headerTextProvider: CLKSimpleTextProvider(text: textString ), body1TextProvider: CLKSimpleTextProvider(text: dataList[0] ), body2TextProvider: CLKSimpleTextProvider(text: textString2 ))
                        return textTemplate
                    }
                   else{
                    print("No messageA 2")
                    
                    let textString = "Eng_shu:000-00"
                    let textString2 = "test"
                    let textString3 = "test"
                    
                    let textTemplate = CLKComplicationTemplateGraphicRectangularStandardBody(headerTextProvider: CLKSimpleTextProvider(text: textString ), body1TextProvider: CLKSimpleTextProvider(text: textString2 ), body2TextProvider: CLKSimpleTextProvider(text: textString3 ))
                    return textTemplate
                    
                      //Coffee Breask用Complication
//                    // Create the data providers.
//                    //let imageProvider = CLKFullColorImageProvider(fullColorImage: #imageLiteral(resourceName: "CoffeeGraphicRectangular"))
//                    let titleTextProvider = CLKSimpleTextProvider(text: "Coffee Tracker", shortText: "Coffee")
//
//                    let mgCaffeineProvider = CLKSimpleTextProvider(text: "0.491")
//                    let mgUnitProvider = CLKSimpleTextProvider(text: "mg Caffeine", shortText: "mg")
//                    //mgUnitProvider.tintColor = data.color(forCaffeineDose: data.mgCaffeine(atDate: date))
//                    //                                if #available(watchOSApplicationExtension 6.0, *) {
//                    //                                    _ = CLKTextProvider(format: "%@ %@", mgCaffeineProvider, mgUnitProvider)
//                    //                                } else {
//                    //                                    // Fallback on earlier versions
//                    //                                }
//                    _ = CLKTextProvider(format: "%@ %@", mgCaffeineProvider, mgUnitProvider)
//
//                    let percentage = Float(min(0.491 / 500.0, 1.0))
//                    let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
//                                                               gaugeColors: [.green, .yellow, .red],
//                                                               gaugeColorLocations: [0.0, 300.0 / 500.0, 450.0 / 500.0] as [NSNumber],
//                                                               fillFraction: percentage)
//
//                    // Create the template using the providers.
//                    let template = CLKComplicationTemplateGraphicRectangularTextGauge(headerTextProvider: titleTextProvider, body1TextProvider: CLKSimpleTextProvider(text: "test"), gaugeProvider: gaugeProvider)
//                    return template
                  }
    }
    
    // Returns an extra large graphic template
    @available(watchOSApplicationExtension 7.0, *)
    private func createGraphicExtraLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
        
        // Create the data providers.
        let percentage = Float(signOf: 0.491 / 500.0, magnitudeOf: 1.0)
        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
                                                   gaugeColors: [.green, .yellow, .red],
                                                   gaugeColorLocations: [0.0, 300.0 / 500.0, 450.0 / 500.0] as [NSNumber],
                                                   fillFraction: percentage)
        
        let mgCaffeineProvider = CLKSimpleTextProvider(text: "0.491")
        
        return CLKComplicationTemplateGraphicExtraLargeCircularOpenGaugeSimpleText(
            gaugeProvider: gaugeProvider,
            bottomTextProvider: CLKSimpleTextProvider(text: "mg"),
            centerTextProvider: mgCaffeineProvider)
    }
    
//    //現在時刻の取得
//    func getNowClockString() -> String {
//        let formatter = DateFormatter()
//        //formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
//        formatter.dateFormat = "yyyy-MM-dd"
//        let now = Date()
//        return formatter.string(from: now)
//    }
    
}
