//  LutecCamera
//
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//

import Foundation


//发送实时命令
//感应距离 D    a~z
//延时时间 T    a~z
//光敏阀值 X    a~z
//感应模式 M    a 感应模式、b D2D、c 常亮、d 测试
//指示灯控 P    a 开、z 关
//低亮亮度 L    a~z
//高亮亮度 H    a~z
//低亮延时 S    a~z
//闪灯控制 A    a 开、z 关
//C、R、G、B    a~z
//感应器控 K    a 开、b 关
//主灯控制 E    a 开、b 关

//0TBMdU

enum LampMode: String{
    case Sensor = "b"
    case D2D = "c"
    case AlwaysOn = "d"
    case Test = "e"
}
enum AlarmMode:String{
    case ON = "b"
    case DEFAULT = "a"
    case OFF = "z"
}

enum Level:String{
    case LOW = "Q"
    case MIDDLE = "Y"
    case HIGH = "Z"
    case CUSTOM = "O"
};


public struct CMD{
    fileprivate var command: String
    fileprivate var value: String
    fileprivate init(command: String,value: String){
        self.command = command
        self.value = value
    }
    internal var str: String{
        return "B" + command + value + "U"
    }
    //感应距离 D    a~z
    internal static func Distance(_ value: String) -> CMD{
        return CMD(command: "D",value: value)
    }
    //高亮亮度 H    a~z
    internal static func HBright(_ value: String) -> CMD{
        return CMD(command: "H", value: value)
    }
    //延时时间 T    a~z
    internal static func SDely(_ value: String) -> CMD{
        return CMD(command: "T",value: value)
    }
    //报警使能 A    b,z
    internal static func Alarm(_ on:Bool) -> CMD{
        return CMD(command: "A",value: on ? "b" : "z")
    }

    //光敏阀值 X    a~z
    internal static func Lux(_ value: String) -> CMD{
        return CMD(command: "X", value: value)
    }
    //感应模式 M    a 感应模式、b D2D、c 常亮、d 测试
    internal static func SMode(_ mode: LampMode) -> CMD{
        return CMD(command: "M",value: mode.rawValue)
    }
    //指示灯控 P    a 开、z 关
    internal static func Indicator(_ on: Bool) -> CMD{
        return CMD(command: "P", value: on ? "b" : "z")
    }
    //低亮亮度 L    a~z
    internal static func LBright(_ value: String) -> CMD{
        return CMD(command: "L", value: value)
    }
    //低亮延时 S    a~z
    internal static func LDely(_ value: String) -> CMD{
        return CMD(command: "S", value: value)
    }
    //闪灯控制 A    a 开、z 关
    internal static func Flash(_ on: Bool) -> CMD{
        return CMD(command: "A", value: on ? "b" : "z")
    }
    //C、R、G、B    a~z
    internal static func C(_ value: String) -> CMD{
        return CMD(command: "C", value: value)
    }
    //C、R、G、B    a~z
    internal static func R(_ value: String) -> CMD{
        return CMD(command: "R", value: value)
    }
    //C、R、G、B    a~z
    internal static func G(_ value: String) -> CMD{
        return CMD(command: "G", value: value)
    }
    //C、R、G、B    a~z
    internal static func B(_ value: String) -> CMD{
        return CMD(command: "B", value: value)
    }
    //感应器控 K    a 开、b 关
    internal static func Sensor(_ on: Bool) -> CMD{
        return CMD(command: "K", value: on ? "b" : "z")
    }
    //主灯控制 E    a 开、b 关
    internal static func Lamp(_ on: Bool) -> CMD{
        return CMD(command: "E", value: on ? "b" : "z")
    }
    //警戒级别,高中低客户定义
    internal static func SLevel(_ level: Level) -> CMD{
        return CMD(command: level.rawValue, value:level.rawValue)
    }
}
