//
//  TrackLog.swift
//  FunSDKDemo
//
//  Created by lhb on 2017/9/22.
//  Copyright © 2017年 lutec. All rights reserved.
//

import SwiftyJSON
import Foundation

func ==(lhs: TrackLog, rhs: TrackLog) -> Bool{
    return lhs.sn == rhs.sn
}

class TrackLog:Equatable{
    //序列号
    var sn : String
    //名称
    var name : String
    //参数模式
    var level : Level
    //灯控模式
    var mode: LampMode
    //报警模式
    var alarm: AlarmMode
    //光敏阀值
    var lux: String
    //感应距离
    var distance: String
    //高亮亮度
    var highlight:String
    //低亮亮度
    var lowlight: String
    //高亮延时
    var hld: String
    //低亮延时
    var lld: String
    //指示器
    var indicator : String
    
    var password: String
    
    var il: Int
    
    init(){
        self.name = "LUTEC"
        self.sn = ""
        self.level = .MIDDLE
        self.lux = "a"
        self.distance = "a"
        self.highlight = "a"
        self.lowlight = "a"
        self.hld = "b"
        self.lld = "a"
        self.mode = .Sensor
        self.alarm = .OFF
        self.indicator = "a"
        self.password = ""
        self.il = 1
    }
    convenience init(sn:String){
        self.init()
        self.sn = sn
        
    }
    var json:JSON{
        get{
            return JSON(["sn":sn,"name":name,"level":level.rawValue,"lux":lux,"distance":distance,"highlight":highlight,"lowlight":lowlight,"lld":lld,"hld":hld,"mode":mode.rawValue,"indicator":indicator,"alarm":alarm.rawValue,"password":password,"il":il])
        }
    }
    init(json: JSON){
        self.sn = json["sn"].stringValue
        self.name = json["name"].stringValue
        self.level = Level(rawValue: json["level"].stringValue)!
        self.lux = json["lux"].stringValue
        self.distance = json["distance"].stringValue
        self.highlight = json["highlight"].stringValue
        self.lowlight = json["lowlight"].stringValue
        self.hld = json["hld"].stringValue
        self.lld = json["lld"].stringValue
        self.mode = LampMode(rawValue: json["mode"].stringValue)!
        self.indicator = json["indicator"].stringValue
        self.alarm = AlarmMode(rawValue: json["alarm"].stringValue)!
        if let pwd = json["password"].string {
            self.password = pwd
        }else {
            self.password = ""
        }
        if let il = json["il"].int{
            self.il = il
        }else{
            self.il = 1
        }
    }
}

