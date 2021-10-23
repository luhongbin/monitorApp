//
//  NewCameraController.swift
//  LutecCamera
//
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//


import UIKit
import MBProgressHUD
import CoreLocation

class NewCameraController: UIViewController,MBProgressHUDDelegate {
    @IBOutlet weak var supportdot: UIView!
    @IBOutlet weak var rapidConfigLabel: UILabel!
    @IBOutlet weak var addLabel: UILabel!
    
    @IBOutlet var newCameraBtn: UIButton!
    @IBOutlet var verLbl: UILabel!
    
    @IBOutlet var leftBarView: UIView!
    @IBOutlet var leftBarBtn: UIButton!
    
    @IBOutlet weak var supportIconWidth: NSLayoutConstraint!
    @IBOutlet weak var supportIconHeight: NSLayoutConstraint!
    @IBOutlet weak var moreIconHeight: NSLayoutConstraint!
    @IBOutlet weak var moreIconWidth: NSLayoutConstraint!
    @IBOutlet weak var supportIconX: NSLayoutConstraint!
    @IBOutlet weak var moreIconX: NSLayoutConstraint!
   
    @IBOutlet weak var support: UILabel!
    @IBOutlet weak var Welcome: UILabel!
    @IBOutlet weak var More: UILabel!
    @IBOutlet var bottomBar:UIView!
    
    @IBOutlet var serialLbl: UILabel!
    
    var  effectView: UIVisualEffectView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initNavBar()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.verLbl.text = String(format: "v%@", appVersion!)
        self.serialLbl.adjustsFontSizeToFitWidth = true
        self.rapidConfigLabel.adjustsFontSizeToFitWidth = true
        self.addLabel.text = NSLocalizedString("Add camera", comment: "")
        self.serialLbl.text = NSLocalizedString("Manual Input", comment: "")
        self.rapidConfigLabel.text = NSLocalizedString("Rapid Configuration", comment: "")
        self.Welcome.text=NSLocalizedString("welcome", comment: "")
        self.support.text=NSLocalizedString("support", comment: "")
        self.More.text=NSLocalizedString("more", comment: "")

        if iPad {
            supportIconHeight.constant = 48
            supportIconWidth.constant = 48
            moreIconHeight.constant = 48
            moreIconWidth.constant = 48
            supportIconX.constant  = -38
            moreIconX.constant = -38
        }else{
            supportIconHeight.constant = 32
            supportIconWidth.constant = 32
            moreIconHeight.constant = 32
            moreIconWidth.constant = 32
            supportIconX.constant  = -24
            moreIconX.constant = -24
        }
        //升级提示的小红点
//        self.removeBadgeOnItemIndex(index: 1)
//        self.showDotOnItemIndex(index: 1)
        
        let app = UIApplication.shared.delegate as! AppDelegate
        
        if app.devices.isEmpty {
            self.navigationItem.hidesBackButton = true
            self.leftBarBtn.isHidden = true
        }
    }
    
    @IBAction func onSupportClick(_ sender: UIButton) {
        let webVC = WebViewController()
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    @IBAction func onMoreClick(_ sender: UIButton) {
        let moreVC = MoreViewController(nibName: "MoreViewController", bundle: nil)
        self.navigationController?.pushViewController(moreVC, animated: true)
    }

    
    @objc func hideBottomSheet(){
        
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomBar.frame = CGRect(x: 0,y: ScreenHeight, width: ScreenWidth, height: ScreenHeight * 229 / 667)
            self.effectView.alpha = 0
            }, completion: { complete in
                self.effectView?.removeFromSuperview()
                self.bottomBar.removeFromSuperview()
        })
        
    }
    
    func showBottomSheet(){
        effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        effectView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        effectView.alpha = 0
        effectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewCameraController.hideBottomSheet)))
        bottomBar.frame = CGRect(x: 0,y: ScreenHeight, width: ScreenWidth, height: ScreenHeight * 229 / 667)
        
        self.navigationController?.view.addSubview(effectView)
        self.navigationController?.view.addSubview(bottomBar)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomBar.frame = CGRect(x: 0,y: ScreenHeight * 438 / 667, width: ScreenWidth, height: ScreenHeight * 229 / 667)
            self.effectView.alpha = 0.9
        })
    }
    
    // MARK: - 导航栏
    func initNavBar(){
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont(name: "HelveticaNeue-Bold", size: 17)!]
        self.navigationItem.title = NSLocalizedString("home", comment: "")
        
        //左导航按钮
        let left_negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: self, action: nil)
        left_negativeSpacer.width = -18.0
        let leftBar = UIBarButtonItem(customView: self.leftBarView)
        self.navigationItem.leftBarButtonItems = [left_negativeSpacer,leftBar]
    }
    
//    //画一个小红点把他放在tabbaritem的位置（显示小红点）
//    func showDotOnItemIndex(index:Int) {
//        let tabBar = self.supportdot
//        
//        let view = UIView()
//        view.tag = 888
//        view.layer.cornerRadius = 5
//        view.backgroundColor = UIColor.red
//        let tabBarFrome = tabBar?.frame
//        
//        let percentX = (1 + 0.65) / 5;
//        let x = ceilf(Float( percentX) * Float((tabBarFrome?.size.width)!))
//        let y = ceilf(0.01 * Float((tabBarFrome?.size.width)!))
//        view.frame = CGRect(x:CGFloat(x),y:CGFloat(y),width: 10,height: 10)//圆形大小为10
//        support.addSubview(view)
//    }
//    
//    //这个是移除小红点
//    func removeBadgeOnItemIndex(index:Int) {
//        if let view = supportdot.viewWithTag(888) {
//            view.removeFromSuperview()
//        }
//    }
//    
    
    //MARK: 点击事件
    
    @IBAction func back(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func onManualClick(){
        hideBottomSheet()
        self.navigationController?.pushViewController(ManualController(nibName: "ManualController", bundle: nil), animated: true)
    }
    @IBAction func onQuickConfigClick(){
        hideBottomSheet()
        self.navigationController?.pushViewController(QuickConfigController(nibName: "QuickConfigController", bundle: nil), animated: true)
    }

    @IBAction func addNewCamera(){
        if(CLLocationManager.authorizationStatus() != .denied) {
            self.navigationController?.pushViewController(QuickConfigController(nibName: "QuickConfigController", bundle: nil), animated: true)
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
        //        showBottomSheet()
    }
}
