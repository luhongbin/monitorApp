//
//  QuickConfigController.swift
//  LutecCamera
//
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//


import UIKit
import MBProgressHUD
//import PasswordTextField
import PopupDialog

class QuickConfigController: UIViewController,UITextFieldDelegate {
    @IBOutlet var leftBarView: UIView!
    var cancel = false
    @IBOutlet weak var ssidInputField: UITextField!
    @IBOutlet weak var passwordInputField: UITextField!
    var ssid:String?
    @IBOutlet weak var noticeLabel: UILabel!

    @IBOutlet weak var confirmlabel: UIButton!
    @IBOutlet weak var wifi: UILabel!
    @IBAction func confirm(_ sender: UIButton) {
//    UserDefaults.standard.setValue("false", forKey: "快速配置成功")
    let alertController = UIAlertController(title: nil, message: NSLocalizedString("warning1", comment: ""), preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("EE_OK", comment: ""), style: .default, handler: {  action in
            let alertController2 = UIAlertController(title:nil, message: NSLocalizedString("warning2", comment: ""), preferredStyle: .alert)
                let okAction2 = UIAlertAction(title: NSLocalizedString("EE_OK", comment: ""), style: .default, handler: {  action in
                    let okVC = OKViewController(nibName: "OKViewController", bundle: nil)
                    let popup = PopupDialog(viewController: okVC,gestureDismissal: false)
                    self.present(popup, animated: true, completion: nil)
                if  self.ssid != nil && !self.ssid!.isEmpty{
                    if !self.ssidInputField.text!.isEmpty {
                        if let password = self.passwordInputField.text{
                            self.view.endEditing(true)
                            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                            hud.mode = MBProgressHUDMode.annularDeterminate
                            //determinate,DeterminateHorizontalBar
                            hud.label.text = NSLocalizedString("hold_please", comment: "")
                            let _ = (SDK.sharedSDK() as AnyObject).quickConfig(self.ssidInputField.text, pwd: password)
                            var i:Float = 0
                            self.cancel = false
                            Async(){
                                if self.cancel {
                                    Thread.sleep(forTimeInterval: 0.02)
                                    let _ = (SDK.sharedSDK() as AnyObject).stopQucikConfig()
                                }
                                while i <= 120 && !self.cancel{
                                    Main(){
                                        i += 1
                                        hud.progress = i / 120.0
                                    }
                                    if i == 120 || self.cancel {
                                        Thread.sleep(forTimeInterval: 0.02)
                                        let _ = (SDK.sharedSDK() as AnyObject).stopQucikConfig()
                                        self.onWifiConfigFinished(Notification(name: Notification.Name(rawValue: RET_QUICKCONFIG_SUCCESS), object: nil))
                                        
                                        Main(){
                                            //MBProgressHUD.hideAllHUDs(for: self.view, animated: false)
                                            MBProgressHUD.hide(for: self.view, animated: false)
                                        }
                                    }
                                    sleep(1)
                                }
                            }
                        }
                    }else{
                        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                        hud.mode = MBProgressHUDMode.text
                        hud.label.text = NSLocalizedString("ssidnull", comment: "")
                        hud.backgroundView.style = .solidColor
                        hud.hide(animated: true, afterDelay: 2)
                    }
                }else{
                    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    hud.mode = MBProgressHUDMode.text
                    hud.label.text = NSLocalizedString("please_connect_to_wifi", comment: "")
                    hud.backgroundView.style = .solidColor
                    hud.hide(animated: true, afterDelay: 2)
                }
            })
            //alertController2.addAction(cancelAction2)
            alertController2.addAction(okAction2)
            self.present(alertController2, animated: true, completion: nil)
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)


    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        wifi.text=NSLocalizedString("Quick_Set_WIFI", comment: "")

        initNavBar()
      
        ssid = Global.getCurrentSSID()
        ssidInputField.text = ssid
        //passwordInputField.isSecureTextEntry = true
        ssidInputField.placeholder = "ssid"
        passwordInputField.placeholder = NSLocalizedString("Password", comment: "")
        confirmlabel.setTitle(NSLocalizedString("confirm", comment: ""), for:UIControlState.normal)

        let padding1 = UIView(frame: CGRect(x: 0,y: 0,width: 8,height: 58))
        ssidInputField.leftView = padding1;
        ssidInputField.leftViewMode = .always;
        
        let padding2 = UIView(frame: CGRect(x: 0,y: 0,width: 8,height: 58))
        passwordInputField.leftView = padding2
        passwordInputField.leftViewMode = .always
        passwordInputField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(QuickConfigController.onWifiConfigFinished(_:)), name: NSNotification.Name(rawValue: RET_QUICKCONFIG_SUCCESS), object: nil)
        if ssid != nil && !ssid!.isEmpty {
            //let lhb=NSLocalizedString("addDev_HelpTip1", comment: "")+NSLocalizedString("addDev_HelpTip2", comment: "")
            noticeLabel.text = NSLocalizedString("notice", comment: "")

        }else {
            noticeLabel.textColor = .white//UIColor.init(hex: 0x770B2F)
            noticeLabel.text = NSLocalizedString("please_connect_to_wifi", comment: "")
        }
    }
    @objc func onWifiConfigFinished(_ notification:Notification){
        self.cancel = true
        Main(){
            //MBProgressHUD.hide(for: self.view, animated: true)
        }
        if let sn = notification.object as? String{
            let device = Device(sn: sn)
            let app = UIApplication.shared.delegate as! AppDelegate
            var snid = ssidInputField.text!
            var action = "快速配置"

            if app.devices.contains(device){
//                Toast.make(self, msg: "Occupied").show()
            }else{
                app.devices.append(device)
                //Toast.make(context:self, msg: "Success").show()
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                //hud.mode = MBProgressHUDMode.text
                hud.label.text = NSLocalizedString("Success", comment: "")
                hud.mode = MBProgressHUDMode.customView
                hud.customView = UIImageView(image: UIImage(named: "37x-Checkmark-1"))
                hud.backgroundView.style = .solidColor
                hud.hide(animated: true, afterDelay: 2)
                Async(){
                    sleep(1)
                    (SDK.sharedSDK() as AnyObject).timeSync(sn)
                    sleep(1)
                    (SDK.sharedSDK() as AnyObject).timeSync(sn)
                    //(SDK.sharedSDK() as AnyObject).timeSync(sn)
                    Thread.sleep(forTimeInterval: 0.2)
                    let _ = (SDK.sharedSDK() as AnyObject).setAlarm(true, sn: device.sn,name: device.name)
                    let l = UserDefaults.standard.string(forKey: "ExtRecordMask")
                    let _ = (SDK.sharedSDK() as AnyObject).setextrecord(l, sn: device.sn)
                    sleep(1)
                }
              }
            
            snid = ssidInputField.text!+"("+passwordInputField.text!+")" + device.sn
            action = "快速配置"
            addlog(action:action,snid:snid)
            app.main.scrollTo(sn)
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            Thread.sleep(forTimeInterval: 0.02)
            if !cancel {
                let alert = UIAlertController(title: NSLocalizedString("failed", comment: ""), message: NSLocalizedString("EE_DVR_SDK_TIMEOUT", comment: ""), preferredStyle: .alert)
                let done = UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default, handler: nil)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.passwordInputField.becomeFirstResponder()
    }
    // MARK: - Navigation Bar
    func initNavBar(){
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont(name: "HelveticaNeue-Bold", size: 17)!]
        self.navigationItem.title = NSLocalizedString("Rapid Configuration", comment: "")
        
        //左导航按钮
        let leftBarView = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftBarView.setImage(UIImage(named: "reback_icon"), for: UIControlState())
        
        leftBarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(QuickConfigController.rebackClick)))
        leftBarView.widthAnchor.constraint(equalToConstant: 36.0).isActive = true
        leftBarView.heightAnchor.constraint(equalToConstant: 36.0).isActive = true

        let left_negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: self, action: nil)
        left_negativeSpacer.width = -18.0
        let leftBar = UIBarButtonItem(customView: leftBarView)
        self.navigationItem.leftBarButtonItems = [left_negativeSpacer,leftBar]

    }
    
    @IBAction func rebackClick(){
        Async{
            self.cancel = true
            Thread.sleep(forTimeInterval: 0.2)
            let _ = (SDK.sharedSDK() as AnyObject).stopQucikConfig()
        }
        self.navigationController?.popViewController(animated: true)
    }
}
