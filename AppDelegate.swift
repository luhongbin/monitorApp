//  AppDelegate.swift
//  LutecCamera
//
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
import IQKeyboardManagerSwift
import UIKit
import SwiftyJSON
import UserNotifications
import MBProgressHUD

let DATA_KEY = "DEVICES"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var main:MainController!
    var navigation:UINavigationController!
    var select: Device!
//  luhongbin 2017.06.25
    var application: UIApplication!
    var OrangeView: UIView!
    var devices:[Device]!{
        didSet{
           onDeviceChange()
        }
    }
    
    func onDeviceChange(){
        Thread.sleep(forTimeInterval: 0.02)
        UserDefaults.standard.set(JSON(devices.map({$0.json})).description, forKey: DATA_KEY)
        print(JSON(devices.map({$0.json})).description )
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Thread.sleep(forTimeInterval: 1.5) //延长3秒
        if let json = UserDefaults.standard.string(forKey: DATA_KEY){
            do {
                devices = try JSON(data: (json as NSString).data(using: String.Encoding.utf8.rawValue)!).arrayValue.map({Device(json: $0)})
            } catch {}
        }else{
            devices = [Device]()
        }
        //self.application = application
        Thread.sleep(forTimeInterval: 0.02)
        let _ = (SDK.sharedSDK() as AnyObject).initSDK()
        UIApplication.shared.isStatusBarHidden = false
        self.window = UIWindow(frame: UIScreen.main.bounds)

        main = MainController(nibName: "MainController",bundle: nil)

        navigation = UINavigationController(rootViewController: main)
        
        navigation.navigationBar.barTintColor = .black
        //UIColor(hex: 0x3F4453)
        //navigation.navigationBar.barTintColor = UIColor(hex: 0xF07800)
        //navigation.navigationBar.setBackgroundImage(UIImage(named: "navigation"), for: .default)
        navigation.navigationBar.titleTextAttributes =  [NSAttributedStringKey.foregroundColor: UIColor(hex: 0xF07800)]
        navigation.navigationBar.tintColor = UIColor(hex: 0xF07800)
        navigation.navigationBar.isTranslucent = false
        self.window?.rootViewController = navigation
        self.window?.makeKeyAndVisible()
        let infoDictionary = Bundle.main.infoDictionary // 得到当前应用的版本号
        let currentAppVersion = infoDictionary!["CFBundleShortVersionString"] as! String
        let userDefaults = UserDefaults.standard// 取出之前保存的版本号
        let appVersion = userDefaults.string(forKey: "appVersion")
        
        // 如果 appVersion 为 nil 说明是第一次启动；如果 appVersion 不等于 currentAppVersion 说明是更新了
        if appVersion == nil || appVersion != currentAppVersion {
            userDefaults.setValue(currentAppVersion, forKey: "appVersion")// 保存最新的版本号
            let guideViewController = GuideViewController(nibName: "GuideViewController",bundle: nil)
            main.navigationController?.pushViewController(guideViewController, animated: false)
        }else{
            main.navigationController?.pushViewController(ProcessViewController(nibName: "ProcessViewController",bundle: nil), animated: false)
        }
        UserDefaults.standard.setValue("c", forKey: "连灯状态")
        UserDefaults.standard.setValue("0", forKey: "报警等级")
        UserDefaults.standard.setValue("z", forKey: "报警方式")
        userDefaults.synchronize()

        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: UNAuthorizationOptions(rawValue : UNAuthorizationOptions.alert.rawValue | UNAuthorizationOptions.badge.rawValue | UNAuthorizationOptions.sound.rawValue)){ (granted: Bool, error:Error?) in
                if granted {
                    print("干的漂亮success")
                }
            }
            UIApplication.shared.registerForRemoteNotifications()
            //            center.delegate = self
        }else if #available(iOS 8.0, *) {
            // 请求授权
            let type = UIUserNotificationType.alert.rawValue | UIUserNotificationType.badge.rawValue | UIUserNotificationType.sound.rawValue
            let set = UIUserNotificationSettings(types: UIUserNotificationType(rawValue: type), categories: nil)
            UIApplication.shared.registerUserNotificationSettings(set)
            // 需要通过设备UDID, 和app bundle id, 发送请求, 获取deviceToken
            UIApplication.shared.registerForRemoteNotifications()
        }else {
            let type = UIRemoteNotificationType(rawValue: UIRemoteNotificationType.alert.rawValue | UIRemoteNotificationType.sound.rawValue | UIRemoteNotificationType.badge.rawValue)
            UIApplication.shared.registerForRemoteNotifications(matching: type)
        }

        UIApplication.shared.statusBarStyle = .lightContent
        UIApplication.shared.applicationIconBadgeNumber = 0
        if let options = launchOptions {
           print("alarmmessage1\(options)")
        
           if let userInfo = options[UIApplicationLaunchOptionsKey.remoteNotification] as?  [AnyHashable: Any] {
              let aps = userInfo["aps"] as! [NSString : NSString]
              _ = aps["alert"]! as NSString
              let uuid = userInfo["UUID"] as! String
              print("alarmmessage\(uuid)")
        
              if devices.map({$0.sn}).contains(uuid){
              }else{
              devices.append(Device(sn: uuid))
              onDeviceChange()
              }
              main.willScroll(uuid)
           }
        }

        IQKeyboardManager.sharedManager().enable = true
        return true
    }
    
     func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        let aps = userInfo["aps"] as! [NSString : NSString]
        let message = aps["alert"]! as NSString
        let uuid = userInfo["UUID"] as! String
        let alert = UIAlertController(title: "", message: message as String , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default, handler: { void in
            
        }))
        if !devices.map({$0.sn}).contains(uuid) {
            devices.append(Device(sn: uuid))
            onDeviceChange()
        }
        main.present(alert, animated: true, completion: nil)
    }
// 当请求完毕之后, 会调用这个方法, 把获取到的deviceToken 返回给我们
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var device_token = NSString(format: "%@", deviceToken as CVarArg)
        device_token = device_token.replacingOccurrences(of: " ", with: "") as NSString
        device_token = device_token.replacingOccurrences(of: "<", with: "") as NSString
        device_token = device_token.replacingOccurrences(of: ">", with: "") as NSString
        print("token:")
        print(device_token)
        Thread.sleep(forTimeInterval: 0.02)
        (SDK.sharedSDK() as AnyObject).initMC(device_token as String)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {//完全退出App也会调用这个方法
        let aps = userInfo["aps"] as! [NSString : NSString]
        let message = aps["alert"]! as NSString
        let uuid = userInfo["UUID"] as! String
        let alert = UIAlertController(title: "", message: message as String , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default, handler: { void in
            
        }))
        if !devices.map({$0.sn}).contains(uuid) {
            devices.append(Device(sn: uuid))
            onDeviceChange()
        }
        main.present(alert, animated: true, completion: nil)
        completionHandler(.newData)
    }
        func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
            print(error)
            print( "didFailToRegisterForRemoteNotificationsWithError错了")
    
        }

    func applicationWillTerminate(_ application: UIApplication) {
        Thread.sleep(forTimeInterval: 0.02)
        let _ = (SDK.sharedSDK() as AnyObject).unInit()

    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.application = application
        application.beginBackgroundTask(expirationHandler:)
        //exit(0) //直接退出后台，但是推送通知需要
    }
}
