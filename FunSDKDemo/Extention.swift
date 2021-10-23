//
//  Extention.swift
//  LutecCamera
//
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//

import UIKit
import Foundation
import Photos
import AVFoundation

let ScreenWidth = UIScreen.main.bounds.size.width //屏幕宽度
let ScreenHeight = UIScreen.main.bounds.size.height //屏幕高度


let iPad = UIScreen.main.bounds.size.width == 768 //iPad
let iPhone = iPhone4 || iPhone5 || iPhone6 || iPhone6Plus || iPhonex
//iPad
let iPhone6 = UIScreen.main.bounds.size.width == 375 && UIScreen.main.bounds.size.height == 667
let iPhone6Plus = UIScreen.main.bounds.size.width == 414 && UIScreen.main.bounds.size.height == 736
let iPhone5 = UIScreen.main.bounds.size.width == 320 && UIScreen.main.bounds.size.height == 568
let iPhone4 = UIScreen.main.bounds.size.width == 320 && UIScreen.main.bounds.size.height == 480
let iPhonex = UIScreen.main.bounds.size.width == 375 && UIScreen.main.bounds.height == 812

let SH = (iPhonex ? (ScreenHeight-84) * 225/603:(ScreenHeight-64) * 225/603)
let SW = ScreenWidth * 359/375

var device:Device?
var app:AppDelegate!

var mCountry = ""
var mobidver = ""
var password = ""
var mobidname = ""
var devname = ""
var mobid = ""
var mcountrycode = ""

func getcountry() -> String {
    CLLocationModule.sharedInstance().GetLatitudeLongitudeAndCity()
    let userDefaults = UserDefaults.standard
    return  userDefaults.object(forKey: "ISOcountryCode") as! String
    //return "GB"
}
func addlog(action:String,snid:String) {
    Thread.sleep(forTimeInterval: 0.02)
    CLLocationModule.sharedInstance().GetLatitudeLongitudeAndCity()
    let userDefaults = UserDefaults.standard
    let longitude = userDefaults.object(forKey: "longitude")
    let latitude = userDefaults.object(forKey: "latitude")
    let altitude = userDefaults.object(forKey: "altitude")

    let mCountry = userDefaults.object(forKey: "Country")
    app = UIApplication.shared.delegate as! AppDelegate
    let snid = snid
    let uuid =  UIDevice.current.identifierForVendor!.uuidString
    let action = action
    let mobname = UIDevice.current.name //手机名称
    let mobtype = UIDevice().modelName
    let mobver = UIDevice.current.systemVersion
    let infoDic = Bundle.main.infoDictionary
    let mobid = infoDic?["CFBundleIdentifier"]
    let mobidname = infoDic?["CFBundleDisplayName"] // 获取App的名称
    let mobidver = infoDic?["CFBundleShortVersionString"] // 获取App的build版本
    let speed = Global.getInterfaceBytes()
    let firmver = ""

    let sn = app.select.sn
    print(sn)
    let devname = app.select.name
    let password = app.select.password
    let soapMessage = "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><addsn xmlns='http://www.w3schools.com/xml/'><sn>\(String(describing: sn))</sn><snid>\(snid)</snid><uuid>\(uuid)</uuid><action>\(action)</action><devname>\(devname)</devname><mobname>\(mobname)</mobname><mobtype>\(mobtype)</mobtype><mobver>\(mobver)</mobver><mobidname>\(String(describing: mobidname))</mobidname><mobid>\(String(describing: mobid))</mobid><mobidver>\(String(describing: mobidver))</mobidver><firmver>\(firmver)</firmver><longitude>\(String(describing: longitude))</longitude><latitude>\(String(describing: latitude))</latitude><Country>\(String(describing: mCountry))</Country><password>\(password)</password><speed>\(speed)</speed><altitude>\(String(describing: altitude))</altitude></addsn></soap12:Body></soap12:Envelope>"
    
    servisRun(xml:soapMessage)
}
func servisRun(xml:String!){
    let soapMessage = xml
    let msgLength = String(describing: soapMessage?.count)
    
    let url = URL(string: "http://www.umenb.com:3211/lutec/services/MyService")!
    let request = NSMutableURLRequest(url: url)
    request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.addValue(msgLength, forHTTPHeaderField: "Content-Length")
    request.httpMethod = "POST"
    request.httpBody = soapMessage?.data(using: String.Encoding.utf8, allowLossyConversion: false)
    let session = URLSession.shared
    
    let task =  session.dataTask(with: request as URLRequest) { (data, resp, error) in
        guard error == nil && data != nil else{ // && data != nil
            print("connection error or data is nill")
            let url2 = URL(string: "http://192.168.0.2/lutec/services/MyService")!
            
            let request = NSMutableURLRequest(url: url2)
            request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addValue(msgLength, forHTTPHeaderField: "Content-Length")
            request.addValue("SOAPAction",forHTTPHeaderField:"http://192.168.0.2/lutec/services/MyService")
            request.httpMethod = "POST"
            request.httpBody = soapMessage?.data(using: String.Encoding.utf8, allowLossyConversion: false)
            let task =  session.dataTask(with: request as URLRequest) { (data, resp, error) in
                guard error == nil && data != nil else{ // && data != nil
                    return
                }
            }
            task.resume()
            return
        }
    }
    task.resume()
}


func Async(_ exec: @escaping () -> Void){
    //DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: exec)
    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: exec)

}
func Main(_ exec: @escaping () -> Void){
    DispatchQueue.main.async(execute: exec)
}

struct Constraint {
    static func changeMultiplier(_ constraint: NSLayoutConstraint, multiplier: CGFloat) -> NSLayoutConstraint {
        let newConstraint = NSLayoutConstraint(
            item: constraint.firstItem as Any,
            attribute: constraint.firstAttribute,
            relatedBy: constraint.relation,
            toItem: constraint.secondItem,
            attribute: constraint.secondAttribute,
            multiplier: multiplier,
            constant: constraint.constant)
        
        newConstraint.priority = constraint.priority
        
        NSLayoutConstraint.deactivate([constraint])
        NSLayoutConstraint.activate([newConstraint])
        
        return newConstraint
    }
}

//主题颜色
let NavColor            = Color(63,g: 67,b: 84)
let LevelMiddleColor     = Color(255,g: 133,b: 0)
let LevelCostomColor     = Color(194,g: 80,b: 255)
let LevelHighColor  = Color(255,g: 0,b: 0)
let LevelLowColor = Color(164,g: 235,b: 83)

//根据指定参数生成一个UIColor,透明度默认为1.0
func Color(_ r: Int, g: Int, b: Int) -> UIColor {
    return UIColor(red: CGFloat(r) / CGFloat(255.0), green: CGFloat(g) / CGFloat(255.0), blue: CGFloat(b) / CGFloat(255.0), alpha: 1.0)
}

extension UIColor{
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let red     = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green   = CGFloat((hex & 0x00FF00) >> 8 ) / 255.0
        let blue    = CGFloat((hex & 0x0000FF)      ) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
let letter = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
//let letterdistance = ["a","j","k","l","m","n","o","p","q","r","s","t","u","v","w"]
let letterdistance = ["a","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y"]
extension String{
    //0~25
    var letter26:Float{
        if let index = letter.index(of: self){
            return Float(index)
        }else{
            return 0
        }
    }
    //0~16
    var letter17:Float{
        if let index = letterdistance.index(of: self){
            return Float(index)
        }else{
            return 0
        }
    }
    func matching(_ regex:String)  -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let results = regex.matches(in: self,
                options: [], range: NSMakeRange(0, self.count))
            return !results.isEmpty
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return false
        }
    }
}



typealias Task = (_ cancel : Bool) -> ()
func delay(_ time:TimeInterval, task:@escaping ()->()) ->  Task? {
    func dispatch_later(_ block:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: block)
    }
    var closure: (()->())? = task
    var result: Task?
    let delayedClosure: Task = {
        cancel in
        let internalClosure = closure
            if (cancel == false) {
                DispatchQueue.main.async(execute: internalClosure!);
            }
        
        closure = nil
        result = nil
    }
    result = delayedClosure
    dispatch_later {
        if let delayedClosure = result {
            delayedClosure(false)
        }
    }
    return result;
}

open class AppInfoModel : NSObject {
    var version : AnyObject? /** 版本号*/
    var bundleId : AnyObject? /** bundleId*/
    var currentVersionReleaseDate : AnyObject? /** 当前版本更新时间*/
    var appDescription : AnyObject? /** APP简介*/
    var releaseNotes : AnyObject? /** 更新日志*/
    var trackId : AnyObject? /** APPId*/
    var trackViewUrl : AnyObject? /** AppStore地址*/
    var fileSizeBytes : AnyObject? /** App文件大小*/
    var sellerName : AnyObject? /** 开发商*/
    var screenshotUrls : [AnyObject]? /** 展示图*/
    
    public init(dic:[String:AnyObject]) {
        super.init()
        
        self.version = dic["version"]
        self.releaseNotes = dic["releaseNotes"]
        self.currentVersionReleaseDate = dic["currentVersionReleaseDate"]
        self.trackId = dic["trackId"]
        self.bundleId = dic["bundleId"]
        self.trackViewUrl = dic["trackViewUrl"]
        self.appDescription = dic["appDescription"]
        self.sellerName = dic["sellerName"]
        self.fileSizeBytes = dic["fileSizeBytes"]
        self.screenshotUrls = dic["screenshotUrls"] as! [AnyObject]?
    }
}

//        let str = "尊敬的顾客，您有1000积分即将过期，请尽快使用"
//        let attributeStr = changeTextChange(regex: "\\d+", text: str, color: UIColor.red)
//        let alertController = UIAlertController(title: "积分即将过期提醒",
//                                                message: attributeStr.string, preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "兑换菜品", style: .cancel, handler: nil)
//        let okAction = UIAlertAction(title: "暂不兑换", style: .default, handler: {
//            action in
//            print("点击了确定")
//        })
//        alertController.addAction(cancelAction)
//        alertController.addAction(okAction)
//        self.present(alertController, animated: true, completion: nil)


//根据正则表达式改变文字颜色

func changeTextChange(regex: String, text: String, color: UIColor) -> NSMutableAttributedString {
    
    let attributeString = NSMutableAttributedString(string: text)
    
    do {
        
        let regexExpression = try NSRegularExpression(pattern: regex, options: NSRegularExpression.Options())
        
        let result = regexExpression.matches(in: text, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, text.count))
        
        for item in result {
            
            attributeString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: item.range)
            
        }
        
    } catch {
        
        print("Failed with error: \(error)")
        
    }
    
    return attributeString
    
}
class Toast {
    fileprivate var msg: String
    fileprivate var time: TimeInterval!
    fileprivate var view: UIView!
    fileprivate var typeError = false
    
    class func make(context : UIViewController,msg: String,time:TimeInterval = 2) -> Toast{
        return Toast(v: context.view, m: msg, t: time)
    }
    class func make(context: UIView,msg: String,time:TimeInterval = 2) -> Toast {
        return Toast(v: context, m: msg, t: time)
    }
    class func makeError(context: UIView,msg: String,time:TimeInterval = 2) -> Toast {
        return Toast(v: context, m: msg, t: time,typeError: true)
    }
    fileprivate init(v: UIView,m: String,t:TimeInterval,typeError: Bool = false){
        view = v
        time = t
        msg = m
        self.typeError = typeError
    }
    func show(){
        let alert = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        alert.font = UIFont.systemFont(ofSize: 18)
        alert.text = msg
        alert.textColor = UIColor.white
        alert.sizeToFit()
        
        let frame = UIView(frame: CGRect(x: 0, y: 0, width: alert.bounds.width + 80, height: alert.bounds.height + 40))
        frame.backgroundColor = UIColor(hex: 0x000000, alpha: 0.6)
        frame.layer.cornerRadius = 6
        alert.center = frame.center
        frame.addSubview(alert)
        frame.center = view.center
        frame.alpha = 0
        view.addSubview(frame)
        UIView.animate(withDuration: 0.3, animations: {
            frame.alpha = 1.0
        })
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(self.time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)){
//            UIView.animate(withDuration: 0.3, animations: { a in
//                    frame.alpha = 0
//                }, completion: { b in
//                    frame.removeFromSuperview()
//            })
//
//        }
    }
}

