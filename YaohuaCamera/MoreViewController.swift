//
//  MoreViewController.swift
//  LutecCamera
//
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//
import UIKit
import MBProgressHUD
import CoreLocation


var CHECKUPGRADE = 0
var CHECKGDPRS = 0
var getresult = "0"

class MoreViewController: UITableViewController,UIAlertViewDelegate {
    
    @IBOutlet var leftBarView: UIView!
    @IBOutlet var leftBarBtn: UIButton!
    var app: AppDelegate!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        app = UIApplication.shared.delegate as! AppDelegate
        NotificationCenter.default.addObserver(self, selector: #selector(MoreViewController.onGDPR(_:)), name: NSNotification.Name(rawValue: RET_GD), object: nil)
            //判断连接
        NotificationCenter.default.addObserver(self, selector: #selector(MoreViewController.onCHKGDPR(_:)), name: NSNotification.Name(rawValue: CHECK_GDPR), object: nil)//判断连接

        self.navigationItem.title = NSLocalizedString("more", comment: "")//"More"
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont(name: "HelveticaNeue-Bold", size: 17)!]
        let left_negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: self, action: nil) //左导航按钮
        left_negativeSpacer.width = -18.0
        let leftBar = UIBarButtonItem(customView: self.leftBarView)
        self.navigationItem.leftBarButtonItems = [left_negativeSpacer,leftBar]
    }
    @objc func onCHKGDPR(_ notification:Notification) {
        if let cmd = (notification.object as? Bool){
            if (cmd == false) {
                let hud = MBProgressHUD.showAdded(to:  self.view, animated: true)
                hud.label.text = NSLocalizedString("failed", comment: "")
                hud.mode = .text
                hud.label.textColor = UIColor.init(hex: 0x770B2F)
                hud.hide(animated: true, afterDelay: 2)
                UserDefaults.standard.setValue("f", forKey: "ExtRecordMask")// 保存最新的版本号
            }else{
                let hud = MBProgressHUD.showAdded(to:  self.view, animated: true)
                hud.label.text = NSLocalizedString("success", comment: "")
                hud.mode = .text
                hud.label.textColor = UIColor.init(hex: 0x770B2F)
                hud.hide(animated: true, afterDelay: 2)
            }
        }
    }
    func createQRForString(_ qrString: String?) -> UIImage?{
        if let sureQRString = qrString {
            let stringData = sureQRString.data(using: String.Encoding.utf8,
                allowLossyConversion: false)
            // 创建一个二维码的滤镜
            let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
            qrFilter.setValue(stringData, forKey: "inputMessage")
            qrFilter.setValue("H", forKey: "inputCorrectionLevel")
            let qrCIImage = qrFilter.outputImage
            // 创建一个颜色滤镜,黑白色
            let colorFilter = CIFilter(name: "CIFalseColor")!
            colorFilter.setDefaults()
            colorFilter.setValue(qrCIImage, forKey: "inputImage")
            colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
            colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
            // 返回二维码image
            let codeImage = UIImage(ciImage: colorFilter.outputImage!
                .transformed(by: CGAffineTransform(scaleX: 5, y: 5)))
            return codeImage
        }
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func rebackClick(){
        self.navigationController?.popViewController(animated: true)
    }
    func lightSwitchClick(_ sender:UISwitch) {
        Thread.sleep(forTimeInterval: 0.2)

        if sender.isOn {
            let _ = (SDK.sharedSDK() as AnyObject).send("BPbU", dev: app.select.sn)
            app.select.indicator = "b"
        }else {
            let _ = (SDK.sharedSDK() as AnyObject).send("BPzU", dev: app.select.sn)
            app.select.indicator = "z"
        }
        app.onDeviceChange()
    }
    @objc func onDeleteClick(_ sender:UIButton) {
        let device = app.devices[sender.tag - 1]
        let deleteAlert = UIAlertController(title: nil,message: NSLocalizedString("sure", comment: ""), preferredStyle: .alert)
        deleteAlert.addAction(UIAlertAction(title:  NSLocalizedString("yes", comment: ""), style: .default, handler: { action in
            if let index = self.app.devices.index(of: device){
                self.app.devices.remove(at: index)
                self.app.main.cells.removeValue(forKey: device.sn)
                Thread.sleep(forTimeInterval: 0.2)

                (SDK.sharedSDK() as AnyObject).setAlarm(false, sn: device.sn, name: "")
                Thread.sleep(forTimeInterval: 0.2)
                (SDK.sharedSDK() as AnyObject).logout(device.sn)
            
                if self.app.select.sn == device.sn {
                    if !self.app.devices.isEmpty {
                        if index == 0 {
                            self.app.main.scrollTo(self.app.devices.first!.sn)
                        }else {
                            let last = self.app.devices[index-1]
                            self.app.main.scrollTo(last.sn)
                        }
                    }
                }else{
                    self.app.main.scrollTo(self.app.select.sn)
                }
                self.tableView.reloadData()
            }
        }))
        deleteAlert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .cancel, handler: nil))
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + app.devices.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 10
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 96
        }else {
            switch indexPath.row {
            case 0: return 2
            case 1: return 44
            case 2: return ScreenWidth * 0.33 + 24 + 24
            case 8: return 70
            default: return 44
            }
        }
    }
    @objc func onDevupdate(_ notification:Notification) {
         CHECKUPGRADE = (notification.object as? NSInteger)!
        print("CHECKUPGRADE前:\(CHECKUPGRADE)")
    }
    @objc func onGDPR(_ notification:Notification) {
        if let cmd = (notification.object as? String){
            if (cmd == "false") {
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = MBProgressHUDMode.text
                hud.label.text = NSLocalizedString("failed", comment: "")
                hud.backgroundView.style = .solidColor //.Blur 或SolidColor
                hud.hide(animated: true, afterDelay: 2)
                print("getextrecord",getresult)
            }else{
                if (cmd == "0" || cmd == "4" || cmd == "7") {
                   
                    let StorageSelection = AlertController(title:nil, message:  NSLocalizedString("Storage mode selection", comment: ""), preferredStyle: .alert)
                    
                    for l in ["7","4","0"] {
                        var value:String!
                        switch l {
                        case "0":value = NSLocalizedString("No Storage", comment: "")
                        case "4":value = NSLocalizedString("Move Storage", comment: "")
                        case "7":value = NSLocalizedString("Continuous Storage", comment: "")
                        default:value = NSLocalizedString("Continuous Storage", comment: "")
                        }
                        
                        if l == cmd {
                            let act = UIAlertAction(title:value, style: .destructive, handler: {
                                action in
                                let _ = (SDK.sharedSDK() as AnyObject).setextrecord(l, sn: getresult)
                                self.app.onDeviceChange()
                                let snid = l
                                let action = "存储设置"
                                addlog(action:action,snid:snid)
                                
                            })
                            StorageSelection.addAction( act )
                            act.actionImage = UIImage(named: "RadionSelected")
                        } else {
                            let act = UIAlertAction(title:value, style: .default, handler: {
                                action in
                                let _ = (SDK.sharedSDK() as AnyObject).setextrecord(l, sn: getresult)
                                self.app.onDeviceChange()
                                let snid = l
                                let action = "存储设置"
                                addlog(action:action,snid:snid)
                            })
                            StorageSelection.addAction( act )
                        }
                        print("getextrecord",getresult)
                    }
                    
                    StorageSelection.addAction(UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .destructive, handler: { action in
                    }))
                    //self.present(alertPassword, animated: true, completion: nil)
                    if iPad {
                        StorageSelection.popoverPresentationController?.sourceView = self.view// support iPad
                        // StorageSelection.popoverPresentationController?.sourceRect = (tableView.cellForRow(at: indexPath)?.frame)!
                    }
                    self.present(StorageSelection, animated: true, completion: nil)
                }

            }
        }
      }
    override func tableView(_ table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell!
        
        if indexPath.section == 0 {
            let cellIndetify = "addSharingCameraCell"
            
            cell = tableView.dequeueReusableCell(withIdentifier: cellIndetify) as UITableViewCell?
            
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: cellIndetify)
            }
            cell.imageView?.image = UIImage(named: "scan")
            cell?.backgroundColor = UIColor.black
            //NavColor
            cell?.textLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
            cell?.textLabel?.textColor = UIColor.white
            cell.textLabel?.text = NSLocalizedString("add_the_sharing_camera", comment: "")
            cell.accessoryType = .disclosureIndicator
        } else {
            let device = app.devices[indexPath.section - 1]
//            (SDK.sharedSDK() as AnyObject).checkUpgrade(device.sn)
//            print("\(device.sn):CHECKUPGRADE中间:\(CHECKUPGRADE)")
//            
            cell =  tableView.dequeueReusableCell(withIdentifier: "\(device.sn).\(indexPath.row)") as UITableViewCell?
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "\(device.sn).\(indexPath.row)")
            }
            
            for view in cell.contentView.subviews {
                view.removeFromSuperview()
            }
            cell?.selectionStyle = .none
            cell?.accessoryType  = .none
            cell?.backgroundColor = UIColor.black
            //NavColor
            cell?.textLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
            cell?.textLabel?.textColor = Color(166, g: 173, b: 177)
            
            switch indexPath.row {
            case 0:
                cell.backgroundColor  = UIColor.black
            case 1:
                let deviceName = UILabel(frame: CGRect(x: 0,y: 0,width: ScreenWidth,height: 44))
                deviceName.font = UIFont(name: "HelveticaNeue", size: 16)
                deviceName.textColor = UIColor.white
                deviceName.text = device.name
                deviceName.textAlignment = .center
                cell?.contentView.addSubview(deviceName)
                cell?.selectionStyle = .default
                cell?.accessoryType  = .disclosureIndicator
            case 2:
                let imageWidth = ScreenWidth * 0.33
                let image = UIImageView(frame: CGRect(x: (table.bounds.width - imageWidth)/2, y: 8, width: imageWidth,  height: imageWidth))
                image.image = createQRForString(device.sn)
                cell.addSubview(image)
                
                let text = UITextView(frame: CGRect(x: 0,y: image.frame.maxY + 4,width: table.bounds.width,height: 24))
                text.text = device.sn
                text.textAlignment = .center
                text.isSelectable = true
                text.isScrollEnabled = false
                text.isEditable = false
                text.backgroundColor  = UIColor.black//clear
                text.textColor = UIColor.white
                cell.contentView.addSubview(text)
            case 3:
                cell!.textLabel?.text =  NSLocalizedString("Storage mode selection", comment: "")
                cell?.selectionStyle = .default
                cell?.accessoryType  = .disclosureIndicator
            case 4:
                let text = UILabel(frame: CGRect(x: 20, y: 0, width: ScreenWidth - 51 - 15, height: 44))
                text.text =  NSLocalizedString("setting_image_flip", comment: "")
                text.font = UIFont(name: "HelveticaNeue", size: 15)
                text.textColor = Color(166, g: 173, b: 177)
                
                let lightSwitch = UISwitch(frame: CGRect(x: ScreenWidth - 51 - 15, y: 7, width: 51, height: 31))
                lightSwitch.tag = indexPath.section
                lightSwitch.addTarget(self,action: #selector(MoreViewController.onFlipClick(_:)), for: .valueChanged)
                lightSwitch.isOn = UserDefaults.standard.bool(forKey: device.sn + ".flip")
                cell.contentView.addSubview(text)
                cell?.contentView.addSubview(lightSwitch)
            case 5:
                cell!.textLabel?.text =  NSLocalizedString("setting_time_sync", comment: "")
                cell?.selectionStyle = .default
                cell?.accessoryType  = .disclosureIndicator
                break;
            case 6:
                cell!.textLabel?.text =  NSLocalizedString("setting_share_camera", comment: "")
                cell?.selectionStyle = .default
                cell?.accessoryType  = .disclosureIndicator
            case 7:
                let text = UILabel(frame: CGRect(x: 20, y: 0, width: ScreenWidth - 51 - 15, height: 44))
                text.text =  NSLocalizedString("Firmware update", comment: "")
                text.font = UIFont(name: "HelveticaNeue", size: 15)
                text.textColor = Color(166, g: 173, b: 177)
                text.tag = indexPath.section
                cell.contentView.addSubview(text)
                cell?.selectionStyle = .default
                cell?.accessoryType  = .disclosureIndicator
            case 8:
                cell!.textLabel?.text =  NSLocalizedString("Sure_Reset", comment: "")
                cell?.selectionStyle = .default
                cell?.accessoryType  = .disclosureIndicator
            case 9:
                let delete = UIButton(frame: CGRect(x: 16,y: 12,width: ScreenWidth - 32,height: 46))
//                delete.titleLabel?.font = UIFont(name: "Helvetica", size: 16)
                //delete.setBackgroundImage(UIImage(named: "delete_camera_bg"), for: UIControlState())
//                delete.imageView?.contentMode = .ScaleAspectFill
                delete.backgroundColor = .red
                delete.tag = indexPath.section
                delete.setTitleColor(UIColor.white, for: UIControlState())
                delete.setTitle( NSLocalizedString("setting_delete", comment: ""), for: UIControlState())
                delete.addTarget(self, action: #selector(MoreViewController.onDeleteClick(_:)), for: .touchUpInside)
                cell.contentView.addSubview(delete)
            default:break
            }
        }
        return cell
    }
   
    @objc func onFlipClick(_ sender:UISwitch){
        let device = app.devices[sender.tag - 1]
        UserDefaults.standard.set(sender.isOn, forKey: device.sn + ".flip")
        Thread.sleep(forTimeInterval: 0.2)

        (SDK.sharedSDK() as AnyObject).flip(device.sn, flip: sender.isOn)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            self.navigationController?.pushViewController(ManualController(nibName: "ManualController", bundle: nil), animated: true)
        }else{
            let device = app.devices[indexPath.section - 1]
            switch indexPath.row {
            case 1:
                let deviceNameController = DeviceNameControllerViewController(nibName: "DeviceNameControllerViewController",bundle: nil)
                deviceNameController.device = device
                self.navigationController?.pushViewController(deviceNameController, animated: true)
            case 3:
                getresult = device.sn
                (SDK.sharedSDK() as AnyObject).getextrecord(device.sn)
                let hud = MBProgressHUD.showAdded(to:  self.view, animated: true)
                hud.label.text = NSLocalizedString("connect", comment: "")
                hud.mode = .text
                hud.label.textColor = UIColor.init(hex: 0x770B2F)
                hud.hide(animated: true, afterDelay: 2)
            case 5:
                if(CLLocationManager.authorizationStatus() != .denied) {
                    let Alert = UIAlertController(title: nil,message: NSLocalizedString("sure", comment: ""), preferredStyle: .alert)
                    Alert.addAction(UIAlertAction(title:  NSLocalizedString("yes", comment: ""), style: .default, handler: { action in
                        (SDK.sharedSDK() as AnyObject).timeSync(device.sn)
                        sleep(1)
                        (SDK.sharedSDK() as AnyObject).timeSync(device.sn)
                        sleep(1)
                        (SDK.sharedSDK() as AnyObject).timeSync(device.sn)
                        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                        //hud.mode = MBProgressHUDMode.text
                        hud.label.text = NSLocalizedString("success", comment: "")
                        hud.mode = MBProgressHUDMode.customView
                        hud.customView = UIImageView(image: UIImage(named: "37x-Checkmark-1"))
                        hud.backgroundView.style = .solidColor
                        hud.hide(animated: true, afterDelay: 2)
                    }))
                    Alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .cancel, handler: nil))
                    self.present(Alert, animated: true, completion: nil)
                    print("应用拥有定位权限")
                }else {
                    let alertController = UIAlertController(title: NSLocalizedString("Open the location switch", comment: ""),message: NSLocalizedString("location service", comment: ""),preferredStyle: .alert)
                    let settingsAction = UIAlertAction(title: NSLocalizedString("Set up", comment: ""), style: .default) { (alertAction) in
                        if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.openURL(appSettings as URL)
                        }
                    }
                    alertController.addAction(settingsAction)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    present(alertController, animated: true, completion: nil)
                }
            case 6:
                let shareVC = UIActivityViewController(activityItems: [device.sn], applicationActivities: nil)
                shareVC.popoverPresentationController?.sourceView = self.view // support iPad
                shareVC.popoverPresentationController?.sourceRect = (tableView.cellForRow(at: indexPath)?.frame)!

                self.navigationController?.present(shareVC, animated: true, completion:nil)
            case 7:
                (SDK.sharedSDK() as AnyObject).checkUpgrade(device.sn)
                
                NotificationCenter.default.addObserver(self, selector: #selector(MoreViewController.onDevupdate(_:)), name: NSNotification.Name(rawValue: CHECK_UPGRADE), object: nil)//判断是否升级
                if  CHECKUPGRADE>0 {
                    let Alert = UIAlertController(title: NSLocalizedString("Firmware update", comment: ""),message: NSLocalizedString("Firmware update alter", comment: ""), preferredStyle: .alert)
                        Alert.addAction(UIAlertAction(title:  NSLocalizedString("yes", comment: ""), style: .default, handler: { action in
                            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                            hud.mode = .indeterminate

                            hud.label.text = NSLocalizedString("Firmware update alter", comment: "")
//                            (SDK.sharedSDK() as AnyObject).devStartUpgrade(Int32(CHECKUPGRADE),sn:device.sn)
//                            hud.hide(animated: true ,afterDelay: 2)
                            //DispatchQueue.global(qos: .userInitiated).async {
                                (SDK.sharedSDK() as AnyObject).devStartUpgrade(Int32(CHECKUPGRADE),sn:device.sn)
                              //  DispatchQueue.main.async {
                             hud.hide(animated: true ,afterDelay: 2)
                             hud.removeFromSuperview()
                             //   }
                           // }
                    }))
                    Alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .cancel, handler: nil))
                    self.present(Alert, animated: true, completion: nil)
                }else{
                    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    hud.mode = MBProgressHUDMode.text
                    //annularDeterminate
                    hud.label.text = NSLocalizedString("devupdate", comment: "")
                    //设置背景,加遮罩
                    hud.backgroundView.style = .solidColor //.Blur 或SolidColor
                    hud.hide(animated: true, afterDelay: 2)
                }
            case 8:
//               if (SDK.sharedSDK() as AnyObject).searchsn(device.sn)==true {
//                    let deviceNameController = DeviceChangePwd(nibName: "DeviceChangePwd",bundle: nil)
//                    deviceNameController.device = device
//                    self.navigationController?.pushViewController(deviceNameController, animated: true)
//               }else{
//                    let sn=device.sn
//                    let soapMessage1 = "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><getqconfig xmlns='http://www.w3schools.com/xml/'><sn>\(sn)</sn></getqconfig></soap12:Body></soap12:Envelope>"
//                    CHECKUPGRADE=0
//                    self.servisRunconfig(xml:soapMessage1)
//                    if CHECKUPGRADE == 1 {
                        let deviceNameController = DeviceChangePwd(nibName: "DeviceChangePwd",bundle: nil)
                        deviceNameController.device = device
                        self.navigationController?.pushViewController(deviceNameController, animated: true)
//                    }else{
//                        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
//                        hud.mode = MBProgressHUDMode.text
//                                            //annularDeterminate
//                        hud.label.text = NSLocalizedString("devpermission", comment: "")
//                        hud.backgroundView.style = .solidColor //.Blur 或SolidColor
//                        hud.hide(animated: true, afterDelay: 2)
//                    }
//                }

              default:break;
            }
        }
    }
    func servisRunconfig( xml:String!)  {
        let soapMessage = xml
        let msgLength = String(describing: soapMessage?.count)
        
        let url = URL(string: "http://www.umenb.com:3211/lutec/services/MyService")!
        let request = NSMutableURLRequest(url: url)
        //var mutableData:NSMutableData  = NSMutableData.alloc()
        print(url)
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(msgLength, forHTTPHeaderField: "Content-Length")
        //request.addValue("SOAPAction",forHTTPHeaderField:"http://www.umenb.com:3211/lutec/services/MyService")
        request.httpMethod = "POST"
        request.httpBody = soapMessage?.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        let session = URLSession.shared
        
        let task =  session.dataTask(with: request as URLRequest) { (data, resp, error) in
            guard error == nil && data != nil else{ // && data != nil
                print("connection error or data is nill")
                let url2 = URL(string: "http://192.168.0.2/lutec/services/MyService")!
                
                let request = NSMutableURLRequest(url: url2)
                //var mutableData:NSMutableData  = NSMutableData.alloc()
                request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.addValue(msgLength, forHTTPHeaderField: "Content-Length")
                request.addValue("SOAPAction",forHTTPHeaderField:"http://192.168.0.2/lutec/services/MyService")
                request.httpMethod = "POST"
                request.httpBody = soapMessage?.data(using: String.Encoding.utf8, allowLossyConversion: false)
                let task =  session.dataTask(with: request as URLRequest) { (data, resp, error) in
                    guard error == nil && data != nil else{ // && data != nil
                        return
                    }
                    let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    let result = dataString?.substring(with: NSMakeRange(457, 8))
                    if result == "Optional" {
                        CHECKUPGRADE=1
                    }
                }
                task.resume()
                return
            }
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            let result = dataString?.substring(with: NSMakeRange(457, 8))
            
            if result == "Optional" {
                CHECKUPGRADE=1
            }
        }
        task.resume()
    }
    
}



