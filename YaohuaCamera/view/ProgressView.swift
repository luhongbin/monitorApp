//
//  ProgressView.swift
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.

import UIKit

enum TimeScaleType:Int {
    case fifteenMins = 0     //15分钟
    case halfFifteenMins = 1 //7分半
    case halfFiveMins = 2    //2分半
};

let lattice_mid_width = iPad ? 29 * 4 + 4 : 16 * 4 + 4   //中格长度
let FifteenMinsTotalWidth     = lattice_mid_width * 24 + 1
let HalfFifteenMinsTotalWidth = lattice_mid_width * 48 + 1
let HalfFiveMinsTotalWidth    = lattice_mid_width * 144 + 1

class ProgressView: UIView {
    var files:NSMutableArray?
    let dataFormat = DateFormatter()
    var start:DateComponents
    var end:DateComponents
    var timelong:TimeInterval
    var startlong:TimeInterval
    var endlong:TimeInterval
    var calendar:Calendar
    var time_scale:TimeScaleType = .fifteenMins

    override init(frame: CGRect) {
        self.start = DateComponents()
        self.end = DateComponents()
        self.timelong = 0
        self.startlong = 0
        self.endlong = 0
        self.dataFormat.dateFormat = "HH:mm"
        self.calendar = Calendar.current
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 96/255, green: 103/255, blue: 115/255, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.start = DateComponents()
        self.end = DateComponents()
        self.timelong = 0
        self.startlong = 0
        self.endlong = 0
        self.dataFormat.dateFormat = "HH:mm"
        self.calendar = Calendar.current
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor(red: 96/255, green: 103/255, blue: 115/255, alpha: 1)
    }
    
    func reset(_ start: DateComponents,end: DateComponents,files: NSMutableArray?){
        self.files = files
        self.start = start
        self.end = end
        self.timelong = calendar.date(from: end)!.timeIntervalSince1970  - calendar.date(from: start)!.timeIntervalSince1970
        self.startlong = calendar.date(from: start)!.timeIntervalSince1970
        self.endlong = calendar.date(from: end)!.timeIntervalSince1970
        
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        for sub in self.subviews {
            sub.removeFromSuperview()
        }
        
        UIColor(red: 242/255, green: 91/255, blue: 91/255, alpha: 1).setFill()

        if let fs = files {
            for file in fs {
                let data = file as! FileData
                var today = start
                today.hour = 0;
                today.minute = 0;
                today.minute = 0;
                let b = ((today as NSDateComponents).date?.timeIntervalSince1970)! + TimeInterval(data.stBeginTime);
                let e = ((today as NSDateComponents).date?.timeIntervalSince1970)! + TimeInterval(data.stEndTime);
                let x = self.bounds.width * CGFloat((b - startlong) / timelong)
                let width = self.bounds.width * CGFloat((e - b ) / timelong)
                print("timeselect")
                print("\(x),\(width),\(b),\(startlong)")
                UIBezierPath(rect: CGRect(x: x, y: 0, width: width, height: self.bounds.height)).fill()
            }
        }
        
        var lattice_count = 24
        let lattice_min_width = CGFloat(iPad ? 29 : 16)
        
        switch self.time_scale {
        case .fifteenMins:    lattice_count = 24
        case .halfFifteenMins:lattice_count = 48
        case .halfFiveMins:   lattice_count = 144
        }
        
        for i in 1...(lattice_count) {
            UIColor.black.setFill()
            let time = Date(timeIntervalSince1970: startlong + (endlong - startlong) * Double(i) / Double(lattice_count) + 1)
            let str = dataFormat.string(from: time)
            //最后一项时间不显示
            if i != lattice_count {
                let label = UILabel(frame: CGRect(x: self.bounds.width * CGFloat(i) / CGFloat(lattice_count) - lattice_min_width, y: iPad ? 4 : 0, width: lattice_min_width * 2, height: 16))
                label.text = str
                label.font =  UIFont.systemFont(ofSize: iPad ? 14 : 10)
                label.textAlignment = .center
                label.backgroundColor = UIColor.clear
                label.textColor = UIColor.white
                self.addSubview(label)
            }
            UIBezierPath(rect: CGRect(x: self.bounds.width * CGFloat(i) / CGFloat(lattice_count) , y: self.bounds.height * 0.6 , width: 1, height: self.bounds.height * 0.5)).fill()
            UIColor.gray.setFill()
            for j in 1...3 {
                UIBezierPath(rect: CGRect(x: self.bounds.width * CGFloat((i-1)*4 + j) / (4 * CGFloat(lattice_count)) , y: self.bounds.height * 0.6 , width: 1, height: self.bounds.height * 0.2)).fill()
            }
        }
    }
}
