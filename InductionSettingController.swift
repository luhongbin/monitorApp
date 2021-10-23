//
//  InductionSettingController.swift
//  YaoHuaCamera
//
//  Created by Menervil on 15/9/29.
//  Copyright (c) 2015年 Menervil. All rights reserved.
//

import UIKit
import Foundation

enum InductionCell:Int {
    case modeCell            //模式
    case distanceCell       //距离
    case sensorDely         //感应器延时
    case luxCell            //光敏阀值
    case inductionModeCell  //感应模式
    case indicatorLightCell //指示灯开关
    case lowLightCell       //低亮亮度
    case highLightCell           //高亮亮度
    case lowLightDelyCell     //低亮延时
    case flashLightCell         //闪光灯开关
    case brightnessCCell        //亮度C
    case brightnessRCell        //亮度R
    case brightnessGCell        //亮度G
    case brightnessBCell        //亮度B
    case sensorEnableCell       //感应器开关
    case lampEnableCell         //主灯开关
    case level //外部报警级别
};

class InductionSettingController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate {
    
    @IBOutlet var leftBarView: UIView!
    @IBOutlet var leftBarBtn: UIButton!
    
    @IBOutlet weak var buttonWidth: NSLayoutConstraint!
    @IBOutlet var rightBarView: UIView!
    @IBOutlet var rightBarBtn: UIButton!
    
//    @IBOutlet weak var buttonTop: NSLayoutConstraint!
//    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    //Induction View
    @IBOutlet var inductionView: UIView!

//    @IBOutlet var width_divideLine: NSLayoutConstraint!
//    @IBOutlet var height_inductionView: NSLayoutConstraint!
    
    //Settings View
    @IBOutlet var settingsView: UIView!

    //    @IBOutlet var height_settingsView: NSLayoutConstraint!
//    @IBOutlet var width_settingsView: NSLayoutConstraint!
    
//    @IBOutlet var normalTitleView: UIView!
//    @IBOutlet var energyTitleView: UIView!
//    @IBOutlet var customTitleView: UIView!
//    @IBOutlet var sensitiveTitleView: UIView!
    
//    @IBOutlet var origin_Y_energyTitleView: NSLayoutConstraint!
//    @IBOutlet var width_energyTitleView: NSLayoutConstraint!
//    @IBOutlet var height_energyTitleView: NSLayoutConstraint!
//    
//    @IBOutlet var origin_Y_sensitiveTitleView: NSLayoutConstraint!
//    @IBOutlet var width_sensitiveTitleView: NSLayoutConstraint!
//    @IBOutlet var height_sensitiveTitleView: NSLayoutConstraint!
    
//    @IBOutlet var normalTitle: UILabel!
//    @IBOutlet var energySaveTitle: UILabel!
//    @IBOutlet var customtext: UILabel!
//    @IBOutlet var sensitiveTitle: UILabel!
    
//    @IBOutlet var normalLight: UIImageView!
//    @IBOutlet var energySaveLight: UIImageView!
//    @IBOutlet var customLight: UIImageView!
//    @IBOutlet var sensitiveLight: UIImageView!
//    @IBOutlet var inductionImg: UIImageView!
//    @IBOutlet var height_inductionImg: NSLayoutConstraint!
//    @IBOutlet var width_inductionImg: NSLayoutConstraint!
//    @IBOutlet var origin_X_sensitiveLight: NSLayoutConstraint!
    
    @IBOutlet var inductionInfoTable: UITableView!
    
    
    var cellArr : [InductionCell]!
    var app: AppDelegate!
    
    var startPoint : CGPoint = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        app = UIApplication.shared.delegate as! AppDelegate
        
        self.initNavBar()
        
        
        self.customtext.layer.borderWidth = 2// 设置button边框宽度
        self.customtext.layer.borderColor =  UIColor.red.cgColor// 设置button边框颜色
        if app.select.mode == .AlwaysOn {
            cellArr = [.highLightCell]
            self.navigationItem.title = NSLocalizedString("reaction_light_level", comment: "")
        }else{
            self.navigationItem.title = NSLocalizedString("security_Level", comment: "")
            cellArr = [.modeCell,.luxCell,.distanceCell,.lowLightCell,.lowLightDelyCell,.highLightCell,.sensorDely,.level]
            self.inductionInfoTable.tableHeaderView = self.inductionView
        }
        
        inductionInfoTable.tableFooterView = UIView(frame: CGRect.zero)
         NotificationCenter.default.addObserver(self, selector: #selector(InductionSettingController.onConfigResutl(_:)), name: NSNotification.Name(rawValue: RET_CONFIG), object: nil)
        let _ = (SDK.sharedSDK() as AnyObject).send("BFbU", dev: self.app.select.sn)
//        self.initView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onConfigResutl(_ notification:Notification){
        if let cmd = (notification.object as? String)?.characters{
            print("查返回：\(cmd.map({String($0)}).description)")
            if cmd.count == 12 && cmd.first == "B" && cmd.last == "U" {
                let config = cmd.map({String($0)})
                
                app.select.distance = config[1]
                app.select.hld = config[2]
                app.select.lux = config[3]
                if let mode = LampMode(rawValue: config[4]) {
                    app.select.mode = mode
                }
                
                app.select.indicator  = config[5]
                app.select.lowlight = config[6]
                app.select.highlight = config[7]
                app.select.lld = config[8]
                //app.select.alarm = AlarmMode(rawValue: config[9])
                //app.select.alarm=AlarmMode(rawValue: config[9])!

                if let level = Level(rawValue: config[10]) {
                    app.select.level = level
                }
                print("level:\(config[9]) and \(config[10])=\(config[10])")
                app.onDeviceChange()
//                self.updateSettingsView()
                self.inductionInfoTable.reloadData()
            }
        }
    }
   
    // MARK: - Init View
    func initNavBar(){
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.orange,NSAttributedStringKey.font:UIFont(name: "HelveticaNeue-Bold", size: 17)!]
        //左导航按钮
        let left_negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: self, action: nil)
        left_negativeSpacer.width = -18.0
        let leftBar = UIBarButtonItem(customView: self.leftBarView)
        self.navigationItem.leftBarButtonItems = [left_negativeSpacer,leftBar]
        
        //右导航按钮
        let right_negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: self, action: nil)
        right_negativeSpacer.width = -18.0
        let rightBar = UIBarButtonItem(customView: self.rightBarView)
        self.navigationItem.rightBarButtonItems = [right_negativeSpacer,rightBar]
    }
//    func initView(){
//        if iPad {
////            normalTitle.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
////            customTitle.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
////            energySaveTitle.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
////            sensitiveTitle.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
////            buttonWidth = Constraint.changeMultiplier(buttonWidth, multiplier: 250/600)
////            buttonHeight = Constraint.changeMultiplier(buttonHeight, multiplier: 250/600)
////            buttonTop.constant = 220
//        }
//        if iPhone {
////            buttonWidth = Constraint.changeMultiplier(buttonWidth, multiplier: 350/600)
////            buttonHeight = Constraint.changeMultiplier(buttonHeight, multiplier: 350/600)
////            buttonTop.constant = 180
//        }
//
////        let tap = UITapGestureRecognizer(target: self, action: #selector(InductionSettingController.tapGestureRecognizer(_:)))
////        self.inductionImg.addGestureRecognizer(tap)
////
////        let tap1 = UITapGestureRecognizer(target: self, action: #selector(InductionSettingController.energyTitletitleTapGestureRecognizer(_:)))
////        self.energyTitleView.addGestureRecognizer(tap1)
////        let tap2 = UITapGestureRecognizer(target: self, action: #selector(InductionSettingController.normalTitletitleTapGestureRecognizer(_:)))
////        self.normalTitleView.addGestureRecognizer(tap2)
////        let tap3 = UITapGestureRecognizer(target: self, action: #selector(InductionSettingController.sensitiveTitletitleTapGestureRecognizer(_:)))
////        self.sensitiveTitleView.addGestureRecognizer(tap3)
////        let tap4 = UITapGestureRecognizer(target: self, action: #selector(InductionSettingController.customTitletitleTapGestureRecognizer(_:)))
////        self.customTitleView.addGestureRecognizer(tap4)
//
//        self.updateSettingsView()
//    }
//    func updateSettingsView(){
    
//        normalTitle.text     = NSLocalizedString("middle", comment: "")
//        energySaveTitle.text = NSLocalizedString("low", comment: "")
//        sensitiveTitle.text  = NSLocalizedString("high", comment: "")
//        customTitle.text     = NSLocalizedString("custom", comment: "")
//
//        normalTitle.adjustsFontSizeToFitWidth     = true
//        energySaveTitle.adjustsFontSizeToFitWidth = true
//        sensitiveTitle.adjustsFontSizeToFitWidth  = true
//        customTitle.adjustsFontSizeToFitWidth     = true
//
//        normalTitle.textColor     = UIColor.white
//        energySaveTitle.textColor = UIColor.white
//        sensitiveTitle.textColor  = UIColor.white
//        customTitle.textColor     = UIColor.white
//
////        normalLight.image     = UIImage(named: "dark_lights_icon")
////        energySaveLight.image = UIImage(named: "dark_lights_icon")
////        sensitiveLight.image  = UIImage(named: "dark_lights_icon")
////        customLight.image     = UIImage(named: "dark_lights_icon")
//        UIView.animate(withDuration: 0.25, animations: {
//            if let current = self.app.select {
//                switch current.level {
//                case .LOW:
//                    self.energySaveTitle.textColor = LevelLowColor
////                    self.energySaveLight.image     = UIImage(named: "energy_save_lights_icon")
////                    self.inductionImg.image    = UIImage(named: "energy_save_inductiion_large")
////                    self.inductionImg.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2 / 2))
//                case .MIDDLE:
//                    self.normalTitle.textColor = LevelMiddleColor
////                    self.normalLight.image     = UIImage(named: "normal_lights_icon")
////                    self.inductionImg.image    = UIImage(named: "normal_inductiion_large")
////                    self.inductionImg.transform = CGAffineTransform(rotationAngle: 0)
//                case .HIGH:
//                    self.sensitiveTitle.textColor = LevelHighColor
////                    self.sensitiveLight.image     = UIImage(named: "sensitive_lights_icon")
////                    self.inductionImg.image    = UIImage(named: "sensitive_inductiion_large")
////                    self.inductionImg.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2 / 2))
//                case .CUSTOM:
//                    self.customTitle.textColor = LevelCostomColor
////                    self.customLight.image     = UIImage(named: "custom_lights_icon copy")
////                    self.inductionImg.image    = UIImage(named: "custom_inductiion_large")
////                    self.inductionImg.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
//                }
//            }
//        })
//    }
    
    @IBAction func rebackClick(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func moreClick(){
        let moreVC = MoreViewController(nibName: "MoreViewController", bundle: nil)
        
        self.navigationController?.pushViewController(moreVC, animated: true)
    }
    func angleBetweenLines(_ line1Start:CGPoint,line1End:CGPoint,line2Start:CGPoint,line2End:CGPoint) -> CGFloat {
        let a = line1End.x - line1Start.x
        let b = line1End.y - line1Start.y
        let c = line2End.x - line2Start.x
        let d = line2End.y - line2Start.y
        
        let rads = acos(((a * c) + (b * d)) / ((sqrt(a * a + b * b)) * (sqrt(c * c + d * d))))
        return  (180.0 * rads)
    }
    // MARK: - UITapGestureRecognizer Action
    @objc func tapGestureRecognizer(_ tap:UITapGestureRecognizer)
    {
        
        if let level = self.app.select?.level{
            switch level{
            case .LOW :
                handleLevelChange(.MIDDLE)
            case .MIDDLE:
                handleLevelChange(.HIGH)
            case .HIGH:
                handleLevelChange(.CUSTOM)
            case .CUSTOM:
                handleLevelChange(.LOW)
            }
        }
    }
    
    func handleLevelChange(_ level:Level){
        app.select?.level = level
//        self.updateSettingsView()
        self.inductionInfoTable.reloadData()
        let _ = (SDK.sharedSDK() as AnyObject).send(CMD.SLevel(level).str, dev: app.select.sn)
        switch level {
        case .LOW:
             (SDK.sharedSDK() as AnyObject).setOutInput( 1, sn: app.select.sn)
        case .MIDDLE:
             (SDK.sharedSDK() as AnyObject).setOutInput( 4, sn: app.select.sn)
        case .HIGH:
            (SDK.sharedSDK() as AnyObject).setOutInput( 7, sn: app.select.sn)
        case .CUSTOM:
            (SDK.sharedSDK() as AnyObject).setOutInput( 8, sn: app.select.sn)
            //break
        }
        self.inductionInfoTable.isScrollEnabled = level == .CUSTOM
                //(SDK.sharedSDK() as AnyObject).send(AppDelegate.current.lLoginId, data: strdup(CMD.SLevel(level).str))
        app.onDeviceChange()
    }
    
    @IBAction func energybutton(_ sender: Any)
    {
        handleLevelChange(.LOW)
    }
   @IBAction func normalbutton(_ sender: Any)
    {
        handleLevelChange(.MIDDLE)
    }
    @IBAction func sensorbutton(_ sender: Any)
    {
        handleLevelChange(.HIGH)
    }
    @IBAction func custombutton(_ sender: Any)    {
        handleLevelChange(.CUSTOM)
    }
    // MARK: - UITableView Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.app.select?.level == .CUSTOM || app.select.mode == .AlwaysOn ? cellArr.count : 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellArr[indexPath.row] == .modeCell ? 45 : 87
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let rowIndex = indexPath.row
        let cellType = cellArr[rowIndex]
        tableView.backgroundColor = .black
        if cellType == .modeCell{
            let cellIdentifier = "InductionModelCell"
            var cell =  tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? InductionModelCell
            
            if cell == nil {
                cell = Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)?.first as? InductionModelCell
            }
            cell?.backgroundColor = .black
            cell?.contentView.backgroundColor = .black

            //NavColor
            cell?.accessoryType  = UITableViewCellAccessoryType.none
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            cell?.layoutMargins  = UIEdgeInsetsMake(0, 46, 0, 30)
            cell?.separatorInset = UIEdgeInsetsMake(0, 46, 0, 30)
            cell?.loadView(self.app.select.level)
            return cell!
        }else if cellType == .luxCell || cellType == .distanceCell || cellType == .highLightCell || cellType == .lowLightCell {
            let cellIdentifier = "SettingViewCell"
            var cell =  tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? SettingViewCell
            
            if cell == nil {
                cell = Bundle.main.loadNibNamed(cellIdentifier, owner: self, options: nil)?.first as? SettingViewCell
            }
            cell?.backgroundColor = .black
            cell?.contentView.backgroundColor = .black

            //NavColor
            cell?.textLabel?.font = UIFont(name: "HelveticaNeue", size: 12)
            cell?.textLabel?.textColor = UIColor(hex: 0xF07800)
                //Color(166, g: 173, b: 177)
            cell?.detailTextLabel?.font = UIFont(name: "HelveticaNeue", size: 12)
            cell?.detailTextLabel?.textColor = UIColor(hex: 0xF07800)
//            UIColor.white
            cell?.accessoryType  = UITableViewCellAccessoryType.none
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            cell?.layoutMargins  = UIEdgeInsetsMake(0, 46, 0, 30)
            cell?.separatorInset = UIEdgeInsetsMake(0, 46, 0, 30)
            cell?.startLabel.attributedText = nil
            cell?.endLabel.attributedText = nil
            cell?.slider.tag = cellType.rawValue

            var value: Float = 0.0
            var title = ""
            var min = ""
            var max = ""
            switch cellType {
            case .luxCell:
                title = NSLocalizedString("sensor_activation_level", comment: "")
                max = "Dark"
                min = "Bright"

                cell?.slider.minimumValue = 0
                cell?.slider.maximumValue = 22
                value = self.app.select.lux.value
                let  day = NSTextAttachment()
                day.image = UIImage(named: "day")
                let  dayString = NSAttributedString(attachment: day)
                cell?.startLabel.attributedText = dayString
                let  attachment = NSTextAttachment()
                attachment.image = UIImage(named: "night")
                let  attachmentString = NSAttributedString(attachment: attachment)
                cell?.endLabel.attributedText = attachmentString
                value = self.app.select.lux.value

            case .distanceCell:
                title = NSLocalizedString("sensor_detection_distance", comment: "")
                max = NSLocalizedString("far", comment: "")
                min = NSLocalizedString("near", comment: "")
                
                cell?.slider.minimumValue = 0
                cell?.slider.maximumValue = 22
                value = self.app.select.distance.value
            case .highLightCell:
                title = app.select.mode == .AlwaysOn ? "" : NSLocalizedString("reaction_light_level", comment: "")
                min = "30%"
                max = "100%"
                cell?.slider.minimumValue = 7
                cell?.slider.maximumValue = 25
                value = self.app.select.highlight.value
            case .lowLightCell:
                title = NSLocalizedString("continues_light_level", comment: "")
                min = "0%"
                max = "40%"
                cell?.slider.minimumValue = 0
                cell?.slider.maximumValue = 11
                value = self.app.select.lowlight.value
            default: break
            }
            cell?.slider.value = value
             cell?.titleLabel.text = title
            if cellType != .luxCell {
               cell?.endLabel.text = max
               cell?.startLabel.text = min
            }
            cell?.slider.addTarget(self, action: #selector(InductionSettingController.onValueChange(_:)), for: .valueChanged)
            cell?.slider.addTarget(self, action: #selector(InductionSettingController.onValueSet(_:)), for: .touchUpOutside)
            cell?.slider.addTarget(self, action: #selector(InductionSettingController.onValueSet(_:)), for: .touchUpInside)
            // 设置圆点图片
            cell?.backgroundColor = .clear
            //cell?.slider.setThumbImage(UIImage.init(named: "yuan.png"), for: UIControlState.normal)
            cell?.slider.thumbTintColor = UIColor.orange // 设置圆点颜色
            cell?.slider.minimumTrackTintColor = UIColor.orange // 设置滑动过的颜色
            cell?.slider.maximumTrackTintColor = UIColor.white // 设置未滑动过的颜色
            cell?.titleLabel?.textColor = UIColor(hex: 0xF07800)
            cell?.detailTextLabel?.textColor = UIColor(hex: 0xF07800)
            cell?.endLabel?.textColor = UIColor(hex: 0xF07800)
            cell?.startLabel?.textColor = UIColor(hex: 0xF07800)
            cell?.endLabel?.backgroundColor = .black
            cell?.startLabel?.backgroundColor = .black
            cell?.titleLabel?.backgroundColor = .black
            cell?.slider.backgroundColor = .black
           return cell!
        }else{
            let cellIdentifier = "Other_Cell"
            var cell =  tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: cellIdentifier)
            }
            cell?.backgroundColor = .black
            //NavColor
            cell?.textLabel?.font = UIFont(name: "HelveticaNeue", size: 17)
            cell?.textLabel?.textColor = UIColor(hex: 0xF07800)
            cell?.detailTextLabel?.textColor = UIColor(hex: 0xF07800)
            //Color(166, g: 173, b: 177)
            cell?.detailTextLabel?.font = UIFont(name: "HelveticaNeue", size: 17)
            //UIColor.white
            cell?.accessoryType  = UITableViewCellAccessoryType.disclosureIndicator
            cell?.selectionStyle = UITableViewCellSelectionStyle.default
            cell?.layoutMargins  = UIEdgeInsetsMake(0, 46, 0, 30)
            cell?.separatorInset = UIEdgeInsetsMake(0, 46, 0, 30)
            if self.app.select?.level == .CUSTOM {
                cell?.textLabel?.font = UIFont(name: "HelveticaNeue", size: 17)
                cell?.detailTextLabel?.font = UIFont(name: "HelveticaNeue", size: 17)
                cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                cell?.selectionStyle = UITableViewCellSelectionStyle.default
            }
            
            //  [.LUXCell,.DistanceCell,.HighLightCell,.SensorDely,.LowLightCell,.LowLightDelyCell]
            switch cellType{
            case .sensorDely:
                cell?.textLabel?.text = NSLocalizedString("reaction_light_time", comment: "")
                cell?.detailTextLabel?.text =  "\(Int(self.app.select.hld.value))MIN"
            case .lowLightDelyCell:
                cell?.textLabel?.text = NSLocalizedString("continues_light_time", comment: "")
                if self.app.select.lld.value == 0 {
                    cell?.detailTextLabel?.text = NSLocalizedString("DUSK/DAWN", comment: "")
                }else{
                    cell?.detailTextLabel?.text =  "\(Int(self.app.select.lld.value * 25 / 60))H"
                }
            case .level:
                 cell?.textLabel?.text = NSLocalizedString("alert_level", comment: "")
                 let value:String!
                 switch self.app.select.il {//self.app.select.il 这个是本地状态，改成设备状态采用下列代码
                
                 case 1:value = "low"
                    case 4:value = "middle"
                    case 7:value = "high"
                 default:value = ""
                 }
                 cell?.detailTextLabel?.text =  value
                 
                 if value == "low" || value == "middle" || value == "high" {
                    let  image = NSTextAttachment()
                    let m = UIImage(named: value)!
                    UIGraphicsBeginImageContextWithOptions(CGSize(width: m.size.width  * (18 / m.size.height), height: 18), false, UIScreen.main.scale)
                    m.draw(in: CGRect(x: 0, y: 0,width: m.size.width  * (18 / m.size.height), height: 18))
                    let reSizeImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext();
                    image.image = reSizeImage
                    let  imageString = NSAttributedString(attachment: image)
                    cell?.detailTextLabel?.attributedText = imageString
                 }
                break
            default:break
            }
            return cell!
        }
    }
    //    [.LUXCell,.DistanceCell,.HighLightCell,.SensorDely,.LowLightCell,.LowLightDelyCell]
    var before:TimeInterval = Date().timeIntervalSince1970
    @objc func onValueChange(_ sender: UISlider){
        if Date().timeIntervalSince1970 - before < 0.2{
            return
        }
        before = Date().timeIntervalSince1970
        switch InductionCell(rawValue: sender.tag)!{
        case .luxCell:
            app.select.lux = letter[Int(sender.value)]
            let _ = (SDK.sharedSDK() as AnyObject).send(CMD.Lux(app.select.lux).str, dev: app.select.sn)
            //            SDK.send(AppDelegate.current.lLoginId, data: strdup(CMD.Lux(AppDelegate.current.lux).str))
        case .distanceCell:
            app.select.distance = letter[Int(sender.value)]
            let _ = (SDK.sharedSDK() as AnyObject).send(CMD.Distance(app.select.distance).str, dev: app.select.sn)
            //            SDK.send(AppDelegate.current.lLoginId, data: strdup(CMD.Distance(AppDelegate.current.distance).str))
            
        case .highLightCell:
            app.select!.highlight = letter[Int(sender.value)]
            let _ = (SDK.sharedSDK() as AnyObject).send(CMD.HBright( app.select.highlight).str, dev: app.select.sn)
            //            SDK.send(AppDelegate.current.lLoginId, data: strdup(CMD.HBright( AppDelegate.current.highlight).str))
        case .lowLightCell:
            app.select!.lowlight = letter[Int(sender.value)]
            let _ = (SDK.sharedSDK() as AnyObject).send(CMD.LBright(app.select.lowlight).str, dev: app.select.sn)
            //            SDK.send(AppDelegate.current.lLoginId, data: strdup(CMD.LBright(AppDelegate.current.lowlight).str))
        default: break
        }
    }
    @objc func onValueSet(_ sender: UISlider){
        switch InductionCell(rawValue: sender.tag)!{
        case .luxCell:
            app.select!.lux = letter[Int(sender.value)]
            let _ = (SDK.sharedSDK() as AnyObject).send(CMD.Lux(app.select.lux).str, dev: app.select.sn)
            //            SDK.send(AppDelegate.current.lLoginId, data: strdup(CMD.Lux(AppDelegate.current.lux).str))
        case .distanceCell:
            app.select!.distance = letter[Int(sender.value)]
            let _ = (SDK.sharedSDK() as AnyObject).send(CMD.Distance(app.select.distance).str, dev: app.select.sn)
        case .highLightCell:
            app.select!.highlight = letter[Int(sender.value)]
            let _ = (SDK.sharedSDK() as AnyObject).send(CMD.HBright( app.select.highlight).str, dev: app.select.sn)
        case .lowLightCell:
            app.select!.lowlight = letter[Int(sender.value)]
            let _ = (SDK.sharedSDK() as AnyObject).send(CMD.LBright(app.select.lowlight).str, dev: app.select.sn)
        default :break
        }
        app.onDeviceChange()
    }
    let sensorDelys = [1,3,10,15]
    let lowLightDelys = [0,2,4,6,10]
    let levels = [1,4,7]
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellType = cellArr[indexPath.row]
        var value=""
        if cellType == .sensorDely {
            let alertController = UIAlertController(title:nil, message:  NSLocalizedString("reaction_light_time", comment: ""),preferredStyle: .actionSheet)
            for dely in sensorDelys{
                alertController.addAction(UIAlertAction(title: "\(dely)MIN", style: .default, handler: {
                    action in
                    let minute = dely
                    value = "\(minute)MIN"
                    let hld = letter[minute]
                    self.app.select!.hld = hld
                    let _ = (SDK.sharedSDK() as AnyObject).send(CMD.SDely(hld).str, dev: self.app.select.sn)
                    let cell = self.inductionInfoTable.cellForRow(at: IndexPath(row: indexPath.row, section: 0))
                    cell?.detailTextLabel?.text = value
                    self.app.onDeviceChange()
                }))
            }
            alertController.popoverPresentationController?.sourceView = self.view // support iPad
            alertController.popoverPresentationController?.sourceRect = (tableView.cellForRow(at: indexPath)?.frame)!
            self.dismiss(animated: false, completion: nil)
            self.present(alertController, animated: true, completion: nil)
        }
        if cellType == .lowLightDelyCell{
            let alertController = UIAlertController(title:nil, message:  NSLocalizedString("continues_light_time", comment: ""),preferredStyle: .actionSheet)
            for dely in lowLightDelys{
                if dely == 0 {
                    alertController.addAction(UIAlertAction(title:  NSLocalizedString("DUSK/DAWN", comment: ""), style: .default, handler: {
                        action in
                        let hour = dely
                        let lld = letter[Int(Double(hour) * 2.5)]
                        self.app.select!.lld = lld
                        value = NSLocalizedString("DUSK/DAWN", comment: "")
                        let _ = (SDK.sharedSDK() as AnyObject).send(CMD.LDely(lld).str, dev: self.app.select.sn)
                        let cell = self.inductionInfoTable.cellForRow(at: IndexPath(row: indexPath.row, section: 0))
                        cell?.detailTextLabel?.text = value
                        self.app.onDeviceChange()
                    }))
                }else{
                    alertController.addAction(UIAlertAction(title: "\(dely)H", style: .default, handler:  {
                        action in
                        let hour = dely
                        let lld = letter[Int(Double(hour) * 2.5)]
                        self.app.select!.lld = lld
                        value = "\(hour)H"
                        let _ = (SDK.sharedSDK() as AnyObject).send(CMD.LDely(lld).str, dev: self.app.select.sn)
                        let cell = self.inductionInfoTable.cellForRow(at: IndexPath(row: indexPath.row, section: 0))
                        cell?.detailTextLabel?.text = value
                        self.app.onDeviceChange()
                    }))
                }
            }
            // support iPad
            alertController.popoverPresentationController?.sourceView = self.view
            alertController.popoverPresentationController?.sourceRect = (tableView.cellForRow(at: indexPath)?.frame)!
            self.present(alertController, animated: true, completion: nil)
        }
        if cellType == .level {
            let alertController = UIAlertController(title:nil, message:  NSLocalizedString("alert_level", comment: ""),preferredStyle: .actionSheet)
            for l in levels{
                var value:String!
                switch l {
                case 1:value = NSLocalizedString("lowalter", comment: "")
                case 4:value = NSLocalizedString("middlealert", comment: "")
                case 7:value = NSLocalizedString("highalert", comment: "")
                default:value = ""
                }
                alertController.addAction(UIAlertAction(title:value, style: .default, handler: {
                    action in
                    self.app.select!.il = Int(l)
                    switch self.app.select.il {
                    case 1:value = "low"
                    case 4:value = "middle"
                    case 7:value = "high"
                    default:value = ""
                    }
                    //let _ = (SDK.sharedSDK() as AnyObject).send(CMD.SLevel(Int32(l)).str, dev: self.app.select.sn)
                    print("写回数据库的报警\(self.app.select!.il)")
                    (SDK.sharedSDK() as AnyObject).setOutInput(Int32(Int(self.app.select!.il)), sn: self.app.select!.sn)
                    let cell = self.inductionInfoTable.cellForRow(at: IndexPath(row: indexPath.row, section: 0))
                    cell?.detailTextLabel?.text = value
                    if value == "low" || value == "middle" || value == "high" {
                        let  image = NSTextAttachment()
                        let m = UIImage(named: value)!
                        
                        UIGraphicsBeginImageContextWithOptions(CGSize(width: m.size.width  * (18 / m.size.height), height: 18), false, UIScreen.main.scale)
                        m.draw(in: CGRect(x: 0, y: 0,width: m.size.width  * (18 / m.size.height), height: 18))
                        let reSizeImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext();
                        image.image = reSizeImage
                        let  imageString = NSAttributedString(attachment: image)
                        cell?.detailTextLabel?.attributedText = imageString
                    }
                    self.app.onDeviceChange()
                    
                    let snid = String(self.app.select.il)
                    let action = "报警级别"
                    addlog(action:action,snid:snid)
              }))
            }
            alertController.popoverPresentationController?.sourceView = self.view// support iPad
            alertController.popoverPresentationController?.sourceRect = (tableView.cellForRow(at: indexPath)?.frame)!
            self.present(alertController, animated: true, completion: nil)
            //            alertController.backgroundColor = UIColor.gray
        }
    }
    
}
