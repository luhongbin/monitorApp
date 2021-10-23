//
//  Device.swift
//  LutecCamera
//
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//
import SwiftyJSON
import Foundation

func ==(lhs: Device, rhs: Device) -> Bool{
    return lhs.sn == rhs.sn
}

class Device:Equatable{
    var sn : String //序列号
    var name : String //名称
    var level : Level //报警参数设置：LOW:1, MIDDLE:4, HIGH:7, .CUSTOM:8
    var mode: LampMode //灯控模式
    var alarm: AlarmMode //报警模式
    var lux: String //光敏阀值
    var distance: String //感应距离
    var highlight:String //高亮亮度
    var lowlight: String //低亮亮度
    var hld: String //高亮延时
    var lld: String //低亮延时
    var indicator : String //指示器
    var password: String //密码
    var il: Int //报警级别
    var StorageMode: Int  //存储方式，1不存储，2移动报警触发存储，3连续存储

    init(){
        self.name = "STEINEL"
        self.sn = ""
        self.level = .MIDDLE
        self.lux = "a"
        self.distance = "a"
        self.highlight = "a"
        self.lowlight = "a"
        self.hld = "b"
        self.lld = "a"
        self.mode = .Sensor
        self.alarm = .DEFAULT
        self.indicator = "a"
        self.password = ""
        self.il = 1
        self.StorageMode = 2
    }
    convenience init(sn:String){
        self.init()
        self.sn = sn
       
    }
    var json:JSON{
        get{
            return JSON(["sn":sn,"name":name,"level":level.rawValue,"lux":lux,"distance":distance,"highlight":highlight,"lowlight":lowlight,"lld":lld,"hld":hld,"mode":mode.rawValue,"indicator":indicator,"alarm":alarm.rawValue,"password":password,"il":il,"StorageMode":StorageMode])
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
        if let StorageMode = json["StorageMode"].int{
            self.StorageMode = StorageMode
        }else{
            self.StorageMode = 2
        }
    }
}
