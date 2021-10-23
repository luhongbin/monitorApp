//
//  MyLocation.swift
//  FunSDKDemo
//
//  Created by lhb on 2017/9/22.
//  Copyright © 2017年 lutec. All rights reserved.
//
import UIKit
import CoreLocation

class CLLocationModule: NSObject ,CLLocationManagerDelegate{
    private static let aSharedInstance: CLLocationModule = CLLocationModule() //单例
    private override init() {}
    class func sharedInstance() -> CLLocationModule {
        return aSharedInstance
    }
    var locManager: CLLocationManager!
    
    func GetLatitudeLongitudeAndCity(){
        if CLLocationManager.locationServicesEnabled() == false {
            print("此设备不能定位")
            return
        }
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        //locManager.distanceFilter = 1000.0
        locManager.requestWhenInUseAuthorization()// 前台定位 locManager.requestAlwaysAuthorization()
        locManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("得到数据")
        if let currLocation = locations.last { //获取最新的坐标
            let mlongitude = currLocation.coordinate.longitude
            let mlatitude = currLocation.coordinate.latitude //获取纬度
            let maltitude = currLocation.altitude
            print(mlongitude, mlatitude,maltitude)
            let geoCoder:CLGeocoder = CLGeocoder.init() // [S] 反编码以便获取其他信息
            geoCoder.reverseGeocodeLocation(locations.last!, completionHandler: {(placemarks,error) in
                if placemarks == nil{ // 如果断网或者定位失败
                    print("抱歉，获取不到您的位置")
                    return
                }
                let placeMark:CLPlacemark = placemarks![0];
                let mCountry = (placeMark.addressDictionary?["Country"] as? String)!; //国家
                print(mCountry)
                //let mISOcountryCode = (placeMark.addressDictionary?["isoCountryCode"] as? String)!; //国家代码
                let mISOcountryCode:String? =  placeMark.isoCountryCode
                print(mISOcountryCode ?? "")

                let userDefaults = UserDefaults.standard
                userDefaults.set(mlongitude, forKey: "longitude")
                userDefaults.set(mlatitude, forKey: "latitude")
                userDefaults.set(maltitude, forKey: "altitude")
                userDefaults.set(mCountry, forKey: "Country")
                userDefaults.set(mISOcountryCode, forKey: "ISOcountryCode")
                userDefaults.synchronize()
            });
        }
        manager.stopUpdatingLocation()
    }
    private func locationManager(manager:CLLocationManager, didFailWithError error:NSError) {
        print("locationManager error");
    }
}
//
//import Foundation
//import UIKit
//import CoreLocation
//
//class MyLocation:CLLocationManager, CLLocationManagerDelegate {
//
//    private var successBlock: ((_ address: String) -> Void)?
//    private var failBlock: ((_ error: String) -> Void)?
//    public var locManager: CLLocationManager!
//    override init() {
//        super.init()
//        locManager = CLLocationManager()
//        locManager.delegate = self //设置定位服务管理器代理
//        locManager.desiredAccuracy = kCLLocationAccuracyBest //设置定位精度
//    }
//    convenience init(getLocation success: @escaping (_ address: String) -> Void, failed: @escaping (_ error: String) -> Void) {
//        self.init()
//        self.getLocation(success: success, failed: failed)
//    }
//
//    func getLocation(success: @escaping (_ address: String) -> Void, failed: @escaping (_ error: String) -> Void) {
//        self.successBlock = success
//        self.failBlock = failed
//
//        //self.requestWhenInUseAuthorization()
////        if CLLocationManager.authorizationStatus() == .notDetermined {
//            self.requestWhenInUseAuthorization() //requestAlwaysAuthorization()//
////        }else{
////            print("ok")
////        }
//        if (CLLocationManager.locationServicesEnabled()) {
//            locManager.distanceFilter = 10
//            locManager.startUpdatingLocation() //允许使用定位服务的话，开启定位服务更新
//            print("定位开始")
//        } else {
//            print("此设备不能定位")
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("得到数据")
//        if let currLocation = locations.last { //获取最新的坐标
//            self.stopUpdatingLocation()
//
//            let mlongitude = currLocation.coordinate.longitude
//            let mlatitude = currLocation.coordinate.latitude //获取纬度
//            let maltitude = currLocation.altitude
//            print(mlongitude, mlatitude,maltitude)
//            let geoCoder:CLGeocoder = CLGeocoder.init() // [S] 反编码以便获取其他信息
//            geoCoder.reverseGeocodeLocation(locations.last!, completionHandler: {(placemarks,error) in
//                if placemarks == nil{ // 如果断网或者定位失败
//                    print("抱歉，获取不到您的位置")
//                    return
//                }
//                let placeMark:CLPlacemark = placemarks![0];
//                mCountry = (placeMark.addressDictionary?["Country"] as? String)!; //国家
//                print(mCountry)
//            });
//
////            let geocoder = CLGeocoder.init()
////            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
////
////                if let name = placemarks?.first?.name {
////                    self.successBlock?(name)
////                } else {
////                    self.failBlock?("抱歉，获取不到您的位置")
////                }
////
////            }
//        }
//    }
//    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus){
//
//        switch(status){
//
//        case CLAuthorizationStatus.notDetermined :
//
//            print("当前状态是:NotDetermined")
//
//            // 检测是否有requestAlwaysAuthorization 这个方法 如果有则执行
//
////            if (locManager.respondsToSelector("requestAlwaysAuthorization")){
////
////                print("有requestAlwaysAuthorization方法即将执行该方法...")
////
////                locManager.requestAlwaysAuthorization()
////
////                locManager.requestWhenInUseAuthorization()
////
////
////
////            }else{
////
//                print("没有requestAlwaysAuthorization方法")
//
////            }
//
//        default:
//
//            break
//
//        }
//    }
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        self.stopUpdatingLocation()
//        var str = "未知错误"
//        switch (error as NSError).code {
//        case 0:
//            str = "位置不可用"
//            break
//        case 1:
//            str = "用户关闭"
//            break
//        default: break
//        }
//        print(str)
//        self.failBlock?(str)
//    }
//}
//
////import CoreLocation
////
////public var mlongitude :Double?
////public var mlatitude :Double?
////public var maltitude :Double?
////public var mCountry :String?
////
////class MyLocation: UIViewController,CLLocationManagerDelegate{
////    let locationManager = CLLocationManager()
////    var currentLocation:CLLocation!
////    var lock = NSLock()
////    override func viewDidLoad() {
////        super.viewDidLoad();
////        // Do any additional setup after loading the view.
////        locationManager.delegate = self //设置定位服务管理器代理
////        if CLLocationManager.authorizationStatus() == .notDetermined {
////            locationManager.requestWhenInUseAuthorization() //requestAlwaysAuthorization()//
////        }
////        locationManager.desiredAccuracy = kCLLocationAccuracyBest //设置定位精度
////        if (CLLocationManager.locationServicesEnabled())
////        {
////            locationManager.startUpdatingLocation(); //允许使用定位服务的话，开启定位服务更新
////            print("定位开始")
////            //self.navigationController?.popToRootViewController(animated: true)
////
////        }
////    }
////    //定位改变执行，可以得到新位置、旧位置
////    private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
////        print("得到数据")
////        mlongitude = 0
////        mlatitude = 0
////        maltitude = 0
////        mCountry = ""
////        lock.lock()
////        let currLocation:CLLocation = locations.last! //获取最新的坐标
////        mlongitude = currLocation.coordinate.longitude
////        mlatitude = currLocation.coordinate.latitude //获取纬度
////        maltitude = currLocation.altitude
////        self.locationManager.stopUpdatingLocation()
////
////        let geoCoder:CLGeocoder = CLGeocoder.init() // [S] 反编码以便获取其他信息
////        geoCoder.reverseGeocodeLocation(locations.last!, completionHandler: {(placemarks,error) in
////            if placemarks == nil{ // 如果断网或者定位失败
////                return
////            }
////            let placeMark:CLPlacemark = placemarks![0];
////            mCountry = placeMark.addressDictionary?["Country"] as? String; //国家
////        });
////        lock.unlock()
////    }
////    private func locationManager( manager: CLLocationManager, didFailWithError error: Error) {
////        print("定位出错拉！！\(error)")
////    }
////    override func viewDidAppear(_ animated: Bool) {
////        if(CLLocationManager.authorizationStatus() != .denied) {
////            print("应用拥有定位权限")
////        }else {
////            let aleat = UIAlertController(title: "打开定位开关", message:"定位服务未开启,请进入系统设置>隐私>定位服务中打开开关,并允许xxx使用定位服务", preferredStyle: .alert)
////            let tempAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
////            }
////            let callAction = UIAlertAction(title: "立即设置", style: .default) { (action) in
////                let url = NSURL.init(string: UIApplicationOpenSettingsURLString)
////                if(UIApplication.shared.canOpenURL(url! as URL)) {
////                    //ios10废弃openurl
////                    if #available(iOS 10.0, *) {
////                        UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
////                    } else {
////                        // Fallback on earlier versions
////                    }
////                }
////            }
////            aleat.addAction(tempAction)
////            aleat.addAction(callAction)
////            self.present(aleat, animated: true, completion: nil)
////        }
////    }
////}
////

