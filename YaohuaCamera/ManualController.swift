//
//  ManualController.swift
//  LutecCamera
//
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//


import UIKit
import AVFoundation
import MBProgressHUD
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

//上面两段程序是swift3.0转换时候自动生成的，用于运算符变更的处理
class ManualController: UIViewController,UITextFieldDelegate,AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet var leftBarView: UIView!
    
    @IBOutlet var rightBarView: UIView!
    @IBOutlet var rightBarBtn: UIButton!
    
    @IBOutlet weak var previewLayout: UIView!
    @IBOutlet weak var inputField: UITextField!
    
    @IBOutlet weak var confirmlabel: UIButton!
    @IBOutlet weak var numinit: UILabel!
    
    var session: AVCaptureSession!
    var device: AVCaptureDevice!
    var input: AVCaptureDeviceInput!
    var output: AVCaptureMetadataOutput!
    var preview: AVCaptureVideoPreviewLayer!
    let app = UIApplication.shared.delegate as! AppDelegate

    let reg = "^(([a-zA-Z]|[0-9]){16}|((?:(?:25[0-5]|2[0-4]\\d|((1\\d{2})|([1-9]?\\d)))\\.){3}(?:25[0-5]|2[0-4]\\d|((1\\d{2})|([1-9]?\\d)))))$"
    
    @IBAction func confirm(_ sender: UIButton) {
        
        if inputField.text?.lengthOfBytes(using: String.Encoding.utf8) > 0 {
          
//            if app.devices.contains(device){
////                Toast.make(self, msg: "Occupied").show()
////                 app.main.scrollTo(device.sn)
////                 self.navigationController?.popToRootViewControllerAnimated(true)
//                app.main.scrollTo(device.sn)
//                self.navigationController?.popToRootViewControllerAnimated(true)
//            }else
            if inputField.text!.matching(reg){
                let device:Device
                
                if inputField.text!.matching("^([a-zA-Z]|[0-9]){16}$") {
                    device = Device(sn: inputField.text!)
                }else{
                    device = Device(sn: "\(inputField.text!):34567")
                }
                if !app.devices.contains(device) {
                    app.devices.append(device)
                    app.onDeviceChange()
                }
                app.main.scrollTo(device.sn)
                self.navigationController?.popToRootViewController(animated: true)
            }else {
                //Toast.make(context:self.view, msg: "Serial number error").show()
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = MBProgressHUDMode.text
                hud.label.text = NSLocalizedString("EE_LOGIN_ERROR", comment: "")
                hud.backgroundView.style = .solidColor
                hud.hide(animated: true, afterDelay: 2)
            }
        }else{
            //Toast.make(context:self.view, msg: "Serial number error").show()
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = MBProgressHUDMode.text
            hud.label.text = NSLocalizedString("EE_LOGIN_ERROR", comment: "")
            hud.backgroundView.style = .solidColor
            hud.hide(animated: true, afterDelay: 2)
        }
        
    }
    override func viewDidLoad() {
        
        
        initNavBar()
        super.viewDidLoad()
        let padding = UIView(frame: CGRect(x: 0,y: 0,width: 8,height: 58))
        inputField.leftView = padding
        inputField.leftViewMode = .always
        
        setupCamera()
    }
    // MARK: - Navigation Bar
    func initNavBar(){
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont(name: "HelveticaNeue-Bold", size: 17)!]
        self.navigationItem.title = NSLocalizedString("enter_serial_number", comment: "")
        let leftBarView = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftBarView.setImage(UIImage(named: "reback_icon"), for: UIControlState())
        
        leftBarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ManualController.rebackClick)))
        leftBarView.widthAnchor.constraint(equalToConstant: 36.0).isActive = true
        leftBarView.heightAnchor.constraint(equalToConstant: 36.0).isActive = true
        //左导航按钮
        let left_negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: self, action: nil)
        left_negativeSpacer.width = -18.0
        let leftBar = UIBarButtonItem(customView: leftBarView)
        self.navigationItem.leftBarButtonItems = [left_negativeSpacer,leftBar]
        
//        //右导航按钮
//        let right_negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: self, action: nil)
//        right_negativeSpacer.width = -18.0
//        let rightBar = UIBarButtonItem(customView: self.rightBarView)
//        self.navigationItem.rightBarButtonItems = [right_negativeSpacer,rightBar]

    }
    @IBAction func rebackClick(){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func scanClick(){
//        self.view.endEditing(true)
//        let scanVC = ScanCodeViewController(nibName: "ScanCodeViewController", bundle: nil)
//        scanVC.delegate = self
//        self.navigationController?.presentViewController(scanVC, animated: true, completion: {
//        })
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("回收弹出的键盘.")
        return true
    }
    // MARK: - ScannerControllerDelegate
    func didScanCodeSuccess(_ str: String) {
        let number_str = NSString(string: str)
        if number_str.length != 0 {
            self.inputField.text = str
            self.confirm(UIButton(type: .system))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        confirmlabel.setTitle(NSLocalizedString("confirm", comment: ""), for:UIControlState.normal)
        numinit.text=NSLocalizedString("enter_serial_number", comment: "")
        self.startCamera()
    }
    func setupCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        if authStatus == AVAuthorizationStatus.restricted || authStatus == AVAuthorizationStatus.denied {
             print("未授权相机功能.")
            return;
        }
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            device = AVCaptureDevice.default(for: AVMediaType.video)
            do {
                input = try AVCaptureDeviceInput(device: device)
            } catch _ as NSError {
                print("相机设备有错.")
                input = nil
            }
            output = AVCaptureMetadataOutput()

            //高质量采集率
            session = AVCaptureSession()
            session!.canSetSessionPreset(AVCaptureSession.Preset.high)
            
            if session!.canAddInput(input) {
                session!.addInput(input)
                print("加载输入.")
            }
            
            if session!.canAddOutput(output) {
                session!.addOutput(output)
                print("加载输出.")
            }
            //设置监听监听解析到的数据类型,并设置代理
            output!.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //设置输出能够解析的数据类型availableMetadataObjectTypes
            output!.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            //添加预览图层
            preview = AVCaptureVideoPreviewLayer(session: session!)
            preview!.videoGravity = AVLayerVideoGravity.resizeAspectFill
            preview!.frame = CGRect( x: 0, y: 0, width: ScreenWidth * 304/375, height: ScreenWidth * 304/375)
            
            self.previewLayout.layer.insertSublayer(preview!, at: 0)
        }
        
    }
    
    func startCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .notDetermined {
            // 第一次触发授权 alert
            AVCaptureDevice.requestAccess(for: AVMediaType.video,
                                                      completionHandler: { (granted:Bool) -> Void in
                                                        if (granted == false) {
                                                            print(granted)
                                                        }
                                                        else {
                                                            print(granted)
                                                        }
            })
        }
        
        if authStatus == AVAuthorizationStatus.restricted || authStatus == AVAuthorizationStatus.denied {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = MBProgressHUDMode.text
            hud.label.text = "Allows access to the camera for scanning the shared serial number."
            hud.backgroundView.style = .solidColor
            hud.hide(animated: true, afterDelay: 2)
            print("无开启摄像头权限.")
            return;
        }
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            print("启动扫描二维码.")
            session?.startRunning()
        }
    }
  

    func stopCamera() {
        self.session?.stopRunning()
        print("二维码扫描完成.")
    }
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        print("识别结果输出.")
        if  metadataObjects.count == 0 { //metadataObjects == nil ||
            print("No QR code is detected")
            return
        }
        if metadataObjects.count > 0 {
            stopCamera()
            let qrInfo = (metadataObjects[0] as! AVMetadataMachineReadableCodeObject).stringValue
            // 判断格式 格式如下 {"type":"s_bind","data":{"key":"NNOG0SF","company_name":"\u591a\u5ba2\u6d4b\u8bd5\u5e97"}}
            didScanCodeSuccess(qrInfo!)
            self.stopCamera()
        }
        else {
            print("识别不到内容.")
        }
    }
}
