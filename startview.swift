//  startview.swift
//  FunSDKDemo
//
//  Created by lhb on 2017/12/11.
//  Copyright © 2017年 lutec. All rights reserved.
//
//
//  GuideViewController.swift
//  LutecCamera
//
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//


import UIKit

class startview: UIViewController {
    fileprivate let numOfPages = 5
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.isTranslucent = true;
        self.navigationItem.hidesBackButton = true
        let progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.default)
        progressView.frame = CGRect(x: 0, y: 0, width: 200, height: 10)
        progressView.layer.position = CGPoint(x: self.view.frame.width/2, y: 90)
        progressView.progress = 0.5
        self.view.addSubview(progressView)
//                        self.progressView=UIProgressView(progressViewStyle : UIProgressViewStyle.default)
//                        self.progressView.frame = CGRect(x: 0, y: ScreenHeight-10, width: ScreenWidth, height: 10)
//                //        self.progressView.transform = CGAffineTransform(scaleX: 1.0, y: 3.0)
//                        self.window!.addSubview(self.progressView)
//                        self.progressView.progress=0.1
//                        self.progressView.progressTintColor=UIColor.blue
//                        self.progressView.trackTintColor=UIColor.green
//                        self.progressView.backgroundColor=UIColor.red
//                        self.progressView.setProgress(0.1, animated: true)
//                        self.progressView.progressTintColor = UIColor.black//已有进度颜色
//                        self.progressView.trackTintColor = UIColor.green//剩余进度颜色
//
//
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onStartClick() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isTranslucent = false;
        self.navigationController?.popToRootViewController(animated: false)
        
    }
    // 隐藏状态栏
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
//
//import UIKit
//import MBProgressHUD
//
//class startview: UIViewController  {
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.navigationController?.isNavigationBarHidden = true
//        self.navigationController?.navigationBar.isTranslucent = true;
//        self.navigationItem.hidesBackButton = true
//        
//        //播放启动画面动画
//        //launchAnimation()
//        self.navigationController?.isNavigationBarHidden = false
//        self.navigationController?.navigationBar.isTranslucent = false;
//        self.navigationController?.popToRootViewController(animated: false)
//    }
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        self.automaticallyAdjustsScrollViewInsets = false
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    //播放启动画面动画
//    private func launchAnimation() {
////        //获取启动视图
////        let vc = UIStoryboard(name: "LaunchScreen", bundle: nil)
////            .instantiateViewController(withIdentifier: "launch")
////        let launchview = vc.view!
////        let delegate = UIApplication.shared.delegate
////        delegate?.window!!.addSubview(launchview)
//        // 添加到父视图
//        //初始化对话框，置于当前的View当中
//        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
//        hud.label.text = NSLocalizedString("DownLoad", comment: "")//"Loading"
//        hud.mode = .indeterminate
//        hud.label.textColor = UIColor.red
//        hud.hide(animated: true, afterDelay: 200)
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//
//}


//self.window?.makeKeyAndVisible()
//let vc = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateViewController(withIdentifier: "launch")
//let launchview = vc.view!
//let delegate = UIApplication.shared.delegate
//delegate?.window!!.addSubview(launchview)
//// 添加到父视图
////初始化对话框，置于当前的View当中
//let hud = MBProgressHUD.showAdded(to: launchview, animated: true)
//hud.label.text = NSLocalizedString("DownLoad", comment: "")//"Loading"
//hud.mode = .indeterminate
//hud.label.textColor = UIColor.red
//hud.hide(animated: true, afterDelay: 200)

//        let OrangeView = UIView(frame: CGRect(x: 0, y: 500, width: 200, height: 40))
//        // 添加到父视图
//        self.window?.addSubview(OrangeView)
//        //初始化对话框，置于当前的View当中
//        let hud = MBProgressHUD.showAdded(to: self.OrangeView, animated: true)
//        hud.label.text = NSLocalizedString("DownLoad", comment: "")//"Loading"
//        hud.mode = .indeterminate
//        hud.label.textColor = UIColor.init(hex: 0x770B2F)
//        hud.hide(animated: true, afterDelay: 2)
//如果设置此属性，则当前view置于后台
//        HUD.dimBackground  = true
//        //设置对话框文字
//        HUD.label.text = "正在加载"
//设置模式为进度条
//        HUD.mode = MBProgressHUDMode.determinateHorizontalBar
//        HUD.show(animated: true, whileExecuting: {
//            var progress : Float = 0.0
//            while(progress < 1.0){
//                progress += 0.01
//                HUD.progress = progress
//                usleep(50000)
//            }
//        }, completionBlock: {
//            HUD.removeFromSuperview()
//        })
//                self.progressView=UIProgressView(progressViewStyle : UIProgressViewStyle.default)
//                self.progressView.frame = CGRect(x: 0, y: ScreenHeight-10, width: ScreenWidth, height: 10)
//        //        self.progressView.transform = CGAffineTransform(scaleX: 1.0, y: 3.0)
//                self.window!.addSubview(self.progressView)
//                self.progressView.progress=0.1
//                self.progressView.progressTintColor=UIColor.blue
//                self.progressView.trackTintColor=UIColor.green
//                self.progressView.backgroundColor=UIColor.red
//                self.progressView.setProgress(0.1, animated: true)
//                self.progressView.progressTintColor = UIColor.black//已有进度颜色
//                self.progressView.trackTintColor = UIColor.green//剩余进度颜色
